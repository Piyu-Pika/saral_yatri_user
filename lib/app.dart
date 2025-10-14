import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/booking/booking_screen.dart';
import 'presentation/screens/ticket/ticket_screen.dart';
import 'presentation/screens/qr_demo_screen.dart';
import 'presentation/screens/conductor/ticket_verification_screen.dart';

class SaralYatriApp extends ConsumerWidget {
  const SaralYatriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Saral Yatri',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/booking': (context) => const BookingScreen(),
        '/ticket': (context) => const TicketScreen(),
        '/qr-demo': (context) => const QRDemoScreen(),
        '/conductor-verify': (context) => const TicketVerificationScreen(),
      },
    );
  }
}