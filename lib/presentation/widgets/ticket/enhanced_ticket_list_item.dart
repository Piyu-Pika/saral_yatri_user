import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/enhanced_ticket_display_model.dart';

class EnhancedTicketListItemWidget extends StatelessWidget {
  final EnhancedTicketDisplayModel enhancedTicket;
  final VoidCallback onTap;

  const EnhancedTicketListItemWidget({
    super.key,
    required this.enhancedTicket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ticket = enhancedTicket.ticket;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ticket.isExpired
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (ticket.isExpired
                                ? AppColors.error
                                : AppColors.primary)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.confirmation_number,
                        color: ticket.isExpired
                            ? AppColors.error
                            : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            enhancedTicket.busDisplay,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            enhancedTicket.ticketTitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ticket.isExpired
                            ? AppColors.error.withValues(alpha: 0.1)
                            : AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        enhancedTicket.statusDisplay,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: ticket.isExpired
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Route name (if available and different from station names)
                if (enhancedTicket.isDataResolved &&
                    enhancedTicket.routeName.isNotEmpty &&
                    !enhancedTicket.routeName.startsWith('Route'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      enhancedTicket.routeName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                // Journey details with resolved names
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'From',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            enhancedTicket.boardingStationName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'To',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            enhancedTicket.destinationStationName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Footer row with additional info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ticket.bookingTime.day}/${ticket.bookingTime.month}/${ticket.bookingTime.year}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (enhancedTicket.isDataResolved)
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: AppColors.success.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Names resolved',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          enhancedTicket.formattedFare,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ticket.isExpired
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                        ),
                        if (ticket.subsidyAmount > 0)
                          Text(
                            'Saved ₹${ticket.subsidyAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.success.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
