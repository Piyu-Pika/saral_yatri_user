import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr/qr.dart';
import '../utils/logger.dart';

class QRService {
  static const int _defaultSize = 200;
  static const int _quietZone = 4;

  /// Generate QR code as image bytes
  static Future<Uint8List> generateQRCode(
    String data, {
    int size = _defaultSize,
    Color foregroundColor = Colors.black,
    Color backgroundColor = Colors.white,
  }) async {
    try {
      // Create QR code
      final qrCode = QrCode.fromData(
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );

      // Create QR image
      final qrImage = QrImage(qrCode);
      
      // Convert to image bytes
      final imageBytes = await _qrImageToBytes(
        qrImage,
        size: size,
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
      );

      AppLogger.info('QR code generated successfully for data length: ${data.length}');
      return imageBytes;
    } catch (e) {
      AppLogger.error('Failed to generate QR code: $e');
      rethrow;
    }
  }

  /// Convert QR image to bytes
  static Future<Uint8List> _qrImageToBytes(
    QrImage qrImage, {
    required int size,
    required Color foregroundColor,
    required Color backgroundColor,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = false;

    // Fill background
    paint.color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), paint);

    // Calculate module size
    final moduleCount = qrImage.moduleCount;
    final moduleSize = (size - 2 * _quietZone) / moduleCount;

    // Draw QR modules
    paint.color = foregroundColor;
    for (int x = 0; x < moduleCount; x++) {
      for (int y = 0; y < moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          final rect = Rect.fromLTWH(
            _quietZone + x * moduleSize,
            _quietZone + y * moduleSize,
            moduleSize,
            moduleSize,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }

    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  /// Generate ticket QR data
  static String generateTicketQRData({
    required String ticketId,
    required String userId,
    required String busId,
    required DateTime expiryTime,
    required String routeId,
  }) {
    final qrData = {
      'ticket_id': ticketId,
      'user_id': userId,
      'bus_id': busId,
      'route_id': routeId,
      'expiry': expiryTime.millisecondsSinceEpoch,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // Convert to compact string format
    return '${qrData['ticket_id']}|${qrData['user_id']}|${qrData['bus_id']}|${qrData['route_id']}|${qrData['expiry']}|${qrData['timestamp']}';
  }

  /// Parse ticket QR data
  static Map<String, dynamic>? parseTicketQRData(String qrData) {
    try {
      final parts = qrData.split('|');
      if (parts.length != 6) {
        AppLogger.warning('Invalid QR data format: expected 6 parts, got ${parts.length}');
        return null;
      }

      return {
        'ticket_id': parts[0],
        'user_id': parts[1],
        'bus_id': parts[2],
        'route_id': parts[3],
        'expiry': int.parse(parts[4]),
        'timestamp': int.parse(parts[5]),
      };
    } catch (e) {
      AppLogger.error('Failed to parse QR data: $e');
      return null;
    }
  }

  /// Validate ticket QR data
  static bool validateTicketQR(Map<String, dynamic> qrData) {
    try {
      // Check if ticket is expired
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(qrData['expiry']);
      if (DateTime.now().isAfter(expiryTime)) {
        AppLogger.warning('Ticket expired at: $expiryTime');
        return false;
      }

      // Check if QR is too old (prevent replay attacks)
      final timestamp = DateTime.fromMillisecondsSinceEpoch(qrData['timestamp']);
      const maxAge = Duration(hours: 24);
      if (DateTime.now().difference(timestamp) > maxAge) {
        AppLogger.warning('QR code too old: $timestamp');
        return false;
      }

      return true;
    } catch (e) {
      AppLogger.error('Failed to validate QR data: $e');
      return false;
    }
  }

  /// Validate QR code string
  static bool validateQRCode(String qrCode) {
    try {
      // Check if QR code is not empty
      if (qrCode.trim().isEmpty) {
        AppLogger.warning('QR code is empty');
        return false;
      }

      // Try to parse the QR data
      final qrData = parseTicketQRData(qrCode);
      if (qrData == null) {
        AppLogger.warning('Failed to parse QR code data');
        return false;
      }

      // Validate the parsed data
      return validateTicketQR(qrData);
    } catch (e) {
      AppLogger.error('Failed to validate QR code: $e');
      return false;
    }
  }
}