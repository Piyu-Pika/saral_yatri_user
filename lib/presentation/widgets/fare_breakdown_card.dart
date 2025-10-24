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
    // Handle new API response structure
    final baseFare = (fareData['base_fare'] ?? 0.0).toDouble();
    final totalSubsidyAmount =
        (fareData['total_subsidy_amount'] ?? 0.0).toDouble();
    final totalTaxAmount = (fareData['total_tax_amount'] ?? 0.0).toDouble();
    final finalAmount = (fareData['final_amount'] ?? 0.0).toDouble();
    final governmentShare = (fareData['government_share'] ?? 0.0).toDouble();
    final passengerShare = (fareData['passenger_share'] ?? 0.0).toDouble();
    final distance = (fareData['distance'] ?? 0.0).toDouble();
    final busType = fareData['bus_type'] as String?;
    final routeType = fareData['route_type'] as String?;
    final appliedSubsidies =
        fareData['applied_subsidies'] as List<dynamic>? ?? [];
    final taxes = fareData['taxes'] as List<dynamic>? ?? [];

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

            // Trip Info
            if (distance > 0)
              _buildFareRow(
                'Distance',
                '${distance.toStringAsFixed(1)} km',
                isInfo: true,
              ),

            if (busType != null)
              _buildFareRow(
                'Bus Type',
                busType.toUpperCase(),
                isInfo: true,
              ),

            if (routeType != null)
              _buildFareRow(
                'Route Type',
                routeType.toUpperCase(),
                isInfo: true,
              ),

            const SizedBox(height: 8),

            // Base Fare
            _buildFareRow(
              'Base Fare',
              '₹${baseFare.toStringAsFixed(2)}',
            ),

            // Applied Subsidies
            if (appliedSubsidies.isNotEmpty) ...[
              for (var subsidy in appliedSubsidies)
                _buildFareRow(
                  '${subsidy['scheme_name'] ?? 'Subsidy'}',
                  '-₹${(subsidy['discount_amount'] ?? 0.0).toStringAsFixed(2)}',
                  valueColor: AppTheme.successColor,
                ),
            ],

            // Taxes
            if (taxes.isNotEmpty) ...[
              for (var tax in taxes)
                _buildFareRow(
                  '${tax['tax_type'] ?? 'Tax'}',
                  '+₹${(tax['tax_amount'] ?? 0.0).toStringAsFixed(2)}',
                  valueColor: AppTheme.errorColor,
                ),
            ],

            if (totalSubsidyAmount > 0 || totalTaxAmount > 0)
              const Divider(height: 24),

            // Final Amount
            _buildFareRow(
              'Total Amount',
              '₹${finalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),

            // Government Share Info
            if (totalSubsidyAmount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.successColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.successColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You saved ₹${totalSubsidyAmount.toStringAsFixed(2)} with government subsidy!',
                            style: const TextStyle(
                              color: AppTheme.successColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (governmentShare > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Government pays: ₹${governmentShare.toStringAsFixed(2)} • You pay: ₹${passengerShare.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.successColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
              color: valueColor ??
                  (isTotal ? AppTheme.primaryColor : AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
