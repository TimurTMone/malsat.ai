import 'listing_media_model.dart';
import 'seller_model.dart';
import 'region_model.dart';

class ListingModel {
  final String id;
  final String sellerId;
  final String category;
  final String? subcategory;
  final String? breed;
  final String title;
  final String? description;
  final int priceKgs;
  final int? ageMonths;
  final double? weightKg;
  final String? gender;
  final String? healthStatus;
  final bool hasVetCert;
  final double? locationLat;
  final double? locationLng;
  final String? regionId;
  final String? village;
  final String status;
  final int viewsCount;
  final int favoritesCount;
  final bool isPremium;
  final DateTime createdAt;
  final List<ListingMediaModel> media;
  final SellerModel? seller;
  final RegionModel? region;
  final bool isFavorited;
  // Mode B — invest instead of direct-buy
  final bool modeBEligible;
  final int? modeBMinInvestmentKgs;
  final int? modeBExpectedReturnPercent;
  final int? modeBDurationMonths;
  final String? modeBCaretakerName;

  const ListingModel({
    required this.id,
    required this.sellerId,
    required this.category,
    this.subcategory,
    this.breed,
    required this.title,
    this.description,
    required this.priceKgs,
    this.ageMonths,
    this.weightKg,
    this.gender,
    this.healthStatus,
    this.hasVetCert = false,
    this.locationLat,
    this.locationLng,
    this.regionId,
    this.village,
    this.status = 'ACTIVE',
    this.viewsCount = 0,
    this.favoritesCount = 0,
    this.isPremium = false,
    required this.createdAt,
    this.media = const [],
    this.seller,
    this.region,
    this.isFavorited = false,
    this.modeBEligible = false,
    this.modeBMinInvestmentKgs,
    this.modeBExpectedReturnPercent,
    this.modeBDurationMonths,
    this.modeBCaretakerName,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as String,
      sellerId: json['sellerId'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      breed: json['breed'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      priceKgs: json['priceKgs'] as int,
      ageMonths: json['ageMonths'] as int?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      gender: json['gender'] as String?,
      healthStatus: json['healthStatus'] as String?,
      hasVetCert: json['hasVetCert'] as bool? ?? false,
      locationLat: (json['locationLat'] as num?)?.toDouble(),
      locationLng: (json['locationLng'] as num?)?.toDouble(),
      regionId: json['regionId'] as String?,
      village: json['village'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      viewsCount: json['viewsCount'] as int? ?? 0,
      favoritesCount: json['favoritesCount'] as int? ?? 0,
      isPremium: json['isPremium'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      media: (json['media'] as List<dynamic>?)
              ?.map((m) =>
                  ListingMediaModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      seller: json['seller'] != null
          ? SellerModel.fromJson(json['seller'] as Map<String, dynamic>)
          : null,
      region: json['region'] != null
          ? RegionModel.fromJson(json['region'] as Map<String, dynamic>)
          : null,
      isFavorited: json['isFavorited'] as bool? ?? false,
      modeBEligible: json['modeBEligible'] as bool? ?? false,
      modeBMinInvestmentKgs: json['modeBMinInvestmentKgs'] as int?,
      modeBExpectedReturnPercent: json['modeBExpectedReturnPercent'] as int?,
      modeBDurationMonths: json['modeBDurationMonths'] as int?,
      modeBCaretakerName: json['modeBCaretakerName'] as String?,
    );
  }

  String? get primaryImageUrl {
    if (media.isEmpty) return null;
    final primary = media.where((m) => m.isPrimary).toList();
    if (primary.isNotEmpty) return primary.first.mediaUrl;
    return media.first.mediaUrl;
  }

}

class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  bool get hasNextPage => page < totalPages;
}

class ListingsResponse {
  final List<ListingModel> listings;
  final PaginationModel pagination;

  const ListingsResponse({
    required this.listings,
    required this.pagination,
  });

  factory ListingsResponse.fromJson(Map<String, dynamic> json) {
    return ListingsResponse(
      listings: (json['listings'] as List<dynamic>)
          .map((l) => ListingModel.fromJson(l as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(
          json['pagination'] as Map<String, dynamic>),
    );
  }
}
