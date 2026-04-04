class RegionModel {
  final String id;
  final String nameKy;
  final String nameRu;

  const RegionModel({
    required this.id,
    required this.nameKy,
    required this.nameRu,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'] as String,
      nameKy: json['nameKy'] as String? ?? '',
      nameRu: json['nameRu'] as String? ?? '',
    );
  }

  String localizedName(String locale) => locale == 'ru' ? nameRu : nameKy;
}
