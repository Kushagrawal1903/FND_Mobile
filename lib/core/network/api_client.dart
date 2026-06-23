import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/core/config/environment.dart';
import 'package:truthlens/core/storage/secure_storage_service.dart';
import 'package:truthlens/core/network/api_exceptions.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage);
});

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;

  ApiClient(this._secureStorage) {
    _dio = Dio(BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await _secureStorage.clearAll();
            // In a full implementation, you would trigger a re-auth event or 
            // Riverpod state invalidation to push the user to the login screen.
          }
          return handler.next(_handleDioError(e));
        },
      ),
    );
  }

  DioException _handleDioError(DioException error) {
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out';
        throw NetworkException(message);
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null) {
          final data = response.data;
          final errorMsg = data is Map ? data['message'] : 'Server error';
          
          if (response.statusCode == 401) {
            throw UnauthorizedException(errorMsg ?? 'Unauthorized');
          } else if (response.statusCode == 400) {
            throw ValidationException(errorMsg ?? 'Invalid request');
          } else {
            throw ApiException(errorMsg ?? 'Server error', response.statusCode);
          }
        }
        throw ServerException('Unknown server error');
      case DioExceptionType.cancel:
        throw ApiException('Request cancelled');
      case DioExceptionType.connectionError:
        throw NetworkException('No internet connection');
      default:
        throw ApiException('Something went wrong');
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }
}
