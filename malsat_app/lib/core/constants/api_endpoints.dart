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

  // Herd (Livestock CRM)
  static const String herd = '/api/herd';
  static String herdAnimal(String id) => '/api/herd/$id';

  // Caretakers
  static const String caretakers = '/api/caretakers';

  // Butcher Drops (meat ordering)
  static const String drops = '/api/drops';
  static String drop(String id) => '/api/drops/$id';
  static String dropOrder(String id) => '/api/drops/$id/order';
  static String dropOrders(String id) => '/api/drops/$id/orders';

  // Meat Orders
  static String order(String id) => '/api/orders/$id';
  static String orderReceipt(String id) => '/api/orders/$id/receipt';
  static const String myOrders = '/api/orders/me';
  static const String sellerOrders = '/api/orders/seller';

  // User profile (self)
  static const String me = '/api/users/me';

  // Hubs (apartment complexes)
  static const String hubs = '/api/hubs';
  static const String hubJoin = '/api/hubs/join';
  static String hub(String id) => '/api/hubs/$id';

  // Livestock Tokens
  static const String tokens = '/api/tokens';
  static String token(String id) => '/api/tokens/$id';
  static String tokenBuy(String id) => '/api/tokens/$id/buy';
  static const String tokenPortfolio = '/api/tokens/portfolio';
}
