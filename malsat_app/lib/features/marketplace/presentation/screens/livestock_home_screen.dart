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
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../core/widgets/view_mode_toggle.dart';
import '../../../home/presentation/providers/home_provider.dart';

/// Tinted colour pair for an animal category — drawn from the design
/// system's category palette so the tiles are self-contained (no network
/// images that can fail to load).
class _CatTone {
  final Color bg;
  final Color fg;
  const _CatTone(this.bg, this.fg);
}

const _kTones = {
  'CATTLE': _CatTone(AppColors.cattleBackground, AppColors.cattleForeground),
  'SHEEP': _CatTone(AppColors.sheepBackground, AppColors.sheepForeground),
  'HORSE': _CatTone(AppColors.horseBackground, AppColors.horseForeground),
  'ARASHAN':
      _CatTone(AppColors.arashanBackground, AppColors.arashanForeground),
};

/// Livestock world main page — editorial intro, the animal taxonomy
/// (Cattle · Sheep · Horse), premium tiers (Kök-Börü horses, Arashan
/// sheep) and the live listings feed.
class LivestockHomeScreen extends ConsumerWidget {
  const LivestockHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(latestListingsProvider);
    final viewMode = ref.watch(listingViewModeProvider);
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    final locale = ref.watch(localeProvider).languageCode;
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
              // ── Editorial intro ──
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t(dict, 'home.heroBadge'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(t(dict, 'home.heroTitle'),
                        style: AppTypography.display),
                    const SizedBox(height: AppSpacing.xs),
                    Text(t(dict, 'home.heroSubtitle'),
                        style: AppTypography.bodyMuted),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Search ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _SearchPill(
                  hint: t(dict, 'search.searchPlaceholder'),
                  onTap: () => context.push('/search'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Browse by animal ──
              _SectionLabel(t(dict, 'livestock.browseTitle')),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: _CategoryCard(
                        label: t(dict, 'categories.cattle'),
                        icon: LucideIcons.beef,
                        tone: _kTones['CATTLE']!,
                        onTap: () =>
                            context.push('/search?category=CATTLE'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _CategoryCard(
                        label: t(dict, 'categories.sheep'),
                        icon: LucideIcons.cloud,
                        tone: _kTones['SHEEP']!,
                        onTap: () =>
                            context.push('/search?category=SHEEP'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _CategoryCard(
                        label: t(dict, 'categories.horse'),
                        icon: LucideIcons.wind,
                        tone: _kTones['HORSE']!,
                        onTap: () =>
                            context.push('/search?category=HORSE'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Premium tiers ──
              _SectionLabel(t(dict, 'livestock.featuredTitle')),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    _FeaturedCard(
                      tag: t(dict, 'livestock.sportTag'),
                      tagColor: AppColors.auctionAccent,
                      title: t(dict, 'livestock.kokBoruTitle'),
                      desc: t(dict, 'livestock.kokBoruDesc'),
                      icon: LucideIcons.award,
                      tone: _kTones['HORSE']!,
                      onTap: () => context.push('/search?category=HORSE'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _FeaturedCard(
                      tag: t(dict, 'livestock.premiumTag'),
                      tagColor: accent,
                      title: t(dict, 'livestock.arashanTitle'),
                      desc: t(dict, 'livestock.arashanDesc'),
                      icon: LucideIcons.star,
                      tone: _kTones['ARASHAN']!,
                      onTap: () =>
                          context.push('/search?category=ARASHAN'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Latest listings ──
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(t(dict, 'home.latestListings'),
                          style: AppTypography.h2),
                    ),
                    const ViewModeToggle(),
                  ],
                ),
              ),
              listingsAsync.when(
                data: (listings) {
                  if (listings.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(t(dict, 'common.noResults'),
                            style: AppTypography.bodyMuted),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: LayoutBuilder(
                      builder: (ctx, c) => _buildListings(
                          listings, viewMode, dict, locale, c.maxWidth),
                    ),
                  );
                },
                loading: () => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: List.generate(
                        3, (_) => const ShimmerCard(height: 200)),
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
  Map<String, dynamic>? dict,
  String locale,
  double maxWidth,
) {
  switch (mode) {
    case ListingViewMode.large:
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: listings.length,
        itemBuilder: (context, index) =>
            ListingCardLarge(listing: listings[index], locale: locale),
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
            listing: listings[index], dict: dict ?? {}, locale: locale),
      );
    case ListingViewMode.list:
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: listings.length,
        itemBuilder: (context, index) => ListingCardRow(
            listing: listings[index], dict: dict ?? {}, locale: locale),
      );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Text(text, style: AppTypography.h2),
    );
  }
}

class _SearchPill extends StatelessWidget {
  final String hint;
  final VoidCallback onTap;

  const _SearchPill({required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            Text(hint,
                style:
                    AppTypography.body.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

/// Tinted animal category tile — solid colour, icon, label.
class _CategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final _CatTone tone;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.label,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 0.86,
        child: Container(
          decoration: BoxDecoration(
            color: tone.bg,
            borderRadius: AppRadius.lgAll,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                top: -6,
                child: Icon(icon,
                    size: 64,
                    color: tone.fg.withValues(alpha: 0.12)),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, size: 22, color: tone.fg),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: tone.fg,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wide premium-tier card (Kök-Börü horses, Arashan sheep).
class _FeaturedCard extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final String title;
  final String desc;
  final IconData icon;
  final _CatTone tone;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.tag,
    required this.tagColor,
    required this.title,
    required this.desc,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: tone.bg,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppRadius.lg)),
              ),
              child: Icon(icon, size: 34, color: tone.fg),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(title,
                        style: AppTypography.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(desc,
                        style: AppTypography.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: Icon(LucideIcons.chevronRight,
                  size: 20, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
