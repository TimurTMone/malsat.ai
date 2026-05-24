import 'package:flutter/material.dart';

/// MalSat v2.0 — single source of truth for the redesign.
///
/// One accent. Paper, ink, mist. No category palettes, no two-world
/// duality, no stock photos. Heros are gradient until commissioned
/// Kyrgyz photography exists.
class V2 {
  V2._();

  // Surface
  static const Color paper = Color(0xFFFAF7F2);
  static const Color mist = Color(0xFFE8E2D7);
  static const Color hairline = Color(0x141A1614);

  // Ink
  static const Color ink = Color(0xFF1A1614);
  static const Color muted = Color(0xFF7A716A);

  // Single accent — terracotta clay
  static const Color terracotta = Color(0xFFB7410E);
  static const Color terracottaDeep = Color(0xFF8A2F08);

  // Hero gradients — pure color, never stock photography.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment(-0.3, -0.9),
    end: Alignment(0.6, 1.0),
    colors: [Color(0xFFC97842), Color(0xFF8A2F08), Color(0xFF2A1810)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient heroGradientDeep = LinearGradient(
    begin: Alignment(-0.3, -0.9),
    end: Alignment(0.6, 1.0),
    colors: [Color(0xFF8A2F08), Color(0xFF4A1A05), Color(0xFF1A1614)],
    stops: [0.0, 0.6, 1.0],
  );

  static TextStyle get display => const TextStyle(
        fontSize: 34,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: ink,
      );

  static TextStyle get displaySmall => const TextStyle(
        fontSize: 28,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: ink,
      );

  static TextStyle get body => const TextStyle(
        fontSize: 16,
        height: 1.45,
        color: muted,
      );

  static TextStyle get step => const TextStyle(
        fontSize: 12,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w500,
        color: muted,
      );

  static TextStyle get ctaText => const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: paper,
      );
}

/// Headline-sized primary button. Ink by default, terracotta when [accent].
class V2Cta extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool accent;

  const V2Cta({
    super.key,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: accent ? V2.terracotta : V2.ink,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(label, style: V2.ctaText),
            ),
          ),
        ),
      ),
    );
  }
}

/// Farmer-and-parent button: 64pt tall, 19pt label, big tap target.
/// This is the primary CTA on all v2 screens — never use the slim
/// [V2Cta] for buyer-facing actions.
class V2BigCta extends StatelessWidget {
  final String label;
  final String? sublabel;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool accent;
  final bool outlined;

  const V2BigCta({
    super.key,
    required this.label,
    required this.onTap,
    this.sublabel,
    this.icon,
    this.accent = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = outlined
        ? V2.paper
        : (accent ? V2.terracotta : V2.ink);
    final fg = outlined ? V2.ink : V2.paper;
    final border = outlined
        ? const Border.fromBorderSide(BorderSide(color: V2.ink, width: 2))
        : null;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: border,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: fg, size: 24),
                  const SizedBox(width: 12),
                ],
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: fg,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (sublabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sublabel!,
                        style: TextStyle(
                          color: fg.withValues(alpha: 0.75),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Slim leading-back chip used on every non-home screen.
class V2BackButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  const V2BackButton({
    super.key,
    required this.onTap,
    this.color = V2.ink,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(Icons.arrow_back_ios_new, color: color, size: 22),
      ),
    );
  }
}
