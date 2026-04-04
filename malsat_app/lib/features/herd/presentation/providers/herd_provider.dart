import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/herd_api.dart';
import '../../domain/owned_animal_model.dart';
import '../../domain/caretaker_model.dart';

final herdApiProvider = Provider<HerdApi>((ref) {
  final dio = ref.read(dioProvider);
  return HerdApi(dio);
});

final herdPortfolioProvider = FutureProvider<HerdPortfolio>((ref) async {
  final api = ref.read(herdApiProvider);
  return api.getHerd();
});

final animalDetailProvider =
    FutureProvider.family<OwnedAnimal, String>((ref, id) async {
  final api = ref.read(herdApiProvider);
  return api.getAnimal(id);
});

final caretakersProvider =
    FutureProvider.family<List<Caretaker>, String?>((ref, category) async {
  final api = ref.read(herdApiProvider);
  return api.getCaretakers(category: category);
});
