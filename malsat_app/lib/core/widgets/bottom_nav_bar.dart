import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../i18n/app_localizations.dart';
import '../state/world_provider.dart';
import '../theme/app_world.dart';

/// Bottom navigation — five slots. The first two are the worlds (Meat /
/// Livestock) as first-class destinations; the centre is Sell; the last
/// two are Activity (world-aware label + icon) and Profile. The Meat and
/// Livestock tabs always wear their own world's accent (terracotta /
/// sage) so the user sees both worlds coloured by identity, not by which
/// is "currently active." The shared tabs pick up whichever world the
/// user last set.
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
    final currentAccent = AppWorldPalette.forWorld(world).accent;
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
          height: 64,
          child: Row(
            children: [
              // Tab 0: Meat — always wears terracotta when active.
              _NavItem(
                icon: LucideIcons.beef,
                label: t(dict, 'nav.meat'),
                isActive: currentIndex == 0,
                accent: AppColors.meatAccent,
                onTap: () => _go(0),
              ),
              // Tab 1: Livestock — always wears sage when active.
              _NavItem(
                icon: LucideIcons.layers,
                label: t(dict, 'nav.livestock'),
                isActive: currentIndex == 1,
                accent: AppColors.livestockAccent,
                onTap: () => _go(1),
              ),
              // Tab 2: Sell — central + raised, uses current world accent.
              _NavItem(
                icon: LucideIcons.plusCircle,
                label: t(dict, 'nav.sell'),
                isActive: currentIndex == 2,
                accent: currentAccent,
                isPrimary: true,
                onTap: () => _go(2),
              ),
              // Tab 3: Activity — world-aware label + icon.
              _NavItem(
                icon: isMeat ? LucideIcons.shoppingBag : LucideIcons.layers,
                label: t(dict, isMeat ? 'nav.orders' : 'nav.herd'),
                isActive: currentIndex == 3,
                accent: currentAccent,
                onTap: () => _go(3),
              ),
              // Tab 4: Profile.
              _NavItem(
                icon: LucideIcons.userCircle,
                label: t(dict, 'nav.profile'),
                isActive: currentIndex == 4,
                accent: currentAccent,
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
              scale: isActive ? 1.0 : 0.94,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              child: Icon(icon, size: isPrimary ? 26 : 22, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.navLabel.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
