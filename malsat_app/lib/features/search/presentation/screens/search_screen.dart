import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/widgets/listing_card.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const SearchScreen({super.key, this.initialCategory});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _scrollController = ScrollController();
  bool _initialCategoryApplied = false;

  @override
  void initState() {
    super.initState();
    // Apply initial category from route param once
    if (widget.initialCategory != null && !_initialCategoryApplied) {
      _initialCategoryApplied = true;
      Future.microtask(() {
        final currentFilters = ref.read(searchFiltersProvider);
        if (currentFilters.category != widget.initialCategory) {
          ref
              .read(searchFiltersProvider.notifier)
              .setCategory(widget.initialCategory);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dictAsync = ref.watch(dictionaryProvider);
    final locale = ref.watch(localeProvider);
    final filters = ref.watch(searchFiltersProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return dictAsync.when(
      data: (dict) => SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: t(dict, 'search.searchPlaceholder'),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Category filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: t(dict, 'categories.horse'),
                    icon: LucideIcons.wind,
                    isActive: filters.category == 'HORSE',
                    activeColor: AppColors.horseBackground,
                    activeFgColor: AppColors.horseForeground,
                    onTap: () => ref
                        .read(searchFiltersProvider.notifier)
                        .setCategory('HORSE'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: t(dict, 'categories.cattle'),
                    icon: LucideIcons.beef,
                    isActive: filters.category == 'CATTLE',
                    activeColor: AppColors.cattleBackground,
                    activeFgColor: AppColors.cattleForeground,
                    onTap: () => ref
                        .read(searchFiltersProvider.notifier)
                        .setCategory('CATTLE'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: t(dict, 'categories.sheep'),
                    icon: LucideIcons.cloud,
                    isActive: filters.category == 'SHEEP',
                    activeColor: AppColors.sheepBackground,
                    activeFgColor: AppColors.sheepForeground,
                    onTap: () => ref
                        .read(searchFiltersProvider.notifier)
                        .setCategory('SHEEP'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: t(dict, 'categories.arashan'),
                    icon: LucideIcons.award,
                    isActive: filters.category == 'ARASHAN',
                    activeColor: AppColors.arashanBackground,
                    activeFgColor: AppColors.arashanForeground,
                    onTap: () => ref
                        .read(searchFiltersProvider.notifier)
                        .setCategory('ARASHAN'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Sort row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Results count
                  resultsAsync.whenOrNull(
                        data: (r) => Text(
                          t(dict, 'search.resultsCount', {
                            'count': '${r.pagination.total}',
                          }),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ) ??
                      const SizedBox.shrink(),
                  const Spacer(),
                  // Sort dropdown
                  PopupMenuButton<String>(
                    onSelected: (sort) =>
                        ref.read(searchFiltersProvider.notifier).setSort(sort),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'newest',
                        child: Text(t(dict, 'search.sortNewest')),
                      ),
                      PopupMenuItem(
                        value: 'price_asc',
                        child: Text(t(dict, 'search.sortPriceLow')),
                      ),
                      PopupMenuItem(
                        value: 'price_desc',
                        child: Text(t(dict, 'search.sortPriceHigh')),
                      ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.arrowUpDown,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          t(dict, 'common.sort'),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Results
            Expanded(
              child: resultsAsync.when(
                data: (response) {
                  if (response.listings.isEmpty) {
                    return Center(
                      child: Text(
                        t(dict, 'common.noResults'),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        ref.refresh(searchResultsProvider.future),
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: response.listings.length,
                      itemBuilder: (context, index) => ListingCard(
                        listing: response.listings[index],
                        dict: dict,
                        locale: locale.languageCode,
                      ),
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t(dict, 'common.error'),
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            ref.refresh(searchResultsProvider.future),
                        child: Text(t(dict, 'common.loading')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Center(child: Text('Error')),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final Color activeFgColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.activeFgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : activeColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isActive ? Colors.white : activeFgColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : activeFgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
