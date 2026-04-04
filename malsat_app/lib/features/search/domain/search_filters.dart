class SearchFilters {
  final String? category;
  final int? minPrice;
  final int? maxPrice;
  final String? regionId;
  final String? breed;
  final String? gender;
  final String sort;

  const SearchFilters({
    this.category,
    this.minPrice,
    this.maxPrice,
    this.regionId,
    this.breed,
    this.gender,
    this.sort = 'newest',
  });

  SearchFilters copyWith({
    String? Function()? category,
    int? Function()? minPrice,
    int? Function()? maxPrice,
    String? Function()? regionId,
    String? Function()? breed,
    String? Function()? gender,
    String? sort,
  }) {
    return SearchFilters(
      category: category != null ? category() : this.category,
      minPrice: minPrice != null ? minPrice() : this.minPrice,
      maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
      regionId: regionId != null ? regionId() : this.regionId,
      breed: breed != null ? breed() : this.breed,
      gender: gender != null ? gender() : this.gender,
      sort: sort ?? this.sort,
    );
  }

  bool get hasActiveFilters =>
      category != null ||
      minPrice != null ||
      maxPrice != null ||
      regionId != null ||
      breed != null ||
      gender != null;
}
