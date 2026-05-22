import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography — the Steppe Premium voice.
///
/// Two typefaces carry the brand:
///  - **Unbounded** — a geometric display face for statements (the
///    wordmark, page titles, hero prices). Distinctly not-a-template,
///    full Cyrillic support.
///  - **Manrope** — a warm, highly readable grotesk for everything the
///    eye actually reads (body, UI, captions).
class AppTypography {
  AppTypography._();

  /// Display face — big brand statements.
  static TextStyle display = GoogleFonts.unbounded(
    fontSize: 21,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Page titles.
  static TextStyle h1 = GoogleFonts.unbounded(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.22,
    color: AppColors.textPrimary,
  );

  /// Section headers.
  static TextStyle h2 = GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// Card titles, list-row headlines.
  static TextStyle title = GoogleFonts.manrope(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Default body copy.
  static TextStyle body = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  /// Secondary / supporting copy.
  static TextStyle bodyMuted = GoogleFonts.manrope(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  /// Small metadata — timestamps, counts, captions.
  static TextStyle caption = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  /// Hero price figure — set in the display face.
  static TextStyle priceLarge = GoogleFonts.unbounded(
    fontSize: 21,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  /// In-card price.
  static TextStyle price = GoogleFonts.manrope(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Uppercase tracking-out badge / eyebrow label.
  static TextStyle badge = GoogleFonts.manrope(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
  );

  /// Button / CTA label.
  static TextStyle button = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.1,
  );

  /// Bottom-nav item label.
  static TextStyle navLabel = GoogleFonts.manrope(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  /// The MalSat wordmark.
  static TextStyle wordmark({double size = 22, Color? color}) =>
      GoogleFonts.unbounded(
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: color ?? AppColors.textPrimary,
      );
}
