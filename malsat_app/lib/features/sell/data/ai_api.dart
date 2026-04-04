import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_exception.dart';

class AiAnalysisResult {
  final String? category;
  final String? breed;
  final String? gender;
  final int? estimatedAgeMonths;
  final double? estimatedWeightKg;
  final String? healthStatus;
  final String? title;
  final String? description;
  final int? suggestedPriceKgs;
  final String confidence;

  AiAnalysisResult({
    this.category,
    this.breed,
    this.gender,
    this.estimatedAgeMonths,
    this.estimatedWeightKg,
    this.healthStatus,
    this.title,
    this.description,
    this.suggestedPriceKgs,
    this.confidence = 'low',
  });

  factory AiAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AiAnalysisResult(
      category: json['category'] as String?,
      breed: json['breed'] as String?,
      gender: json['gender'] as String?,
      estimatedAgeMonths: json['estimatedAgeMonths'] as int?,
      estimatedWeightKg: (json['estimatedWeightKg'] as num?)?.toDouble(),
      healthStatus: json['healthStatus'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      suggestedPriceKgs: json['suggestedPriceKgs'] as int?,
      confidence: json['confidence'] as String? ?? 'low',
    );
  }
}

class PhotoQualityResult {
  final bool animalDetected;
  final String? animalType;
  final String backgroundQuality;
  final String lightingQuality;
  final List<String> suggestedEdits;
  final int overallScore;

  PhotoQualityResult({
    this.animalDetected = false,
    this.animalType,
    this.backgroundQuality = 'messy',
    this.lightingQuality = 'poor',
    this.suggestedEdits = const [],
    this.overallScore = 5,
  });

  factory PhotoQualityResult.fromJson(Map<String, dynamic> json) {
    return PhotoQualityResult(
      animalDetected: json['animalDetected'] as bool? ?? false,
      animalType: json['animalType'] as String?,
      backgroundQuality: json['backgroundQuality'] as String? ?? 'messy',
      lightingQuality: json['lightingQuality'] as String? ?? 'poor',
      suggestedEdits: (json['suggestedEdits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      overallScore: json['overallScore'] as int? ?? 5,
    );
  }

  bool get needsEnhancement => overallScore < 7;
}

class AiApi {
  final Dio _dio;

  AiApi(this._dio);

  /// Analyze a livestock photo with Claude Vision.
  /// Returns category, breed, title, description, price suggestion.
  Future<AiAnalysisResult> analyzePhoto({
    required String filePath,
    required String fileName,
    String lang = 'ky',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'lang': lang,
      });

      final response = await _dio.post(
        ApiEndpoints.aiAnalyzePhoto,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return AiAnalysisResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Analyze photo quality (background, lighting, score).
  Future<PhotoQualityResult> analyzePhotoQuality({
    required String filePath,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'action': 'analyze',
      });

      final response = await _dio.post(
        ApiEndpoints.aiRemoveBackground,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return PhotoQualityResult.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Enhance photo (remove background, clean up).
  /// Returns URLs for original and enhanced versions.
  Future<Map<String, dynamic>> enhancePhoto({
    required String filePath,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'action': 'enhance',
      });

      final response = await _dio.post(
        ApiEndpoints.aiRemoveBackground,
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
