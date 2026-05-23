import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/butcher_api.dart';
import '../../domain/butcher_partner.dart';

final butcherApiProvider = Provider<ButcherApi>((ref) {
  final dio = ref.read(dioProvider);
  return ButcherApi(dio);
});

/// Active butcher partners. P0 returns one Bishkek partner.
final butcherPartnersProvider =
    FutureProvider<List<ButcherPartner>>((ref) async {
  ref.watch(currentUserProvider);
  final api = ref.read(butcherApiProvider);
  return api.getPartners();
});
