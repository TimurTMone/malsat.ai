import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography — Steppe Premium, refined.
///
/// One workhorse face — **Manrope** — carries every screen the user
/// reads. **Unbounded** is reserved for the wordmark alone, where the
/// brand wants to be felt rather than read. The weight ladder runs one
/// step lighter than the previous revision: titles set at w600, body at
/// w400, captions at w500 — so the eye breathes between elements the way
/// it does in premium global apps.
class AppTypography {
  AppTypography._();

  /// Display — the headline of a product page. Confident, single idea,
  /// almost shocking on first glance. Always single-statement.
  static TextStyle display = GoogleFonts.manrope(
    fontSize: 38,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    height: 1.05,
    color: AppColors.textPrimary,
  );

  /// Page titles.
  static TextStyle h1 = GoogleFonts.manrope(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.7,
    height: 1.12,
    color: AppColors.textPrimary,
  );

  /// Section headers.
  static TextStyle h2 = GoogleFonts.manrope(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.18,
    color: AppColors.textPrimary,
  );

  /// Card titles, list-row headlines.
  static TextStyle title = GoogleFonts.manrope(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Default body copy.
  static TextStyle body = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Secondary / supporting copy.
  static TextStyle bodyMuted = GoogleFonts.manrope(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  /// Small metadata — timestamps, counts, captions.
  static TextStyle caption = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  /// Hero price figure.
  static TextStyle priceLarge = GoogleFonts.manrope(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  /// In-card price.
  static TextStyle price = GoogleFonts.manrope(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Tracking-out eyebrow label — used for section openers.
  static TextStyle eyebrow = GoogleFonts.manrope(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
  );

  /// Uppercase chip badge.
  static TextStyle badge = GoogleFonts.manrope(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );

  /// Button / CTA label.
  static TextStyle button = GoogleFonts.manrope(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  /// Bottom-nav item label.
  static TextStyle navLabel = GoogleFonts.manrope(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.1,
  );

  /// The MalSat wordmark — the only place Unbounded is allowed to speak.
  static TextStyle wordmark({double size = 21, Color? color}) =>
      GoogleFonts.unbounded(
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: color ?? AppColors.textPrimary,
      );
}
