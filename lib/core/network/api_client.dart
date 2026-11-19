import 'package:dio/dio.dart';
import 'package:mallow_news_app/core/constants/app_constants.dart';
import 'package:mallow_news_app/core/errors/app_exception.dart';
class ApiClient {
  late final Dio _dio;

  ApiClient({Dio? dio}) {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            headers: {'Accept': 'application/json'},
          ),
        );
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        endpoint,
        queryParameters: queryParameters,
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }

      throw const DataParsingException('Invalid API response format.');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnexpectedException(e.toString());
    }
  }

  AppException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return const NotFoundException();
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(
            'Server error ($statusCode). Please try again later.',
            statusCode,
          );
        } else if (statusCode != null && statusCode >= 400) {
          return ClientException(
            'Request error ($statusCode). Please verify and try again.',
            statusCode,
          );
        }
        return UnexpectedException(
          'Received invalid status code: $statusCode',
        );

      case DioExceptionType.cancel:
        return const UnexpectedException('Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException('Security certificate verification failed.');

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return const NetworkException();
        }
        return UnexpectedException(
          error.message ?? 'An unknown network error occurred.',
        );
    }
  }
}
