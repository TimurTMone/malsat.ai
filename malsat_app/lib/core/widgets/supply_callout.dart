import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_shadows.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../theme/app_world.dart';
import 'pressable_scale.dart';

/// The primary supply-side call to action — invites the user to list their
/// own animal or meat. Placed high on the home page because a marketplace
/// lives or dies on supply: every screen should nudge "add yours".
class SupplyCallout extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SupplyCallout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppWorldPalette.of(context).accent;

    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: AppRadius.mdAll,
              ),
              child: const Icon(LucideIcons.plus,
                  size: 22, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.title.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.caption),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight,
                size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
