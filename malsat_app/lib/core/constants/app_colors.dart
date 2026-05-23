import 'package:flutter/material.dart';

/// MalSat colour system — Steppe Premium, refined.
///
/// The page is paper, not cream — a warm near-white (`background`) that
/// reads global, with the deeper bone reserved for inset surfaces and
/// secondary chips. Two heritage accents — terracotta clay for Meat,
/// sagebrush olive for Livestock — and a tighter, softer category
/// palette than the previous revision (so tiles feel like watercolour,
/// not poster paint). No pure white, no pure black.
class AppColors {
  AppColors._();

  // ── Surfaces ──────────────────────────────────────────────────
  /// App canvas — pure white. Content carries the warmth, not the page.
  static const Color background = Color(0xFFFFFFFF);

  /// Inset / chip background — a barely-there warm gray.
  static const Color backgroundSecondary = Color(0xFFF4F1EA);

  /// Cards and raised surfaces — also pure white. Depth is hierarchy
  /// (typography, spacing, photography), not tint.
  static const Color surface = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE9E4D8);
  static const Color borderStrong = Color(0xFFC9C0AB);

  // ── Ink ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111111); // crisp near-black
  static const Color textSecondary = Color(0xFF6B6657); // warm taupe
  static const Color textMuted = Color(0xFFA9A28E);

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
  static const Color meatAccentSurface = Color(0xFFF6E7DC);

  // Livestock — sagebrush olive: pasture, growth, the steppe.
  static const Color livestockAccent = primary;
  static const Color livestockAccentDark = primaryDark;
  static const Color livestockAccentSurface = Color(0xFFEDEFDF);

  // Auctions — burnished ochre.
  static const Color auctionAccent = Color(0xFFC8862A);
  static const Color auctionAccentDark = Color(0xFF99641A);
  static const Color auctionAccentSurface = Color(0xFFF6ECD6);

  // ── Category tints — soft watercolour pairs ──────────────────
  static const Color horseBackground = Color(0xFFF4ECDD); // sand
  static const Color horseForeground = Color(0xFF6B5430);
  static const Color cattleBackground = Color(0xFFF5E8DD); // clay
  static const Color cattleForeground = Color(0xFF7A4326);
  static const Color sheepBackground = Color(0xFFEEF0E2); // sage
  static const Color sheepForeground = Color(0xFF4C5733);
  static const Color arashanBackground = Color(0xFFF0E8E9); // dusty plum
  static const Color arashanForeground = Color(0xFF5E4750);

  // ── Monetization ──────────────────────────────────────────────
  static const Color premiumGold = Color(0xFFC8862A);
  static const Color premiumGoldLight = Color(0xFFF6ECD6);
  static const Color boostBlue = Color(0xFF3F5E78);
  static const Color boostBlueLight = Color(0xFFE2E9EF);

  // ── Semantic ──────────────────────────────────────────────────
  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF4F7A2E);
}
