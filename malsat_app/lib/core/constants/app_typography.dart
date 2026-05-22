import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography ramp. Named styles replace the dozens of inline `TextStyle`s
/// so weight, size and tracking stay consistent across the app.
///
/// The app uses the platform font; hierarchy comes from weight + tracking,
/// not a custom typeface. Tight negative tracking on large text gives the
/// modern, condensed marketplace feel.
class AppTypography {
  AppTypography._();

  /// Big screen / hero titles.
  static const TextStyle display = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    height: 1.15,
    color: AppColors.textPrimary,
  );

  /// Page titles.
  static const TextStyle h1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Section headers.
  static const TextStyle h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// Card titles, list-row headlines.
  static const TextStyle title = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Default body copy.
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// Secondary / supporting copy.
  static const TextStyle bodyMuted = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Small metadata — timestamps, counts, captions.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  /// Hero price figure.
  static const TextStyle priceLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  /// In-card price.
  static const TextStyle price = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  /// Uppercase tracking-out badge / eyebrow label.
  static const TextStyle badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.6,
  );

  /// Button / CTA label.
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  /// Bottom-nav item label.
  static const TextStyle navLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );
}
