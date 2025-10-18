import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/ticket_model.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/ticket/ticket_card.dart';
import '../../widgets/ticket/qr_display.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final TicketModel ticket;

  const TicketDetailScreen({
    super.key,
    required this.ticket,
  });

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.ticket.isActive) {
      _enableScreenProtection();
    }
  }

  @override
  void dispose() {
    if (widget.ticket.isActive) {
      _disableScreenProtection();
    }
    super.dispose();
  }

  Future<void> _enableScreenProtection() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (e) {
      // Handle silently
    }
  }

  Future<void> _disableScreenProtection() async {
    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (e) {
      // Handle silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ticket Details',
        actions: [
          if (widget.ticket.isActive)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share feature will be available soon'),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: widget.ticket.isActive 
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.ticket.isActive ? Icons.check_circle : Icons.error,
                    color: widget.ticket.isActive ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.ticket.isActive ? 'ACTIVE TICKET' : 'EXPIRED TICKET',
                    style: TextStyle(
                      color: widget.ticket.isActive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Ticket card
                  TicketCardWidget(ticket: widget.ticket),

                  const SizedBox(height: 16),

                  // QR code (only for active tickets)
                  if (widget.ticket.isActive) ...[
                    QRDisplayWidget(ticket: widget.ticket),
                    const SizedBox(height: 16),
                  ],

                  // Journey details
                  _buildJourneyDetails(),

                  const SizedBox(height: 16),

                  // Fare breakdown
                  _buildFareBreakdown(),

                  const SizedBox(height: 16),

                  // Booking information
                  _buildBookingInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Journey Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Bus Number', widget.ticket.busNumber),
            _buildDetailRow('Route', widget.ticket.routeName),
            _buildDetailRow('From', widget.ticket.boardingStop),
            _buildDetailRow('To', widget.ticket.droppingStop),
            _buildDetailRow('Travel Date', 
              '${widget.ticket.bookingTime.day}/${widget.ticket.bookingTime.month}/${widget.ticket.bookingTime.year}'),
            _buildDetailRow('Valid Until', 
              '${widget.ticket.expiryTime.day}/${widget.ticket.expiryTime.month}/${widget.ticket.expiryTime.year} '
              '${widget.ticket.expiryTime.hour}:${widget.ticket.expiryTime.minute.toString().padLeft(2, '0')}'),
          ],
        ),
      ),
    );
  }

  Widget _buildFareBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fare Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Original Fare', '₹${widget.ticket.originalFare.toStringAsFixed(2)}'),
            _buildDetailRow('Subsidy Amount', '-₹${widget.ticket.subsidyAmount.toStringAsFixed(2)}'),
            const Divider(),
            _buildDetailRow('Final Amount', '₹${widget.ticket.finalFare.toStringAsFixed(2)}', 
              isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Ticket ID', widget.ticket.id),
            _buildDetailRow('Booking Time', 
              '${widget.ticket.bookingTime.day}/${widget.ticket.bookingTime.month}/${widget.ticket.bookingTime.year} '
              '${widget.ticket.bookingTime.hour}:${widget.ticket.bookingTime.minute.toString().padLeft(2, '0')}'),
            _buildDetailRow('Payment Method', widget.ticket.paymentMethod.toUpperCase()),
            _buildDetailRow('Status', widget.ticket.status.toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
