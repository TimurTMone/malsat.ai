import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/world_provider.dart';
import '../../../../core/theme/app_world.dart';
import '../../../drops/presentation/screens/drops_screen.dart';
import 'livestock_home_screen.dart';

/// Home tab — renders the active world's main page.
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final world = ref.watch(worldProvider);
    return world == AppWorld.livestock
        ? const LivestockHomeScreen()
        : const DropsScreen();
  }
}
