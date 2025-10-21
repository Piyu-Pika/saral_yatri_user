import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr/qr.dart';
import '../../data/models/enhanced_ticket_model.dart';

class QrUtils {
  /// Generate QR code data from ticket information
  static String generateQrData(QrData qrData) {
    // Convert QR data to JSON string for the QR code
    return jsonEncode(qrData.toJson());
  }

  /// Generate QR code from QR data object
  static QrCode generateQrCode(QrData qrData) {
    final qrDataString = generateQrData(qrData);
    
    final qr = QrCode.fromData(
      data: qrDataString,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );
    
    return qr;
  }

  /// Generate QR code widget
  static Widget generateQrWidget(
    QrData qrData, {
    double size = 200.0,
    Color foregroundColor = Colors.black,
    Color backgroundColor = Colors.white,
  }) {
    final qrDataString = generateQrData(qrData);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.9, size * 0.9),
          painter: SimpleQrPainter(
            data: qrDataString,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }

  /// Validate QR data structure
  static bool isValidQrData(String qrDataString) {
    try {
      final data = jsonDecode(qrDataString);
      
      // Check if required fields are present
      final requiredFields = [
        'ticket_id',
        'ticket_number',
        'passenger_id',
        'bus_id',
        'route_id',
        'boarding_station_id',
        'destination_station_id',
        'travel_date',
        'valid_until',
        'fare_amount',
        'government_signature',
        'validation_code',
        'issuing_authority',
        'timestamp',
      ];
      
      for (final field in requiredFields) {
        if (!data.containsKey(field) || data[field] == null) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Extract QR data from scanned string
  static QrData? parseQrData(String qrDataString) {
    try {
      if (!isValidQrData(qrDataString)) {
        return null;
      }
      
      final data = jsonDecode(qrDataString);
      return QrData.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Generate a compact QR data string (for smaller QR codes)
  static String generateCompactQrData(QrData qrData) {
    // Create a more compact representation for smaller QR codes
    final compactData = {
      'tid': qrData.ticketId,
      'tno': qrData.ticketNumber,
      'pid': qrData.passengerId,
      'bid': qrData.busId,
      'rid': qrData.routeId,
      'bsi': qrData.boardingStationId,
      'dsi': qrData.destinationStationId,
      'td': qrData.travelDate,
      'vu': qrData.validUntil,
      'fa': qrData.fareAmount,
      'sa': qrData.subsidyAmount,
      'gs': qrData.governmentSignature,
      'vc': qrData.validationCode,
      'ia': qrData.issuingAuthority,
      'dc': qrData.departmentCode,
      'cc': qrData.cityCode,
      'ts': qrData.timestamp,
    };
    
    return jsonEncode(compactData);
  }
}

class SimpleQrPainter extends CustomPainter {
  final String data;
  final Color color;

  SimpleQrPainter({
    required this.data,
    this.color = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      final qrCode = QrCode.fromData(
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );

      final qrImage = QrImage(qrCode);
      final pixelSize = size.width / qrImage.moduleCount;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      for (int x = 0; x < qrImage.moduleCount; x++) {
        for (int y = 0; y < qrImage.moduleCount; y++) {
          if (qrImage.isDark(y, x)) {
            final rect = Rect.fromLTWH(
              x * pixelSize,
              y * pixelSize,
              pixelSize,
              pixelSize,
            );
            canvas.drawRect(rect, paint);
          }
        }
      }
    } catch (e) {
      // Fallback: draw a simple placeholder
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = 2;
      
      canvas.drawRect(Offset.zero & size, paint);
      
      // Draw text indicating QR code
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'QR CODE',
          style: TextStyle(
            color: color,
            fontSize: size.width * 0.1,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}