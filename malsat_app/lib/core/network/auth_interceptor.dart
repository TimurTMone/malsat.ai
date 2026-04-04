import 'dart:async';
import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import '../constants/api_endpoints.dart';

/// Dio interceptor that:
/// 1. Attaches Bearer token to every request
/// 2. On 401, attempts token refresh and retries the original request
/// 3. If refresh fails, clears tokens and calls onAuthExpired callback
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  final void Function()? onAuthExpired;

  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  /// Endpoints that should NOT have auth headers attached
  static const _publicEndpoints = [
    ApiEndpoints.login,
    ApiEndpoints.verify,
    ApiEndpoints.refresh,
  ];

  AuthInterceptor({
    required Dio dio,
    required TokenStorage tokenStorage,
    this.onAuthExpired,
  })  : _dio = dio,
        _tokenStorage = tokenStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    if (_publicEndpoints.contains(options.path)) {
      return handler.next(options);
    }

    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't retry auth endpoints
    if (_publicEndpoints.contains(err.requestOptions.path)) {
      return handler.next(err);
    }

    // Attempt token refresh
    final newToken = await _tryRefreshToken();
    if (newToken == null) {
      // Refresh failed — user must re-login
      await _tokenStorage.clearTokens();
      onAuthExpired?.call();
      return handler.next(err);
    }

    // Retry original request with new token
    try {
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newToken';
      final response = await _dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  /// Ensures only one refresh happens at a time.
  /// Concurrent 401s wait for the same refresh result.
  Future<String?> _tryRefreshToken() async {
    if (_isRefreshing) {
      // Wait for the in-flight refresh
      return _refreshCompleter?.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        _refreshCompleter!.complete(null);
        return null;
      }

      final response = await _dio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'] as String;
      await _tokenStorage.saveAccessToken(newAccessToken);
      _refreshCompleter!.complete(newAccessToken);
      return newAccessToken;
    } catch (_) {
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }
}
