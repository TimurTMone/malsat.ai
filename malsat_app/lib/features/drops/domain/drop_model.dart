class ButcherDrop {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String? breed;
  final double totalWeightKg;
  final double remainingWeightKg;
  final int pricePerKg;
  final double minOrderKg;
  final double? maxOrderKg;
  final List<int> portionPresets;
  final DateTime butcherDate;
  final String pickupAddress;
  final String? village;
  final bool deliveryAvailable;
  final int deliveryFee;
  final String? deliveryRadius;
  final String status;
  final int viewsCount;
  final int orderCount;
  final double claimedWeightKg;
  final int progressPercent;
  final DateTime createdAt;
  final DropSeller seller;
  final DropRegion? region;
  final List<DropMedia> media;

  ButcherDrop({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.breed,
    required this.totalWeightKg,
    required this.remainingWeightKg,
    required this.pricePerKg,
    required this.minOrderKg,
    this.maxOrderKg,
    required this.portionPresets,
    required this.butcherDate,
    required this.pickupAddress,
    this.village,
    this.deliveryAvailable = false,
    this.deliveryFee = 0,
    this.deliveryRadius,
    required this.status,
    required this.viewsCount,
    required this.orderCount,
    required this.claimedWeightKg,
    required this.progressPercent,
    required this.createdAt,
    required this.seller,
    this.region,
    required this.media,
  });

  factory ButcherDrop.fromJson(Map<String, dynamic> j) {
    final presets = j['portionPresets'];
    final presetList = presets is List
        ? presets.map((e) => (e as num).toInt()).toList()
        : <int>[5, 10, 15];

    return ButcherDrop(
      id: j['id'] as String,
      title: j['title'] as String,
      description: j['description'] as String?,
      category: j['category'] as String,
      breed: j['breed'] as String?,
      totalWeightKg: (j['totalWeightKg'] as num).toDouble(),
      remainingWeightKg: (j['remainingWeightKg'] as num).toDouble(),
      pricePerKg: (j['pricePerKg'] as num).toInt(),
      minOrderKg: (j['minOrderKg'] as num).toDouble(),
      maxOrderKg: j['maxOrderKg'] != null
          ? (j['maxOrderKg'] as num).toDouble()
          : null,
      portionPresets: presetList,
      butcherDate: DateTime.parse(j['butcherDate'] as String),
      pickupAddress: j['pickupAddress'] as String,
      village: j['village'] as String?,
      deliveryAvailable: j['deliveryAvailable'] as bool? ?? false,
      deliveryFee: (j['deliveryFee'] as num?)?.toInt() ?? 0,
      deliveryRadius: j['deliveryRadius'] as String?,
      status: j['status'] as String,
      viewsCount: (j['viewsCount'] as num).toInt(),
      orderCount: (j['orderCount'] as num).toInt(),
      claimedWeightKg: (j['claimedWeightKg'] as num).toDouble(),
      progressPercent: (j['progressPercent'] as num).toInt(),
      createdAt: DateTime.parse(j['createdAt'] as String),
      seller: DropSeller.fromJson(j['seller'] as Map<String, dynamic>),
      region: j['region'] != null
          ? DropRegion.fromJson(j['region'] as Map<String, dynamic>)
          : null,
      media: j['media'] != null
          ? (j['media'] as List)
              .map((m) => DropMedia.fromJson(m as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  bool get isOpen => status == 'OPEN';
  bool get isSoldOut => status == 'SOLD_OUT';
  bool get isUpcoming => status == 'UPCOMING';

  Duration get timeUntilButcher => butcherDate.difference(DateTime.now());
  int get daysUntilButcher => timeUntilButcher.inDays;
}

class DropSeller {
  final String id;
  final String? name;
  final String? phone;
  final String? avatarUrl;
  final double trustScore;
  final bool isVerifiedBreeder;

  DropSeller({
    required this.id,
    this.name,
    this.phone,
    this.avatarUrl,
    required this.trustScore,
    required this.isVerifiedBreeder,
  });

  factory DropSeller.fromJson(Map<String, dynamic> j) {
    return DropSeller(
      id: j['id'] as String,
      name: j['name'] as String?,
      phone: j['phone'] as String?,
      avatarUrl: j['avatarUrl'] as String?,
      trustScore: (j['trustScore'] as num).toDouble(),
      isVerifiedBreeder: j['isVerifiedBreeder'] as bool,
    );
  }
}

class DropRegion {
  final String id;
  final String nameKy;
  final String nameRu;

  DropRegion({required this.id, required this.nameKy, required this.nameRu});

  factory DropRegion.fromJson(Map<String, dynamic> j) {
    return DropRegion(
      id: j['id'] as String,
      nameKy: j['nameKy'] as String,
      nameRu: j['nameRu'] as String,
    );
  }
}

class DropMedia {
  final String id;
  final String mediaUrl;
  final String mediaType;
  final bool isPrimary;

  DropMedia({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
    required this.isPrimary,
  });

  factory DropMedia.fromJson(Map<String, dynamic> j) {
    return DropMedia(
      id: j['id'] as String,
      mediaUrl: j['mediaUrl'] as String,
      mediaType: j['mediaType'] as String,
      isPrimary: j['isPrimary'] as bool,
    );
  }
}
