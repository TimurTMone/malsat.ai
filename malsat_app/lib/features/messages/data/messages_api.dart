import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_exception.dart';

class MessagesApi {
  final Dio _dio;

  MessagesApi(this._dio);

  /// Get all conversations for the current user.
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final response = await _dio.get(ApiEndpoints.conversations);
      return (response.data as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create or get existing conversation with a seller about a listing.
  Future<Map<String, dynamic>> createConversation({
    required String sellerId,
    String? listingId,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.conversations,
        data: {
          'sellerId': sellerId,
          if (listingId != null) 'listingId': listingId,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get messages for a conversation. Pass [afterId] for polling new messages.
  Future<List<Map<String, dynamic>>> getMessages(
    String conversationId, {
    String? afterId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (afterId != null) params['after'] = afterId;

      final response = await _dio.get(
        ApiEndpoints.conversationMessages(conversationId),
        queryParameters: params,
      );
      return (response.data as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Send a text message.
  Future<Map<String, dynamic>> sendMessage(
    String conversationId, {
    String? content,
    String? mediaUrl,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.conversationMessages(conversationId),
        data: {
          if (content != null) 'content': content,
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
        },
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
