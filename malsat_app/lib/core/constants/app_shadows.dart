import 'package:flutter/material.dart';

/// Elevation scale. Three named tiers replace the ad-hoc `BoxShadow`
/// literals scattered across screens, so depth is consistent.
///
/// Shadows are intentionally soft and warm-neutral. Accent-tinted glows
/// (e.g. on hero banners) are composed locally via [coloredGlow].
class AppShadows {
  AppShadows._();

  /// Resting elevation — product cards, list rows.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F000000), // ~6% black
      blurRadius: 12,
      offset: Offset(0, 3),
    ),
    BoxShadow(
      color: Color(0x08000000), // ~3% black
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Raised elevation — pressed/featured cards, floating buttons, popovers.
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x1A000000), // ~10% black
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Sheet / modal elevation.
  static const List<BoxShadow> sheet = [
    BoxShadow(
      color: Color(0x26000000), // ~15% black
      blurRadius: 32,
      offset: Offset(0, -4),
    ),
  ];

  /// An accent-tinted glow — for hero banners and primary CTAs.
  static List<BoxShadow> coloredGlow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.28),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
