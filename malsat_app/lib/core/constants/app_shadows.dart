import 'package:flutter/material.dart';

/// Elevation scale. Three named tiers replace the ad-hoc `BoxShadow`
/// literals scattered across screens, so depth is consistent.
///
/// Shadows are intentionally soft and warm-neutral — closer to ambient
/// occlusion than to drop-shadow. Accent-tinted glows (e.g. on hero
/// banners) are composed locally via [coloredGlow].
class AppShadows {
  AppShadows._();

  /// Resting elevation — product cards, list rows.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000), // ~4% black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x05000000), // ~2% black
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Raised elevation — pressed/featured cards, floating buttons, popovers.
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x14000000), // ~8% black
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Sheet / modal elevation.
  static const List<BoxShadow> sheet = [
    BoxShadow(
      color: Color(0x1F000000), // ~12% black
      blurRadius: 36,
      offset: Offset(0, -4),
    ),
  ];

  /// An accent-tinted glow — for hero banners and primary CTAs.
  static List<BoxShadow> coloredGlow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.18),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
}
