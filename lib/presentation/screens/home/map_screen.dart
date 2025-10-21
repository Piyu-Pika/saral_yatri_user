import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/providers/location_provider.dart';
import '../../../data/providers/bus_provider.dart';
import '../../../data/providers/station_provider.dart';
import '../../widgets/map/bus_marker.dart';
import '../../widgets/map/station_marker.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(19.0760, 72.8777); // Mumbai default

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  Future<void> _initializeMap() async {
    // Get current location
    await ref.read(locationProvider.notifier).getCurrentLocation();

    // Load buses and stations
    ref.read(busProvider.notifier).loadActiveBuses();
    ref.read(stationProvider.notifier).loadActiveStations();
  }

  void _onCurrentLocationPressed() {
    ref.read(locationProvider.notifier).getCurrentLocation();

    final locationState = ref.read(locationProvider);
    if (locationState.currentPosition != null) {
      final pos = locationState.currentPosition!;
      final latLng = LatLng(pos.latitude, pos.longitude);

      _mapController.move(latLng, 15.0);
      setState(() {
        _currentCenter = latLng;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final busState = ref.watch(busProvider);
    final stationState = ref.watch(stationProvider);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 13.0,
              minZoom: 10.0,
              maxZoom: 18.0,
              onTap: (_, __) {
                // Handle map tap
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.saralyatri.app',
              ),
              // Station markers
              MarkerLayer(
                markers: stationState.stations.map((station) {
                  return Marker(
                    point: LatLng(
                      station.location.latitude,
                      station.location.longitude,
                    ),
                    width: 40,
                    height: 40,
                    child: StationMarkerWidget(station: station),
                  );
                }).toList(),
              ),
              // Bus markers
              MarkerLayer(
                markers: busState.buses.map((bus) {
                  return Marker(
                    point: LatLng(
                      bus.currentLocation.latitude,
                      bus.currentLocation.longitude,
                    ),
                    width: 50,
                    height: 50,
                    child: BusMarkerWidget(bus: bus),
                  );
                }).toList(),
              ),
              // Current location marker
              if (locationState.currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        locationState.currentPosition!.latitude,
                        locationState.currentPosition!.longitude,
                      ),
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Loading overlay
          if (locationState.isLoading || busState.isLoading || stationState.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Current location button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _onCurrentLocationPressed,
              child: const Icon(
                Icons.my_location,
                color: AppColors.primary,
              ),
            ),
          ),

          // Map info panel
          const Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap on bus stops to see routes. Tap floating button to book tickets.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
