import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/bus_model.dart';
import '../../../data/models/station_model.dart';
import '../../../data/providers/station_provider.dart';
import '../../../data/providers/route_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/booking/station_dropdown.dart';
import '../../widgets/booking/fare_display.dart';
import 'ticket_booking_form_screen.dart';

class StationSelectionScreen extends ConsumerStatefulWidget {
  final BusModel? selectedBus;
  final String? busQRData;
  final String? conductorQRData;

  const StationSelectionScreen({
    super.key,
    this.selectedBus,
    this.busQRData,
    this.conductorQRData,
  });

  @override
  ConsumerState<StationSelectionScreen> createState() =>
      _StationSelectionScreenState();
}

class _StationSelectionScreenState
    extends ConsumerState<StationSelectionScreen> {
  StationModel? _selectedBoardingStation;
  StationModel? _selectedDestinationStation;
  bool _isCalculatingFare = false;
  double? _calculatedFare;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStations();
    });
  }

  Future<void> _loadStations() async {
    final stationNotifier = ref.read(stationProvider.notifier);
    await stationNotifier.loadActiveStations();

    if (widget.selectedBus?.routeId != null) {
      final routeNotifier = ref.read(routeProvider.notifier);
      await routeNotifier.loadRouteStations(widget.selectedBus!.routeId);
    }
  }

  Future<void> _calculateFare() async {
    if (_selectedBoardingStation == null ||
        _selectedDestinationStation == null) {
      return;
    }

    setState(() {
      _isCalculatingFare = true;
    });

    try {
      final routeNotifier = ref.read(routeProvider.notifier);
      final fare = await routeNotifier.calculateFare(
        fromStationId: _selectedBoardingStation!.id ?? '',
        toStationId: _selectedDestinationStation!.id ?? '',
        routeId: widget.selectedBus?.routeId ?? '',
      );

      setState(() {
        _calculatedFare = fare;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error calculating fare: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isCalculatingFare = false;
      });
    }
  }

  void _proceedToBooking() {
    if (_selectedBoardingStation == null ||
        _selectedDestinationStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both boarding and destination stations'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TicketBookingFormScreen(
          bus: widget.selectedBus!,
          boardingStation: _selectedBoardingStation!,
          destinationStation: _selectedDestinationStation!,
          calculatedFare: _calculatedFare ?? 0.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stationState = ref.watch(stationProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Select Stations',
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bus information card
            if (widget.selectedBus != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.directions_bus,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.selectedBus!.busNumber,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${widget.selectedBus!.routeName} • ${widget.selectedBus!.totalSeats} seats',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.selectedBus!.isActive ? 'ACTIVE' : 'INACTIVE',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
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

            const SizedBox(height: 24),

            // Station selection
            if (stationState.isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              // Boarding station dropdown
              StationDropdown(
                label: 'Boarding Station',
                hintText: 'Select where you will board the bus',
                selectedStation: _selectedBoardingStation,
                onChanged: (station) {
                  setState(() {
                    _selectedBoardingStation = station;
                  });
                  _calculateFare();
                },
              ),

              const SizedBox(height: 20),

              // Arrow indicator
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_downward,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Destination station dropdown
              StationDropdown(
                label: 'Destination Station',
                hintText: 'Select where you will get off',
                selectedStation: _selectedDestinationStation,
                excludeStationIds: _selectedBoardingStation?.id != null 
                    ? [_selectedBoardingStation!.id!] 
                    : null,
                onChanged: (station) {
                  setState(() {
                    _selectedDestinationStation = station;
                  });
                  _calculateFare();
                },
              ),
            ],

            const SizedBox(height: 24),

            // Fare calculation
            if (_isCalculatingFare)
              const Center(child: CircularProgressIndicator())
            else if (_calculatedFare != null)
              FareDisplay(
                originalFare: _calculatedFare!,
                subsidyAmount: 0,
                finalFare: _calculatedFare!,
                showBreakdown: false,
              ),

            const Spacer(),

            // Proceed button
            CustomButton(
              onPressed: _selectedBoardingStation != null &&
                      _selectedDestinationStation != null
                  ? _proceedToBooking
                  : null,
              text: 'Proceed to Booking',
              icon: Icons.arrow_forward,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
