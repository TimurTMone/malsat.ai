import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../v2_bottom_nav.dart';
import '../v2_listings_data.dart';
import '../v2_theme.dart';

/// MalSat v2 — Home (Lalafo/OLX-style marketplace).
///
/// Familiar pattern: header, search bar, category chips, 2-column grid
/// of listing cards, bottom nav. Same vocabulary as every marketplace
/// users already know. Bottom nav makes the browse/event separation
/// unmistakable.
class V2HomeScreen extends StatefulWidget {
  const V2HomeScreen({super.key});

  @override
  State<V2HomeScreen> createState() => _V2HomeScreenState();
}

class _V2HomeScreenState extends State<V2HomeScreen> {
  V2Category _active = V2Category.all;
  String _query = '';

  List<V2Listing> get _filtered {
    final q = _query.trim().toLowerCase();
    return v2Listings.where((l) {
      if (_active != V2Category.all && l.category != _active) return false;
      if (q.isEmpty) return true;
      return l.kindKy.toLowerCase().contains(q) ||
          l.kindRu.toLowerCase().contains(q) ||
          l.villageKy.toLowerCase().contains(q) ||
          l.villageRu.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: V2.paper,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            _SearchBar(
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            _CategoryChips(
              active: _active,
              onPick: (c) {
                HapticFeedback.selectionClick();
                setState(() => _active = c);
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? const _Empty()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.66,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) =>
                          _ListingCard(listing: filtered[i]),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const V2BottomNav(currentIndex: 0),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Row(
        children: [
          const Text(
            'MalSat',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: V2.ink,
            ),
          ),
          const Spacer(),
          IconButton(
            iconSize: 26,
            color: V2.ink,
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEAE0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: V2.muted, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: const TextStyle(fontSize: 16, color: V2.ink),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Издөө · Поиск',
                  hintStyle: TextStyle(color: V2.muted, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final V2Category active;
  final ValueChanged<V2Category> onPick;

  const _CategoryChips({required this.active, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: V2Category.values.map((c) {
          final isActive = c == active;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onPick(c),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? V2.ink : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? V2.ink : V2.mist,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  c.ky,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? V2.paper : V2.ink,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final V2Listing listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: V2.paper,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/v2/listing/${listing.id}');
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: V2.mist, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Thumb(listing: listing),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_fmt(listing.priceKgs)} сом',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: V2.ink,
                        fontFeatures: [FontFeature.tabularFigures()],
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing.detailKy,
                      style: const TextStyle(
                        fontSize: 14,
                        color: V2.ink,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 13, color: V2.muted),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${listing.villageKy} · ${listing.agoKy}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: V2.muted,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  String _fmt(int p) {
    final s = p.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _Thumb extends StatelessWidget {
  final V2Listing listing;
  const _Thumb({required this.listing});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(14),
        topRight: Radius.circular(14),
      ),
      child: AspectRatio(
        aspectRatio: 1.05,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                listing.tone.withValues(alpha: 0.85),
                Color.lerp(listing.tone, const Color(0xFF1A1614), 0.4)!,
              ],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  listing.kindKy,
                  style: TextStyle(
                    color: V2.paper.withValues(alpha: 0.92),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xCC000000),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '~${listing.weightKg} кг',
                    style: const TextStyle(
                      color: V2.paper,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: V2.muted),
            const SizedBox(height: 12),
            const Text(
              'Эч нерсе табылган жок',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: V2.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text('Ничего не найдено',
                style: const TextStyle(color: V2.muted, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
