import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/widgets/listing_card.dart';
import '../providers/home_provider.dart';

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

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () => ref.refresh(latestListingsProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search pill
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: GestureDetector(
                  onTap: () => context.go('/search'),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.borderStrong),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.search,
                            size: 18, color: AppColors.textPrimary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t(dict, 'search.searchPlaceholder'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                t(dict, 'common.all'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderStrong),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.slidersHorizontal,
                              size: 16, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category tabs -- horizontal scroll, underline style
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _CategoryTab(
                      icon: LucideIcons.wind,
                      label: t(dict, 'categories.horse'),
                      onTap: () => context.go('/search?category=HORSE'),
                    ),
                    _CategoryTab(
                      icon: LucideIcons.beef,
                      label: t(dict, 'categories.cattle'),
                      onTap: () => context.go('/search?category=CATTLE'),
                    ),
                    _CategoryTab(
                      icon: LucideIcons.cloud,
                      label: t(dict, 'categories.sheep'),
                      onTap: () => context.go('/search?category=SHEEP'),
                    ),
                    _CategoryTab(
                      icon: LucideIcons.award,
                      label: t(dict, 'categories.arashan'),
                      onTap: () => context.go('/search?category=ARASHAN'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Dual-mode unified hero — "Any animal. Your way."
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.22),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0B547),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ЭКИ ЖОЛУ • ANY ANIMAL. YOUR WAY.',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B4332),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Мал сатып ал. Же малчы жалдап пайда тап.',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ар бир жарыяда эки тандоо: Өзүм алам • Малчы жалдайм',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => context.go('/search'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                                ),
                                child: const Column(
                                  children: [
                                    Text(
                                      'Өзүм алам',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Сатуучудан алуу',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => context.push('/caretakers'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0B547),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Column(
                                  children: [
                                    Text(
                                      'Малчы жалдайм',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1B4332),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Пайда алам',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF1B4332),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Listings grid
              listingsAsync.when(
                data: (listings) {
                  if (listings.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          t(dict, 'common.noResults'),
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
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.58,
                      ),
                      itemCount: listings.length,
                      itemBuilder: (context, index) => ListingCard(
                        listing: listings[index],
                        dict: dict,
                        locale: locale,
                      ),
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('Something went wrong',
                            style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              ref.refresh(latestListingsProvider.future),
                          child: const Text('Try again'),
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
            const SizedBox(height: 4),
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
