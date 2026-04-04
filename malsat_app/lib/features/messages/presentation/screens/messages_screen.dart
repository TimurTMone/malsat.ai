import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/widgets/time_ago.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/messages_provider.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);
    final isAuth = ref.watch(isAuthenticatedProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (!isAuth) {
      return dictAsync.when(
        data: (dict) => SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.messageCircle,
                    size: 48, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text(t(dict, 'common.login'),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.push('/auth/login'),
                  child: Text(t(dict, 'common.login')),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Error')),
      );
    }

    final conversationsAsync = ref.watch(conversationsProvider);

    return dictAsync.when(
      data: (dict) => SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                t(dict, 'nav.messages'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: conversationsAsync.when(
                data: (conversations) {
                  if (conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.messageCircle,
                              size: 56, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          Text(
                            t(dict, 'messages.noMessages'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t(dict, 'messages.typeMessage'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        ref.refresh(conversationsProvider.future),
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: conversations.length,
                      separatorBuilder: (ctx, i) => const Divider(
                        height: 1,
                        indent: 76,
                        color: AppColors.border,
                      ),
                      itemBuilder: (context, index) {
                        final conv = conversations[index];
                        final buyer = conv['buyer'] as Map<String, dynamic>;
                        final seller = conv['seller'] as Map<String, dynamic>;
                        final lastMsg =
                            conv['lastMessage'] as Map<String, dynamic>?;
                        final unread = conv['unreadCount'] as int? ?? 0;
                        final listing =
                            conv['listing'] as Map<String, dynamic>?;

                        // Show the other person
                        final isMyBuyer =
                            buyer['id'] == currentUser?.id;
                        final other = isMyBuyer ? seller : buyer;
                        final otherName =
                            other['name'] as String? ?? other['phone'] as String;
                        final initials = otherName.isNotEmpty
                            ? otherName[0].toUpperCase()
                            : '?';

                        return InkWell(
                          onTap: () => context
                              .push('/chat/${conv['id']}'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              otherName,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: unread > 0
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color:
                                                    AppColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (lastMsg != null)
                                            Text(
                                              timeAgo(
                                                  DateTime.parse(
                                                      lastMsg['createdAt']
                                                          as String),
                                                  dict),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              lastMsg?['content']
                                                      as String? ??
                                                  (listing != null
                                                      ? listing['title']
                                                          as String
                                                      : ''),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: unread > 0
                                                    ? AppColors
                                                        .textPrimary
                                                    : AppColors
                                                        .textMuted,
                                                fontWeight: unread > 0
                                                    ? FontWeight.w500
                                                    : FontWeight.w400,
                                              ),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (unread > 0)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                              ),
                                              child: Text(
                                                '$unread',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(
                  child: TextButton(
                    onPressed: () =>
                        ref.refresh(conversationsProvider.future),
                    child: const Text('Retry'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Center(child: Text('Error')),
    );
  }
}
