import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/auctions_api.dart';
import '../../domain/auction_model.dart';

final auctionsApiProvider = Provider<AuctionsApi>((ref) {
  return AuctionsApi(ref.watch(dioProvider));
});

final auctionsListProvider = FutureProvider<AuctionsResponse>((ref) async {
  return ref.watch(auctionsApiProvider).getAuctions();
});

final auctionDetailProvider =
    FutureProvider.family<Auction, String>((ref, id) async {
  return ref.watch(auctionsApiProvider).getAuction(id);
});
