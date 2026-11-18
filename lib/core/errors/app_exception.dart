/// Base class for all application-specific exceptions.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Thrown when device has no internet connection or network is unreachable.
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Please check your network and retry.',
  ]);
}

/// Thrown when an API request times out (connect, send, or receive).
class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'Connection timed out. The server took too long to respond.',
  ]);
}

/// Thrown when the server returns a 5xx error.
class ServerException extends AppException {
  const ServerException([
    super.message = 'Server encountered an error. Please try again later.',
    super.statusCode,
  ]);
}

/// Thrown when client makes an invalid request (400, 422, etc.).
class ClientException extends AppException {
  const ClientException([
    super.message = 'Invalid request. Please try again.',
    super.statusCode,
  ]);
}

/// Thrown when requested resource is not found (404).
class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
  ]);
}

/// Thrown when the response payload cannot be parsed or is in an unexpected format.
class DataParsingException extends AppException {
  const DataParsingException([
    super.message = 'Failed to parse response from server.',
  ]);
}

/// Thrown for unclassified or generic unexpected errors.
class UnexpectedException extends AppException {
  const UnexpectedException([
    super.message = 'An unexpected error occurred. Please try again.',
  ]);
}
