import '../domain/listing_model.dart';
import 'listing_api.dart';

class ListingRepository {
  final ListingApi _api;

  ListingRepository(this._api);

  Future<ListingsResponse> getListings({
    String? category,
    int? minPrice,
    int? maxPrice,
    String? regionId,
    String? breed,
    String? gender,
    String sort = 'newest',
    int page = 1,
    int limit = 20,
  }) {
    return _api.getListings(
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      regionId: regionId,
      breed: breed,
      gender: gender,
      sort: sort,
      page: page,
      limit: limit,
    );
  }

  Future<ListingModel> getListing(String id) => _api.getListing(id);
}
