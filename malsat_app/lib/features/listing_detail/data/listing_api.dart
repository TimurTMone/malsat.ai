import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../domain/listing_model.dart';

class ListingApi {
  final Dio _dio;

  ListingApi(this._dio);

  Future<ListingsResponse> getListings({
    String? category,
    int? minPrice,
    int? maxPrice,
    String? regionId,
    String? breed,
    String? gender,
    String sort = 'newest',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'sort': sort,
        'page': page,
        'limit': limit,
      };
      if (category != null) queryParams['category'] = category;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (regionId != null) queryParams['regionId'] = regionId;
      if (breed != null) queryParams['breed'] = breed;
      if (gender != null) queryParams['gender'] = gender;

      final response = await _dio.get(
        ApiEndpoints.listings,
        queryParameters: queryParams,
      );
      return ListingsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ListingModel> getListing(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.listing(id));
      return ListingModel.fromJson(response.data as Map<String, dynamic>);
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
