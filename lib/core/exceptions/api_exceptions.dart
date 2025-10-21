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
  NetworkException(super.message);
}

class AuthException extends ApiException {
  AuthException(super.message) : super(statusCode: 401);
}

class ServerException extends ApiException {
  ServerException(super.message, int statusCode) 
      : super(statusCode: statusCode);
}

class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  ValidationException(super.message, {this.errors});
}
