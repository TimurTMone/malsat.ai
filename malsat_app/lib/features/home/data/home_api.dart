import '../../listing_detail/data/listing_api.dart';
import '../../listing_detail/domain/listing_model.dart';

class HomeApi {
  final ListingApi _listingApi;

  HomeApi(this._listingApi);

  Future<List<ListingModel>> getLatestListings() async {
    final response = await _listingApi.getListings(
      sort: 'newest',
      limit: 6,
      page: 1,
    );
    return response.listings;
  }
}
