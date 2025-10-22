import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/bus_model.dart';
import '../../../data/models/station_model.dart';
import '../../../data/providers/bus_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/fare_breakdown_card.dart';
import '../../widgets/booking/station_dropdown.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _busNumberController = TextEditingController();
  BusModel? _selectedBus;
  StationModel? _selectedBoardingStation;
  StationModel? _selectedDropStation;
  String _selectedPaymentMethod = 'digital';
  String _selectedTicketType = 'single';
  bool _isBusInfoExpanded = false;

  final List<String> _paymentMethods = ['digital', 'cash', 'card'];
  final List<String> _ticketTypes = [
    'single',
    'return',
    'daily',
    'weekly',
    'monthly'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        if (args['bus'] != null) {
          setState(() {
            _selectedBus = args['bus'] as BusModel;
          });
          _loadRouteStations();
        }
      }
    });
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadRouteStations() async {
    if (_selectedBus != null) {
      await ref
          .read(busProvider.notifier)
          .loadRouteStations(_selectedBus!.routeId);
    }
  }

  Future<void> _searchBusByNumber() async {
    if (_busNumberController.text.trim().isEmpty) return;

    // Clear any previous errors
    ref.read(ticketProvider.notifier).clearError();

    final bus = await ref.read(busProvider.notifier).getBusByNumber(
          _busNumberController.text.trim(),
        );

    if (bus != null) {
      setState(() {
        _selectedBus = bus;
        _isBusInfoExpanded = true; // Auto-expand to show bus details
      });
      _loadRouteStations();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bus not found'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _calculateFare() async {
    if (_selectedBus != null &&
        _selectedBoardingStation != null &&
        _selectedDropStation != null) {
      // Validate that all IDs are not empty and have valid format
      if (_selectedBus!.id.isEmpty ||
          _selectedBus!.routeId.isEmpty ||
          _selectedBoardingStation!.id.isEmpty ||
          _selectedDropStation!.id.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Invalid bus or station data. Please try selecting again.'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        return;
      }

      // Validate MongoDB ObjectId format (24 character hex string)
      final objectIdRegex = RegExp(r'^[0-9a-fA-F]{24}$');
      if (!objectIdRegex.hasMatch(_selectedBus!.id) ||
          !objectIdRegex.hasMatch(_selectedBus!.routeId) ||
          !objectIdRegex.hasMatch(_selectedBoardingStation!.id) ||
          !objectIdRegex.hasMatch(_selectedDropStation!.id)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid ID format. Please refresh and try again.'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        return;
      }

      // Debug logging
      print('Calculating fare with:');
      print('Bus ID: ${_selectedBus!.id}');
      print('Route ID: ${_selectedBus!.routeId}');
      print('Boarding Station ID: ${_selectedBoardingStation!.id}');
      print('Drop Station ID: ${_selectedDropStation!.id}');
      print('Ticket Type: $_selectedTicketType');

      // Clear any previous errors before calculating
      ref.read(ticketProvider.notifier).clearError();

      try {
        await ref.read(ticketProvider.notifier).calculateFare(
              busId: _selectedBus!.id,
              routeId: _selectedBus!.routeId,
              boardingStationId: _selectedBoardingStation!.id,
              droppingStationId: _selectedDropStation!.id,
              ticketType: _selectedTicketType,
              travelDate: DateTime.now(),
            );
      } catch (e) {
        print('Fare calculation error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to calculate fare: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return AppTheme.successColor;
      case 'parked':
        return Colors.blue;
      case 'maintenance':
        return AppTheme.warningColor;
      case 'out_of_service':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryInfo(String label, DateTime expiryDate) {
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate.difference(now).inDays;
    final isExpiringSoon = daysUntilExpiry <= 30;
    final isExpired = daysUntilExpiry < 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isExpired
                ? Icons.error
                : (isExpiringSoon ? Icons.warning : Icons.schedule),
            size: 14,
            color: isExpired
                ? AppTheme.errorColor
                : (isExpiringSoon
                    ? AppTheme.warningColor
                    : AppTheme.textSecondary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
              style: TextStyle(
                fontSize: 12,
                color: isExpired
                    ? AppTheme.errorColor
                    : (isExpiringSoon
                        ? AppTheme.warningColor
                        : AppTheme.textSecondary),
              ),
            ),
          ),
          if (isExpired)
            const Text(
              'EXPIRED',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.errorColor,
              ),
            )
          else if (isExpiringSoon)
            Text(
              '${daysUntilExpiry}d left',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.warningColor,
              ),
            ),
        ],
      ),
    );
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

  Future<void> _bookTicket() async {
    if (_selectedBus == null ||
        _selectedBoardingStation == null ||
        _selectedDropStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Check if fare is calculated
    final ticketState = ref.read(ticketProvider);
    if (ticketState.fareCalculation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for fare calculation to complete'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    // Validate fare amount
    final finalAmount = ticketState.fareCalculation!['final_amount'] ?? 0.0;
    if (finalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid fare amount. Please recalculate fare.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bus: ${_selectedBus!.busNumber}'),
            Text('Route: ${_selectedBus!.routeName}'),
            Text('From: ${_selectedBoardingStation!.name}'),
            Text('To: ${_selectedDropStation!.name}'),
            Text('Ticket Type: ${_selectedTicketType.toUpperCase()}'),
            Text('Payment Method: ${_getPaymentMethodDisplayName(_selectedPaymentMethod)}'),
            const SizedBox(height: 8),
            Text(
              'Total Amount: ₹${finalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Book Ticket'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;

    // Book the ticket using the enhanced booking method
    try {
      final success = await ref.read(ticketProvider.notifier).bookEnhancedTicket(
        busId: _selectedBus!.id,
        routeId: _selectedBus!.routeId,
        boardingStationId: _selectedBoardingStation!.id,
        droppingStationId: _selectedDropStation!.id,
        paymentMethod: _selectedPaymentMethod,
        ticketType: _selectedTicketType,
        travelDate: DateTime.now(),
      );

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ticket booked successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }

        // Navigate to ticket screen with the booked ticket
        final bookedTicket = ref.read(ticketProvider).currentEnhancedTicket;
        if (bookedTicket != null && mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/qr-ticket',
            arguments: {
              'ticket': bookedTicket,
              'showSuccessMessage': true,
            },
          );
        } else {
          // Fallback: navigate to my tickets screen
          Navigator.pushReplacementNamed(context, '/my-tickets');
        }
      } else {
        // Error handling is done in the provider, just show a generic message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to book ticket. Please try again.'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final busState = ref.watch(busProvider);
    final ticketState = ref.watch(ticketProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Ticket'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bus Selection Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Bus',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedBus == null) ...[
                      // Bus Number Input
                      TextFormField(
                        controller: _busNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Bus Number',
                          hintText: 'Enter bus number',
                          prefixIcon: Icon(Icons.directions_bus),
                        ),
                      ),
                      const SizedBox(height: 12),

                      CustomButton(
                        text: 'Search Bus',
                        onPressed:
                            busState.isLoading ? null : _searchBusByNumber,
                        isLoading: busState.isLoading,
                      ),
                    ] else ...[
                      // Selected Bus Info - Expandable
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Bus Header - Always visible
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isBusInfoExpanded = !_isBusInfoExpanded;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.directions_bus,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Bus ${_selectedBus!.busNumber}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _selectedBus!
                                                              .busType ==
                                                          'ordinary'
                                                      ? Colors.blue.withValues(
                                                          alpha: 0.1)
                                                      : Colors.purple
                                                          .withValues(
                                                              alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  _selectedBus!.busType
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        _selectedBus!.busType ==
                                                                'ordinary'
                                                            ? Colors.blue
                                                            : Colors.purple,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (_selectedBus!
                                              .fleetNumber.isNotEmpty)
                                            Text(
                                              'Fleet: ${_selectedBus!.fleetNumber}',
                                              style: const TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          Text(
                                            'Route: ${_selectedBus!.routeName}',
                                            style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.event_seat,
                                                size: 16,
                                                color: _selectedBus!
                                                            .seatingCapacity >
                                                        0
                                                    ? AppTheme.successColor
                                                    : AppTheme.errorColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${_selectedBus!.seatingCapacity} seats capacity',
                                                style: TextStyle(
                                                  color: _selectedBus!
                                                              .seatingCapacity >
                                                          0
                                                      ? AppTheme.successColor
                                                      : AppTheme.errorColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      _isBusInfoExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Expandable Bus Details
                            if (_isBusInfoExpanded) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    // Bus Status and Current Status
                                    Row(
                                      children: [
                                        Icon(
                                          _selectedBus!.isActive
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: _selectedBus!.isActive
                                              ? AppTheme.successColor
                                              : AppTheme.errorColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _selectedBus!.isActive
                                              ? 'Active'
                                              : 'Inactive',
                                          style: TextStyle(
                                            color: _selectedBus!.isActive
                                                ? AppTheme.successColor
                                                : AppTheme.errorColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                    _selectedBus!.currentStatus)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _selectedBus!.currentStatus
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: _getStatusColor(
                                                  _selectedBus!.currentStatus),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Bus Features
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        if (_selectedBus!.hasAirConditioning)
                                          _buildFeatureChip(
                                              Icons.ac_unit, 'AC'),
                                        if (_selectedBus!.hasWifi)
                                          _buildFeatureChip(Icons.wifi, 'WiFi'),
                                        if (_selectedBus!.hasGps)
                                          _buildFeatureChip(
                                              Icons.gps_fixed, 'GPS'),
                                        if (_selectedBus!.isAccessible)
                                          _buildFeatureChip(
                                              Icons.accessible, 'Accessible'),
                                        if (_selectedBus!
                                            .emissionStandard.isNotEmpty)
                                          _buildFeatureChip(Icons.eco,
                                              _selectedBus!.emissionStandard),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Compliance Status
                                    Row(
                                      children: [
                                        Icon(
                                          _selectedBus!.isCompliant
                                              ? Icons.verified
                                              : Icons.warning,
                                          color: _selectedBus!.isCompliant
                                              ? AppTheme.successColor
                                              : AppTheme.warningColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _selectedBus!.isCompliant
                                              ? 'Compliant'
                                              : 'Non-Compliant',
                                          style: TextStyle(
                                            color: _selectedBus!.isCompliant
                                                ? AppTheme.successColor
                                                : AppTheme.warningColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Important Dates
                                    if (_selectedBus!.fitnessExpiryDate !=
                                            null ||
                                        _selectedBus!.insuranceExpiryDate !=
                                            null) ...[
                                      const Divider(height: 16),
                                      if (_selectedBus!.fitnessExpiryDate !=
                                          null)
                                        _buildExpiryInfo(
                                          'Fitness Expires',
                                          _selectedBus!.fitnessExpiryDate!,
                                        ),
                                      if (_selectedBus!.insuranceExpiryDate !=
                                          null)
                                        _buildExpiryInfo(
                                          'Insurance Expires',
                                          _selectedBus!.insuranceExpiryDate!,
                                        ),
                                    ],

                                    // Last Updated
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: AppTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Last updated: ${_formatDateTime(_selectedBus!.lastUpdated)}',
                                          style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Action Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: busState.isLoading
                                                ? null
                                                : () async {
                                                    // Refresh bus data
                                                    final updatedBus = await ref
                                                        .read(busProvider
                                                            .notifier)
                                                        .getBusByNumber(
                                                            _selectedBus!
                                                                .busNumber);
                                                    if (updatedBus != null) {
                                                      setState(() {
                                                        _selectedBus =
                                                            updatedBus;
                                                      });
                                                    }
                                                  },
                                            icon: busState.isLoading
                                                ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  )
                                                : const Icon(Icons.refresh,
                                                    size: 16),
                                            label: const Text('Refresh'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _selectedBus = null;
                                                _selectedBoardingStation = null;
                                                _selectedDropStation = null;
                                                _selectedTicketType = 'single';
                                                _isBusInfoExpanded = false;
                                              });
                                              ref
                                                  .read(ticketProvider.notifier)
                                                  .clearFareCalculation();
                                              ref
                                                  .read(ticketProvider.notifier)
                                                  .clearError();
                                            },
                                            icon: const Icon(
                                                Icons.change_circle,
                                                size: 16),
                                            label: const Text('Change'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
            ),

            const SizedBox(height: 16),

            // Route Selection Section
            if (_selectedBus != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Route',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Boarding Station Dropdown
                      StationDropdown(
                        label: 'Boarding Station',
                        hintText: 'Select boarding station',
                        selectedStation: _selectedBoardingStation,
                        onChanged: (station) {
                          setState(() {
                            _selectedBoardingStation = station;
                            // Clear drop station if it's the same as boarding station
                            if (_selectedDropStation?.id == station?.id) {
                              _selectedDropStation = null;
                            }
                          });
                          _calculateFare();
                        },
                        excludeStationIds: _selectedDropStation != null
                            ? [_selectedDropStation!.id]
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Drop Station Dropdown
                      StationDropdown(
                        label: 'Drop Station',
                        hintText: 'Select drop station',
                        selectedStation: _selectedDropStation,
                        onChanged: (station) {
                          setState(() {
                            _selectedDropStation = station;
                          });
                          _calculateFare();
                        },
                        excludeStationIds: _selectedBoardingStation != null
                            ? [_selectedBoardingStation!.id]
                            : null,
                      ),

                      // Show route info
                      if (_selectedBoardingStation != null ||
                          _selectedDropStation != null)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info,
                                  color: Colors.blue, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Route: ${_selectedBus!.routeName}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Fare Breakdown
              if (ticketState.fareCalculation != null)
                FareBreakdownCard(fareData: ticketState.fareCalculation!)
              else if (_selectedBoardingStation != null &&
                  _selectedDropStation != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (ticketState.error == null) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Calculating fare...',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ] else ...[
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.errorColor,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to calculate fare',
                            style: TextStyle(
                              color: AppTheme.errorColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _calculateFare,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Retry'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Ticket Type
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ticket Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedTicketType,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            prefixIcon: Icon(Icons.confirmation_number),
                          ),
                          items: _ticketTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type.toUpperCase(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTicketType = value ?? 'single';
                            });
                            _calculateFare(); // Recalculate fare when ticket type changes
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Payment Method
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
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedPaymentMethod,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            prefixIcon: Icon(Icons.payment),
                          ),
                          items: _paymentMethods.map((method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: Text(
                                _getPaymentMethodDisplayName(method),
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value ?? 'digital';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bus status warning
              if (_selectedBus != null && !_selectedBus!.isActive)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.errorColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This bus is currently inactive and not available for booking.',
                          style: TextStyle(
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Compliance warning
              if (_selectedBus != null && !_selectedBus!.isCompliant)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.warningColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: AppTheme.warningColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This bus has compliance issues. Please check with the operator.',
                          style: TextStyle(
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Book Ticket Button
              CustomButton(
                text: _selectedBus != null && !_selectedBus!.isActive
                    ? 'Bus Inactive - Cannot Book'
                    : ticketState.fareCalculation != null
                        ? 'Book Ticket - ₹${(ticketState.fareCalculation!['final_amount'] ?? 0.0).toStringAsFixed(2)}'
                        : 'Calculate Fare First',
                onPressed: (ticketState.isLoading ||
                        (_selectedBus != null && !_selectedBus!.isActive) ||
                        ticketState.fareCalculation == null ||
                        _selectedBoardingStation == null ||
                        _selectedDropStation == null)
                    ? null
                    : _bookTicket,
                isLoading: ticketState.isLoading,
              ),
            ],

            // Error Message with Server Status
            if (busState.error != null || ticketState.error != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.errorColor.withValues(alpha: 0.3)),
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
                            (busState.error ?? ticketState.error ?? '').toString(),
                            style: const TextStyle(
                              color: AppTheme.errorColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Show server status if it's a server issue
                    if ((busState.error ?? ticketState.error ?? '').contains('Server is temporarily unavailable') ||
                        (busState.error ?? ticketState.error ?? '').contains('maintenance')) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.construction,
                              color: Colors.orange,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Server maintenance in progress. Some features may be limited.',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
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
          ],
        ),
      ),
    );
  }
}
