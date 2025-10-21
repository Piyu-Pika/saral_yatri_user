import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/location_service.dart';
import '../../providers/auth_provider.dart';
import '../../../data/providers/bus_provider.dart';
import '../../widgets/booking_options_drawer.dart';
import '../../widgets/bus_marker.dart';
import '../../widgets/bus_stop_marker.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final MapController _mapController = MapController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  LatLng _currentLocation = const LatLng(28.6139, 77.2090); // Default Delhi
  bool _isLocationLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadData();
  }

  Future<void> _initializeLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLocationLoaded = true;
      });
      
      // Move map to current location
      _mapController.move(_currentLocation, 15.0);
      
      // Load nearby buses
      ref.read(busProvider.notifier).loadNearbyBuses(
        position.latitude,
        position.longitude,
      );
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      ref.read(busProvider.notifier).loadAllBuses(),
      ref.read(busProvider.notifier).loadBusStops(),
    ]);
  }

  void _openBookingOptions() {
    _scaffoldKey.currentState?.openDrawer();
  }

  // // Debug method to test API logging
  // void _testApiCall() async {
  //   try {
  //     // Test API call to see logging in action
  //     await ref.read(busProvider.notifier).loadAllBuses();
      
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('API test completed - check logs!'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('API test failed: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final busState = ref.watch(busProvider);
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Saral Yatri'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _openBookingOptions,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _initializeLocation,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authProvider.notifier).logout();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (context) => [
               PopupMenuItem(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                },
                value: 'profile',
                child: const ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                ),
              ),
              PopupMenuItem(
                onTap: (){
                  Navigator.pushNamed(context, '/ticket');
                },
                value: 'tickets',
                child: const ListTile(
                  leading: Icon(Icons.confirmation_number),
                  title: Text('My Tickets'),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const BookingOptionsDrawer(),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15.0,
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              // Tile Layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.saralyatri.app',
              ),
              
              // Bus Stop Markers
              MarkerLayer(
                markers: busState.busStops.map((busStop) {
                  return Marker(
                    point: busStop.location,
                    width: 40,
                    height: 40,
                    child: BusStopMarker(busStop: busStop),
                  );
                }).toList(),
              ),
              
              // Bus Markers
              MarkerLayer(
                markers: busState.buses.map((bus) {
                  return Marker(
                    point: bus.currentLocation,
                    width: 50,
                    height: 50,
                    child: BusMarker(bus: bus),
                  );
                }).toList(),
              ),
              
              // Current Location Marker
              if (_isLocationLoaded)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          // Welcome Card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome, ${authState.user?.username ?? 'User'}!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Find buses and book your tickets easily',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Quick Actions
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'qr_scan',
                  onPressed: () {
                    Navigator.pushNamed(context, '/qr-scanner');
                  },
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'tickets',
                  onPressed: () {
                    Navigator.pushNamed(context, '/my-tickets');
                  },
                  backgroundColor: AppTheme.secondaryColor,
                  child: const Icon(Icons.confirmation_number, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Loading Indicator
          if (busState.isLoading)
            const Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Loading buses...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}