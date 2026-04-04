class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromStatusCode(int statusCode, [String? message]) {
    switch (statusCode) {
      case 400:
        return ApiException(message ?? 'Bad request', statusCode: 400);
      case 401:
        return ApiException(message ?? 'Unauthorized', statusCode: 401);
      case 403:
        return ApiException(message ?? 'Forbidden', statusCode: 403);
      case 404:
        return ApiException(message ?? 'Not found', statusCode: 404);
      default:
        return ApiException(message ?? 'Server error', statusCode: statusCode);
    }
  }

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
