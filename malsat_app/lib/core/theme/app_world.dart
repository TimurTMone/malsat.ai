import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// The two co-equal marketplace worlds, plus a neutral default for screens
/// that belong to neither (Sell, Herd, Profile, auth).
enum AppWorld { meat, livestock, neutral }

/// Per-world palette, carried on the [ThemeData] as a [ThemeExtension].
///
/// Widgets that must recolor per world read it with
/// `Theme.of(context).extension<AppWorldPalette>()` (see the [of] helper),
/// instead of reaching for `AppColors` constants directly. This is what
/// makes the Meat tab read crimson and the Livestock tab read green
/// without any per-widget branching.
@immutable
class AppWorldPalette extends ThemeExtension<AppWorldPalette> {
  final AppWorld world;

  /// The world's primary accent — CTAs, active states, highlights.
  final Color accent;

  /// A darker shade of the accent — gradients, pressed states.
  final Color accentDark;

  /// A pale tint of the accent — selected backgrounds, soft fills.
  final Color accentSurface;

  /// Foreground colour to use on top of [accent].
  final Color onAccent;

  /// Gradient stops for the world's hero banner.
  final List<Color> heroGradient;

  const AppWorldPalette({
    required this.world,
    required this.accent,
    required this.accentDark,
    required this.accentSurface,
    required this.onAccent,
    required this.heroGradient,
  });

  static const AppWorldPalette meat = AppWorldPalette(
    world: AppWorld.meat,
    accent: AppColors.meatAccent,
    accentDark: AppColors.meatAccentDark,
    accentSurface: AppColors.meatAccentSurface,
    onAccent: Colors.white,
    heroGradient: [AppColors.meatAccentDark, AppColors.meatAccent],
  );

  static const AppWorldPalette livestock = AppWorldPalette(
    world: AppWorld.livestock,
    accent: AppColors.livestockAccent,
    accentDark: AppColors.livestockAccentDark,
    accentSurface: AppColors.livestockAccentSurface,
    onAccent: Colors.white,
    heroGradient: [AppColors.livestockAccentDark, AppColors.livestockAccent],
  );

  static const AppWorldPalette neutral = AppWorldPalette(
    world: AppWorld.neutral,
    accent: AppColors.accent,
    accentDark: AppColors.primaryDark,
    accentSurface: AppColors.backgroundSecondary,
    onAccent: Colors.white,
    heroGradient: [AppColors.primaryDark, AppColors.primary],
  );

  static AppWorldPalette forWorld(AppWorld world) => switch (world) {
        AppWorld.meat => meat,
        AppWorld.livestock => livestock,
        AppWorld.neutral => neutral,
      };

  /// Reads the active world palette from context, falling back to neutral
  /// if no extension is registered (e.g. inside a bare [Theme]).
  static AppWorldPalette of(BuildContext context) =>
      Theme.of(context).extension<AppWorldPalette>() ?? neutral;

  @override
  AppWorldPalette copyWith({
    AppWorld? world,
    Color? accent,
    Color? accentDark,
    Color? accentSurface,
    Color? onAccent,
    List<Color>? heroGradient,
  }) {
    return AppWorldPalette(
      world: world ?? this.world,
      accent: accent ?? this.accent,
      accentDark: accentDark ?? this.accentDark,
      accentSurface: accentSurface ?? this.accentSurface,
      onAccent: onAccent ?? this.onAccent,
      heroGradient: heroGradient ?? this.heroGradient,
    );
  }

  @override
  AppWorldPalette lerp(ThemeExtension<AppWorldPalette>? other, double t) {
    if (other is! AppWorldPalette) return this;
    return AppWorldPalette(
      world: t < 0.5 ? world : other.world,
      accent: Color.lerp(accent, other.accent, t)!,
      accentDark: Color.lerp(accentDark, other.accentDark, t)!,
      accentSurface: Color.lerp(accentSurface, other.accentSurface, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      heroGradient: [
        Color.lerp(heroGradient.first, other.heroGradient.first, t)!,
        Color.lerp(heroGradient.last, other.heroGradient.last, t)!,
      ],
    );
  }
}
