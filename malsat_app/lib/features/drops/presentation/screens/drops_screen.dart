import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/state/view_mode.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../core/widgets/view_mode_toggle.dart';
import '../providers/drops_provider.dart';
import '../widgets/drop_card.dart';
import '../widgets/drop_card_compact.dart';
import '../widgets/drop_card_row.dart';

class DropsScreen extends ConsumerWidget {
  const DropsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dropsAsync = ref.watch(dropsListProvider);
    final viewMode = ref.watch(listingViewModeProvider);
    final dict = ref.watch(dictionaryProvider).valueOrNull;

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () => ref.refresh(dropsListProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero banner
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7F1D1D), Color(0xFFB91C1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB91C1C).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCA5A5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t(dict, 'drops.heroBadge'),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7F1D1D),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t(dict, 'drops.heroTitle'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t(dict, 'drops.heroSubtitle'),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _InfoChip(
                              icon: LucideIcons.beef,
                              label: t(dict, 'drops.chipFresh'),
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              icon: LucideIcons.truck,
                              label: t(dict, 'drops.chipPickup'),
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              icon: LucideIcons.shield,
                              label: t(dict, 'drops.chipVerified'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section title + actions row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t(dict, 'drops.sectionOpen'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/orders/me'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.shoppingBag,
                                size: 13, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              t(dict, 'drops.myOrdersBtn'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // View-mode toggle row — right-aligned, Unaa-style
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [ViewModeToggle()],
                ),
              ),

              // Drops list
              dropsAsync.when(
                data: (drops) {
                  if (drops.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          t(dict, 'drops.noOrders'),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          builder: (ctx, c) =>
                              _buildDrops(context, drops, viewMode, c.maxWidth),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
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
        separatorBuilder: (_, __) => const SizedBox(height: 16),
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
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
