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
import '../../../../core/widgets/recruit_empty_state.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../core/widgets/supply_callout.dart';
import '../../../../core/widgets/view_mode_toggle.dart';
import '../providers/drops_provider.dart';
import '../widgets/drop_card.dart';
import '../widgets/drop_card_compact.dart';
import '../widgets/drop_card_row.dart';

/// One selectable meat category. `code` is null for the "All" chip;
/// otherwise it matches `ButcherDrop.category`.
class _MeatCategory {
  final String? code;
  final String i18nKey;

  const _MeatCategory(this.code, this.i18nKey);
}

const _kCategories = [
  _MeatCategory(null, 'common.all'),
  _MeatCategory('CATTLE', 'categories.cattle'),
  _MeatCategory('HORSE', 'categories.horse'),
  _MeatCategory('SHEEP', 'categories.sheep'),
  _MeatCategory('ARASHAN', 'categories.arashan'),
];

/// Meat world main page — editorial intro, search, category filters, and
/// the live meat-drops feed. No marketing banner: the user lands straight
/// on content they can act on.
class DropsScreen extends ConsumerStatefulWidget {
  const DropsScreen({super.key});

  @override
  ConsumerState<DropsScreen> createState() => _DropsScreenState();
}

class _DropsScreenState extends ConsumerState<DropsScreen> {
  String? _category;
  String _query = '';

  List _filter(List drops) {
    final q = _query.trim().toLowerCase();
    return drops.where((d) {
      if (_category != null && d.category != _category) return false;
      if (q.isEmpty) return true;
      final hay = [
        d.title,
        d.breed ?? '',
        d.village ?? '',
      ].join(' ').toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dropsAsync = ref.watch(dropsListProvider);
    final viewMode = ref.watch(listingViewModeProvider);
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    final accent = AppWorldPalette.of(context).accent;
    final loaded = dropsAsync.valueOrNull;

    return SafeArea(
      child: RefreshIndicator(
        color: accent,
        onRefresh: () => ref.refresh(dropsListProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Editorial intro — what this app is, in three lines ──
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t(dict, 'drops.heroBadge'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            t(dict, 'drops.heroTitle'),
                            style: AppTypography.display,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            t(dict, 'drops.heroSubtitle'),
                            style: AppTypography.bodyMuted,
                          ),
                          if (loaded != null && loaded.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            _LiquidityStrip(
                              count: loaded.length,
                              unit: t(dict, 'supply.unitDrops'),
                              villages: _villageCount(loaded),
                              villagesWord: t(dict, 'supply.villages'),
                              accent: accent,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _MyOrdersButton(
                      label: t(dict, 'drops.myOrdersBtn'),
                      onTap: () => context.push('/orders/me'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Supply CTA — the marketplace lives on listings ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SupplyCallout(
                  title: t(dict, 'supply.meatTitle'),
                  subtitle: t(dict, 'supply.meatSub'),
                  onTap: () => context.go('/sell'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Search ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _SearchField(
                  hint: t(dict, 'drops.searchHint'),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Category filters — navigate immediately ──
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  itemCount: _kCategories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (ctx, i) {
                    final cat = _kCategories[i];
                    return _CategoryChip(
                      label: t(dict, cat.i18nKey),
                      isActive: _category == cat.code,
                      accent: accent,
                      onTap: () => setState(() => _category = cat.code),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Feed ──
              dropsAsync.when(
                data: (drops) {
                  final filtered = _filter(drops);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0,
                            AppSpacing.lg, AppSpacing.md),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(t(dict, 'drops.sectionOpen'),
                                      style: AppTypography.h2),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    '${filtered.length}',
                                    style: AppTypography.h2.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const ViewModeToggle(),
                          ],
                        ),
                      ),
                      if (filtered.isEmpty)
                        RecruitEmptyState(
                          icon: LucideIcons.beef,
                          title: t(dict, 'supply.emptyMeatTitle'),
                          subtitle: t(dict, 'supply.emptySub'),
                          ctaLabel: t(dict, 'supply.emptyCta'),
                          onTap: () => context.go('/sell'),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, anim) =>
                                FadeTransition(
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
                              key: ValueKey('$viewMode-$_category'),
                              child: LayoutBuilder(
                                builder: (ctx, c) => _buildDrops(
                                    context, filtered, viewMode, c.maxWidth),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
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
                              ref.refresh(dropsListProvider.future),
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

Widget _buildDrops(
  BuildContext context,
  List drops,
  ListingViewMode mode,
  double maxWidth,
) {
  switch (mode) {
    case ListingViewMode.large:
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: drops.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (ctx, index) => DropCard(
          drop: drops[index],
          onTap: () => context.push('/drop/${drops[index].id}'),
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
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.lg,
          childAspectRatio: 0.66,
        ),
        itemCount: drops.length,
        itemBuilder: (ctx, index) => DropCardCompact(
          drop: drops[index],
          onTap: () => context.push('/drop/${drops[index].id}'),
        ),
      );
    case ListingViewMode.list:
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: drops.length,
        itemBuilder: (ctx, index) => DropCardRow(
          drop: drops[index],
          onTap: () => context.push('/drop/${drops[index].id}'),
        ),
      );
  }
}

/// Tappable search field that filters the visible drops.
class _SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: TextField(
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: AppTypography.body,
        decoration: InputDecoration(
          isCollapsed: true,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15),
          prefixIcon: const Icon(LucideIcons.search,
              size: 19, color: AppColors.textSecondary),
          hintText: hint,
          hintStyle: AppTypography.body.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// A meat-category filter pill.
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color accent;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isActive ? accent : AppColors.surface,
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: isActive ? accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Compact pill linking to the buyer's own meat orders.
class _MyOrdersButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MyOrdersButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: AppRadius.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.shoppingBag,
                size: 14, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Distinct villages across the loaded drops — a small liquidity proof.
int _villageCount(List drops) =>
    drops.map((d) => d.village).whereType<String>().toSet().length;

/// Liquidity proof strip — "N drops · M villages". A live, honest signal
/// that the marketplace has supply.
class _LiquidityStrip extends StatelessWidget {
  final int count;
  final String unit;
  final int villages;
  final String villagesWord;
  final Color accent;

  const _LiquidityStrip({
    required this.count,
    required this.unit,
    required this.villages,
    required this.villagesWord,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$count $unit',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        if (villages > 0) ...[
          Text('  ·  ',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          Text(
            '$villages $villagesWord',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
