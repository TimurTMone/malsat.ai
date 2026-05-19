import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Layout the user has picked for browsing marketplace listings, drops,
/// and auctions. Persists across the bazaar's section chips so the user
/// only needs to choose once.
enum ListingViewMode {
  /// One full-width hero card per row. Default — most context, biggest visuals.
  large,

  /// Two compact cards per row.
  grid,

  /// Tightly packed list — small photo on the left, info on the right.
  list,
}

final listingViewModeProvider =
    StateProvider<ListingViewMode>((ref) => ListingViewMode.large);
