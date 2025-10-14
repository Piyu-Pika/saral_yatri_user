import 'package:dev_log/dev_log.dart';

class AppLogger {
  static void info(String message) {
    Log.i(message);
  }

  static void warning(String message) {
    Log.w(message);
  }

  static void error(String message) {
    Log.e(message);
  }

  static void debug(String message) {
    Log.d(message);
  }
}