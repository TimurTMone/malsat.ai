import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_exception.dart';

class FavoritesApi {
  final Dio _dio;

  FavoritesApi(this._dio);

  /// Get all favorites for the current user.
  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final response = await _dio.get(ApiEndpoints.favorites);
      return (response.data as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Toggle favorite. Returns true if favorited, false if unfavorited.
  Future<bool> toggleFavorite(String listingId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.favorites,
        data: {'listingId': listingId},
      );
      return response.data['favorited'] as bool;
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
