class Auction {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String? subcategory;
  final int startingPrice;
  final int currentBid;
  final int bidIncrement;
  final int bidCount;
  final DateTime endsAt;
  final int minutesLeft;
  final String bazaarName;
  final String bazaarLocation;
  final String? village;
  final String status;
  final int viewsCount;
  final int watcherCount;
  final AuctionSeller seller;
  final AuctionRegion? region;
  final List<AuctionMedia> media;

  const Auction({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.subcategory,
    required this.startingPrice,
    required this.currentBid,
    required this.bidIncrement,
    required this.bidCount,
    required this.endsAt,
    required this.minutesLeft,
    required this.bazaarName,
    required this.bazaarLocation,
    this.village,
    required this.status,
    required this.viewsCount,
    required this.watcherCount,
    required this.seller,
    this.region,
    this.media = const [],
  });

  factory Auction.fromJson(Map<String, dynamic> json) {
    return Auction(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      startingPrice: (json['startingPrice'] as num).toInt(),
      currentBid: (json['currentBid'] as num).toInt(),
      bidIncrement: (json['bidIncrement'] as num).toInt(),
      bidCount: (json['bidCount'] as num).toInt(),
      endsAt: DateTime.parse(json['endsAt'] as String),
      minutesLeft: (json['minutesLeft'] as num).toInt(),
      bazaarName: json['bazaarName'] as String,
      bazaarLocation: json['bazaarLocation'] as String,
      village: json['village'] as String?,
      status: json['status'] as String,
      viewsCount: (json['viewsCount'] as num).toInt(),
      watcherCount: (json['watcherCount'] as num).toInt(),
      seller: AuctionSeller.fromJson(json['seller'] as Map<String, dynamic>),
      region: json['region'] != null
          ? AuctionRegion.fromJson(json['region'] as Map<String, dynamic>)
          : null,
      media: (json['media'] as List<dynamic>? ?? [])
          .map((m) => AuctionMedia.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isLive => status == 'LIVE' || status == 'ENDING_SOON';
  bool get isEndingSoon => status == 'ENDING_SOON';
  bool get hasEnded => status == 'ENDED' || minutesLeft <= 0;
  int get nextMinBid => currentBid + bidIncrement;

  String get timeLeftText {
    if (minutesLeft <= 0) return 'Аяктады';
    if (minutesLeft < 60) return '$minutesLeft мүн';
    final hours = minutesLeft ~/ 60;
    final mins = minutesLeft % 60;
    if (hours < 24) return '${hours}с ${mins}мүн';
    final days = hours ~/ 24;
    return '$days күн';
  }
}

class AuctionSeller {
  final String id;
  final String? name;
  final String? phone;
  final String? avatarUrl;
  final double trustScore;
  final bool isVerifiedBreeder;

  const AuctionSeller({
    required this.id,
    this.name,
    this.phone,
    this.avatarUrl,
    required this.trustScore,
    required this.isVerifiedBreeder,
  });

  factory AuctionSeller.fromJson(Map<String, dynamic> json) {
    return AuctionSeller(
      id: json['id'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      trustScore: (json['trustScore'] as num?)?.toDouble() ?? 0.0,
      isVerifiedBreeder: json['isVerifiedBreeder'] as bool? ?? false,
    );
  }
}

class AuctionRegion {
  final String id;
  final String nameKy;
  final String nameRu;

  const AuctionRegion({
    required this.id,
    required this.nameKy,
    required this.nameRu,
  });

  factory AuctionRegion.fromJson(Map<String, dynamic> json) {
    return AuctionRegion(
      id: json['id'] as String,
      nameKy: json['nameKy'] as String,
      nameRu: json['nameRu'] as String,
    );
  }
}

class AuctionMedia {
  final String id;
  final String mediaUrl;
  final bool isPrimary;

  const AuctionMedia({
    required this.id,
    required this.mediaUrl,
    required this.isPrimary,
  });

  factory AuctionMedia.fromJson(Map<String, dynamic> json) {
    return AuctionMedia(
      id: json['id'] as String,
      mediaUrl: json['mediaUrl'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

class AuctionsResponse {
  final List<Auction> auctions;
  final int total;

  const AuctionsResponse({required this.auctions, required this.total});

  factory AuctionsResponse.fromJson(Map<String, dynamic> json) {
    return AuctionsResponse(
      auctions: (json['auctions'] as List<dynamic>)
          .map((a) => Auction.fromJson(a as Map<String, dynamic>))
          .toList(),
      total: (json['pagination']?['total'] as num?)?.toInt() ?? 0,
    );
  }
}
