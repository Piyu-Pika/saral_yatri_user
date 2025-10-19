import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/station_model.dart';
import 'fare_display.dart';

class BookingSummary extends StatelessWidget {
  final StationModel? fromStation;
  final StationModel? toStation;
  final String? busNumber;
  final String? routeName;
  final double? originalFare;
  final double? subsidyAmount;
  final double? finalFare;
  final String? paymentMethod;
  final DateTime? travelDate;
  final bool showEditButton;
  final VoidCallback? onEdit;

  const BookingSummary({
    super.key,
    this.fromStation,
    this.toStation,
    this.busNumber,
    this.routeName,
    this.originalFare,
    this.subsidyAmount,
    this.finalFare,
    this.paymentMethod,
    this.travelDate,
    this.showEditButton = true,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.summarize,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Booking Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (showEditButton && onEdit != null)
                  TextButton(
                    onPressed: onEdit,
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Journey details
            if (fromStation != null && toStation != null) ...[
              _JourneyRoute(
                fromStation: fromStation!,
                toStation: toStation!,
              ),
              const SizedBox(height: 16),
            ],

            // Bus details
            if (busNumber != null || routeName != null) ...[
              _DetailRow(
                icon: Icons.directions_bus,
                label: 'Bus',
                value: busNumber ?? 'Not selected',
                subtitle: routeName,
              ),
              const SizedBox(height: 12),
            ],

            // Travel date
            if (travelDate != null) ...[
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Travel Date',
                value: _formatDate(travelDate!),
              ),
              const SizedBox(height: 12),
            ],

            // Payment method
            if (paymentMethod != null) ...[
              _DetailRow(
                icon: Icons.payment,
                label: 'Payment Method',
                value: paymentMethod!.toUpperCase(),
              ),
              const SizedBox(height: 16),
            ],

            // Fare details
            if (originalFare != null && finalFare != null) ...[
              FareDisplay(
                originalFare: originalFare!,
                subsidyAmount: subsidyAmount ?? 0,
                finalFare: finalFare!,
                showBreakdown: false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (targetDate == tomorrow) {
      return 'Tomorrow, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _JourneyRoute extends StatelessWidget {
  final StationModel fromStation;
  final StationModel toStation;

  const _JourneyRoute({
    required this.fromStation,
    required this.toStation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // From station
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FROM',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fromStation.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  fromStation.code,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Arrow
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: AppColors.primary,
              size: 16,
            ),
          ),

          // To station
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'TO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  toStation.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.end,
                ),
                Text(
                  toStation.code,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
