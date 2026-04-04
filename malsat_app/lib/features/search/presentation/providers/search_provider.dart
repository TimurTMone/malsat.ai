import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/search_filters.dart';
import '../../../listing_detail/domain/listing_model.dart';
import '../../../listing_detail/presentation/providers/listing_providers.dart';

final searchFiltersProvider =
    StateNotifierProvider<SearchFiltersNotifier, SearchFilters>((ref) {
  return SearchFiltersNotifier();
});

class SearchFiltersNotifier extends StateNotifier<SearchFilters> {
  SearchFiltersNotifier() : super(const SearchFilters());

  void setCategory(String? category) {
    // Toggle: if same category, clear it
    if (state.category == category) {
      state = state.copyWith(category: () => null);
    } else {
      state = state.copyWith(category: () => category);
    }
  }

  void setSort(String sort) {
    state = state.copyWith(sort: sort);
  }

  void setPriceRange(int? min, int? max) {
    state = state.copyWith(
      minPrice: () => min,
      maxPrice: () => max,
    );
  }

  void setBreed(String? breed) {
    state = state.copyWith(breed: () => breed);
  }

  void setGender(String? gender) {
    state = state.copyWith(gender: () => gender);
  }

  void clearAll() {
    state = const SearchFilters();
  }
}

/// Paginated search results
final searchPageProvider = StateProvider<int>((ref) => 1);

final searchResultsProvider =
    FutureProvider<ListingsResponse>((ref) async {
  final filters = ref.watch(searchFiltersProvider);
  final page = ref.watch(searchPageProvider);
  final repo = ref.read(listingRepositoryProvider);

  return repo.getListings(
    category: filters.category,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice,
    regionId: filters.regionId,
    breed: filters.breed,
    gender: filters.gender,
    sort: filters.sort,
    page: page,
    limit: 20,
  );
});
