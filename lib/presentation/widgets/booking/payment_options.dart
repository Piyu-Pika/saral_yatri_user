import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum PaymentMethod {
  upi,
  card,
  netBanking,
  wallet,
  cash,
}

class PaymentOptions extends StatefulWidget {
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod) onMethodSelected;
  final bool showCashOption;

  const PaymentOptions({
    super.key,
    this.selectedMethod,
    required this.onMethodSelected,
    this.showCashOption = false,
  });

  @override
  State<PaymentOptions> createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {
  PaymentMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedMethod;
  }

  void _selectMethod(PaymentMethod method) {
    setState(() {
      _selectedMethod = method;
    });
    widget.onMethodSelected(method);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // UPI Payment
        _PaymentOptionTile(
          method: PaymentMethod.upi,
          title: 'UPI Payment',
          subtitle: 'Pay using Google Pay, PhonePe, Paytm, etc.',
          icon: Icons.account_balance_wallet,
          isSelected: _selectedMethod == PaymentMethod.upi,
          onTap: () => _selectMethod(PaymentMethod.upi),
        ),
        
        const SizedBox(height: 12),
        
        // Card Payment
        _PaymentOptionTile(
          method: PaymentMethod.card,
          title: 'Credit/Debit Card',
          subtitle: 'Visa, Mastercard, RuPay cards accepted',
          icon: Icons.credit_card,
          isSelected: _selectedMethod == PaymentMethod.card,
          onTap: () => _selectMethod(PaymentMethod.card),
        ),
        
        const SizedBox(height: 12),
        
        // Net Banking
        _PaymentOptionTile(
          method: PaymentMethod.netBanking,
          title: 'Net Banking',
          subtitle: 'Pay directly from your bank account',
          icon: Icons.account_balance,
          isSelected: _selectedMethod == PaymentMethod.netBanking,
          onTap: () => _selectMethod(PaymentMethod.netBanking),
        ),
        
        const SizedBox(height: 12),
        
        // Wallet
        _PaymentOptionTile(
          method: PaymentMethod.wallet,
          title: 'Digital Wallet',
          subtitle: 'Paytm, Amazon Pay, Mobikwik, etc.',
          icon: Icons.account_balance_wallet_outlined,
          isSelected: _selectedMethod == PaymentMethod.wallet,
          onTap: () => _selectMethod(PaymentMethod.wallet),
        ),
        
        // Cash option (if enabled)
        if (widget.showCashOption) ...[
          const SizedBox(height: 12),
          _PaymentOptionTile(
            method: PaymentMethod.cash,
            title: 'Cash Payment',
            subtitle: 'Pay cash to the conductor',
            icon: Icons.money,
            isSelected: _selectedMethod == PaymentMethod.cash,
            onTap: () => _selectMethod(PaymentMethod.cash),
          ),
        ],
      ],
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final PaymentMethod method;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.method,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Helper extension to get payment method display name
extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.netBanking:
        return 'Net Banking';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }

  String get apiValue {
    switch (this) {
      case PaymentMethod.upi:
        return 'upi';
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.netBanking:
        return 'netbanking';
      case PaymentMethod.wallet:
        return 'wallet';
      case PaymentMethod.cash:
        return 'cash';
    }
  }
}