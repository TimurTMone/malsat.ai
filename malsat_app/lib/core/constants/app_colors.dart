import 'package:flutter/material.dart';

/// MalSat colour system — "Steppe Premium".
///
/// A warm, earthen palette: bone surfaces, warm-ink type, and two
/// heritage accents — terracotta clay for the Meat world, sagebrush
/// olive for the Livestock world. No pure white, no pure black —
/// every surface is warmed, the way felt and leather are warm.
class AppColors {
  AppColors._();

  // ── Surfaces ──────────────────────────────────────────────────
  /// App background — warm bone.
  static const Color background = Color(0xFFF3EEE3);

  /// Inset / chip background — a deeper bone.
  static const Color backgroundSecondary = Color(0xFFEAE3D3);

  /// Cards and raised surfaces — a warm near-white.
  static const Color surface = Color(0xFFFDFBF5);

  static const Color border = Color(0xFFE3DBC9);
  static const Color borderStrong = Color(0xFFCFC5AE);

  // ── Ink ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1F1B14); // warm near-black
  static const Color textSecondary = Color(0xFF6E6553); // warm taupe
  static const Color textMuted = Color(0xFFA89E88);

  // ── Brand ─────────────────────────────────────────────────────
  /// Neutral brand accent — terracotta clay.
  static const Color accent = Color(0xFFC8502D);

  /// Livestock world base — sagebrush olive.
  static const Color primary = Color(0xFF6F7A3F);
  static const Color primaryDark = Color(0xFF525A2C);
  static const Color primaryLight = Color(0xFF97A05F);

  // ── World accents ─────────────────────────────────────────────
  // Meat — terracotta clay: warmth, fire, appetite.
  static const Color meatAccent = Color(0xFFC8502D);
  static const Color meatAccentDark = Color(0xFF9A3A1E);
  static const Color meatAccentSurface = Color(0xFFF3E1D6);

  // Livestock — sagebrush olive: pasture, growth, the steppe.
  static const Color livestockAccent = primary;
  static const Color livestockAccentDark = primaryDark;
  static const Color livestockAccentSurface = Color(0xFFE8EAD8);

  // Auctions — burnished ochre.
  static const Color auctionAccent = Color(0xFFC8862A);
  static const Color auctionAccentDark = Color(0xFF99641A);
  static const Color auctionAccentSurface = Color(0xFFF2E6CE);

  // ── Category tints — muted earthen pairs ──────────────────────
  static const Color horseBackground = Color(0xFFEFE6D3); // sand
  static const Color horseForeground = Color(0xFF6B5430);
  static const Color cattleBackground = Color(0xFFF0E2D6); // clay
  static const Color cattleForeground = Color(0xFF7A4326);
  static const Color sheepBackground = Color(0xFFE7EADA); // sage
  static const Color sheepForeground = Color(0xFF4C5733);
  static const Color arashanBackground = Color(0xFFEAE1E2); // dusty plum
  static const Color arashanForeground = Color(0xFF5E4750);

  // ── Monetization ──────────────────────────────────────────────
  static const Color premiumGold = Color(0xFFC8862A);
  static const Color premiumGoldLight = Color(0xFFF2E6CE);
  static const Color boostBlue = Color(0xFF3F5E78);
  static const Color boostBlueLight = Color(0xFFDFE6EC);

  // ── Semantic ──────────────────────────────────────────────────
  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF4F7A2E);
}
