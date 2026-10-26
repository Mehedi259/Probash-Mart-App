import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../../data/services/storage_service.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;
  String _baseUrl = AppConstants.defaultBaseUrl;

  String get baseUrl => _baseUrl;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void updateBaseUrl(String newUrl) {
    _baseUrl = newUrl;
    _dio.options.baseUrl = newUrl;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = StorageService().accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Try refresh token once
            final refreshToken = StorageService().refreshToken;
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                final refreshResponse = await _dio.post(
                  ApiEndpoints.refreshToken,
                  data: {'refresh': refreshToken},
                  options: Options(headers: {'Authorization': null}),
                );
                if (refreshResponse.statusCode == 200) {
                  final newAccess = refreshResponse.data['access'];
                  await StorageService().saveTokens(
                    access: newAccess,
                    refresh: refreshToken,
                  );
                  // Retry original request
                  final retryOptions = error.requestOptions;
                  retryOptions.headers['Authorization'] = 'Bearer $newAccess';
                  final retryResponse = await _dio.fetch(retryOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (_) {
                await StorageService().clearAuth();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Helper to convert relative or mismatched backend image URLs
  /// to the current host so images load smoothly on both emulator & device.
  String resolveImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return '';
    if (rawUrl.startsWith('assets/')) return rawUrl;

    if (rawUrl.startsWith('http')) {
      // Replace localhost/127.0.0.1 or server IP with current active baseUrl if needed
      final uri = Uri.tryParse(rawUrl);
      if (uri != null) {
        if (uri.host == '127.0.0.1' || uri.host == 'localhost' || uri.host == '10.0.2.2' || uri.host == '46.225.103.236') {
          final currentBase = Uri.parse(_baseUrl);
          return uri.replace(
            scheme: currentBase.scheme,
            host: currentBase.host,
            port: currentBase.port,
          ).toString();
        }
      }
      return rawUrl;
    }

    // Relative url
    final cleanPath = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
    return '$_baseUrl$cleanPath';
  }

  // --- HTTP Methods ---

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
