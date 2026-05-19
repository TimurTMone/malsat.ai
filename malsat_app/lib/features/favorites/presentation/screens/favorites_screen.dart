import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/widgets/listing_card.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);
    final locale = ref.watch(localeProvider);
    final favoritesAsync = ref.watch(favoritesListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: dictAsync.when(
          data: (dict) => Text(
            t(dict, 'favorites.title'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          loading: () => const Text(''),
          error: (_, _) => const Text(''),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: dictAsync.when(
        data: (dict) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.refresh(favoritesListProvider.future),
          child: favoritesAsync.when(
            data: (listings) {
              if (listings.isEmpty) {
                return _EmptyState(dict: dict);
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemCount: listings.length,
                itemBuilder: (context, index) => ListingCard(
                  listing: listings[index],
                  dict: dict,
                  locale: locale.languageCode,
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorState(
              message: e.toString(),
              dict: dict,
              onRetry: () => ref.refresh(favoritesListProvider.future),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Map<String, dynamic> dict;
  const _EmptyState({required this.dict});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        const Icon(LucideIcons.heart, size: 48, color: AppColors.textMuted),
        const SizedBox(height: 12),
        Center(
          child: Text(
            t(dict, 'favorites.empty'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            t(dict, 'favorites.emptySub'),
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Map<String, dynamic> dict;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.dict, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        const Icon(LucideIcons.alertCircle,
            size: 48, color: AppColors.error),
        const SizedBox(height: 12),
        Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: onRetry,
            child: Text(t(dict, 'common.retry')),
          ),
        ),
      ],
    );
  }
}
