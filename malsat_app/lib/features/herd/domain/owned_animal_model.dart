class OwnedAnimal {
  final String id;
  final String tokenId;
  final String name;
  final String category;
  final String breed;
  final String photo;
  final DateTime purchasedAt;
  final int purchasePriceKgs;
  final int currentValueKgs;
  final int ageMonths;
  final int weightKg;
  final String gender;
  final String status;
  final String? caretakerId;
  final String? caretakerName;
  final String locationVillage;
  final String locationRegion;
  final int healthScore;
  final int weightGainKg;
  final int vetVisits;
  final String nextMilestone;
  final DateTime seasonEndAt;
  final int loyaltyPoints;

  OwnedAnimal({
    required this.id,
    required this.tokenId,
    required this.name,
    required this.category,
    required this.breed,
    required this.photo,
    required this.purchasedAt,
    required this.purchasePriceKgs,
    required this.currentValueKgs,
    required this.ageMonths,
    required this.weightKg,
    required this.gender,
    required this.status,
    required this.caretakerId,
    required this.caretakerName,
    required this.locationVillage,
    required this.locationRegion,
    required this.healthScore,
    required this.weightGainKg,
    required this.vetVisits,
    required this.nextMilestone,
    required this.seasonEndAt,
    required this.loyaltyPoints,
  });

  factory OwnedAnimal.fromJson(Map<String, dynamic> j) {
    return OwnedAnimal(
      id: j['id'] as String,
      tokenId: j['tokenId'] as String,
      name: j['name'] as String,
      category: j['category'] as String,
      breed: j['breed'] as String,
      photo: j['photo'] as String,
      purchasedAt: DateTime.parse(j['purchasedAt'] as String),
      purchasePriceKgs: j['purchasePriceKgs'] as int,
      currentValueKgs: j['currentValueKgs'] as int,
      ageMonths: j['ageMonths'] as int,
      weightKg: j['weightKg'] as int,
      gender: j['gender'] as String,
      status: j['status'] as String,
      caretakerId: j['caretakerId'] as String?,
      caretakerName: j['caretakerName'] as String?,
      locationVillage: j['locationVillage'] as String,
      locationRegion: j['locationRegion'] as String,
      healthScore: j['healthScore'] as int,
      weightGainKg: j['weightGainKg'] as int,
      vetVisits: j['vetVisits'] as int,
      nextMilestone: j['nextMilestone'] as String,
      seasonEndAt: DateTime.parse(j['seasonEndAt'] as String),
      loyaltyPoints: j['loyaltyPoints'] as int,
    );
  }

  int get profitKgs => currentValueKgs - purchasePriceKgs;
  double get profitPercent =>
      purchasePriceKgs == 0 ? 0 : (profitKgs / purchasePriceKgs) * 100;
}

class HerdSummary {
  final int totalAnimals;
  final int totalInvestedKgs;
  final int currentValueKgs;
  final int unrealizedProfitKgs;
  final int profitPercent;
  final int totalLoyaltyPoints;
  final int totalWeightGainKg;
  final int activeCaretakers;

  HerdSummary({
    required this.totalAnimals,
    required this.totalInvestedKgs,
    required this.currentValueKgs,
    required this.unrealizedProfitKgs,
    required this.profitPercent,
    required this.totalLoyaltyPoints,
    required this.totalWeightGainKg,
    required this.activeCaretakers,
  });

  factory HerdSummary.fromJson(Map<String, dynamic> j) {
    return HerdSummary(
      totalAnimals: j['totalAnimals'] as int,
      totalInvestedKgs: j['totalInvestedKgs'] as int,
      currentValueKgs: j['currentValueKgs'] as int,
      unrealizedProfitKgs: j['unrealizedProfitKgs'] as int,
      profitPercent: j['profitPercent'] as int,
      totalLoyaltyPoints: j['totalLoyaltyPoints'] as int,
      totalWeightGainKg: j['totalWeightGainKg'] as int,
      activeCaretakers: j['activeCaretakers'] as int,
    );
  }
}

class HerdPortfolio {
  final List<OwnedAnimal> animals;
  final HerdSummary summary;

  HerdPortfolio({required this.animals, required this.summary});

  factory HerdPortfolio.fromJson(Map<String, dynamic> j) {
    return HerdPortfolio(
      animals: (j['animals'] as List<dynamic>)
          .map((a) => OwnedAnimal.fromJson(a as Map<String, dynamic>))
          .toList(),
      summary: HerdSummary.fromJson(j['summary'] as Map<String, dynamic>),
    );
  }
}
