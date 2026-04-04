class UserModel {
  final String id;
  final String phone;
  final String? name;
  final String? avatarUrl;
  final bool isVerifiedBreeder;

  const UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.avatarUrl,
    this.isVerifiedBreeder = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isVerifiedBreeder: json['isVerifiedBreeder'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'name': name,
        'avatarUrl': avatarUrl,
        'isVerifiedBreeder': isVerifiedBreeder,
      };

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
