import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/messages_api.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final messagesApiProvider = Provider<MessagesApi>((ref) {
  final dio = ref.read(dioProvider);
  return MessagesApi(dio);
});

/// All conversations for the current user.
final conversationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (!isAuth) return [];

  final api = ref.read(messagesApiProvider);
  return api.getConversations();
});

/// Messages for a specific conversation.
final messagesProvider = FutureProvider.family<List<Map<String, dynamic>>,
    String>((ref, conversationId) async {
  final api = ref.read(messagesApiProvider);
  return api.getMessages(conversationId);
});
