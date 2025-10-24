import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/qr_code_widget.dart';

class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key});

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect to the new my tickets screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/my-tickets');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while redirecting
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final ticket;
  final VoidCallback onTap;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = ticket.isExpired;
    final isActive = ticket.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bus ${ticket.busNumber}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isExpired
                          ? AppTheme.errorColor
                          : isActive
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isExpired
                          ? 'EXPIRED'
                          : isActive
                              ? 'ACTIVE'
                              : ticket.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Route Info
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${ticket.boardingStop} → ${ticket.droppingStop}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Fare and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${ticket.finalFare.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM, hh:mm a').format(ticket.bookingTime),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketDetailsModal extends StatelessWidget {
  final ticket;

  const TicketDetailsModal({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = ticket.isExpired;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ticket Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isExpired ? Colors.red[50] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isExpired ? AppTheme.errorColor : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      children: [
                        QRCodeWidget(
                          data: ticket.qrCode,
                          size: 200,
                          isExpired: isExpired,
                        ),
                        if (isExpired) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'EXPIRED',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ticket Information
                  _buildInfoCard([
                    _buildInfoRow('Ticket ID', ticket.id),
                    _buildInfoRow('Bus Number', ticket.busNumber),
                    _buildInfoRow('Route', ticket.routeName),
                    _buildInfoRow('Boarding Stop', ticket.boardingStop),
                    _buildInfoRow('Drop Stop', ticket.droppingStop),
                  ]),

                  const SizedBox(height: 16),

                  // Fare Information
                  _buildInfoCard([
                    _buildInfoRow('Original Fare',
                        '₹${ticket.originalFare.toStringAsFixed(2)}'),
                    if (ticket.subsidyAmount > 0)
                      _buildInfoRow('Subsidy',
                          '-₹${ticket.subsidyAmount.toStringAsFixed(2)}',
                          valueColor: AppTheme.successColor),
                    _buildInfoRow(
                        'Final Fare', '₹${ticket.finalFare.toStringAsFixed(2)}',
                        valueColor: AppTheme.primaryColor, isTotal: true),
                    _buildInfoRow(
                        'Payment Method', ticket.paymentMethod.toUpperCase()),
                  ]),

                  const SizedBox(height: 16),

                  // Time Information
                  _buildInfoCard([
                    _buildInfoRow(
                        'Booking Time',
                        DateFormat('dd MMM yyyy, hh:mm a')
                            .format(ticket.bookingTime)),
                    _buildInfoRow(
                        'Expiry Time',
                        DateFormat('dd MMM yyyy, hh:mm a')
                            .format(ticket.expiryTime)),
                    if (ticket.verificationTime != null)
                      _buildInfoRow(
                          'Verified At',
                          DateFormat('dd MMM yyyy, hh:mm a')
                              .format(ticket.verificationTime!)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? AppTheme.textPrimary,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
