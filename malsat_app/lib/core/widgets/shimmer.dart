import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Lightweight shimmer placeholder. Wraps any child (or an empty Container)
/// in a pulsing gradient that scans across — gives loading states a
/// modern, animated feel instead of a static grey rectangle.
class Shimmer extends StatefulWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const Shimmer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(8);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _ctl,
          builder: (context, _) {
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) {
                final dx = (_ctl.value * 2 - 1) * bounds.width;
                return LinearGradient(
                  begin: const Alignment(-1, 0),
                  end: const Alignment(1, 0),
                  colors: [
                    AppColors.backgroundSecondary,
                    AppColors.background,
                    AppColors.backgroundSecondary,
                  ],
                  stops: const [0.35, 0.5, 0.65],
                ).createShader(
                  Rect.fromLTWH(dx, 0, bounds.width, bounds.height),
                );
              },
              child: widget.child ??
                  Container(color: AppColors.backgroundSecondary),
            );
          },
        ),
      ),
    );
  }
}

/// Card-shaped shimmer block, ready to drop into a list while data loads.
class ShimmerCard extends StatelessWidget {
  final double height;
  const ShimmerCard({super.key, this.height = 220});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer(
            height: height,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer(
                  width: 140,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Shimmer(
                  width: 200,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 10),
                Shimmer(
                  width: 110,
                  height: 22,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
