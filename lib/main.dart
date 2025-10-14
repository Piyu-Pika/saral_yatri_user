import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';
import 'app.dart';
import 'core/services/permission_service.dart';
import 'core/services/storage_service.dart';
import 'core/network/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await StorageService.init();
  ApiClient.init();
  
  // Initialize screen protection
  await ScreenProtector.protectDataLeakageOn();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Request permissions
  await PermissionService.requestAllPermissions();
  
  runApp(
    const ProviderScope(
      child: SaralYatriApp(),
    ),
  );
}