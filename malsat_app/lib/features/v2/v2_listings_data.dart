import 'package:flutter/material.dart';

/// Mock marketplace listings for the v2 demo. Hard-coded so the redesign
/// can be reviewed without backend/auth wiring. Replace with real API
/// reads when promoting v2 past demo status.
///
/// All animals are halal categories only — sheep, goat, cattle, horse.
/// Marketplace category — drives the chip filter on the home browse.
enum V2Category {
  all,
  sheep,
  cattle,
  horse,
  goat,
}

extension V2CategoryX on V2Category {
  String get ky => switch (this) {
        V2Category.all => 'Бардыгы',
        V2Category.sheep => 'Кой',
        V2Category.cattle => 'Уй',
        V2Category.horse => 'Жылкы',
        V2Category.goat => 'Эчки',
      };
  String get ru => switch (this) {
        V2Category.all => 'Все',
        V2Category.sheep => 'Баран',
        V2Category.cattle => 'Корова',
        V2Category.horse => 'Конь',
        V2Category.goat => 'Коза',
      };
}

class V2Listing {
  final String id;
  final V2Category category;
  final String kindKy;
  final String kindRu;
  final String detailKy;
  final String detailRu;
  final int priceKgs;
  final int weightKg;
  final String villageKy;
  final String villageRu;
  final String sellerName;
  final String sellerPhone;
  final Color tone;
  final String agoKy;
  final String agoRu;

  const V2Listing({
    required this.id,
    required this.category,
    required this.kindKy,
    required this.kindRu,
    required this.detailKy,
    required this.detailRu,
    required this.priceKgs,
    required this.weightKg,
    required this.villageKy,
    required this.villageRu,
    required this.sellerName,
    required this.sellerPhone,
    required this.tone,
    required this.agoKy,
    required this.agoRu,
  });

  int get pricePerKg => (priceKgs / weightKg).round();
}

const v2Listings = <V2Listing>[
  V2Listing(
    id: 'l1',
    category: V2Category.sheep,
    kindKy: 'Кой',
    kindRu: 'Баран',
    detailKy: '1 кой · ~25 кг',
    detailRu: '1 баран · ~25 кг',
    priceKgs: 18000,
    weightKg: 25,
    villageKy: 'Нарын',
    villageRu: 'Нарын',
    sellerName: 'Айылбек Иманов',
    sellerPhone: '+996 700 12 34 56',
    tone: Color(0xFFD9A574),
    agoKy: '2 саат мурун',
    agoRu: '2 ч назад',
  ),
  V2Listing(
    id: 'l2',
    category: V2Category.cattle,
    kindKy: 'Уй',
    kindRu: 'Корова',
    detailKy: '1 уй · ~145 кг',
    detailRu: '1 корова · ~145 кг',
    priceKgs: 75000,
    weightKg: 145,
    villageKy: 'Талас',
    villageRu: 'Талас',
    sellerName: 'Канатбек Осмонов',
    sellerPhone: '+996 555 23 45 67',
    tone: Color(0xFFB7410E),
    agoKy: '5 саат мурун',
    agoRu: '5 ч назад',
  ),
  V2Listing(
    id: 'l3',
    category: V2Category.horse,
    kindKy: 'Эт жылкы',
    kindRu: 'Конь (на мясо)',
    detailKy: '1 жылкы · ~180 кг',
    detailRu: '1 конь · ~180 кг',
    priceKgs: 110000,
    weightKg: 180,
    villageKy: 'Ат-Башы',
    villageRu: 'Ат-Башы',
    sellerName: 'Бакыт Турдубеков',
    sellerPhone: '+996 770 34 56 78',
    tone: Color(0xFF8A5A3B),
    agoKy: 'Бугүн',
    agoRu: 'Сегодня',
  ),
  V2Listing(
    id: 'l4',
    category: V2Category.sheep,
    kindKy: '2 кой',
    kindRu: '2 барана',
    detailKy: '2 кой · ~50 кг',
    detailRu: '2 барана · ~50 кг',
    priceKgs: 35000,
    weightKg: 50,
    villageKy: 'Чүй',
    villageRu: 'Чуй',
    sellerName: 'Жаныбек Мырзаев',
    sellerPhone: '+996 558 45 67 89',
    tone: Color(0xFFC4925A),
    agoKy: 'Кечээ',
    agoRu: 'Вчера',
  ),
  V2Listing(
    id: 'l5',
    category: V2Category.goat,
    kindKy: 'Эчки',
    kindRu: 'Коза',
    detailKy: '1 эчки · ~15 кг',
    detailRu: '1 коза · ~15 кг',
    priceKgs: 12000,
    weightKg: 15,
    villageKy: 'Ысык-Көл',
    villageRu: 'Иссык-Куль',
    sellerName: 'Гүлмира Асанова',
    sellerPhone: '+996 707 56 78 90',
    tone: Color(0xFFAD7C4A),
    agoKy: '3 күн мурун',
    agoRu: '3 дня назад',
  ),
  V2Listing(
    id: 'l6',
    category: V2Category.cattle,
    kindKy: 'Музоо',
    kindRu: 'Телёнок',
    detailKy: '1 музоо · ~70 кг',
    detailRu: '1 телёнок · ~70 кг',
    priceKgs: 35000,
    weightKg: 70,
    villageKy: 'Ош',
    villageRu: 'Ош',
    sellerName: 'Эрмек Калыбеков',
    sellerPhone: '+996 559 67 89 01',
    tone: Color(0xFFCB6B3A),
    agoKy: 'Жума мурун',
    agoRu: 'Неделю назад',
  ),
];

V2Listing? v2ListingById(String id) {
  for (final l in v2Listings) {
    if (l.id == id) return l;
  }
  return null;
}
