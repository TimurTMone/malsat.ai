import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_exception.dart';

class UserApi {
  final Dio _dio;

  UserApi(this._dio);

  /// Get public user profile with listings, reviews, and counts.
  Future<Map<String, dynamic>> getUser(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.user(id));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message =
        (e.response?.data is Map) ? e.response?.data['error'] as String? : null;
    if (statusCode != null) {
      return ApiException.fromStatusCode(statusCode, message);
    }
    return ApiException(e.message ?? 'Network error');
  }
}
