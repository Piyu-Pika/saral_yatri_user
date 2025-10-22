import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/qr_scanner/qr_scanner_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/booking/booking_screen.dart';
import 'presentation/screens/booking/payment_screen.dart';
import 'presentation/screens/ticket/my_tickets_screen.dart';
import 'presentation/screens/ticket/ticket_screen.dart';
import 'presentation/screens/ticket/qr_ticket_screen.dart';
import 'presentation/screens/booking/booking_history_screen.dart';
import 'presentation/screens/profile/help_support_screen.dart';
import 'presentation/screens/profile/about_screen.dart';
import 'presentation/screens/debug/api_diagnostic_screen.dart';
import 'core/services/mock_ticket_service.dart';

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
        '/payment': (context) => const PaymentScreen(),
        '/my-tickets': (context) => const MyTicketsScreen(),
        '/ticket': (context) => const TicketScreen(),
        '/qr-ticket-demo': (context) => QrTicketScreen(
          ticket: MockTicketService.createMockEnhancedTicket(),
        ),
        '/qr-ticket': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final ticket = args?['ticket'];
          if (ticket != null) {
            return QrTicketScreen(ticket: ticket);
          }
          // Fallback to demo ticket if no ticket provided
          return QrTicketScreen(
            ticket: MockTicketService.createMockEnhancedTicket(),
          );
        },
        '/qr-scanner': (context) => const QRScannerScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/booking-history': (context) => const BookingHistoryScreen(),
        '/help-support': (context) => const HelpSupportScreen(),
        '/about': (context) => const AboutScreen(),
        '/api-diagnostics': (context) => const ApiDiagnosticScreen(),
        // '/conductor-verify': (context) => const TicketVerificationScreen(),
      },
    );
  }
}