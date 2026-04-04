import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — rich, warm green (not neon, not forest)
  static const Color primary = Color(0xFF1A7F56);
  static const Color primaryDark = Color(0xFF145F42);
  static const Color primaryLight = Color(0xFF34D399);

  // Brand accent
  static const Color accent = Color(0xFFFF385C); // Airbnb-inspired coral

  // Category colors — muted, sophisticated
  static const Color horseBackground = Color(0xFFFFF7ED); // warm cream
  static const Color horseForeground = Color(0xFF78350F);
  static const Color cattleBackground = Color(0xFFFFF1F2); // rose tint
  static const Color cattleForeground = Color(0xFF881337);
  static const Color sheepBackground = Color(0xFFF0FDF4); // soft mint
  static const Color sheepForeground = Color(0xFF14532D);
  static const Color arashanBackground = Color(0xFFFAF5FF); // lavender
  static const Color arashanForeground = Color(0xFF581C87);

  // Premium / Monetization
  static const Color premiumGold = Color(0xFFD97706);
  static const Color premiumGoldLight = Color(0xFFFEF3C7);
  static const Color boostBlue = Color(0xFF2563EB);
  static const Color boostBlueLight = Color(0xFFDBEAFE);

  // Neutrals — warmer than grey
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF7F7F7);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFEEEEEE);
  static const Color borderStrong = Color(0xFFDDDDDD);
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF717171);
  static const Color textMuted = Color(0xFFB0B0B0);

  // Semantic
  static const Color error = Color(0xFFE31C5F);
  static const Color success = Color(0xFF008A05);
}
