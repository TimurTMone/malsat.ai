import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../../features/listing_detail/domain/listing_model.dart';
import '../../features/favorites/presentation/widgets/favorite_button.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final Map<String, dynamic>? dict;
  final String locale;

  const ListingCard({
    super.key,
    required this.listing,
    this.dict,
    this.locale = 'ky',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/listing/${listing.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo -- rounded, no border, dominant
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: listing.primaryImageUrl ?? _categoryFallback(listing.category),
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) =>
                        const _ImagePlaceholder(),
                    errorWidget: (ctx, url, err) =>
                        const _ImagePlaceholder(),
                  ),
                ),
              ),
              // Favorite button -- top right
              Positioned(
                top: 8,
                right: 8,
                child: FavoriteButton(
                  listingId: listing.id,
                  size: 20,
                  showBackground: true,
                ),
              ),
              // Premium badge
              if (listing.isPremium)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Text(
                      'TOP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              // Horse subcategory badge
              if (listing.category == 'HORSE' && listing.subcategory != null)
                Positioned(
                  top: 8,
                  left: listing.isPremium ? 50 : 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: listing.subcategory == 'KOK_BORU'
                          ? const Color(0xFF1565C0)
                          : const Color(0xFFB91C1C),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      listing.subcategory == 'KOK_BORU'
                          ? 'КӨК БӨРҮ'
                          : 'ЭТ',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              // Mode B — investable pill (bottom-left)
              if (listing.modeBEligible)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.trendingUp,
                            size: 10, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(
                          listing.modeBExpectedReturnPercent != null
                              ? 'Жалдаса +${listing.modeBExpectedReturnPercent}%'
                              : 'Жалдаса болот',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Location + verified
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
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),

          // Title
          Text(
            listing.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),

          // Price -- hero
          Text(
            _formatPrice(listing.priceKgs),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
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
    default: // CATTLE or unknown
      return 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Cow_%28Fleckvieh_breed%29_Oeschinensee_Slaunger_2009-07-07.jpg/800px-Cow_%28Fleckvieh_breed%29_Oeschinensee_Slaunger_2009-07-07.jpg';
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundSecondary,
      child: const Center(
        child: Icon(
          LucideIcons.image,
          size: 28,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
