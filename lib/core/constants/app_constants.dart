class AppConstants {
  // API
  static const String baseUrl = 'https://unprophesied-emerson-unrubrically.ngrok-free.dev/api';
  static const String apiVersion = '/v1';

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String busesEndpoint = '/buses';
  static const String routesEndpoint = '/routes';
  static const String ticketsEndpoint = '/tickets';
  static const String bookingEndpoint = '/bookings';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // App Info
  static const String appName = 'Saral Yatri';
  static const String appVersion = '1.0.0';

  // Ticket Expiry
  static const int ticketExpiryHours = 24;

  // Map
  static const double defaultZoom = 15.0;
  static const double defaultLatitude = 28.6139;
  static const double defaultLongitude = 77.2090;

  // QR Code
  static const int qrCodeSize = 200;
  static const String expiredText = 'EXPIRED';
}
