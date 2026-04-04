import '../../listing_detail/domain/listing_model.dart';
import '../../listing_detail/domain/region_model.dart';

class UserProfileModel {
  final String id;
  final String? name;
  final String? avatarUrl;
  final String? village;
  final String? bio;
  final double trustScore;
  final bool isVerifiedBreeder;
  final DateTime createdAt;
  final RegionModel? region;
  final int listingsCount;
  final int reviewsCount;
  final List<ListingModel> listings;
  final List<ReviewItem> reviews;

  const UserProfileModel({
    required this.id,
    this.name,
    this.avatarUrl,
    this.village,
    this.bio,
    this.trustScore = 0,
    this.isVerifiedBreeder = false,
    required this.createdAt,
    this.region,
    this.listingsCount = 0,
    this.reviewsCount = 0,
    this.listings = const [],
    this.reviews = const [],
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final counts = json['_count'] as Map<String, dynamic>? ?? {};

    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      village: json['village'] as String?,
      bio: json['bio'] as String?,
      trustScore: (json['trustScore'] as num?)?.toDouble() ?? 0,
      isVerifiedBreeder: json['isVerifiedBreeder'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      region: json['region'] != null
          ? RegionModel.fromJson(json['region'] as Map<String, dynamic>)
          : null,
      listingsCount: counts['listings'] as int? ?? 0,
      reviewsCount: counts['reviewsReceived'] as int? ?? 0,
      listings: (json['listings'] as List<dynamic>?)
              ?.map((l) => ListingModel.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
      reviews: (json['reviewsReceived'] as List<dynamic>?)
              ?.map((r) => ReviewItem.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get displayName => name ?? 'User';

  String get initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }
}

class ReviewItem {
  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? reviewerName;
  final String? reviewerAvatarUrl;

  const ReviewItem({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.reviewerName,
    this.reviewerAvatarUrl,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    final reviewer = json['reviewer'] as Map<String, dynamic>?;
    return ReviewItem(
      id: json['id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reviewerName: reviewer?['name'] as String?,
      reviewerAvatarUrl: reviewer?['avatarUrl'] as String?,
    );
  }
}
