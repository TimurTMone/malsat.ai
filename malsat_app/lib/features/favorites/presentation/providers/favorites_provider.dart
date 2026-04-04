import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/favorites_api.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../listing_detail/domain/listing_model.dart';

final favoritesApiProvider = Provider<FavoritesApi>((ref) {
  final dio = ref.read(dioProvider);
  return FavoritesApi(dio);
});

/// Set of listing IDs that are currently favorited.
/// This is the source of truth for favorite state across the app.
final favoritedIdsProvider =
    StateNotifierProvider<FavoritedIdsNotifier, Set<String>>((ref) {
  return FavoritedIdsNotifier(ref);
});

class FavoritedIdsNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;

  FavoritedIdsNotifier(this._ref) : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final isAuth = _ref.read(isAuthenticatedProvider);
    if (!isAuth) return;

    try {
      final api = _ref.read(favoritesApiProvider);
      final favorites = await api.getFavorites();
      final ids = favorites
          .map((f) => f['listingId'] as String)
          .toSet();
      state = ids;
    } catch (_) {
      // Silently fail — favorites are non-critical
    }
  }

  Future<bool> toggle(String listingId) async {
    final api = _ref.read(favoritesApiProvider);
    final favorited = await api.toggleFavorite(listingId);

    if (favorited) {
      state = {...state, listingId};
    } else {
      state = state.where((id) => id != listingId).toSet();
    }
    return favorited;
  }

  void clear() => state = {};
}

/// Check if a specific listing is favorited.
final isFavoritedProvider = Provider.family<bool, String>((ref, listingId) {
  final ids = ref.watch(favoritedIdsProvider);
  return ids.contains(listingId);
});

/// Full favorites list with listing data.
final favoritesListProvider =
    FutureProvider<List<ListingModel>>((ref) async {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (!isAuth) return [];

  final api = ref.read(favoritesApiProvider);
  final favorites = await api.getFavorites();

  return favorites.map((f) {
    final listingJson = f['listing'] as Map<String, dynamic>;
    return ListingModel.fromJson(listingJson);
  }).toList();
});
