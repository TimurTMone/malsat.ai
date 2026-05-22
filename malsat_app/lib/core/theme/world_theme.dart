import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'app_world.dart';

/// Builds a world-scoped [ThemeData] from the neutral base theme.
///
/// Used by the Meat and Livestock branch screens to wrap their body in a
/// `Theme(...)` so everything below — buttons, the colour scheme, and the
/// [AppWorldPalette] extension — picks up the world accent. We override the
/// branch subtree rather than the whole `MaterialApp`, because the shell's
/// `IndexedStack` keeps all branches mounted at once.
ThemeData worldTheme(AppWorld world) {
  final base = AppTheme.light;
  final palette = AppWorldPalette.forWorld(world);

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: palette.accent,
      secondary: palette.accent,
    ),
    extensions: <ThemeExtension<dynamic>>[palette],
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: (base.elevatedButtonTheme.style ?? const ButtonStyle()).copyWith(
        backgroundColor: WidgetStatePropertyAll(palette.accent),
        foregroundColor: WidgetStatePropertyAll(palette.onAccent),
      ),
    ),
  );
}
