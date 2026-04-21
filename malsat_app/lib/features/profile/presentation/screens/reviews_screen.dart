import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../domain/user_profile_model.dart';
import '../providers/profile_provider.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: dictAsync.when(
          data: (dict) => Text(
            t(dict, 'profile.reviews'),
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
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.refresh(myProfileProvider.future),
        child: profileAsync.when(
          data: (profile) {
            if (profile == null || profile.reviews.isEmpty) {
              return const _EmptyState();
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: profile.reviews.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _SummaryCard(
                    average: profile.trustScore,
                    count: profile.reviewsCount,
                  );
                }
                return _ReviewCard(review: profile.reviews[index - 1]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double average;
  final int count;

  const _SummaryCard({required this.average, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 36),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                average.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$count рецензия',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewItem review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  (review.reviewerName ?? '?').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName ?? 'Колдонуучу',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          size: 14,
                          color: i < review.rating
                              ? Colors.amber
                              : AppColors.border,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays == 0) return 'Бүгүн';
    if (diff.inDays == 1) return 'Кечээ';
    if (diff.inDays < 7) return '${diff.inDays} күн';
    return '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Icon(LucideIcons.star, size: 48, color: AppColors.textMuted),
        SizedBox(height: 12),
        Center(
          child: Text(
            'Рецензиялар жок',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
