import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/bus_model.dart';
import '../../providers/bus_provider.dart';
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
  
  final List<String> _paymentMethods = ['digital', 'cash'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        if (args['bus'] != null) {
          setState(() {
            _selectedBus = args['bus'] as BusModel;
          });
          _loadBusStops();
        }
      }
    });
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadBusStops() async {
    if (_selectedBus != null) {
      await ref.read(busProvider.notifier).loadBusStops();
    }
  }

  Future<void> _searchBusByNumber() async {
    if (_busNumberController.text.trim().isEmpty) return;
    
    final bus = await ref.read(busProvider.notifier).getBusByNumber(
      _busNumberController.text.trim(),
    );
    
    if (bus != null) {
      setState(() {
        _selectedBus = bus;
      });
      _loadBusStops();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final busState = ref.watch(busProvider);
    final ticketState = ref.watch(ticketProvider);
    
    final busStops = busState.busStops
        .where((stop) => _selectedBus?.routeId != null && 
                        stop.routeIds.contains(_selectedBus!.routeId))
        .map((stop) => stop.name)
        .toList();

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
                        onPressed: busState.isLoading ? null : _searchBusByNumber,
                        isLoading: busState.isLoading,
                      ),
                    ] else ...[
                      // Selected Bus Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.directions_bus,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Text(
                                    'Available Seats: ${_selectedBus!.availableSeats}',
                                    style: const TextStyle(
                                      color: AppTheme.successColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedBus = null;
                                  _selectedBoardingStop = null;
                                  _selectedDropStop = null;
                                });
                                ref.read(ticketProvider.notifier).clearFareCalculation();
                              },
                              child: const Text('Change'),
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
                      
                      // Boarding Stop
                      CustomDropdown<String>(
                        hintText: 'Select boarding stop',
                        items: busStops,
                        onChanged: (value) {
                          setState(() {
                            _selectedBoardingStop = value;
                          });
                          _calculateFare();
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Drop Stop
                      CustomDropdown<String>(
                        hintText: 'Select drop stop',
                        items: busStops,
                        onChanged: (value) {
                          setState(() {
                            _selectedDropStop = value;
                          });
                          _calculateFare();
                        },
                      ),
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
                      
                      CustomDropdown<String>(
                        hintText: 'Select payment method',
                        items: _paymentMethods,
                        initialItem: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value ?? 'digital';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Book Ticket Button
              CustomButton(
                text: 'Book Ticket',
                onPressed: ticketState.isLoading ? null : _bookTicket,
                isLoading: ticketState.isLoading,
              ),
            ],
            
            // Error Message
            if (busState.error != null || ticketState.error != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
                ),
                child: Text(
                  busState.error ?? ticketState.error ?? '',
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