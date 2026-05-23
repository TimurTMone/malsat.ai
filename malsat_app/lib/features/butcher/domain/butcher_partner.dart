import 'dart:convert';

/// A curated halal butcher partner serving a region.
class ButcherPartner {
  final String id;
  final String name;
  final String? description;
  final String phone;
  final String? regionId;
  final String? halalCertUrl;
  final Map<String, int> pricePerKgByCategory; // by AnimalCategory wire name
  final int imamFeeKgs;
  final int deliveryFeeKgs;
  final String? regionNameKy;
  final String? regionNameRu;
  final String? userAvatarUrl;
  final double userTrustScore;

  const ButcherPartner({
    required this.id,
    required this.name,
    this.description,
    required this.phone,
    this.regionId,
    this.halalCertUrl,
    required this.pricePerKgByCategory,
    required this.imamFeeKgs,
    required this.deliveryFeeKgs,
    this.regionNameKy,
    this.regionNameRu,
    this.userAvatarUrl,
    this.userTrustScore = 0,
  });

  int pricePerKgFor(String category) =>
      pricePerKgByCategory[category] ?? 0;

  /// Estimate total — animal weight × per-kg + (imam ? feeKgs : 0) + delivery.
  /// Server is the authority; this is for the in-app receipt preview.
  int estimateTotal({
    required String animalCategory,
    required double animalWeightKg,
    required bool imamRequested,
  }) {
    final perKg = pricePerKgFor(animalCategory);
    final butchering = (animalWeightKg * perKg).round();
    final imam = imamRequested ? imamFeeKgs : 0;
    return butchering + imam + deliveryFeeKgs;
  }

  factory ButcherPartner.fromJson(Map<String, dynamic> j) {
    final priceRaw = j['pricePerKgByCategory'];
    Map<String, int> priceMap = const {};
    if (priceRaw is String) {
      final decoded = jsonDecode(priceRaw);
      if (decoded is Map) {
        priceMap = decoded.map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        );
      }
    } else if (priceRaw is Map) {
      priceMap = priceRaw.map(
        (k, v) => MapEntry(k.toString(), (v as num).toInt()),
      );
    }
    final region = j['region'] as Map<String, dynamic>?;
    final user = j['user'] as Map<String, dynamic>?;
    return ButcherPartner(
      id: j['id'] as String,
      name: j['name'] as String,
      description: j['description'] as String?,
      phone: j['phone'] as String,
      regionId: j['regionId'] as String?,
      halalCertUrl: j['halalCertUrl'] as String?,
      pricePerKgByCategory: priceMap,
      imamFeeKgs: (j['imamFeeKgs'] as num).toInt(),
      deliveryFeeKgs: (j['deliveryFeeKgs'] as num).toInt(),
      regionNameKy: region?['nameKy'] as String?,
      regionNameRu: region?['nameRu'] as String?,
      userAvatarUrl: user?['avatarUrl'] as String?,
      userTrustScore: (user?['trustScore'] as num?)?.toDouble() ?? 0,
    );
  }
}
