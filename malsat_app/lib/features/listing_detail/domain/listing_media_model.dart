class ListingMediaModel {
  final String id;
  final String mediaUrl;
  final String mediaType;
  final bool isPrimary;
  final int sortOrder;

  const ListingMediaModel({
    required this.id,
    required this.mediaUrl,
    this.mediaType = 'PHOTO',
    this.isPrimary = false,
    this.sortOrder = 0,
  });

  factory ListingMediaModel.fromJson(Map<String, dynamic> json) {
    return ListingMediaModel(
      id: json['id'] as String,
      mediaUrl: json['mediaUrl'] as String,
      mediaType: json['mediaType'] as String? ?? 'PHOTO',
      isPrimary: json['isPrimary'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  bool get isPhoto => mediaType == 'PHOTO';
  bool get isVideo => mediaType == 'VIDEO';
}
