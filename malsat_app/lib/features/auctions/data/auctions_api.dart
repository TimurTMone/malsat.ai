import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../domain/auction_model.dart';

class AuctionsApi {
  final Dio _dio;
  AuctionsApi(this._dio);

  Future<AuctionsResponse> getAuctions({
    String? category,
    String? status,
    String sort = 'ending_soon',
    int page = 1,
    int limit = 20,
  }) async {
    final resp = await _dio.get(
      ApiEndpoints.auctions,
      queryParameters: {
        if (category != null) 'category': category,
        if (status != null) 'status': status,
        'sort': sort,
        'page': page,
        'limit': limit,
      },
    );
    return AuctionsResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Auction> getAuction(String id) async {
    final resp = await _dio.get(ApiEndpoints.auction(id));
    return Auction.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Auction> placeBid(String id, int amount) async {
    final resp = await _dio.post(
      ApiEndpoints.auctionBid(id),
      data: {'amount': amount},
    );
    final data = resp.data as Map<String, dynamic>;
    return Auction.fromJson(data['auction'] as Map<String, dynamic>);
  }
}
