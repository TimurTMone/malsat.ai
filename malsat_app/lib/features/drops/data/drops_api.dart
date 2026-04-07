import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../domain/drop_model.dart';
import '../domain/meat_order_model.dart';

class DropsApi {
  final Dio _dio;
  DropsApi(this._dio);

  Future<DropsResponse> getDrops({
    String? category,
    String? status,
    String sort = 'soonest',
    int page = 1,
    int limit = 20,
  }) async {
    final resp = await _dio.get(
      ApiEndpoints.drops,
      queryParameters: {
        if (category != null) 'category': category,
        if (status != null) 'status': status,
        'sort': sort,
        'page': page,
        'limit': limit,
      },
    );
    return DropsResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<ButcherDrop> getDrop(String id) async {
    final resp = await _dio.get(ApiEndpoints.drop(id));
    return ButcherDrop.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<MeatOrder> placeOrder({
    required String dropId,
    required double weightKg,
    String deliveryMethod = 'pickup',
    String? deliveryAddress,
    String? buyerPhone,
    String? buyerNote,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.dropOrder(dropId),
      data: {
        'weightKg': weightKg,
        'deliveryMethod': deliveryMethod,
        if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
        if (buyerPhone != null) 'buyerPhone': buyerPhone,
        if (buyerNote != null) 'buyerNote': buyerNote,
      },
    );
    return MeatOrder.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<MyOrdersResponse> getMyOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final resp = await _dio.get(
      ApiEndpoints.myOrders,
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      },
    );
    return MyOrdersResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<MeatOrder> updateOrderStatus(String orderId, String status) async {
    final resp = await _dio.patch(
      ApiEndpoints.order(orderId),
      data: {'status': status},
    );
    return MeatOrder.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<ButcherDrop> createDrop({
    required String title,
    String? description,
    required String category,
    String? breed,
    required double totalWeightKg,
    required int pricePerKg,
    double minOrderKg = 3,
    double? maxOrderKg,
    List<int>? portionPresets,
    required DateTime butcherDate,
    required String pickupAddress,
    String? village,
    bool deliveryAvailable = false,
    int deliveryFee = 0,
    String? deliveryRadius,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.drops,
      data: {
        'title': title,
        if (description != null) 'description': description,
        'category': category,
        if (breed != null) 'breed': breed,
        'totalWeightKg': totalWeightKg,
        'pricePerKg': pricePerKg,
        'minOrderKg': minOrderKg,
        if (maxOrderKg != null) 'maxOrderKg': maxOrderKg,
        if (portionPresets != null) 'portionPresets': portionPresets,
        'butcherDate': butcherDate.toIso8601String(),
        'pickupAddress': pickupAddress,
        if (village != null) 'village': village,
        'deliveryAvailable': deliveryAvailable,
        'deliveryFee': deliveryFee,
        if (deliveryRadius != null) 'deliveryRadius': deliveryRadius,
      },
    );
    return ButcherDrop.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<MyOrdersResponse> getSellerOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final resp = await _dio.get(
      ApiEndpoints.sellerOrders,
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      },
    );
    return MyOrdersResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<MeatOrder> getOrder(String orderId) async {
    final resp = await _dio.get(ApiEndpoints.order(orderId));
    return MeatOrder.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<MeatOrder> uploadReceipt(String orderId, File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'receipt.jpg',
      ),
    });
    final resp = await _dio.post(
      ApiEndpoints.orderReceipt(orderId),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return MeatOrder.fromJson(resp.data as Map<String, dynamic>);
  }
}

class DropsResponse {
  final List<ButcherDrop> drops;
  final int total;
  final int totalPages;

  DropsResponse({
    required this.drops,
    required this.total,
    required this.totalPages,
  });

  factory DropsResponse.fromJson(Map<String, dynamic> j) {
    final pagination = j['pagination'] as Map<String, dynamic>;
    return DropsResponse(
      drops: (j['drops'] as List)
          .map((d) => ButcherDrop.fromJson(d as Map<String, dynamic>))
          .toList(),
      total: (pagination['total'] as num).toInt(),
      totalPages: (pagination['totalPages'] as num).toInt(),
    );
  }
}

class MyOrdersResponse {
  final List<MeatOrder> orders;
  final int total;
  final int totalPages;

  MyOrdersResponse({
    required this.orders,
    required this.total,
    required this.totalPages,
  });

  factory MyOrdersResponse.fromJson(Map<String, dynamic> j) {
    final pagination = j['pagination'] as Map<String, dynamic>;
    return MyOrdersResponse(
      orders: (j['orders'] as List)
          .map((o) => MeatOrder.fromJson(o as Map<String, dynamic>))
          .toList(),
      total: (pagination['total'] as num).toInt(),
      totalPages: (pagination['totalPages'] as num).toInt(),
    );
  }
}
