import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          ApiConstants.contentTypeHeader: ApiConstants.contentTypeJson,
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests
          final token = await _storage.read(key: ApiConstants.accessTokenKey);
          if (token != null) {
            options.headers[ApiConstants.authorizationHeader] = 'Bearer $token';
          }

          // Log request
          print('🌐 REQUEST[${options.method}] => ${options.uri}');
          if (options.data != null) {
            print('📤 Data: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response
          print('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
          print('📥 Data: ${response.data}');

          return handler.next(response);
        },
        onError: (error, handler) async {
          // Log error
          print('❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
          print('📛 Message: ${error.message}');
          print('📛 Response: ${error.response?.data}');

          // Handle token expiry
          if (error.response?.statusCode == 401) {
            // Try to refresh token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the request
              final options = error.requestOptions;
              final token = await _storage.read(key: ApiConstants.accessTokenKey);
              options.headers[ApiConstants.authorizationHeader] = 'Bearer $token';

              try {
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: ApiConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _storage.write(
          key: ApiConstants.accessTokenKey,
          value: data['access_token'] as String,
        );

        // Calculate and store expiry time
        final expiresIn = data['expires_in'] as int;
        final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
        await _storage.write(
          key: ApiConstants.tokenExpiryKey,
          value: expiryTime.toIso8601String(),
        );

        return true;
      }
    } catch (e) {
      print('Failed to refresh token: $e');
    }
    return false;
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Upload file
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?data,
      });

      return await _dio.post(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(DioException error) {
    String message;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '连接超时，请检查网络连接';
        break;
      case DioExceptionType.badResponse:
        message = _extractErrorMessage(error.response);
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        break;
      case DioExceptionType.connectionError:
        message = '网络连接失败，请检查网络设置';
        break;
      default:
        message = '发生未知错误: ${error.message}';
    }

    return ApiException(message, error.response?.statusCode);
  }

  String _extractErrorMessage(Response? response) {
    if (response == null) return '服务器响应错误';

    try {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? '服务器响应错误';
      }
    } catch (e) {
      // Ignore parsing errors
    }

    return '服务器响应错误 (${response.statusCode})';
  }

  // Clear tokens (for logout)
  Future<void> clearTokens() async {
    await _storage.delete(key: ApiConstants.accessTokenKey);
    await _storage.delete(key: ApiConstants.refreshTokenKey);
    await _storage.delete(key: ApiConstants.tokenExpiryKey);
    await _storage.delete(key: ApiConstants.userDataKey);
  }

  // Check if token is valid
  Future<bool> isTokenValid() async {
    final token = await _storage.read(key: ApiConstants.accessTokenKey);
    if (token == null) return false;

    final expiryStr = await _storage.read(key: ApiConstants.tokenExpiryKey);
    if (expiryStr == null) return false;

    final expiry = DateTime.parse(expiryStr);
    return DateTime.now().isBefore(expiry);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}
