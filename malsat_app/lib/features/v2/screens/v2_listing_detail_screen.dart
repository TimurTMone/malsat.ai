import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../v2_listings_data.dart';
import '../v2_theme.dart';

/// MalSat v2 — Listing detail.
///
/// One animal, one price, one seller, two ways to act: CALL or BUY.
/// CALL is primary (white-on-ink, top) because farmers/parents verify
/// by voice before buying. BUY is secondary (terracotta).
class V2ListingDetailScreen extends StatelessWidget {
  final String id;
  const V2ListingDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final l = v2ListingById(id);
    if (l == null) {
      return Scaffold(
        backgroundColor: V2.paper,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                V2BackButton(onTap: () => context.pop()),
                const SizedBox(height: 24),
                const Text('Объявление не найдено',
                    style: TextStyle(fontSize: 18, color: V2.ink)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: V2.paper,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailHero(listing: l),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatPrice(l.priceKgs)} сом',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: V2.ink,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '~${l.pricePerKg} сом/кг',
                      style: const TextStyle(
                        fontSize: 16,
                        color: V2.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _InfoRow(
                      icon: Icons.location_on,
                      kyText: l.villageKy,
                      ruText: l.villageRu,
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(
                      icon: Icons.person,
                      kyText: l.sellerName,
                      ruText: 'Продавец · Сатуучу',
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(
                      icon: Icons.scale,
                      kyText: l.detailKy,
                      ruText: l.detailRu,
                    ),
                  ],
                ),
              ),
            ),
            _ActionBar(listing: l),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int p) {
    final s = p.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _DetailHero extends StatelessWidget {
  final V2Listing listing;
  const _DetailHero({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            listing.tone,
            Color.lerp(listing.tone, const Color(0xFF1A1614), 0.5)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.3, -0.5),
                  radius: 1.0,
                  colors: [Color(0x33FFFFFF), Color(0x00000000)],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
              child: V2BackButton(
                onTap: () => context.pop(),
                color: V2.paper,
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: V2.paper.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '~${listing.weightKg} кг',
                    style: const TextStyle(
                      color: V2.paper,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  listing.kindKy,
                  style: const TextStyle(
                    color: V2.paper,
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  listing.kindRu,
                  style: TextStyle(
                    color: V2.paper.withValues(alpha: 0.88),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String kyText;
  final String ruText;
  const _InfoRow({
    required this.icon,
    required this.kyText,
    required this.ruText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: V2.muted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kyText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: V2.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                ruText,
                style: const TextStyle(
                  fontSize: 14,
                  color: V2.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  final V2Listing listing;
  const _ActionBar({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: V2.paper,
        border: Border(top: BorderSide(color: V2.mist, width: 1.2)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CALL — the primary action for parents/farmers.
            V2BigCta(
              label: 'ЧАЛУУ · Позвонить',
              sublabel: listing.sellerPhone,
              icon: Icons.phone,
              onTap: () {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('v2: dials ${listing.sellerPhone}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            V2BigCta(
              label: 'САТЫП АЛУУ · Купить',
              accent: true,
              onTap: () {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'v2: in-app purchase flow goes here'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
