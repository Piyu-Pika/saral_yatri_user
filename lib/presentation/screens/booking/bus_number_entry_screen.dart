import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/providers/bus_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import 'station_selection_screen.dart';

class BusNumberEntryScreen extends ConsumerStatefulWidget {
  const BusNumberEntryScreen({super.key});

  @override
  ConsumerState<BusNumberEntryScreen> createState() =>
      _BusNumberEntryScreenState();
}

class _BusNumberEntryScreenState extends ConsumerState<BusNumberEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _busNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _busNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleBusNumberSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final busNumber = _busNumberController.text.trim().toUpperCase();

      // Search for bus by number
      final busNotifier = ref.read(busProvider.notifier);
      await busNotifier.searchBusByNumber(busNumber);

      final busState = ref.read(busProvider);

      if (busState.selectedBus != null) {
        // Navigate to station selection with found bus
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => StationSelectionScreen(
                selectedBus: busState.selectedBus!,
              ),
            ),
          );
        }
      } else {
        _showErrorDialog('Bus Not Found',
            'No bus found with number $busNumber. Please check the number and try again.');
      }
    } catch (e) {
      _showErrorDialog('Error', e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Enter Bus Number',
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Icon and title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.directions_bus,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter Bus Number',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter the bus registration number to book your ticket',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Bus number input
              CustomTextField(
                controller: _busNumberController,
                label: 'Bus Registration Number',
                hintText: 'e.g. MH-01-AB-1234',
                prefixIcon: Icons.directions_bus,
                validator: Validators.busNumber,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  // Auto format bus number as user types
                  final formatted =
                      value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
                  if (formatted !=
                      value
                          .toUpperCase()
                          .replaceAll(RegExp(r'[^A-Z0-9]'), '')) {
                    _busNumberController.value =
                        _busNumberController.value.copyWith(
                      text: formatted,
                      selection:
                          TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              ),

              const SizedBox(height: 32),

              // Search button
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                CustomButton(
                  onPressed: _handleBusNumberSubmit,
                  text: 'Search Bus',
                  icon: Icons.search,
                  isFullWidth: true,
                ),

              const SizedBox(height: 24),

              // Help text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bus number can be found on the front or side of the bus. Format: State-District-Series-Number (e.g., MH-01-AB-1234)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.info.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Alternative options
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Can\'t find the number? ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Use QR Scanner',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
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
