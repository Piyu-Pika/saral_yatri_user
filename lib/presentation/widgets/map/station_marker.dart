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
        title: Text(station.stationName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${station.stationCode}'),
            Text('Type: ${station.stationType.toUpperCase()}'),
            Text('Address: ${station.address.city}, ${station.address.state}'),
            if (station.accessibility.wheelchairAccess)
              const Text('• Wheelchair Accessible'),
            if (station.facilities.waitingArea)
              const Text('• Waiting Area'),
            if (station.facilities.restrooms)
              const Text('• Restrooms'),
            if (station.facilities.wifi)
              const Text('• WiFi Available'),
            const SizedBox(height: 8),
            Text('Hours: ${station.operatingHours.startTime} - ${station.operatingHours.endTime}'),
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
