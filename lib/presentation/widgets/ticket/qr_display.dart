import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/qr_service.dart';
import '../../../data/models/ticket_model.dart';

class QRDisplayWidget extends StatefulWidget {
  final TicketModel ticket;

  const QRDisplayWidget({
    super.key,
    required this.ticket,
  });

  @override
  State<QRDisplayWidget> createState() => _QRDisplayWidgetState();
}

class _QRDisplayWidgetState extends State<QRDisplayWidget> {
  Uint8List? _qrImageBytes;
  bool _isGenerating = true;

  @override
  void initState() {
    super.initState();
    _generateQRCode();
  }

  Future<void> _generateQRCode() async {
    try {
      // Use encrypted_token from API if available, otherwise generate QR data
      String qrData;
      if (widget.ticket.encryptedToken?.isNotEmpty ?? false) {
        qrData = widget.ticket.encryptedToken!;
      } else if (widget.ticket.qrCode.isNotEmpty) {
        qrData = widget.ticket.qrCode;
      } else {
        // Fallback: Generate QR data from ticket information
        qrData = QRService.generateTicketQRData(
          ticketId: widget.ticket.id,
          userId: widget.ticket.userId,
          busId: widget.ticket.busId,
          expiryTime: widget.ticket.expiryTime,
          routeId: widget.ticket.routeId,
        );
      }

      final qrBytes = await QRService.generateQRCode(qrData, size: 200);

      if (mounted) {
        setState(() {
          _qrImageBytes = qrBytes;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.ticket.isExpired ? AppColors.error : AppColors.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (widget.ticket.isExpired ? AppColors.error : AppColors.primary)
                    .withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // QR Code header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code,
                color: widget.ticket.isExpired
                    ? AppColors.error
                    : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Show this QR to Conductor',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.ticket.isExpired
                      ? AppColors.error
                      : AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // QR Code display
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isGenerating)
                  const CircularProgressIndicator()
                else if (_qrImageBytes != null && !widget.ticket.isExpired)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _qrImageBytes!,
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.ticket.isExpired
                            ? Icons.error
                            : Icons.error_outline,
                        size: 48,
                        color: widget.ticket.isExpired
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.ticket.isExpired
                            ? 'QR CODE EXPIRED'
                            : 'QR CODE ERROR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.ticket.isExpired
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                // Expired overlay
                if (widget.ticket.isExpired)
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.block,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'EXPIRED',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Ticket status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.ticket.isExpired
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.ticket.isExpired
                    ? AppColors.error.withValues(alpha: 0.3)
                    : AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              widget.ticket.isExpired ? 'EXPIRED' : 'VALID TICKET',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.ticket.isExpired
                    ? AppColors.error
                    : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
