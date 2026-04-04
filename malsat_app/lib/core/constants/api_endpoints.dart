class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/api/auth/login';
  static const String verify = '/api/auth/verify';
  static const String refresh = '/api/auth/refresh';

  // Listings
  static const String listings = '/api/listings';
  static String listing(String id) => '/api/listings/$id';

  // Favorites
  static const String favorites = '/api/favorites';

  // Upload
  static const String upload = '/api/upload';

  // Conversations / Messages
  static const String conversations = '/api/conversations';
  static String conversationMessages(String id) =>
      '/api/conversations/$id/messages';

  // AI
  static const String aiAnalyzePhoto = '/api/ai/analyze-photo';
  static const String aiRemoveBackground = '/api/ai/remove-background';

  // Users
  static String user(String id) => '/api/users/$id';
}
