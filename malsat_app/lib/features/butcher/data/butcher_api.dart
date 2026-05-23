import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../drops/domain/meat_order_model.dart';
import '../domain/butcher_partner.dart';

class ButcherApi {
  final Dio _dio;
  ButcherApi(this._dio);

  Future<List<ButcherPartner>> getPartners({String? regionId}) async {
    final resp = await _dio.get(
      ApiEndpoints.butcherPartners,
      queryParameters: {
        if (regionId != null) 'regionId': regionId,
      },
    );
    final list = (resp.data as Map<String, dynamic>)['partners'] as List;
    return list
        .map((j) => ButcherPartner.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<ButcherServiceOrder> submitOrder({
    required String partnerId,
    required String animalCategory,
    required double animalWeightKg,
    String? animalDescription,
    String? animalPhotoUrl,
    required String occasionType,
    required bool imamRequested,
    required List<String> cuttingPreset,
    String? specialDua,
    required String deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
    required DateTime deliveryDate,
    required String buyerPhone,
    String? buyerNote,
    String? sourceListingId,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.butcherService,
      data: {
        'partnerId': partnerId,
        'animalCategory': animalCategory,
        'animalWeightKg': animalWeightKg,
        if (animalDescription != null) 'animalDescription': animalDescription,
        if (animalPhotoUrl != null) 'animalPhotoUrl': animalPhotoUrl,
        'occasionType': occasionType,
        'imamRequested': imamRequested,
        'cuttingPreset': cuttingPreset,
        if (specialDua != null) 'specialDua': specialDua,
        'deliveryAddress': deliveryAddress,
        if (deliveryLat != null) 'deliveryLat': deliveryLat,
        if (deliveryLng != null) 'deliveryLng': deliveryLng,
        'deliveryDate': deliveryDate.toUtc().toIso8601String(),
        'buyerPhone': buyerPhone,
        if (buyerNote != null) 'buyerNote': buyerNote,
        if (sourceListingId != null) 'sourceListingId': sourceListingId,
      },
    );
    return ButcherServiceOrder.fromJson(resp.data as Map<String, dynamic>);
  }
}

/// The wrapper the POST endpoint returns — { order, breakdown }.
class ButcherServiceOrder {
  final MeatOrder order;
  final int butcheringSubtotal;
  final int imamFee;
  final int deliveryFee;
  final int totalPriceKgs;
  final int pricePerKg;

  const ButcherServiceOrder({
    required this.order,
    required this.butcheringSubtotal,
    required this.imamFee,
    required this.deliveryFee,
    required this.totalPriceKgs,
    required this.pricePerKg,
  });

  factory ButcherServiceOrder.fromJson(Map<String, dynamic> j) {
    final breakdown = j['breakdown'] as Map<String, dynamic>;
    return ButcherServiceOrder(
      order: MeatOrder.fromJson(j['order'] as Map<String, dynamic>),
      butcheringSubtotal: (breakdown['butcheringSubtotal'] as num).toInt(),
      imamFee: (breakdown['imamFee'] as num).toInt(),
      deliveryFee: (breakdown['deliveryFee'] as num).toInt(),
      totalPriceKgs: (breakdown['totalPriceKgs'] as num).toInt(),
      pricePerKg: (breakdown['pricePerKg'] as num).toInt(),
    );
  }
}
