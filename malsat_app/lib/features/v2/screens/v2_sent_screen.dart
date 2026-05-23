import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../v2_theme.dart';

/// MalSat v2 — Sent confirmation.
///
/// Big terracotta check that pops in, two lines of text, one quiet
/// "start over" link. The order matters; nothing competes with it.
class V2SentScreen extends StatefulWidget {
  const V2SentScreen({super.key});

  @override
  State<V2SentScreen> createState() => _V2SentScreenState();
}

class _V2SentScreenState extends State<V2SentScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 540),
  )..forward();

  late final Animation<double> _scale = Tween<double>(begin: 0.4, end: 1.0)
      .chain(CurveTween(curve: Curves.easeOutBack))
      .animate(_c);

  late final Animation<double> _opacity = Tween<double>(begin: 0.0, end: 1.0)
      .chain(CurveTween(curve: Curves.easeOut))
      .animate(_c);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V2.paper,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: FadeTransition(
                      opacity: _opacity,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          color: V2.terracotta,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: V2.paper,
                          size: 48,
                          weight: 700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Жөнөтүлдү.',
                    style: V2.display.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sent. A farmer in Naryn is reviewing your order.',
                    textAlign: TextAlign.center,
                    style: V2.body,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You'll hear back within 2 hours.",
                    textAlign: TextAlign.center,
                    style: V2.body.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 56,
            child: SafeArea(
              child: Center(
                child: TextButton(
                  onPressed: () => context.go('/v2'),
                  child: const Text(
                    'Start over',
                    style: TextStyle(
                      color: V2.terracotta,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
