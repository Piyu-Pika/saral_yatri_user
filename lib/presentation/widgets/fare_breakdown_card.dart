import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FareBreakdownCard extends StatelessWidget {
  final Map<String, dynamic> fareData;

  const FareBreakdownCard({
    super.key,
    required this.fareData,
  });

  @override
  Widget build(BuildContext context) {
    final originalFare = (fareData['original_fare'] ?? 0.0).toDouble();
    final subsidyAmount = (fareData['subsidy_amount'] ?? 0.0).toDouble();
    final finalFare = (fareData['final_fare'] ?? 0.0).toDouble();
    final subsidyType = fareData['subsidy_type'] as String?;
    final distance = (fareData['distance'] ?? 0.0).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fare Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Distance
            if (distance > 0)
              _buildFareRow(
                'Distance',
                '${distance.toStringAsFixed(1)} km',
                isInfo: true,
              ),
            
            // Original Fare
            _buildFareRow(
              'Base Fare',
              '₹${originalFare.toStringAsFixed(2)}',
            ),
            
            // Subsidy
            if (subsidyAmount > 0) ...[
              _buildFareRow(
                subsidyType != null ? '$subsidyType Subsidy' : 'Subsidy',
                '-₹${subsidyAmount.toStringAsFixed(2)}',
                valueColor: AppTheme.successColor,
              ),
              const Divider(height: 24),
            ],
            
            // Final Fare
            _buildFareRow(
              'Total Amount',
              '₹${finalFare.toStringAsFixed(2)}',
              isTotal: true,
            ),
            
            // Subsidy Info
            if (subsidyAmount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.successColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You saved ₹${subsidyAmount.toStringAsFixed(2)} with government subsidy!',
                        style: const TextStyle(
                          color: AppTheme.successColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildFareRow(
    String label,
    String value, {
    Color? valueColor,
    bool isTotal = false,
    bool isInfo = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isInfo ? AppTheme.textSecondary : AppTheme.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? (isTotal ? AppTheme.primaryColor : AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}