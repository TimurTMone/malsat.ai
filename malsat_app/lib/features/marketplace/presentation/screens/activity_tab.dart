import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/world_provider.dart';
import '../../../../core/theme/app_world.dart';
import '../../../drops/presentation/screens/my_orders_screen.dart';
import '../../../herd/presentation/screens/herd_screen.dart';

/// Activity tab — the user's own world: meat orders, or the livestock herd.
class ActivityTab extends ConsumerWidget {
  const ActivityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final world = ref.watch(worldProvider);
    return world == AppWorld.livestock
        ? const HerdScreen()
        : const MyOrdersScreen(embedded: true);
  }
}
