import 'package:flutter/material.dart';
import '../constants/app_radius.dart';
import '../constants/app_shadows.dart';
import '../constants/app_spacing.dart';
import '../theme/app_world.dart';

/// The gradient hero banner that opens each marketplace world.
///
/// Replaces the three near-identical inline hero containers that lived in
/// the drops, home and auctions screens. Colours come from the active
/// world's [AppWorldPalette], so the banner is automatically meat-crimson
/// or livestock-green with no per-screen branching.
class WorldHeroBanner extends StatelessWidget {
  /// Small uppercase eyebrow label above the title.
  final String? badge;
  final String title;
  final String? subtitle;

  /// Chips rendered in a horizontal scroll below the copy
  /// (typically [AppChip.onHero]).
  final List<Widget> chips;

  /// Optional decorative icon, faintly shown in the trailing area.
  final IconData? watermark;

  /// Gradient override; defaults to the active world's hero gradient.
  final List<Color>? gradient;

  const WorldHeroBanner({
    super.key,
    this.badge,
    required this.title,
    this.subtitle,
    this.chips = const [],
    this.watermark,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppWorldPalette.of(context);
    final colors = gradient ?? palette.heroGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.coloredGlow(colors.last),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: Stack(
          children: [
            if (watermark != null)
              Positioned(
                right: -16,
                bottom: -16,
                child: Icon(
                  watermark,
                  size: 132,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Text(
                        badge!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.22,
                      letterSpacing: -0.4,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i = 0; i < chips.length; i++) ...[
                            if (i > 0) const SizedBox(width: AppSpacing.sm),
                            chips[i],
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
