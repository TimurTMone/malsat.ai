class SellerModel {
  final String id;
  final String? name;
  final String? avatarUrl;
  final String phone;
  final double trustScore;
  final bool isVerifiedBreeder;

  const SellerModel({
    required this.id,
    this.name,
    this.avatarUrl,
    required this.phone,
    this.trustScore = 0,
    this.isVerifiedBreeder = false,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      phone: json['phone'] as String? ?? '',
      trustScore: (json['trustScore'] as num?)?.toDouble() ?? 0,
      isVerifiedBreeder: json['isVerifiedBreeder'] as bool? ?? false,
    );
  }

  String get displayName => name ?? phone;

  String get initials {
    if (name == null || name!.isEmpty) return phone.substring(phone.length - 2);
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }
}
