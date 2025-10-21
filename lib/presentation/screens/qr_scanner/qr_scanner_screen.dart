import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/bus_provider.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      setState(() {
        _isProcessing = true;
      });

      final String? qrCode = barcodes.first.rawValue;
      if (qrCode != null) {
        await _handleQRCode(qrCode);
      }
    }
  }

  Future<void> _handleQRCode(String qrCode) async {
    try {
      print('QR Code scanned: $qrCode'); // Debug log

      // Handle Bus QR Code
      if (qrCode.startsWith('BUS_')) {
        print('Processing Bus QR Code'); // Debug log
        final busId = qrCode.substring(4); // Remove 'BUS_' prefix

        if (busId.isEmpty) {
          _showError('Invalid bus QR code');
          return;
        }

        final bus = await ref.read(busProvider.notifier).getBusByQrCode(qrCode);
        if (bus != null && mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/booking',
            arguments: {'bus': bus, 'scanType': 'bus'},
          );
        } else {
          _showError('Bus not found or inactive');
        }
        return;
      }

      // Handle Conductor QR Code
      if (qrCode.startsWith('CONDUCTOR_')) {
        print('Processing Conductor QR Code'); // Debug log
        final dataWithoutPrefix =
            qrCode.substring(10); // Remove 'CONDUCTOR_' prefix
        final parts = dataWithoutPrefix.split('|');

        if (parts.length != 8) {
          _showError('Invalid conductor QR code format');
          return;
        }

        // Parse the timestamp first
        final conductorTimestamp = int.tryParse(parts[7]) ?? 0;

        // Parse conductor data
        final conductorData = {
          'type': 'conductor',
          'conductor_id': parts[0],
          'bus_id': parts[1],
          'bus_number': parts[2],
          'route_id': parts[3],
          'route_name': parts[4],
          'conductor_name': parts[5],
          'fare': double.tryParse(parts[6]) ?? 0.0,
          'timestamp': conductorTimestamp,
        };

        // Check if conductor QR is too old (24 hours)
        final timestamp =
            DateTime.fromMillisecondsSinceEpoch(conductorTimestamp);
        const maxAge = Duration(hours: 24);
        if (DateTime.now().difference(timestamp) > maxAge) {
          _showError('Conductor QR code expired');
          return;
        }

        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/booking',
            arguments: {
              'conductorData': conductorData,
              'scanType': 'conductor',
            },
          );
        }
        return;
      }

      // Handle Ticket QR Code (pipe-separated format)
      final parts = qrCode.split('|');
      if (parts.length == 6) {
        print('Processing Ticket QR Code'); // Debug log
        try {
          // Parse the timestamp values first
          final expiryTimestamp = int.parse(parts[4]);
          final generationTimestamp = int.parse(parts[5]);

          final ticketData = {
            'type': 'ticket',
            'ticket_id': parts[0],
            'user_id': parts[1],
            'bus_id': parts[2],
            'route_id': parts[3],
            'expiry': expiryTimestamp,
            'timestamp': generationTimestamp,
          };

          // Check if ticket is expired
          final expiryTime =
              DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
          if (DateTime.now().isAfter(expiryTime)) {
            _showError('Ticket expired');
            return;
          }

          // Check if ticket QR is too old (24 hours)
          final timestamp =
              DateTime.fromMillisecondsSinceEpoch(generationTimestamp);
          const maxAge = Duration(hours: 24);
          if (DateTime.now().difference(timestamp) > maxAge) {
            _showError('Ticket QR code too old');
            return;
          }

          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/ticket-verification',
              arguments: {'ticketData': ticketData},
            );
          }
          return;
        } catch (e) {
          print('Error parsing ticket QR: $e'); // Debug log
          _showError('Invalid ticket QR code');
          return;
        }
      }

      // If none of the above formats match
      _showError('Invalid QR code format');
    } catch (e) {
      print('Error processing QR code: $e'); // Debug log
      _showError('Error processing QR code: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            color: Colors.white,
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? Colors.yellow : Colors.grey,
            ),
            onPressed: () async {
              await cameraController.toggleTorch();
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(
              _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
            ),
            onPressed: () async {
              await cameraController.switchCamera();
              setState(() {
                _isFrontCamera = !_isFrontCamera;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // Overlay
          Container(
            decoration: const ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: AppTheme.primaryColor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Scan Bus QR Code or Conductor QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Position the QR code within the frame',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Processing Indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Processing QR Code...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    double? cutOutSize,
  }) : cutOutSize = cutOutSize ?? 250;

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(
            rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final mCutOutWidth = cutOutSize;
    final mCutOutHeight = cutOutSize;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - mCutOutWidth / 2 + borderOffset,
      rect.top + height / 2 - mCutOutHeight / 2 + borderOffset,
      mCutOutWidth - borderOffset * 2,
      mCutOutHeight - borderOffset * 2,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
          RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
          boxPaint)
      ..restore();

    // Draw corner borders
    final path = Path()
      // Top left
      ..moveTo(cutOutRect.left - borderOffset, cutOutRect.top + borderLength)
      ..lineTo(cutOutRect.left - borderOffset, cutOutRect.top + borderRadius)
      ..quadraticBezierTo(
          cutOutRect.left - borderOffset,
          cutOutRect.top - borderOffset,
          cutOutRect.left + borderRadius,
          cutOutRect.top - borderOffset)
      ..lineTo(cutOutRect.left + borderLength, cutOutRect.top - borderOffset)
      // Top right
      ..moveTo(cutOutRect.right - borderLength, cutOutRect.top - borderOffset)
      ..lineTo(cutOutRect.right - borderRadius, cutOutRect.top - borderOffset)
      ..quadraticBezierTo(
          cutOutRect.right + borderOffset,
          cutOutRect.top - borderOffset,
          cutOutRect.right + borderOffset,
          cutOutRect.top + borderRadius)
      ..lineTo(cutOutRect.right + borderOffset, cutOutRect.top + borderLength)
      // Bottom right
      ..moveTo(
          cutOutRect.right + borderOffset, cutOutRect.bottom - borderLength)
      ..lineTo(
          cutOutRect.right + borderOffset, cutOutRect.bottom - borderRadius)
      ..quadraticBezierTo(
          cutOutRect.right + borderOffset,
          cutOutRect.bottom + borderOffset,
          cutOutRect.right - borderRadius,
          cutOutRect.bottom + borderOffset)
      ..lineTo(
          cutOutRect.right - borderLength, cutOutRect.bottom + borderOffset)
      // Bottom left
      ..moveTo(cutOutRect.left + borderLength, cutOutRect.bottom + borderOffset)
      ..lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom + borderOffset)
      ..quadraticBezierTo(
          cutOutRect.left - borderOffset,
          cutOutRect.bottom + borderOffset,
          cutOutRect.left - borderOffset,
          cutOutRect.bottom - borderRadius)
      ..lineTo(
          cutOutRect.left - borderOffset, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
