import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/station_model.dart';

class StationMarkerWidget extends StatelessWidget {
  final StationModel station;

  const StationMarkerWidget({
    super.key,
    required this.station,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showStationInfo(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.stationMarker,
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
          Icons.location_on,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _showStationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(station.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${station.code}'),
            Text('Route ID: ${station.routeId}'),
            Text('Sequence: ${station.sequence}'),
            Text(
                'Location: ${station.location.latitude.toStringAsFixed(4)}, ${station.location.longitude.toStringAsFixed(4)}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  station.isActive ? Icons.check_circle : Icons.cancel,
                  color: station.isActive ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  station.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: station.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
