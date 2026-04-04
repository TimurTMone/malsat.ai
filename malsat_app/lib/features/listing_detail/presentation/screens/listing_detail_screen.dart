import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../domain/listing_model.dart';
import '../providers/listing_providers.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../../messages/data/messages_api.dart';
import '../../../messages/presentation/providers/messages_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ListingDetailScreen extends ConsumerWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingDetailProvider(listingId));
    final dictAsync = ref.watch(dictionaryProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      body: dictAsync.when(
        data: (dict) => listingAsync.when(
          data: (listing) => _DetailContent(
            listing: listing,
            dict: dict,
            locale: locale.languageCode,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t(dict, 'common.error')),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      ref.refresh(listingDetailProvider(listingId).future),
                  child: Text(t(dict, 'common.loading')),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Error')),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final ListingModel listing;
  final Map<String, dynamic> dict;
  final String locale;

  const _DetailContent({
    required this.listing,
    required this.dict,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Image + app bar
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              leading: _CircleButton(
                icon: Icons.arrow_back,
                onTap: () => context.pop(),
              ),
              actions: [
                _CircleButton(
                  icon: LucideIcons.share2,
                  onTap: () {},
                ),
                const SizedBox(width: 4),
                FavoriteButton(
                  listingId: listing.id,
                  size: 22,
                  showBackground: true,
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: listing.media.isNotEmpty
                    ? _MediaCarousel(media: listing.media)
                    : Container(
                        color: const Color(0xFFE5E7EB),
                        child: const Center(
                          child: Icon(LucideIcons.image,
                              size: 48, color: Color(0xFF9CA3AF)),
                        ),
                      ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium badge
                    if (listing.isPremium)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.crown,
                                  size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                t(dict, 'listing.premium'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Price
                    Text(
                      _formatPrice(listing.priceKgs),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Location + stats row
                    Row(
                      children: [
                        if (listing.village != null || listing.region != null) ...[
                          const Icon(LucideIcons.mapPin,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            _locationText(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        const Icon(LucideIcons.eye,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${listing.viewsCount}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(LucideIcons.heart,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${listing.favoritesCount}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Details grid
                    _DetailsGrid(listing: listing, dict: dict),
                    const SizedBox(height: 16),

                    // Vet certificate badge
                    if (listing.hasVetCert)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.shieldCheck,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              t(dict, 'listing.hasVetCert'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Description
                    if (listing.description != null &&
                        listing.description!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        t(dict, 'listing.description'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        listing.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],

                    // Seller card
                    if (listing.seller != null) ...[
                      const SizedBox(height: 24),
                      _SellerCard(
                        seller: listing.seller!,
                        dict: dict,
                        locale: locale,
                      ),
                    ],

                    // Bottom padding for contact buttons
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Fixed contact buttons
        if (listing.seller != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makeCall(listing.seller!.phone),
                    icon: const Icon(LucideIcons.phone, size: 18),
                    label: Text(t(dict, 'listing.call')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 52),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ChatButton(
                    sellerId: listing.seller!.id,
                    listingId: listing.id,
                    label: t(dict, 'listing.chat'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _makeCall(String phone) {
    launchUrl(Uri.parse('tel:$phone'));
  }

  String _locationText() {
    final parts = <String>[];
    if (listing.village != null) parts.add(listing.village!);
    if (listing.region != null) {
      parts.add(listing.region!.localizedName(locale));
    }
    return parts.join(', ');
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return '$buffer сом';
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

class _MediaCarousel extends StatefulWidget {
  final List media;

  const _MediaCarousel({required this.media});

  @override
  State<_MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<_MediaCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.media.length,
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemBuilder: (context, index) {
            final m = widget.media[index];
            return CachedNetworkImage(
              imageUrl: m.mediaUrl,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => Container(
                color: AppColors.background,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (ctx, url, err) => Container(
                color: AppColors.background,
                child: const Center(
                  child: Icon(LucideIcons.imageOff,
                      size: 40, color: AppColors.textMuted),
                ),
              ),
            );
          },
        ),
        if (widget.media.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.media.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _currentPage
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DetailsGrid extends StatelessWidget {
  final ListingModel listing;
  final Map<String, dynamic> dict;

  const _DetailsGrid({required this.listing, required this.dict});

  @override
  Widget build(BuildContext context) {
    final items = <_DetailItem>[];

    items.add(_DetailItem(
      label: t(dict, 'listing.category'),
      value: t(dict, 'categories.${listing.category.toLowerCase()}'),
    ));

    if (listing.breed != null) {
      items.add(_DetailItem(
        label: t(dict, 'listing.breed'),
        value: listing.breed!,
      ));
    }

    if (listing.ageMonths != null) {
      items.add(_DetailItem(
        label: t(dict, 'listing.age'),
        value: '${listing.ageMonths} ${t(dict, 'common.months')}',
      ));
    }

    if (listing.weightKg != null) {
      items.add(_DetailItem(
        label: t(dict, 'listing.weight'),
        value: '${listing.weightKg} ${t(dict, 'common.kg')}',
      ));
    }

    if (listing.gender != null) {
      final genderKey =
          listing.gender == 'MALE' ? 'gender.male' : 'gender.female';
      items.add(_DetailItem(
        label: t(dict, 'common.all'), // Gender label
        value: t(dict, genderKey),
      ));
    }

    if (listing.healthStatus != null) {
      items.add(_DetailItem(
        label: t(dict, 'listing.healthStatus'),
        value: listing.healthStatus!,
      ));
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 8,
      children: items
          .map((item) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});
}

class _SellerCard extends StatelessWidget {
  final dynamic seller;
  final Map<String, dynamic> dict;
  final String locale;

  const _SellerCard({
    required this.seller,
    required this.dict,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/user/${seller.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  seller.initials,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        seller.displayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (seller.isVerifiedBreeder) ...[
                        const SizedBox(width: 6),
                        const Icon(LucideIcons.badgeCheck,
                            size: 16, color: AppColors.primary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        seller.trustScore.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight,
                size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ChatButton extends ConsumerWidget {
  final String sellerId;
  final String listingId;
  final String label;

  const _ChatButton({
    required this.sellerId,
    required this.listingId,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuth = ref.watch(isAuthenticatedProvider);

    return OutlinedButton.icon(
      onPressed: () async {
        if (!isAuth) {
          context.push('/auth/login');
          return;
        }

        try {
          final api = ref.read(messagesApiProvider);
          final conv = await api.createConversation(
            sellerId: sellerId,
            listingId: listingId,
          );
          if (context.mounted) {
            context.push('/chat/${conv['id']}');
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      },
      icon: const Icon(LucideIcons.messageCircle, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
      ),
    );
  }
}
