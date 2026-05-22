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
import '../../../../core/state/view_mode.dart';
import '../../../../core/theme/app_world.dart';
import '../../../../core/widgets/listing_card.dart';
import '../../../../core/widgets/listing_card_large.dart';
import '../../../../core/widgets/listing_card_row.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../core/widgets/view_mode_toggle.dart';
import '../providers/home_provider.dart';

/// Livestock world browse — fixed-price animal listings.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);
    final locale = ref.watch(localeProvider);

    return dictAsync.when(
      data: (dict) => _HomeContent(dict: dict, locale: locale.languageCode),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Center(child: Text('Error loading')),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  final Map<String, dynamic> dict;
  final String locale;

  const _HomeContent({required this.dict, required this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(latestListingsProvider);
    final viewMode = ref.watch(listingViewModeProvider);
    final accent = AppWorldPalette.of(context).accent;

    return SafeArea(
      child: RefreshIndicator(
        color: accent,
        onRefresh: () => ref.refresh(latestListingsProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search pill.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                child: _SearchPill(
                  placeholder: t(dict, 'search.searchPlaceholder'),
                  hint: t(dict, 'common.all'),
                  onTap: () => context.push('/search'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Category quick-filters.
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  children: [
                    _CategoryTab(
                      icon: LucideIcons.wind,
                      label: t(dict, 'categories.horse'),
                      onTap: () => context.push('/search?category=HORSE'),
                    ),
                    _CategoryTab(
                      icon: LucideIcons.beef,
                      label: t(dict, 'categories.cattle'),
                      onTap: () => context.push('/search?category=CATTLE'),
                    ),
                    _CategoryTab(
                      icon: LucideIcons.cloud,
                      label: t(dict, 'categories.sheep'),
                      onTap: () => context.push('/search?category=SHEEP'),
                    ),
                    _CategoryTab(
                      icon: LucideIcons.award,
                      label: t(dict, 'categories.arashan'),
                      onTap: () => context.push('/search?category=ARASHAN'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.lg),

              // Dual-mode livestock hero — "Any animal. Your way."
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _LivestockHero(
                  badge: t(dict, 'home.heroBadge'),
                  title: t(dict, 'home.heroTitle'),
                  subtitle: t(dict, 'home.heroSubtitle'),
                  buyLabel: t(dict, 'home.iBuy'),
                  buyDesc: t(dict, 'home.iBuyDesc'),
                  hireLabel: t(dict, 'home.iHire'),
                  hireDesc: t(dict, 'home.iHireDesc'),
                  onBuy: () => context.push('/search'),
                  onHire: () => context.push('/caretakers'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Section header + view-mode toggle.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t(dict, 'home.latestListings'),
                        style: AppTypography.h2,
                      ),
                    ),
                    const ViewModeToggle(),
                  ],
                ),
              ),

              // Listings.
              listingsAsync.when(
                data: (listings) {
                  if (listings.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          t(dict, 'common.noResults'),
                          style: AppTypography.bodyMuted,
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.02),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(viewMode),
                        child: LayoutBuilder(
                          builder: (ctx, c) => _buildListings(
                              listings, viewMode, dict, locale, c.maxWidth),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: List.generate(
                      3,
                      (_) => const ShimmerCard(height: 200),
                    ),
                  ),
                ),
                error: (e, st) => Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Text(t(dict, 'common.error'),
                            style: AppTypography.bodyMuted),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: () =>
                              ref.refresh(latestListingsProvider.future),
                          child: Text(t(dict, 'common.retry')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildListings(
  List listings,
  ListingViewMode mode,
  Map<String, dynamic> dict,
  String locale,
  double maxWidth,
) {
  switch (mode) {
    case ListingViewMode.large:
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: listings.length,
        itemBuilder: (context, index) => ListingCardLarge(
          listing: listings[index],
          locale: locale,
        ),
      );
    case ListingViewMode.grid:
      final cols = maxWidth >= 900
          ? 4
          : maxWidth >= 600
              ? 3
              : 2;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.xl,
          childAspectRatio: 0.58,
        ),
        itemCount: listings.length,
        itemBuilder: (context, index) => ListingCard(
          listing: listings[index],
          dict: dict,
          locale: locale,
        ),
      );
    case ListingViewMode.list:
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: listings.length,
        itemBuilder: (context, index) => ListingCardRow(
          listing: listings[index],
          dict: dict,
          locale: locale,
        ),
      );
  }
}

/// Tappable search field shortcut.
class _SearchPill extends StatelessWidget {
  final String placeholder;
  final String hint;
  final VoidCallback onTap;

  const _SearchPill({
    required this.placeholder,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
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
                size: 18, color: AppColors.textPrimary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(placeholder,
                      style: AppTypography.title.copyWith(fontSize: 14)),
                  Text(hint, style: AppTypography.caption),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: AppRadius.smAll,
              ),
              child: const Icon(LucideIcons.slidersHorizontal,
                  size: 16, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Livestock world hero — buy an animal or hire a caretaker.
class _LivestockHero extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final String buyLabel;
  final String buyDesc;
  final String hireLabel;
  final String hireDesc;
  final VoidCallback onBuy;
  final VoidCallback onHire;

  const _LivestockHero({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.buyLabel,
    required this.buyDesc,
    required this.hireLabel,
    required this.hireDesc,
    required this.onBuy,
    required this.onHire,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppWorldPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.coloredGlow(palette.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: AppRadius.smAll,
            ),
            child: Text(
              badge.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.22,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _HeroAction(
                  label: buyLabel,
                  desc: buyDesc,
                  filled: false,
                  onTap: onBuy,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _HeroAction(
                  label: hireLabel,
                  desc: hireDesc,
                  filled: true,
                  onTap: onHire,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  final String label;
  final String desc;
  final bool filled;
  final VoidCallback onTap;

  const _HeroAction({
    required this.label,
    required this.desc,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.textPrimary : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: filled
              ? Colors.white
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: AppRadius.mdAll,
          border: filled
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: TextStyle(
                fontSize: 10,
                color: filled
                    ? AppColors.textSecondary
                    : Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
