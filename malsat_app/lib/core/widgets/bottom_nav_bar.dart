import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../i18n/app_localizations.dart';
import '../state/world_provider.dart';
import '../theme/app_world.dart';

/// Bottom navigation — five world-agnostic slots: Home, Explore, Sell,
/// Activity, Profile. The slots are constant; their content and the
/// Activity label adapt to the active world, and the active item is
/// tinted with that world's accent.
class BottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    final world = ref.watch(worldProvider);
    final accent = AppWorldPalette.forWorld(world).accent;
    final isMeat = world == AppWorld.meat;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: LucideIcons.home,
                label: t(dict, 'nav.home'),
                isActive: currentIndex == 0,
                accent: accent,
                onTap: () => _go(0),
              ),
              _NavItem(
                icon: LucideIcons.search,
                label: t(dict, 'nav.explore'),
                isActive: currentIndex == 1,
                accent: accent,
                onTap: () => _go(1),
              ),
              _NavItem(
                icon: LucideIcons.plusCircle,
                label: t(dict, 'nav.sell'),
                isActive: currentIndex == 2,
                accent: accent,
                isPrimary: true,
                onTap: () => _go(2),
              ),
              _NavItem(
                icon: isMeat ? LucideIcons.shoppingBag : LucideIcons.layers,
                label: t(dict, isMeat ? 'nav.orders' : 'nav.herd'),
                isActive: currentIndex == 3,
                accent: accent,
                onTap: () => _go(3),
              ),
              _NavItem(
                icon: LucideIcons.userCircle,
                label: t(dict, 'nav.profile'),
                isActive: currentIndex == 4,
                accent: accent,
                onTap: () => _go(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _go(int index) {
    HapticFeedback.selectionClick();
    onTap(index);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color accent;
  final VoidCallback onTap;
  final bool isPrimary;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.accent,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? accent
        : isPrimary
            ? accent
            : AppColors.textMuted;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.0 : 0.92,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              child: Icon(icon, size: isPrimary ? 27 : 24, color: color),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.navLabel.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
