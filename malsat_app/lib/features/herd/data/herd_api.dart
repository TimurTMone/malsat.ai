import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../domain/owned_animal_model.dart';
import '../domain/caretaker_model.dart';

class HerdApi {
  final Dio _dio;
  HerdApi(this._dio);

  Future<HerdPortfolio> getHerd() async {
    final resp = await _dio.get(ApiEndpoints.herd);
    return HerdPortfolio.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<OwnedAnimal> getAnimal(String id) async {
    final resp = await _dio.get(ApiEndpoints.herdAnimal(id));
    return OwnedAnimal.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<Caretaker>> getCaretakers({String? category, String? region}) async {
    final resp = await _dio.get(
      ApiEndpoints.caretakers,
      queryParameters: {
        if (category != null) 'category': category,
        if (region != null) 'region': region,
      },
    );
    final data = resp.data as Map<String, dynamic>;
    return (data['caretakers'] as List<dynamic>)
        .map((c) => Caretaker.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}
