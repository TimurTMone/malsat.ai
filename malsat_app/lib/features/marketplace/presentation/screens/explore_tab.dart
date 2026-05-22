import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/world_provider.dart';
import 'explore_screen.dart';

/// Explore tab — a world-aware browse hub.
class ExploreTab extends ConsumerWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final world = ref.watch(worldProvider);
    return ExploreScreen(world: world);
  }
}
