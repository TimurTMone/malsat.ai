import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../i18n/app_localizations.dart';
import '../state/world_provider.dart';
import '../theme/app_world.dart';

/// The master Meat ⇄ Livestock switch — the top-level axis of the whole
/// app. Pinned in the header; the active half fills with that world's
/// accent and a thumb slides between the two.
class WorldSwitch extends ConsumerWidget {
  const WorldSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final world = ref.watch(worldProvider);
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    final isMeat = world == AppWorld.meat;
    final accent = AppWorldPalette.forWorld(world).accent;

    void select(AppWorld w) {
      if (w == world) return;
      HapticFeedback.selectionClick();
      ref.read(worldProvider.notifier).setWorld(w);
    }

    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: AppRadius.pillAll,
      ),
      child: Stack(
        children: [
          // Sliding thumb.
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment:
                isMeat ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: AppRadius.pillAll,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _Half(
                icon: LucideIcons.beef,
                label: t(dict, 'nav.meat'),
                isActive: isMeat,
                onTap: () => select(AppWorld.meat),
              ),
              _Half(
                icon: LucideIcons.layers,
                label: t(dict, 'nav.livestock'),
                isActive: !isMeat,
                onTap: () => select(AppWorld.livestock),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Half extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Half({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isActive ? Colors.white : AppColors.textSecondary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 7),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: fg,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
