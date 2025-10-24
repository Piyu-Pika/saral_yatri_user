import 'package:flutter/material.dart';
import 'package:qr/qr.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class QRCodeWidget extends StatelessWidget {
  final String data;
  final double size;
  final bool isExpired;

  const QRCodeWidget({
    super.key,
    required this.data,
    this.size = 200,
    this.isExpired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // QR Code
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isExpired ? AppTheme.errorColor : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: CustomPaint(
            size: Size(size - 16, size - 16),
            painter: QRPainter(
              data: data,
              isExpired: isExpired,
            ),
          ),
        ),

        // Expired Overlay
        if (isExpired)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                AppConstants.expiredText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class QRPainter extends CustomPainter {
  final String data;
  final bool isExpired;

  QRPainter({
    required this.data,
    required this.isExpired,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );

    final qrImage = QrImage(qrCode);
    final pixelSize = size.width / qrImage.moduleCount;

    final paint = Paint()
      ..color = isExpired ? Colors.grey : Colors.black
      ..style = PaintingStyle.fill;

    for (int x = 0; x < qrImage.moduleCount; x++) {
      for (int y = 0; y < qrImage.moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          final rect = Rect.fromLTWH(
            x * pixelSize + 8,
            y * pixelSize + 8,
            pixelSize,
            pixelSize,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }

    // Add corrupted effect for expired QR codes
    if (isExpired) {
      final corruptPaint = Paint()
        ..color = AppTheme.errorColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Draw diagonal lines to corrupt the QR code
      canvas.drawLine(
        const Offset(8, 8),
        Offset(size.width - 8, size.height - 8),
        corruptPaint,
      );
      canvas.drawLine(
        Offset(size.width - 8, 8),
        Offset(8, size.height - 8),
        corruptPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is QRPainter &&
        (oldDelegate.data != data || oldDelegate.isExpired != isExpired);
  }
}
