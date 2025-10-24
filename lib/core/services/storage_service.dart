import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> setString(String key, String value) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return await _prefs!.setString(key, value);
    } catch (e) {
      print('Error setting string: $e');
      return false;
    }
  }

  static String? getString(String key) {
    try {
      return _prefs?.getString(key);
    } catch (e) {
      print('Error getting string: $e');
      return null;
    }
  }

  static Future<bool> setBool(String key, bool value) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return await _prefs!.setBool(key, value);
    } catch (e) {
      print('Error setting bool: $e');
      return false;
    }
  }

  static bool? getBool(String key) {
    try {
      return _prefs?.getBool(key);
    } catch (e) {
      print('Error getting bool: $e');
      return null;
    }
  }

  static Future<bool> setObject(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      print('Error setting object: $e');
      return false;
    }
  }

  static Map<String, dynamic>? getObject(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting object: $e');
      return null;
    }
  }

  static Future<bool> remove(String key) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return await _prefs!.remove(key);
    } catch (e) {
      print('Error removing key: $e');
      return false;
    }
  }

  static Future<bool> clear() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return await _prefs!.clear();
    } catch (e) {
      print('Error clearing storage: $e');
      return false;
    }
  }
}
