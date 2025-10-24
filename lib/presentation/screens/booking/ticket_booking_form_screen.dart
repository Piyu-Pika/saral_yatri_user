import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/bus_model.dart';
import '../../../data/models/station_model.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/booking/payment_options.dart';
import '../../widgets/booking/booking_summary.dart';
import 'payment_screen.dart';

class TicketBookingFormScreen extends ConsumerStatefulWidget {
  final BusModel bus;
  final StationModel boardingStation;
  final StationModel destinationStation;
  final double calculatedFare;

  const TicketBookingFormScreen({
    super.key,
    required this.bus,
    required this.boardingStation,
    required this.destinationStation,
    required this.calculatedFare,
  });

  @override
  ConsumerState<TicketBookingFormScreen> createState() =>
      _TicketBookingFormScreenState();
}

class _TicketBookingFormScreenState
    extends ConsumerState<TicketBookingFormScreen> {
  String _selectedTicketType = 'single';
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  DateTime _selectedTravelDate = DateTime.now();

  void _proceedToPayment() {
    final bookingData = {
      'bus': widget.bus,
      'boardingStation': widget.boardingStation,
      'dropStation': widget.destinationStation,
      'ticketType': _selectedTicketType,
      'paymentMethod': _selectedPaymentMethod.apiValue,
      'travelDate': _selectedTravelDate,
      'fareData': {
        'final_amount': widget.calculatedFare,
        'base_fare': widget.calculatedFare,
        'subsidy_amount': 0.0,
      },
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PaymentScreen(),
        settings: RouteSettings(arguments: bookingData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Booking Details',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking summary
            BookingSummary(
              fromStation: widget.boardingStation,
              toStation: widget.destinationStation,
              busNumber: widget.bus.busNumber,
              routeName: widget.bus.routeName,
              originalFare: widget.calculatedFare,
              finalFare: widget.calculatedFare,
              paymentMethod: _selectedPaymentMethod.displayName,
              travelDate: _selectedTravelDate,
              showEditButton: false,
            ),

            const SizedBox(height: 24),

            // Ticket type selection
            const Text(
              'Ticket Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textHint),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Single Journey'),
                    subtitle: const Text('One-way ticket'),
                    value: 'single',
                    groupValue: _selectedTicketType,
                    onChanged: (value) {
                      setState(() {
                        _selectedTicketType = value!;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Return Journey'),
                    subtitle: const Text('Round-trip ticket (10% discount)'),
                    value: 'return',
                    groupValue: _selectedTicketType,
                    onChanged: (value) {
                      setState(() {
                        _selectedTicketType = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Travel date selection
            const Text(
              'Travel Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textHint),
                color: Colors.grey[50],
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${_selectedTravelDate.day}/${_selectedTravelDate.month}/${_selectedTravelDate.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedTravelDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedTravelDate = date;
                        });
                      }
                    },
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment method selection
            PaymentOptions(
              selectedMethod: _selectedPaymentMethod,
              onMethodSelected: (method) {
                setState(() {
                  _selectedPaymentMethod = method;
                });
              },
            ),

            const SizedBox(height: 32),

            // Final fare display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '₹${widget.calculatedFare.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Proceed to payment button
            CustomButton(
              onPressed: _proceedToPayment,
              text: 'Proceed to Payment',
              icon: Icons.payment,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
