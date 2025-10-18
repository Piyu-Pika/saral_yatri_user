class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() {
    return 'ApiException: $message';
  }
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class AuthException extends ApiException {
  AuthException(String message) : super(message, statusCode: 401);
}

class ServerException extends ApiException {
  ServerException(String message, int statusCode) 
      : super(message, statusCode: statusCode);
}

class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  ValidationException(String message, {this.errors}) : super(message);
}
