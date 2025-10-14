import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FareDisplay extends StatelessWidget {
  final double originalFare;
  final double subsidyAmount;
  final double finalFare;
  final String? subsidyType;
  final double? distance;
  final bool showBreakdown;

  const FareDisplay({
    super.key,
    required this.originalFare,
    required this.subsidyAmount,
    required this.finalFare,
    this.subsidyType,
    this.distance,
    this.showBreakdown = true,
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
            const Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Fare Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            if (showBreakdown) ...[
              const SizedBox(height: 16),
              
              // Distance (if available)
              if (distance != null)
                _FareRow(
                  label: 'Distance',
                  value: '${distance!.toStringAsFixed(1)} km',
                  isInfo: true,
                ),
              
              // Original fare
              _FareRow(
                label: 'Base Fare',
                value: '₹${originalFare.toStringAsFixed(2)}',
              ),
              
              // Subsidy (if applicable)
              if (subsidyAmount > 0)
                _FareRow(
                  label: subsidyType != null 
                      ? '$subsidyType Subsidy' 
                      : 'Subsidy',
                  value: '-₹${subsidyAmount.toStringAsFixed(2)}',
                  isDiscount: true,
                ),
              
              const Divider(height: 24),
            ],
            
            // Final amount
            _FareRow(
              label: 'Total Amount',
              value: '₹${finalFare.toStringAsFixed(2)}',
              isTotal: true,
            ),
            
            // Savings indicator
            if (subsidyAmount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.savings,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'You save ₹${subsidyAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final bool isDiscount;
  final bool isInfo;

  const _FareRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.isDiscount = false,
    this.isInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal
                  ? AppColors.primary
                  : isDiscount
                      ? AppColors.success
                      : isInfo
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class CompactFareDisplay extends StatelessWidget {
  final double finalFare;
  final double? originalFare;
  final double? subsidyAmount;

  const CompactFareDisplay({
    super.key,
    required this.finalFare,
    this.originalFare,
    this.subsidyAmount,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = subsidyAmount != null && subsidyAmount! > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.currency_rupee,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 4),
          if (hasDiscount && originalFare != null) ...[
            Text(
              '₹${originalFare!.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            '₹${finalFare.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}