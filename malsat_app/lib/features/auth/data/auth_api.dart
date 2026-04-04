import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_exception.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  /// Send OTP to phone number.
  /// Returns normalized phone on success.
  Future<String> login(String phone) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'phone': phone},
      );
      return response.data['phone'] as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Verify OTP code.
  /// Returns {accessToken, refreshToken, user} on success.
  Future<Map<String, dynamic>> verify(String phone, String code) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verify,
        data: {'phone': phone, 'code': code},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Refresh access token using refresh token.
  /// Returns new access token.
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );
      return response.data['accessToken'] as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message =
        (e.response?.data is Map) ? e.response?.data['error'] as String? : null;

    if (statusCode != null) {
      return ApiException.fromStatusCode(statusCode, message);
    }
    return ApiException(e.message ?? 'Network error');
  }
}
