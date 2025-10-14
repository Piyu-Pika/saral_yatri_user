import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/bus_model.dart';

class BusMarkerWidget extends StatelessWidget {
  final BusModel bus;

  const BusMarkerWidget({
    super.key,
    required this.bus,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showBusInfo(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _getBusColor(),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.directions_bus,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Color _getBusColor() {
    if (bus.isActive) {
      return AppColors.success;
    } else {
      return AppColors.error;
    }
  }

  void _showBusInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bus.busNumber),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Route: ${bus.routeName}'),
            Text('Driver: ${bus.driverName}'),
            Text('Conductor: ${bus.conductorName}'),
            Text('Status: ${bus.isActive ? 'ACTIVE' : 'INACTIVE'}'),
            Text('Capacity: ${bus.totalSeats} seats'),
            Text('Available: ${bus.availableSeats} seats'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
