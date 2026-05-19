import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../domain/drop_model.dart';

class DropCard extends ConsumerWidget {
  final ButcherDrop drop;
  final VoidCallback onTap;

  const DropCard({super.key, required this.drop, required this.onTap});

  static const _fallbackPhotos = {
    'CATTLE': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Cow_%28Fleckvieh_breed%29_Oeschinensee_Slaunger_2009-07-07.jpg/800px-Cow_%28Fleckvieh_breed%29_Oeschinensee_Slaunger_2009-07-07.jpg',
    'SHEEP': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Flock_of_sheep.jpg/800px-Flock_of_sheep.jpg',
    'HORSE': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Biandintz_eta_zaldiak_-_modified2.jpg/1200px-Biandintz_eta_zaldiak_-_modified2.jpg',
    'ARASHAN': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Hausziege_04.jpg/800px-Hausziege_04.jpg',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    final photo = drop.media.isNotEmpty
        ? drop.media.first.mediaUrl
        : _fallbackPhotos[drop.category];
    final daysLeft = drop.daysUntilButcher;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with status badge and countdown
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: CachedNetworkImage(
                      imageUrl: photo ?? _fallbackPhotos['CATTLE']!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.backgroundSecondary,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.backgroundSecondary,
                        child: const Icon(LucideIcons.beef,
                            size: 40, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(drop.status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t(dict, 'dropStatus.${drop.status}'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Countdown badge
                  if (drop.isOpen && daysLeft >= 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.clock,
                                size: 11, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              daysLeft == 0
                                  ? t(dict, 'common.today')
                                  : daysLeft == 1
                                      ? t(dict, 'common.tomorrow')
                                      : t(dict, 'common.daysShort',
                                          {'n': '$daysLeft'}),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    drop.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Price per kg — big and bold
                  Text(
                    '${drop.pricePerKg} ${t(dict, 'common.somPerKg')}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Progress bar — the key UX element
                  _ProgressBar(
                    claimed: drop.claimedWeightKg,
                    total: drop.totalWeightKg,
                    percent: drop.progressPercent,
                    label: t(dict, 'drop.kgClaimed', {
                      'claimed': drop.claimedWeightKg.toStringAsFixed(0),
                      'total': drop.totalWeightKg.toStringAsFixed(0),
                    }),
                  ),
                  const SizedBox(height: 8),

                  // Location + orders
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          drop.village ?? drop.region?.nameKy ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(LucideIcons.users,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        '${drop.orderCount}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'OPEN':
        return AppColors.success;
      case 'UPCOMING':
        return AppColors.boostBlue;
      case 'SOLD_OUT':
        return AppColors.accent;
      case 'FULFILLED':
        return AppColors.primaryDark;
      default:
        return AppColors.textMuted;
    }
  }

}

class _ProgressBar extends StatelessWidget {
  final double claimed;
  final double total;
  final int percent;
  final String label;

  const _ProgressBar({
    required this.claimed,
    required this.total,
    required this.percent,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: AppColors.backgroundSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 80 ? AppColors.accent : AppColors.primary,
              ),
            ),
          ),
        ),
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
    );
  }
}
