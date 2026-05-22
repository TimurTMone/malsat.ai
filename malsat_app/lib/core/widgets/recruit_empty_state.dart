import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../theme/app_world.dart';
import 'pressable_scale.dart';

/// An empty feed should never look dead — it should recruit. Instead of
/// "nothing found", this asks the user to be the first to list, with a
/// one-tap CTA into the sell flow.
class RecruitEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onTap;

  const RecruitEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppWorldPalette.of(context).accent;
    final surface = AppWorldPalette.of(context).accentSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxxl, AppSpacing.xl, AppSpacing.xxxl, AppSpacing.xxxl),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(color: surface, shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: accent),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title,
              textAlign: TextAlign.center,
              style: AppTypography.h2.copyWith(fontSize: 17)),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle,
              textAlign: TextAlign.center, style: AppTypography.bodyMuted),
          const SizedBox(height: AppSpacing.xl),
          PressableScale(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl, vertical: 14),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: AppRadius.pillAll,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    ctaLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
