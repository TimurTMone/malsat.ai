import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';

/// A small icon + label pill. Replaces the `_InfoChip` widget that was
/// copy-pasted across the drops, home and auctions screens.
///
/// Two presets cover every current use:
///  - [AppChip.onHero] — translucent white, for use on a coloured hero.
///  - [AppChip.soft]    — a tinted surface chip, for use on white.
class AppChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color background;
  final Color foreground;
  final double fontSize;

  const AppChip({
    super.key,
    this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    this.fontSize = 11,
  });

  /// For placement on a coloured hero banner.
  factory AppChip.onHero({
    Key? key,
    IconData? icon,
    required String label,
  }) {
    return AppChip(
      key: key,
      icon: icon,
      label: label,
      background: Colors.white.withValues(alpha: 0.18),
      foreground: Colors.white,
    );
  }

  /// A soft tinted chip for white surfaces. Pass the accent colour;
  /// the chip derives a pale background from it.
  factory AppChip.soft({
    Key? key,
    IconData? icon,
    required String label,
    Color accent = AppColors.textSecondary,
    Color? surface,
  }) {
    return AppChip(
      key: key,
      icon: icon,
      label: label,
      background: surface ?? AppColors.backgroundSecondary,
      foreground: accent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
