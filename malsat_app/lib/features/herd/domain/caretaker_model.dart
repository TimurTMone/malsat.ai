class Caretaker {
  final String id;
  final String name;
  final String? photo;
  final String village;
  final String region;
  final int yearsExperience;
  final int animalsUnderCare;
  final double rating;
  final int reviewCount;
  final int monthlyFeeKgs;
  final List<String> speciality;
  final bool hasPastures;
  final bool isVerified;
  final String bio;

  Caretaker({
    required this.id,
    required this.name,
    required this.photo,
    required this.village,
    required this.region,
    required this.yearsExperience,
    required this.animalsUnderCare,
    required this.rating,
    required this.reviewCount,
    required this.monthlyFeeKgs,
    required this.speciality,
    required this.hasPastures,
    required this.isVerified,
    required this.bio,
  });

  factory Caretaker.fromJson(Map<String, dynamic> j) {
    return Caretaker(
      id: j['id'] as String,
      name: j['name'] as String,
      photo: j['photo'] as String?,
      village: j['village'] as String,
      region: j['region'] as String,
      yearsExperience: j['yearsExperience'] as int,
      animalsUnderCare: j['animalsUnderCare'] as int,
      rating: (j['rating'] as num).toDouble(),
      reviewCount: j['reviewCount'] as int,
      monthlyFeeKgs: j['monthlyFeeKgs'] as int,
      speciality:
          (j['speciality'] as List<dynamic>).map((e) => e as String).toList(),
      hasPastures: j['hasPastures'] as bool,
      isVerified: j['isVerified'] as bool,
      bio: j['bio'] as String,
    );
  }
}
