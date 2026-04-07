enum AnimalCategory {
  horse('HORSE'),
  cattle('CATTLE'),
  sheep('SHEEP'),
  arashan('ARASHAN');

  const AnimalCategory(this.value);
  final String value;

  static AnimalCategory fromValue(String value) {
    return AnimalCategory.values.firstWhere((e) => e.value == value);
  }
}

enum AnimalGender {
  male('MALE'),
  female('FEMALE');

  const AnimalGender(this.value);
  final String value;

  static AnimalGender fromValue(String value) {
    return AnimalGender.values.firstWhere((e) => e.value == value);
  }
}

enum ListingStatus {
  active('ACTIVE'),
  sold('SOLD'),
  expired('EXPIRED');

  const ListingStatus(this.value);
  final String value;
}

enum ListingSort {
  newest('newest'),
  priceAsc('price_asc'),
  priceDesc('price_desc');

  const ListingSort(this.value);
  final String value;
}

enum DropStatus {
  upcoming('UPCOMING'),
  open('OPEN'),
  soldOut('SOLD_OUT'),
  fulfilled('FULFILLED'),
  cancelled('CANCELLED');

  const DropStatus(this.value);
  final String value;

  static DropStatus fromValue(String value) {
    return DropStatus.values.firstWhere((e) => e.value == value);
  }
}

enum OrderStatus {
  pending('PENDING'),
  paid('PAID'),
  confirmed('CONFIRMED'),
  butchering('BUTCHERING'),
  packaging('PACKAGING'),
  delivering('DELIVERING'),
  delivered('DELIVERED'),
  cancelled('CANCELLED');

  const OrderStatus(this.value);
  final String value;

  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere((e) => e.value == value);
  }
}
