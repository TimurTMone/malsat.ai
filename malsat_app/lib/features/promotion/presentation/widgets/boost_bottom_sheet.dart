import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';

/// Bottom sheet that lets a seller "promote" (boost) their listing or drop.
/// 3 tiers; payment integration is the next step — for now, tapping a package
/// shows a "coming soon" snackbar so the demo flow is honest about state.
class BoostBottomSheet extends ConsumerWidget {
  /// Title of the listing/drop being promoted (shown in the header).
  final String itemTitle;

  /// Whether this is a meat drop (true) or a livestock listing/auction (false).
  /// Used only for display copy.
  final bool isMeatDrop;

  const BoostBottomSheet({
    super.key,
    required this.itemTitle,
    this.isMeatDrop = false,
  });

  static Future<void> show(
    BuildContext context, {
    required String itemTitle,
    bool isMeatDrop = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BoostBottomSheet(
        itemTitle: itemTitle,
        isMeatDrop: isMeatDrop,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.sparkles,
                    color: Color(0xFF92400E), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t(dict, 'boost.sheetTitle'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      t(dict, 'boost.sheetSubtitle'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            itemTitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 18),

          // Packages
          _PackageTile(
            label: t(dict, 'boost.pkgTop3Day'),
            sub: t(dict, 'boost.pkgTop3DaySub'),
            priceKgs: 200,
            badge: null,
            somLabel: t(dict, 'common.som'),
            onTap: () => _comingSoon(context, ref),
          ),
          const SizedBox(height: 10),
          _PackageTile(
            label: t(dict, 'boost.pkgPremium'),
            sub: t(dict, 'boost.pkgPremiumSub'),
            priceKgs: 1000,
            badge: t(dict, 'boost.pkgPremiumBadge'),
            highlighted: true,
            somLabel: t(dict, 'common.som'),
            onTap: () => _comingSoon(context, ref),
          ),
          const SizedBox(height: 10),
          _PackageTile(
            label: isMeatDrop ? t(dict, 'boost.pkgFeaturedDrop') : t(dict, 'boost.pkgFeaturedAuction'),
            sub: t(dict, 'boost.pkgFeaturedSub'),
            priceKgs: 500,
            badge: null,
            somLabel: t(dict, 'common.som'),
            onTap: () => _comingSoon(context, ref),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.info,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t(dict, 'boost.paymentSoon'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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

  void _comingSoon(BuildContext context, WidgetRef ref) {
    final dict = ref.read(dictionaryProvider).valueOrNull;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t(dict, 'boost.paymentSoonToast')),
        backgroundColor: const Color(0xFF92400E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  final String label;
  final String sub;
  final int priceKgs;
  final String? badge;
  final bool highlighted;
  final String somLabel;
  final VoidCallback onTap;

  const _PackageTile({
    required this.label,
    required this.sub,
    required this.priceKgs,
    required this.badge,
    this.highlighted = false,
    required this.somLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: highlighted
              ? const Color(0xFFFFFBEB)
              : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlighted ? const Color(0xFFFCD34D) : AppColors.border,
            width: highlighted ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB91C1C),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$priceKgs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: highlighted
                        ? const Color(0xFF92400E)
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  somLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
