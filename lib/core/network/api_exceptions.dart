class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'Network connection failed']);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized access']) : super(message, 401);
}

class ValidationException extends ApiException {
  ValidationException([String message = 'Invalid data provided']) : super(message, 400);
}

class ServerException extends ApiException {
  ServerException([String message = 'Internal server error']) : super(message, 500);
}
