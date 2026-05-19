import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../i18n/app_localizations.dart';
import 'pressable_scale.dart';
import '../../features/listing_detail/domain/listing_model.dart';
import '../../features/favorites/presentation/widgets/favorite_button.dart';

/// List-row variant of [ListingCard]. Horizontal layout: photo on the left,
/// info on the right. Each card takes the full row width.
class ListingCardRow extends StatelessWidget {
  final ListingModel listing;
  final Map<String, dynamic>? dict;
  final String locale;

  const ListingCardRow({
    super.key,
    required this.listing,
    this.dict,
    this.locale = 'ky',
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => context.push('/listing/${listing.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Photo -- 110×110, rounded only on the left
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: CachedNetworkImage(
                      imageUrl: listing.primaryImageUrl ??
                          _categoryFallback(listing.category),
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => Container(
                        color: AppColors.backgroundSecondary,
                        child: const Center(
                          child: Icon(LucideIcons.image,
                              size: 24, color: AppColors.textMuted),
                        ),
                      ),
                      errorWidget: (ctx, url, err) => Container(
                        color: AppColors.backgroundSecondary,
                        child: const Center(
                          child: Icon(LucideIcons.image,
                              size: 24, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ),
                ),
                if (listing.isPremium)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        t(dict, 'listing.topBadge'),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Info column
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          listing.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Location
                        Row(
                          children: [
                            if (listing.seller?.isVerifiedBreeder ?? false) ...[
                              const Icon(LucideIcons.badgeCheck,
                                  size: 12, color: AppColors.primary),
                              const SizedBox(width: 3),
                            ],
                            Expanded(
                              child: Text(
                                _locationText(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Mode B pill (inline, optional)
                        if (listing.modeBEligible)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.trendingUp,
                                    size: 10, color: AppColors.primary),
                                const SizedBox(width: 3),
                                Text(
                                  listing.modeBExpectedReturnPercent != null
                                      ? '+${listing.modeBExpectedReturnPercent}%'
                                      : t(dict, 'listing.rentAvailable'),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    // Price + favorite row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            _formatPrice(listing.priceKgs),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        FavoriteButton(
                          listingId: listing.id,
                          size: 18,
                          showBackground: false,
                        ),
                      ],
                    ),
                  ],
                ),
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
