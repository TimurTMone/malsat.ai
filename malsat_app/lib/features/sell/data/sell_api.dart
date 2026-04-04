import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_exception.dart';

class SellApi {
  final Dio _dio;

  SellApi(this._dio);

  /// Create a new listing.
  Future<Map<String, dynamic>> createListing({
    required String category,
    required String title,
    required int priceKgs,
    String? subcategory,
    String? breed,
    String? description,
    int? ageMonths,
    double? weightKg,
    String? gender,
    String? healthStatus,
    bool hasVetCert = false,
    double? locationLat,
    double? locationLng,
    String? regionId,
    String? village,
  }) async {
    try {
      final data = <String, dynamic>{
        'category': category,
        'title': title,
        'priceKgs': priceKgs,
      };
      if (subcategory != null) data['subcategory'] = subcategory;
      if (breed != null) data['breed'] = breed;
      if (description != null) data['description'] = description;
      if (ageMonths != null) data['ageMonths'] = ageMonths;
      if (weightKg != null) data['weightKg'] = weightKg;
      if (gender != null) data['gender'] = gender;
      if (healthStatus != null) data['healthStatus'] = healthStatus;
      if (hasVetCert) data['hasVetCert'] = true;
      if (locationLat != null) data['locationLat'] = locationLat;
      if (locationLng != null) data['locationLng'] = locationLng;
      if (regionId != null) data['regionId'] = regionId;
      if (village != null) data['village'] = village;

      final response = await _dio.post(ApiEndpoints.listings, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload a file and optionally attach it to a listing.
  /// Returns {mediaUrl, mediaType} or {id, mediaUrl, mediaType, isPrimary, sortOrder}.
  Future<Map<String, dynamic>> uploadMedia({
    required String filePath,
    required String fileName,
    String? listingId,
    bool isPrimary = false,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        if (listingId != null) 'listingId': listingId,
        'isPrimary': isPrimary.toString(),
      });

      final response = await _dio.post(
        ApiEndpoints.upload,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
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
