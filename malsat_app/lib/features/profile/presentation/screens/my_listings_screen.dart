import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/widgets/listing_card.dart';
import '../providers/profile_provider.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);
    final locale = ref.watch(localeProvider);
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: dictAsync.when(
          data: (dict) => Text(
            t(dict, 'profile.myListings'),
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
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            color: AppColors.primary,
            onPressed: () => context.push('/sell'),
            tooltip: dictAsync.valueOrNull != null
                ? t(dictAsync.valueOrNull, 'listing.create')
                : null,
          ),
        ],
      ),
      body: dictAsync.when(
        data: (dict) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.refresh(myProfileProvider.future),
          child: profileAsync.when(
            data: (profile) {
              if (profile == null || profile.listings.isEmpty) {
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
                itemCount: profile.listings.length,
                itemBuilder: (context, index) => ListingCard(
                  listing: profile.listings[index],
                  dict: dict,
                  locale: locale.languageCode,
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
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
        const Icon(LucideIcons.package, size: 48, color: AppColors.textMuted),
        const SizedBox(height: 12),
        Center(
          child: Text(
            t(dict, 'myListings.empty'),
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
            t(dict, 'myListings.emptySub'),
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
