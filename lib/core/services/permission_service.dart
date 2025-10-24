import 'package:permission_handler/permission_handler.dart';
import 'package:dev_log/dev_log.dart';

class PermissionService {
  static Future<void> requestAllPermissions() async {
    try {
      // Request location permission
      await _requestLocationPermission();

      // Request camera permission
      await _requestCameraPermission();

      // Request notification permission
      await _requestNotificationPermission();
    } catch (e) {
      Log.e('Error requesting permissions: $e');
    }
  }

  static Future<bool> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      Log.i('Location permission granted');
      return true;
    } else {
      Log.w('Location permission denied');
      return false;
    }
  }

  static Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      Log.i('Camera permission granted');
      return true;
    } else {
      Log.w('Camera permission denied');
      return false;
    }
  }

  static Future<bool> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      Log.i('Notification permission granted');
      return true;
    } else {
      Log.w('Notification permission denied');
      return false;
    }
  }

  static Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }

  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }
}
