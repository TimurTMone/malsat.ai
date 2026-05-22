import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../theme/app_world.dart';

/// The marketplace world the user is currently in — Meat or Livestock.
///
/// This is the single top-level axis of the app: the header world-switch
/// flips it, and every shared tab (Home, Explore, Activity) reskins and
/// re-routes off it. The choice is persisted so a returning user lands
/// back where they left off; a brand-new user starts in Meat.
const _kWorldKey = 'malsat.active_world';

class WorldNotifier extends StateNotifier<AppWorld> {
  final FlutterSecureStorage _storage;

  /// Set once the user explicitly picks a world, so a slow async restore
  /// can't overwrite a choice the user made while it was still loading.
  bool _touched = false;

  WorldNotifier(this._storage) : super(AppWorld.meat) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final saved = await _storage.read(key: _kWorldKey);
      if (_touched) return;
      if (saved == AppWorld.livestock.name) state = AppWorld.livestock;
    } catch (_) {
      // Storage unavailable — fall back to the Meat default.
    }
  }

  void setWorld(AppWorld world) {
    if (world == state || world == AppWorld.neutral) return;
    _touched = true;
    state = world;
    _storage.write(key: _kWorldKey, value: world.name);
  }

  void toggle() => setWorld(
        state == AppWorld.meat ? AppWorld.livestock : AppWorld.meat,
      );
}

final worldProvider = StateNotifierProvider<WorldNotifier, AppWorld>(
  (ref) => WorldNotifier(const FlutterSecureStorage()),
);
