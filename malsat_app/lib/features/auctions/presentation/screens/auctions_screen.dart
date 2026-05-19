import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/state/view_mode.dart';
import '../../../../core/widgets/view_mode_toggle.dart';
import '../../domain/auction_model.dart';
import '../providers/auctions_provider.dart';
import '../widgets/auction_card_compact.dart';
import '../widgets/auction_card_row.dart';

class AuctionsScreen extends ConsumerWidget {
  const AuctionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctionsAsync = ref.watch(auctionsListProvider);
    final viewMode = ref.watch(listingViewModeProvider);
    final dict = ref.watch(dictionaryProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () => ref.refresh(auctionsListProvider.future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Hero header
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C2D12), Color(0xFFB91C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.gavel,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t(dict, 'auctions.title'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                t(dict, 'auctions.subtitle'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _InfoChip(
                              icon: LucideIcons.zap,
                              label: t(dict, 'auctions.chipLive')),
                          const SizedBox(width: 8),
                          _InfoChip(
                              icon: LucideIcons.timer,
                              label: t(dict, 'auctions.chipEndingSoon')),
                          const SizedBox(width: 8),
                          _InfoChip(
                              icon: LucideIcons.users,
                              label:
                                  t(dict, 'auctions.chipManyParticipants')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Section header + view-mode toggle row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t(dict, 'auctions.liveAuctions'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const ViewModeToggle(),
                  ],
                ),
              ),
            ),
            // Auction list
            auctionsAsync.when(
              data: (resp) {
                if (resp.auctions.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.gavel,
                              size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(t(dict, 'auctions.noAuctions'),
                              style: const TextStyle(
                                  color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: _buildAuctionsSliver(
                      resp.auctions, viewMode, context),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.alertCircle,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 8),
                      Consumer(builder: (context, ref, _) {
                        final d = ref.watch(dictionaryProvider).valueOrNull;
                        return Text(t(d, 'auctions.failedLoad'));
                      }),
                      Consumer(builder: (context, ref, _) {
                        final d = ref.watch(dictionaryProvider).valueOrNull;
                        return TextButton(
                          onPressed: () =>
                              ref.refresh(auctionsListProvider.future),
                          child: Text(t(d, 'common.retry')),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildAuctionsSliver(
    List<Auction> auctions, ListingViewMode mode, BuildContext context) {
  switch (mode) {
    case ListingViewMode.large:
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AuctionCard(auction: auctions[index]),
          ),
          childCount: auctions.length,
        ),
      );
    case ListingViewMode.grid:
      final width = MediaQuery.of(context).size.width;
      final cols = width >= 900
          ? 4
          : width >= 600
              ? 3
              : 2;
      return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.66,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => AuctionCardCompact(auction: auctions[index]),
          childCount: auctions.length,
        ),
      );
    case ListingViewMode.list:
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => AuctionCardRow(auction: auctions[index]),
          childCount: auctions.length,
        ),
      );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuctionCard extends ConsumerWidget {
  final Auction auction;
  const _AuctionCard({required this.auction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    final photo =
        auction.media.isNotEmpty ? auction.media.first.mediaUrl : null;
    return GestureDetector(
      onTap: () => context.push('/auction/${auction.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: auction.isEndingSoon
                ? const Color(0xFFB91C1C)
                : AppColors.border,
            width: auction.isEndingSoon ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: photo != null
                        ? CachedNetworkImage(
                            imageUrl: photo,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.backgroundSecondary,
                              child: const Center(
                                child: Icon(LucideIcons.image,
                                    color: AppColors.textMuted),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.backgroundSecondary,
                              child: const Center(
                                child: Icon(LucideIcons.image,
                                    color: AppColors.textMuted),
                              ),
                            ),
                          )
                        : Container(color: AppColors.backgroundSecondary),
                  ),
                ),
                // Live badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: auction.isEndingSoon
                          ? const Color(0xFFB91C1C)
                          : AppColors.success,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          auction.isEndingSoon
                              ? t(dict, 'auctions.endingSoonFull')
                              : t(dict, 'auctions.live'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Time left
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.clock,
                            size: 11, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(
                          auction.timeLeftText,
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
            // Card body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auction.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          auction.bazaarName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Bid info row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t(dict, 'auctions.currentBid'),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatPrice(auction.currentBid),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.users,
                                  size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 3),
                              Text(
                                t(dict, 'auctions.bidCount', {'n': '${auction.bidCount}'}),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(LucideIcons.eye,
                                  size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 3),
                              Text(
                                '${auction.viewsCount}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
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

  String _formatPrice(int price) {
    final str = price.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return '$buf c';
  }
}
