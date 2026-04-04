import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/favorites_provider.dart';

class FavoriteButton extends ConsumerWidget {
  final String listingId;
  final double size;
  final bool showBackground;

  const FavoriteButton({
    super.key,
    required this.listingId,
    this.size = 20,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorited = ref.watch(isFavoritedProvider(listingId));
    final isAuth = ref.watch(isAuthenticatedProvider);

    final icon = Icon(
      isFavorited ? LucideIcons.heartOff : LucideIcons.heart,
      size: size,
      color: isFavorited ? AppColors.error : AppColors.textMuted,
    );

    void handleTap() async {
      if (!isAuth) {
        // Could navigate to login, for now just ignore
        return;
      }
      try {
        await ref.read(favoritedIdsProvider.notifier).toggle(listingId);
      } catch (_) {
        // Silently fail
      }
    }

    if (showBackground) {
      return GestureDetector(
        onTap: handleTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
      );
    }

    return GestureDetector(
      onTap: handleTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: icon,
      ),
    );
  }
}
