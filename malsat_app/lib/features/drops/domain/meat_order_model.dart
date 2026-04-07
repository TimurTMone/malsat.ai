class MeatOrder {
  final String id;
  final String dropId;
  final String buyerId;
  final double weightKg;
  final int totalPriceKgs;
  final String deliveryMethod; // "pickup" or "delivery"
  final String? deliveryAddress;
  final int deliveryFee;
  final String status;
  final String? buyerPhone;
  final String? buyerNote;
  final String? receiptUrl;
  final String? butcheringPhotoUrl;
  final String? packagingPhotoUrl;
  final String? deliveringPhotoUrl;
  final DateTime? paidAt;
  final DateTime? confirmedAt;
  final DateTime? butcheringAt;
  final DateTime? packagingAt;
  final DateTime? deliveringAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final OrderDrop? drop;
  final OrderBuyer? buyer;

  MeatOrder({
    required this.id,
    required this.dropId,
    required this.buyerId,
    required this.weightKg,
    required this.totalPriceKgs,
    this.deliveryMethod = 'pickup',
    this.deliveryAddress,
    this.deliveryFee = 0,
    required this.status,
    this.buyerPhone,
    this.buyerNote,
    this.receiptUrl,
    this.butcheringPhotoUrl,
    this.packagingPhotoUrl,
    this.deliveringPhotoUrl,
    this.paidAt,
    this.confirmedAt,
    this.butcheringAt,
    this.packagingAt,
    this.deliveringAt,
    this.deliveredAt,
    required this.createdAt,
    this.drop,
    this.buyer,
  });

  factory MeatOrder.fromJson(Map<String, dynamic> j) {
    return MeatOrder(
      id: j['id'] as String,
      dropId: j['dropId'] as String,
      buyerId: j['buyerId'] as String,
      weightKg: (j['weightKg'] as num).toDouble(),
      totalPriceKgs: (j['totalPriceKgs'] as num).toInt(),
      deliveryMethod: j['deliveryMethod'] as String? ?? 'pickup',
      deliveryAddress: j['deliveryAddress'] as String?,
      deliveryFee: (j['deliveryFee'] as num?)?.toInt() ?? 0,
      status: j['status'] as String,
      buyerPhone: j['buyerPhone'] as String?,
      buyerNote: j['buyerNote'] as String?,
      receiptUrl: j['receiptUrl'] as String?,
      butcheringPhotoUrl: j['butcheringPhotoUrl'] as String?,
      packagingPhotoUrl: j['packagingPhotoUrl'] as String?,
      deliveringPhotoUrl: j['deliveringPhotoUrl'] as String?,
      paidAt: j['paidAt'] != null ? DateTime.parse(j['paidAt'] as String) : null,
      confirmedAt: j['confirmedAt'] != null
          ? DateTime.parse(j['confirmedAt'] as String)
          : null,
      butcheringAt: j['butcheringAt'] != null
          ? DateTime.parse(j['butcheringAt'] as String)
          : null,
      packagingAt: j['packagingAt'] != null
          ? DateTime.parse(j['packagingAt'] as String)
          : null,
      deliveringAt: j['deliveringAt'] != null
          ? DateTime.parse(j['deliveringAt'] as String)
          : null,
      deliveredAt: j['deliveredAt'] != null
          ? DateTime.parse(j['deliveredAt'] as String)
          : null,
      createdAt: DateTime.parse(j['createdAt'] as String),
      drop: j['drop'] != null
          ? OrderDrop.fromJson(j['drop'] as Map<String, dynamic>)
          : null,
      buyer: j['buyer'] != null
          ? OrderBuyer.fromJson(j['buyer'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isPaid => status == 'PAID';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isButchering => status == 'BUTCHERING';
  bool get isPackaging => status == 'PACKAGING';
  bool get isDelivering => status == 'DELIVERING';
  bool get isDelivered => status == 'DELIVERED';
  bool get isCancelled => status == 'CANCELLED';

  bool get isDelivery => deliveryMethod == 'delivery';
  bool get isPickup => deliveryMethod == 'pickup';

  /// Whether the buyer needs to pay (show QR + upload receipt)
  bool get awaitingPayment => isPending;

  /// Whether the order is in the fulfillment pipeline
  bool get inProgress =>
      isPaid || isConfirmed || isButchering || isPackaging || isDelivering;
}

class OrderDrop {
  final String id;
  final String title;
  final String? category;
  final String? breed;
  final int pricePerKg;
  final DateTime butcherDate;
  final String pickupAddress;
  final String? village;
  final String? status;
  final OrderDropSeller? seller;
  final List<OrderDropMedia> media;

  OrderDrop({
    required this.id,
    required this.title,
    this.category,
    this.breed,
    required this.pricePerKg,
    required this.butcherDate,
    required this.pickupAddress,
    this.village,
    this.status,
    this.seller,
    this.media = const [],
  });

  factory OrderDrop.fromJson(Map<String, dynamic> j) {
    return OrderDrop(
      id: j['id'] as String,
      title: j['title'] as String,
      category: j['category'] as String?,
      breed: j['breed'] as String?,
      pricePerKg: (j['pricePerKg'] as num).toInt(),
      butcherDate: DateTime.parse(j['butcherDate'] as String),
      pickupAddress: j['pickupAddress'] as String,
      village: j['village'] as String?,
      status: j['status'] as String?,
      seller: j['seller'] != null
          ? OrderDropSeller.fromJson(j['seller'] as Map<String, dynamic>)
          : null,
      media: j['media'] != null
          ? (j['media'] as List)
              .map((m) => OrderDropMedia.fromJson(m as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class OrderDropSeller {
  final String id;
  final String? name;
  final String? phone;
  final String? paymentQrUrl;
  final String? paymentInfo;

  OrderDropSeller({
    required this.id,
    this.name,
    this.phone,
    this.paymentQrUrl,
    this.paymentInfo,
  });

  factory OrderDropSeller.fromJson(Map<String, dynamic> j) {
    return OrderDropSeller(
      id: j['id'] as String,
      name: j['name'] as String?,
      phone: j['phone'] as String?,
      paymentQrUrl: j['paymentQrUrl'] as String?,
      paymentInfo: j['paymentInfo'] as String?,
    );
  }
}

class OrderDropMedia {
  final String id;
  final String mediaUrl;

  OrderDropMedia({required this.id, required this.mediaUrl});

  factory OrderDropMedia.fromJson(Map<String, dynamic> j) {
    return OrderDropMedia(
      id: j['id'] as String,
      mediaUrl: j['mediaUrl'] as String,
    );
  }
}

class OrderBuyer {
  final String id;
  final String? name;
  final String? phone;

  OrderBuyer({required this.id, this.name, this.phone});

  factory OrderBuyer.fromJson(Map<String, dynamic> j) {
    return OrderBuyer(
      id: j['id'] as String,
      name: j['name'] as String?,
      phone: j['phone'] as String?,
    );
  }
}
