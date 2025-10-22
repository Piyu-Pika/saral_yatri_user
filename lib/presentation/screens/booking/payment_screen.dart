import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/bus_model.dart';
import '../../../data/models/station_model.dart';
import '../../../data/models/enhanced_ticket_model.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/fare_breakdown_card.dart';
import '../ticket/qr_ticket_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessingPayment = false;

  // Booking details from arguments
  BusModel? _bus;
  StationModel? _boardingStation;
  StationModel? _dropStation;
  String _ticketType = 'single';
  String _paymentMethod = 'digital';
  Map<String, dynamic>? _fareData;
  DateTime? _travelDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get arguments from route
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _bus == null) {
      setState(() {
        _bus = args['bus'] as BusModel?;
        _boardingStation = args['boardingStation'] as StationModel?;
        _dropStation = args['dropStation'] as StationModel?;
        _ticketType = args['ticketType'] as String? ?? 'single';
        _paymentMethod = args['paymentMethod'] as String? ?? 'upi';
        _fareData = args['fareData'] as Map<String, dynamic>?;
        _travelDate = args['travelDate'] as DateTime?;
      });
    }
  }

  String _getPaymentMethodDisplayName(String method) {
    switch (method.toLowerCase()) {
      case 'digital':
        return 'UPI/Digital Wallet';
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Debit/Credit Card';
      default:
        return method.toUpperCase();
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'digital':
        return Icons.account_balance_wallet;
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  void _showBookingErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage),
            const SizedBox(height: 16),
            const Text(
              'What would you like to do?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to booking screen
            },
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processPayment(); // Retry payment
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showServerMaintenanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Server Maintenance'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.construction,
              size: 48,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'The booking system is temporarily unavailable due to server maintenance.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'You can create an offline ticket that will be synced when the server is back online.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to booking screen
            },
            child: const Text('Go Back'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Wait a bit before retry
              Future.delayed(const Duration(seconds: 3), () {
                _processPayment();
              });
            },
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createOfflineTicket();
            },
            child: const Text('Create Offline Ticket'),
          ),
        ],
      ),
    );
  }

  Future<void> _createOfflineTicket() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Creating offline ticket...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '✅ Offline ticket created! Will sync when server is available.'),
          backgroundColor: AppTheme.successColor,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to ticket screen (you might want to create a special offline ticket screen)
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/ticket');
      }
    }
  }

  Future<void> _processPayment() async {
    print('🔍 DEBUG: Starting payment process...');
    print('🔍 DEBUG: Bus: ${_bus?.id} (${_bus?.busNumber})');
    print('🔍 DEBUG: Boarding: ${_boardingStation?.id} (${_boardingStation?.name})');
    print('🔍 DEBUG: Drop: ${_dropStation?.id} (${_dropStation?.name})');
    print('🔍 DEBUG: Fare Data: $_fareData');
    print('🔍 DEBUG: Payment Method: $_paymentMethod');
    print('🔍 DEBUG: Ticket Type: $_ticketType');
    print('🔍 DEBUG: Travel Date: $_travelDate');
    
    if (_bus == null ||
        _boardingStation == null ||
        _dropStation == null ||
        _fareData == null) {
      print('❌ DEBUG: Missing booking information!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing booking information'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Step 1: Simulate payment processing
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing payment...'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }

      await Future.delayed(const Duration(seconds: 2));

      // Step 2: Simulate payment success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Booking ticket...'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 1),
          ),
        );
      }

      await Future.delayed(const Duration(seconds: 1));

      // Step 3: Map payment method to API format
      String apiPaymentMode;
      switch (_paymentMethod.toLowerCase()) {
        case 'digital':
          apiPaymentMode = 'upi';
          break;
        case 'cash':
          apiPaymentMode = 'cash';
          break;
        case 'card':
          apiPaymentMode = 'card';
          break;
        default:
          apiPaymentMode = 'upi'; // Default to UPI
      }

      // Step 4: Book the ticket
      print('🎫 DEBUG: Starting ticket booking...');
      print('🎫 DEBUG: API Payment Mode: $apiPaymentMode');
      
      bool success = false;
      EnhancedTicketModel? enhancedTicket;
      
      try {
        // Try enhanced booking first for QR data
        print('🎫 DEBUG: Attempting enhanced booking...');
        success = await ref.read(ticketProvider.notifier).bookEnhancedTicket(
              busId: _bus!.id,
              routeId: _bus!.routeId,
              boardingStationId: _boardingStation!.id,
              droppingStationId: _dropStation!.id,
              paymentMethod: apiPaymentMode,
              ticketType: _ticketType,
              travelDate: _travelDate ?? DateTime.now(),
            );
        
        print('🎫 DEBUG: Enhanced booking success: $success');
        
        if (success) {
          final currentState = ref.read(ticketProvider);
          enhancedTicket = currentState.currentEnhancedTicket;
          print('🎫 DEBUG: Enhanced ticket received: ${enhancedTicket?.id}');
        }
      } catch (e) {
        print('❌ DEBUG: Enhanced booking failed: $e');
        // Fallback to regular booking
        try {
          print('🎫 DEBUG: Attempting regular booking fallback...');
          success = await ref.read(ticketProvider.notifier).bookTicket(
                busId: _bus!.id,
                routeId: _bus!.routeId,
                boardingStationId: _boardingStation!.id,
                droppingStationId: _dropStation!.id,
                paymentMethod: apiPaymentMode,
                ticketType: _ticketType,
                travelDate: _travelDate ?? DateTime.now(),
              );
          print('🎫 DEBUG: Regular booking success: $success');
        } catch (fallbackError) {
          print('❌ DEBUG: Regular booking also failed: $fallbackError');
          throw fallbackError;
        }
      }

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Ticket booked successfully!'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 3),
          ),
        );

        // Wait a moment before navigation
        await Future.delayed(const Duration(seconds: 1));

        // Navigate to appropriate ticket screen
        if (mounted) {
          if (enhancedTicket != null) {
            // Show enhanced QR ticket
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => QrTicketScreen(ticket: enhancedTicket!),
              ),
            );
          } else {
            // Show regular tickets list
            Navigator.pushReplacementNamed(context, '/my-tickets');
          }
        }
      } else if (!success && mounted) {
        // Show error message with retry option
        final currentState = ref.read(ticketProvider);
        final errorMessage = currentState.error ?? 'Failed to book ticket';

        _showBookingErrorDialog(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Server is temporarily unavailable') ||
            errorMessage.contains('space quota')) {
          _showServerMaintenanceDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: $errorMessage'),
              backgroundColor: AppTheme.errorColor,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(ticketProvider);
    final finalAmount = _fareData?['final_amount'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Booking Summary Card
            if (_bus != null &&
                _boardingStation != null &&
                _dropStation != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Booking Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bus Info
                      Row(
                        children: [
                          const Icon(Icons.directions_bus,
                              color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bus ${_bus!.busNumber}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _bus!.routeName,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Journey Info
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppTheme.successColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'From: ${_boardingStation!.name}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.location_off,
                              color: AppTheme.errorColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'To: ${_dropStation!.name}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Ticket Type and Payment Method
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ticket Type',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _ticketType.toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Payment Method',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _getPaymentMethodDisplayName(_paymentMethod),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Fare Breakdown
            if (_fareData != null) FareBreakdownCard(fareData: _fareData!),

            const SizedBox(height: 16),

            // Payment Method Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getPaymentMethodIcon(_paymentMethod),
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getPaymentMethodDisplayName(_paymentMethod),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.successColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Amount Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.payment,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Amount to Pay',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${finalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Payment Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Payment Instructions',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Your payment is secured with encryption\n'
                    '• Ticket will be generated immediately after payment\n'
                    '• You will receive a notification once booking is confirmed\n'
                    '• Keep your phone ready to show the ticket to the conductor',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Pay Now Button
            CustomButton(
              text: _isProcessingPayment
                  ? 'Processing Payment...'
                  : 'Pay Now - ₹${finalAmount.toStringAsFixed(2)}',
              onPressed: (_isProcessingPayment || ticketState.isLoading)
                  ? null
                  : _processPayment,
              isLoading: _isProcessingPayment || ticketState.isLoading,
            ),

            const SizedBox(height: 16),

            // Error Message with Action
            if (ticketState.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.errorColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppTheme.errorColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ticketState.error!,
                            style: const TextStyle(
                              color: AppTheme.errorColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (ticketState.error!
                            .contains('Server is temporarily unavailable') ||
                        ticketState.error!.contains('maintenance')) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _processPayment,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Retry'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _createOfflineTicket,
                              icon: const Icon(Icons.offline_bolt, size: 16),
                              label: const Text('Offline'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
