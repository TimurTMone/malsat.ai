import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/theme/app_world.dart';
import '../../../../core/widgets/pressable_scale.dart';

class _ExploreCat {
  final String code;
  final String i18nKey;
  final IconData icon;
  final Color bg;
  final Color fg;
  const _ExploreCat(this.code, this.i18nKey, this.icon, this.bg, this.fg);
}

const _kMeatCats = [
  _ExploreCat('CATTLE', 'categories.cattle', LucideIcons.beef,
      AppColors.cattleBackground, AppColors.cattleForeground),
  _ExploreCat('HORSE', 'categories.horse', LucideIcons.wind,
      AppColors.horseBackground, AppColors.horseForeground),
  _ExploreCat('SHEEP', 'categories.sheep', LucideIcons.cloud,
      AppColors.sheepBackground, AppColors.sheepForeground),
];

const _kLivestockCats = [
  _ExploreCat('CATTLE', 'categories.cattle', LucideIcons.beef,
      AppColors.cattleBackground, AppColors.cattleForeground),
  _ExploreCat('SHEEP', 'categories.sheep', LucideIcons.cloud,
      AppColors.sheepBackground, AppColors.sheepForeground),
  _ExploreCat('HORSE', 'categories.horse', LucideIcons.wind,
      AppColors.horseBackground, AppColors.horseForeground),
  _ExploreCat('ARASHAN', 'livestock.arashanTitle', LucideIcons.star,
      AppColors.arashanBackground, AppColors.arashanForeground),
];

/// Explore — a world-aware discovery screen: search plus a category grid.
class ExploreScreen extends ConsumerWidget {
  final AppWorld world;

  const ExploreScreen({super.key, required this.world});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    final isMeat = world == AppWorld.meat;
    final cats = isMeat ? _kMeatCats : _kLivestockCats;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t(dict, 'nav.explore'), style: AppTypography.display),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: () => context.push('/search'),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.pillAll,
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.search,
                        size: 19, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.md),
                    Text(t(dict, 'search.searchPlaceholder'),
                        style: AppTypography.body
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(t(dict, 'livestock.browseTitle'),
                style: AppTypography.h2),
            const SizedBox(height: AppSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.5,
              ),
              itemCount: cats.length,
              itemBuilder: (ctx, i) {
                final c = cats[i];
                return _ExploreTile(
                  label: t(dict, c.i18nKey),
                  icon: c.icon,
                  bg: c.bg,
                  fg: c.fg,
                  onTap: () =>
                      context.push('/search?category=${c.code}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _ExploreTile({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.lgAll,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              bottom: -10,
              child: Icon(icon,
                  size: 76, color: fg.withValues(alpha: 0.12)),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 26, color: fg),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
