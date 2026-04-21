import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/drops_api.dart';
import '../../domain/drop_model.dart';
import '../../domain/meat_order_model.dart';

final dropsApiProvider = Provider<DropsApi>((ref) {
  final dio = ref.read(dioProvider);
  return DropsApi(dio);
});

final dropsListProvider = FutureProvider<List<ButcherDrop>>((ref) async {
  final api = ref.read(dropsApiProvider);
  final resp = await api.getDrops();
  return resp.drops;
});

final dropDetailProvider =
    FutureProvider.family<ButcherDrop, String>((ref, id) async {
  final api = ref.read(dropsApiProvider);
  return api.getDrop(id);
});

final myOrdersProvider = FutureProvider<List<MeatOrder>>((ref) async {
  // Re-run when auth changes (login/logout) so we don't serve stale rows
  // from a previous session.
  ref.watch(currentUserProvider);
  final api = ref.read(dropsApiProvider);
  final resp = await api.getMyOrders();
  return resp.orders;
});

final orderDetailProvider =
    FutureProvider.family<MeatOrder, String>((ref, id) async {
  final api = ref.read(dropsApiProvider);
  return api.getOrder(id);
});

final sellerOrdersProvider = FutureProvider<List<MeatOrder>>((ref) async {
  ref.watch(currentUserProvider);
  final api = ref.read(dropsApiProvider);
  final resp = await api.getSellerOrders();
  return resp.orders;
});
