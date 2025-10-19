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

      AppLogger.info(
          'QR code generated successfully for data length: ${data.length}');
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
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), paint);

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

  /// Generate ticket QR data (for conductor verification)
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

  /// Generate bus QR data (for user to identify bus and start booking)
  static String generateBusQRData({
    required String busId,
    required String busNumber,
    required String routeId,
    required String routeName,
    String? driverName,
    String? conductorName,
    int? totalSeats,
    int? availableSeats,
  }) {
    return 'BUS_$busId';
  }

  /// Generate conductor QR data (for pre-filled ticket booking)
  static String generateConductorQRData({
    required String conductorId,
    required String busId,
    required String busNumber,
    required String routeId,
    required String routeName,
    String? conductorName,
    double? fare,
  }) {
    final qrData = {
      'conductor_id': conductorId,
      'bus_id': busId,
      'bus_number': busNumber,
      'route_id': routeId,
      'route_name': routeName,
      'conductor_name': conductorName ?? '',
      'fare': fare ?? 0.0,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // Convert to compact string format for conductor QR
    return 'CONDUCTOR_${qrData['conductor_id']}|${qrData['bus_id']}|${qrData['bus_number']}|${qrData['route_id']}|${qrData['route_name']}|${qrData['conductor_name']}|${qrData['fare']}|${qrData['timestamp']}';
  }

  /// Parse ticket QR data (for conductor verification)
  static Map<String, dynamic>? parseTicketQRData(String qrData) {
    try {
      final parts = qrData.split('|');
      if (parts.length != 6) {
        AppLogger.warning(
            'Invalid ticket QR data format: expected 6 parts, got ${parts.length}');
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
      AppLogger.error('Failed to parse ticket QR data: $e');
      return null;
    }
  }

  /// Parse bus QR data (for user booking)
  static Map<String, dynamic>? parseBusQRData(String qrData) {
    try {
      if (!qrData.startsWith('BUS_')) {
        AppLogger.warning('Invalid bus QR format: must start with BUS_');
        return null;
      }

      final busId = qrData.substring(4); // Remove 'BUS_' prefix
      AppLogger.info('Parsed bus QR - Bus ID: $busId');
      
      return {
        'type': 'bus',
        'bus_id': busId,
      };
    } catch (e) {
      AppLogger.error('Failed to parse bus QR data: $e');
      return null;
    }
  }

  /// Parse conductor QR data (for pre-filled booking)
  static Map<String, dynamic>? parseConductorQRData(String qrData) {
    try {
      if (!qrData.startsWith('CONDUCTOR_')) {
        AppLogger.warning(
            'Invalid conductor QR format: must start with CONDUCTOR_');
        return null;
      }

      final dataWithoutPrefix =
          qrData.substring(10); // Remove 'CONDUCTOR_' prefix
      final parts = dataWithoutPrefix.split('|');

      if (parts.length != 8) {
        AppLogger.warning(
            'Invalid conductor QR data format: expected 8 parts, got ${parts.length}');
        return null;
      }

      return {
        'type': 'conductor',
        'conductor_id': parts[0],
        'bus_id': parts[1],
        'bus_number': parts[2],
        'route_id': parts[3],
        'route_name': parts[4],
        'conductor_name': parts[5],
        'fare': double.tryParse(parts[6]) ?? 0.0,
        'timestamp': int.parse(parts[7]),
      };
    } catch (e) {
      AppLogger.error('Failed to parse conductor QR data: $e');
      return null;
    }
  }

  /// Parse any QR data and determine its type
  static Map<String, dynamic>? parseQRData(String qrData) {
    try {
      AppLogger.info('Parsing QR data: $qrData');
      
      if (qrData.startsWith('BUS_')) {
        AppLogger.info('Detected bus QR code');
        return parseBusQRData(qrData);
      } else if (qrData.startsWith('CONDUCTOR_')) {
        AppLogger.info('Detected conductor QR code');
        return parseConductorQRData(qrData);
      } else {
        AppLogger.info('Attempting to parse as ticket QR code');
        // Try parsing as ticket QR (pipe-separated format)
        final ticketData = parseTicketQRData(qrData);
        if (ticketData != null) {
          // Add type for consistency
          ticketData['type'] = 'ticket';
          AppLogger.info('Successfully parsed as ticket QR');
        }
        return ticketData;
      }
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
      final timestamp =
          DateTime.fromMillisecondsSinceEpoch(qrData['timestamp']);
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

  /// Validate conductor QR data
  static bool validateConductorQR(Map<String, dynamic> qrData) {
    try {
      // Check if QR is too old (prevent replay attacks)
      final timestamp =
          DateTime.fromMillisecondsSinceEpoch(qrData['timestamp']);
      const maxAge = Duration(hours: 24);
      if (DateTime.now().difference(timestamp) > maxAge) {
        AppLogger.warning('Conductor QR code too old: $timestamp');
        return false;
      }

      // Check required fields
      if (qrData['conductor_id']?.toString().isEmpty ?? true) {
        AppLogger.warning('Missing conductor ID');
        return false;
      }

      if (qrData['bus_id']?.toString().isEmpty ?? true) {
        AppLogger.warning('Missing bus ID');
        return false;
      }

      return true;
    } catch (e) {
      AppLogger.error('Failed to validate conductor QR data: $e');
      return false;
    }
  }

  /// Validate QR code string based on its type
  static bool validateQRCode(String qrCode) {
    try {
      // Check if QR code is not empty
      if (qrCode.trim().isEmpty) {
        AppLogger.warning('QR code is empty');
        return false;
      }

      // Parse and validate based on type
      final qrData = parseQRData(qrCode);
      if (qrData == null) {
        AppLogger.warning('Failed to parse QR code data');
        return false;
      }

      AppLogger.info('Validating QR type: ${qrData['type']}');

      // Validate based on QR type
      switch (qrData['type']) {
        case 'bus':
          final isValid = qrData['bus_id']?.toString().isNotEmpty ?? false;
          AppLogger.info('Bus QR validation result: $isValid');
          return isValid;
        case 'conductor':
          final isValid = validateConductorQR(qrData);
          AppLogger.info('Conductor QR validation result: $isValid');
          return isValid;
        case 'ticket':
          final isValid = validateTicketQR(qrData);
          AppLogger.info('Ticket QR validation result: $isValid');
          return isValid;
        default:
          AppLogger.warning('Unknown QR type: ${qrData['type']}');
          return false;
      }
    } catch (e) {
      AppLogger.error('Failed to validate QR code: $e');
      return false;
    }
  }
}
