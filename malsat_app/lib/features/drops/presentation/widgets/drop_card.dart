import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/theme/app_world.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../domain/drop_model.dart';

/// Full-width hero card for a meat drop.
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
    final accent = AppWorldPalette.of(context).accent;
    final photo = drop.media.isNotEmpty
        ? drop.media.first.mediaUrl
        : _fallbackPhotos[drop.category];
    final daysLeft = drop.daysUntilButcher;

    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: CachedNetworkImage(
                      imageUrl: photo ?? _fallbackPhotos['CATTLE']!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: AppColors.backgroundSecondary,
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.backgroundSecondary,
                        child: const Icon(LucideIcons.beef,
                            size: 40, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: _StatusBadge(
                      label: t(dict, 'dropStatus.${drop.status}'),
                      color: _statusColor(drop.status),
                    ),
                  ),
                  if (drop.isOpen && daysLeft >= 0)
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: _CountdownBadge(
                        label: daysLeft == 0
                            ? t(dict, 'common.today')
                            : daysLeft == 1
                                ? t(dict, 'common.tomorrow')
                                : t(dict, 'common.daysShort',
                                    {'n': '$daysLeft'}),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drop.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${drop.pricePerKg} ${t(dict, 'common.somPerKg')}',
                    style: AppTypography.priceLarge.copyWith(
                      fontSize: 18,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ProgressBar(
                    percent: drop.progressPercent,
                    accent: accent,
                    label: t(dict, 'drop.kgClaimed', {
                      'claimed': drop.claimedWeightKg.toStringAsFixed(0),
                      'total': drop.totalWeightKg.toStringAsFixed(0),
                    }),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin,
                          size: 13, color: AppColors.textMuted),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          drop.village ?? drop.region?.nameKy ?? '',
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(LucideIcons.users,
                          size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        '${drop.orderCount}',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
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

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  final String label;

  const _CountdownBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.clock, size: 11, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int percent;
  final Color accent;
  final String label;

  const _ProgressBar({
    required this.percent,
    required this.accent,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: AppColors.backgroundSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
