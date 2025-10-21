class ApiConstants {
  // Base Configuration
  static const String baseUrl = 'https://unprophesied-emerson-unrubrically.ngrok-free.dev/api/v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Authentication Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String subsidyEligibility = '/auth/subsidy-eligibility';

  // Bus Endpoints
  static const String activeBuses = '/buses/active';
  static const String busById = '/buses';
  static const String busByRoute = '/buses';
  static const String busByQrCode = '/buses/qr-lookup';

  // Route Endpoints
  static const String activeRoutes = '/routes/active';
  static const String routeById = '/routes';
  static const String routeFare = '/routes/fare';
  static const String routeStations = '/routes'; // /routes/{route_id}/stations

  // Station Endpoints
  static const String activeStations = '/stations/active';
  static const String stationById = '/stations';
  static const String searchStations = '/stations/search';
  static const String nearbyStations = '/stations/nearby';

  // Ticket Endpoints
  static const String bookTicket = '/tickets/passenger/book';
  static const String myTickets = '/tickets/passenger/my-tickets';
  static const String ticketDetails = '/tickets/passenger';
  static const String calculateFare = '/tickets/calculate-fare';

  // Headers
  static const String authHeader = 'Authorization';
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String bearerPrefix = 'Bearer';
}
