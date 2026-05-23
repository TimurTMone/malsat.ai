import 'package:cached_network_image/cached_network_image.dart';
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
import '../../../../core/widgets/listing_card_large.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../core/widgets/recruit_empty_state.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../core/widgets/supply_callout.dart';
import '../../../home/presentation/providers/home_provider.dart';

/// Tinted colour pair for an animal category — drawn from the design
/// system's category palette so the tiles are self-contained.
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

/// Livestock world — a product page, not a feed.
///
/// One photograph above the fold. One headline. One action. As the user
/// scrolls, each section lands a single idea: today's listings, the
/// taxonomy, the premium tiers, and the sell-yours close.
class LivestockHomeScreen extends ConsumerWidget {
  const LivestockHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(latestListingsProvider);
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    final locale = ref.watch(localeProvider).languageCode;
    final accent = AppWorldPalette.of(context).accent;
    final loaded = listingsAsync.valueOrNull;

    return RefreshIndicator(
      color: accent,
      onRefresh: () => ref.refresh(latestListingsProvider.future),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero — full-bleed photo, one statement, one action ──
            _Hero(
              imageUrl: _heroImage(loaded),
              title: t(dict, 'home.heroTitle'),
              subtitle: t(dict, 'home.heroSubtitle'),
              cta: t(dict, 'home.iBuy'),
              accent: accent,
              count: loaded?.length ?? 0,
              villages: loaded != null ? _villageCount(loaded) : 0,
              unit: t(dict, 'supply.unitAnimals'),
              villagesWord: t(dict, 'supply.villages'),
              onCta: () => context.push('/search'),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Butcher service — for funerals, weddings, kudai tamak ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _ButcherServiceCard(
                title: t(dict, 'butcher.entryCardTitle'),
                subtitle: t(dict, 'butcher.entryCardSubtitle'),
                cta: t(dict, 'butcher.entryCardCta'),
                onTap: () => context.push('/butcher'),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Today's listings ──
            _SectionLabel(t(dict, 'home.latestListings')),
            const SizedBox(height: AppSpacing.md),
            listingsAsync.when(
              data: (listings) {
                if (listings.isEmpty) {
                  return RecruitEmptyState(
                    icon: LucideIcons.layers,
                    title: t(dict, 'supply.emptyLivestockTitle'),
                    subtitle: t(dict, 'supply.emptySub'),
                    ctaLabel: t(dict, 'supply.emptyCta'),
                    onTap: () => context.go('/sell'),
                  );
                }
                final preview = listings.take(3).toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  child: Column(
                    children: preview
                        .map((l) =>
                            ListingCardLarge(listing: l, locale: locale))
                        .toList(),
                  ),
                );
              },
              loading: () => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: List.generate(
                      2, (_) => const ShimmerCard(height: 200)),
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
            const SizedBox(height: AppSpacing.xxl),

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
            const SizedBox(height: AppSpacing.xxl),

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
            const SizedBox(height: AppSpacing.xxl),

            // ── Sell yours — the supply close ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SupplyCallout(
                title: t(dict, 'supply.livestockTitle'),
                subtitle: t(dict, 'supply.livestockSub'),
                onTap: () => context.go('/sell'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _heroImage(List? loaded) {
  if (loaded == null || loaded.isEmpty) return null;
  for (final l in loaded) {
    final url = l.primaryImageUrl as String?;
    if (url != null && url.isNotEmpty) return url;
  }
  return null;
}

/// The product-page hero: a single image, a single statement, a single
/// action. Liquidity sits as a quiet meta line above the headline.
class _Hero extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final String cta;
  final Color accent;
  final int count;
  final int villages;
  final String unit;
  final String villagesWord;
  final VoidCallback onCta;

  const _Hero({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.accent,
    required this.count,
    required this.villages,
    required this.unit,
    required this.villagesWord,
    required this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final heroHeight = mq.size.height * 0.62;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photograph — or a soft gradient placeholder.
          if (imageUrl != null)
            CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppColors.backgroundSecondary),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.backgroundSecondary,
                alignment: Alignment.center,
                child: Icon(LucideIcons.image,
                    size: 64, color: AppColors.textMuted),
              ),
            )
          else
            Container(color: AppColors.backgroundSecondary),

          // Legibility gradient — black at the bottom, transparent at the top.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.45, 1.0],
                colors: [
                  Color(0x00000000),
                  Color(0xCC000000),
                ],
              ),
            ),
          ),

          // Content — bottom-left aligned, headline + subtitle + CTA.
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.xl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (count > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          villages > 0
                              ? '$count $unit · $villages $villagesWord'
                              : '$count $unit',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  title,
                  style: AppTypography.display.copyWith(
                    color: Colors.white,
                    fontSize: 38,
                    height: 1.04,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PressableScale(
                  onTap: onCta,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cta,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.arrowRight,
                            size: 17, color: AppColors.textPrimary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

/// Tinted animal category tile — soft watercolour, icon, label.
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
        aspectRatio: 0.92,
        child: Container(
          decoration: BoxDecoration(
            color: tone.bg,
            borderRadius: AppRadius.lgAll,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -12,
                top: -8,
                child: Icon(icon,
                    size: 70,
                    color: tone.fg.withValues(alpha: 0.10)),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, size: 20, color: tone.fg),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                        color: tone.fg,
                        height: 1.2,
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
              child: Icon(icon, size: 32, color: tone.fg),
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
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
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

/// Distinct villages across the loaded listings — a small liquidity proof.
int _villageCount(List listings) =>
    listings.map((l) => l.village).whereType<String>().toSet().length;

/// Primary supply-side service: halal slaughter + delivery to an event.
/// Visually distinct (deep olive surface, compass icon) so it reads as a
/// service, not another marketplace card.
class _ButcherServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;

  const _ButcherServiceCard({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.md, AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.lgAll,
          boxShadow: AppShadows.coloredGlow(AppColors.primary),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.compass,
                  size: 22, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.pillAll,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cta,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(LucideIcons.arrowRight,
                      size: 14, color: AppColors.textPrimary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
