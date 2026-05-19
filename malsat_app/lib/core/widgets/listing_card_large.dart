import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../i18n/app_localizations.dart';
import 'pressable_scale.dart';
import '../../features/listing_detail/domain/listing_model.dart';
import '../../features/favorites/presentation/widgets/favorite_button.dart';

/// Full-width hero listing card. One per row.
class ListingCardLarge extends ConsumerWidget {
  final ListingModel listing;
  final String locale;

  const ListingCardLarge({
    super.key,
    required this.listing,
    this.locale = 'ky',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    return PressableScale(
      onTap: () => context.push('/listing/${listing.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image with gradient legibility overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Hero(
                      tag: 'listing-${listing.id}',
                      child: CachedNetworkImage(
                        imageUrl: listing.primaryImageUrl ??
                            _categoryFallback(listing.category),
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => Container(
                          color: AppColors.backgroundSecondary,
                          child: const Center(
                            child: Icon(LucideIcons.image,
                                size: 36, color: AppColors.textMuted),
                          ),
                        ),
                        errorWidget: (ctx, url, err) => Container(
                          color: AppColors.backgroundSecondary,
                          child: const Center(
                            child: Icon(LucideIcons.image,
                                size: 36, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Top fade for badge legibility
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (listing.isPremium)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0B547),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t(dict, 'listing.topBadge'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B4332),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                if (listing.category == 'HORSE' && listing.subcategory != null)
                  Positioned(
                    top: 10,
                    left: listing.isPremium ? 56 : 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: listing.subcategory == 'KOK_BORU'
                            ? const Color(0xFF1565C0)
                            : const Color(0xFFB91C1C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        listing.subcategory == 'KOK_BORU'
                            ? t(dict, 'listing.kokBoruBadge')
                            : t(dict, 'listing.meatBadge'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(
                    listingId: listing.id,
                    size: 22,
                    showBackground: true,
                  ),
                ),
                if (listing.modeBEligible)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.trendingUp,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            listing.modeBExpectedReturnPercent != null
                                ? t(dict, 'listing.rentBadge', {'p': '${listing.modeBExpectedReturnPercent}'})
                                : t(dict, 'listing.rentAvailable'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Body — Unaa-style: price hero (left) + location (right), title below
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatPrice(listing.priceKgs),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.6,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              listing.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                height: 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (listing.seller?.isVerifiedBreeder ??
                                  false) ...[
                                const Icon(LucideIcons.badgeCheck,
                                    size: 13, color: AppColors.primary),
                                const SizedBox(width: 3),
                              ],
                              const Icon(LucideIcons.mapPin,
                                  size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 3),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 140),
                                child: Text(
                                  _locationText(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  String _locationText() {
    final parts = <String>[];
    if (listing.village != null) parts.add(listing.village!);
    if (listing.region != null) {
      parts.add(listing.region!.localizedName(locale));
    }
    return parts.isNotEmpty ? parts.join(', ') : '';
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return '$buffer c';
  }
}

String _categoryFallback(String? category) {
  switch (category) {
    case 'HORSE':
      return 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Biandintz_eta_zaldiak_-_modified2.jpg/1200px-Biandintz_eta_zaldiak_-_modified2.jpg';
    case 'SHEEP':
      return 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Flock_of_sheep.jpg/800px-Flock_of_sheep.jpg';
    case 'ARASHAN':
      return 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Hausziege_04.jpg/800px-Hausziege_04.jpg';
    default:
      return 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Cow_%28Fleckvieh_breed%29_Oeschinensee_Slaunger_2009-07-07.jpg/800px-Cow_%28Fleckvieh_breed%29_Oeschinensee_Slaunger_2009-07-07.jpg';
  }
}
