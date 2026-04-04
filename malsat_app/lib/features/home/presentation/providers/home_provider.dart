import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/home_api.dart';
import '../../../listing_detail/domain/listing_model.dart';
import '../../../listing_detail/presentation/providers/listing_providers.dart';

final homeApiProvider = Provider<HomeApi>((ref) {
  final listingApi = ref.read(listingApiProvider);
  return HomeApi(listingApi);
});

final latestListingsProvider =
    FutureProvider<List<ListingModel>>((ref) async {
  final api = ref.read(homeApiProvider);
  return api.getLatestListings();
});
