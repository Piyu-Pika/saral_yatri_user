import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/bus_model.dart';
import '../../../data/providers/bus_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/fare_breakdown_card.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _busNumberController = TextEditingController();
  BusModel? _selectedBus;
  String? _selectedBoardingStop;
  String? _selectedDropStop;
  String _selectedPaymentMethod = 'digital';
  bool _isBusInfoExpanded = false;

  final List<String> _paymentMethods = ['digital', 'cash'];

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
        _selectedBoardingStop != null &&
        _selectedDropStop != null) {
      await ref.read(ticketProvider.notifier).calculateFare(
            busId: _selectedBus!.id,
            boardingStop: _selectedBoardingStop!,
            droppingStop: _selectedDropStop!,
          );
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

  Future<void> _bookTicket() async {
    if (_selectedBus == null ||
        _selectedBoardingStop == null ||
        _selectedDropStop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final success = await ref.read(ticketProvider.notifier).bookTicket(
          busId: _selectedBus!.id,
          boardingStop: _selectedBoardingStop!,
          droppingStop: _selectedDropStop!,
          paymentMethod: _selectedPaymentMethod,
        );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/ticket');
    } else if (!success && mounted) {
      // Show error message if booking failed
      final currentState = ref.read(ticketProvider);
      final errorMessage = currentState.error ?? 'Failed to book ticket';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final busState = ref.watch(busProvider);
    final ticketState = ref.watch(ticketProvider);

    // Get route stations sorted by sequence
    final routeStations =
        busState.routeStations.map((station) => station.name).toList();

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
                                          Text(
                                            'Bus ${_selectedBus!.busNumber}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
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
                                                            .availableSeats >
                                                        0
                                                    ? AppTheme.successColor
                                                    : AppTheme.errorColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${_selectedBus!.availableSeats}/${_selectedBus!.totalSeats} seats available',
                                                style: TextStyle(
                                                  color: _selectedBus!
                                                              .availableSeats >
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
                                    // Bus Status
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
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Driver and Conductor Info
                                    if (_selectedBus!
                                        .driverName.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            size: 16,
                                            color: AppTheme.textSecondary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Driver: ${_selectedBus!.driverName}',
                                            style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                    ],

                                    if (_selectedBus!
                                        .conductorName.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person_outline,
                                            size: 16,
                                            color: AppTheme.textSecondary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Conductor: ${_selectedBus!.conductorName}',
                                            style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],

                                    // Last Updated
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
                                                _selectedBoardingStop = null;
                                                _selectedDropStop = null;
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

                      // Loading indicator for stations
                      if (busState.isLoadingStations)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (routeStations.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No stations found for this route. Please try again.',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Boarding Stop Dropdown
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedBoardingStop,
                            hint: const Text('Select boarding stop'),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            items: routeStations.map((station) {
                              return DropdownMenuItem<String>(
                                value: station,
                                child: Text(
                                  station,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBoardingStop = value;
                                // Clear drop stop if it's the same as boarding stop
                                if (_selectedDropStop == value) {
                                  _selectedDropStop = null;
                                }
                              });
                              _calculateFare();
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Drop Stop Dropdown
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedDropStop,
                            hint: const Text('Select drop stop'),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              prefixIcon: Icon(Icons.location_off),
                            ),
                            items: routeStations
                                .where((station) =>
                                    station != _selectedBoardingStop)
                                .map((station) {
                              return DropdownMenuItem<String>(
                                value: station,
                                child: Text(
                                  station,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDropStop = value;
                              });
                              _calculateFare();
                            },
                          ),
                        ),

                        // Show route info
                        if (_selectedBoardingStop != null ||
                            _selectedDropStop != null)
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Fare Breakdown
              if (ticketState.fareCalculation != null)
                FareBreakdownCard(fareData: ticketState.fareCalculation!),

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
                          value: _selectedPaymentMethod,
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
                                method.toUpperCase(),
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

              // Seat availability warning
              if (_selectedBus != null && _selectedBus!.availableSeats == 0)
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
                          'This bus is fully booked. No seats available.',
                          style: TextStyle(
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Book Ticket Button
              CustomButton(
                text: _selectedBus != null && _selectedBus!.availableSeats == 0
                    ? 'Bus Full - Cannot Book'
                    : 'Book Ticket',
                onPressed: (ticketState.isLoading ||
                        (_selectedBus != null &&
                            _selectedBus!.availableSeats == 0))
                    ? null
                    : _bookTicket,
                isLoading: ticketState.isLoading,
              ),
            ],

            // Error Message
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
      ),
    );
  }
}
