import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../v2_state.dart';
import '../v2_theme.dart';

/// MalSat v2 — Home.
///
/// One photograph (gradient until commissioned), one question,
/// five answers. No tabs, no header, no nav drawer.
class V2HomeScreen extends StatelessWidget {
  const V2HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V2.paper,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const _Hero(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Кандай иш-чарага?', style: V2.display),
                    const SizedBox(height: 4),
                    Text(
                      "What's the occasion?",
                      style: V2.body.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: V2Occasion.all.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: V2.hairline),
                  itemBuilder: (context, i) {
                    final occ = V2Occasion.all[i];
                    return _OccasionRow(occasion: occ);
                  },
                ),
              ),
            ),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.34,
      decoration: const BoxDecoration(gradient: V2.heroGradient),
      child: Stack(
        children: [
          // Radial highlight for depth without imagery.
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.4, -0.6),
                  radius: 1.0,
                  colors: [Color(0x4DFFDCB4), Color(0x00000000)],
                ),
              ),
            ),
          ),
          // Vignette
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0x731A1614)],
                  stops: [0.55, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MalSat',
                    style: TextStyle(
                      color: V2.paper,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    'KY · RU · EN',
                    style: TextStyle(
                      color: V2.paper.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OccasionRow extends StatelessWidget {
  final V2Occasion occasion;
  const _OccasionRow({required this.occasion});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/v2/count', extra: occasion);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              occasion.ky,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                color: V2.ink,
              ),
            ),
            const Spacer(),
            Text(
              occasion.en,
              style: const TextStyle(
                fontSize: 13,
                letterSpacing: 0.3,
                color: V2.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('v2: opens supplier flow')),
            );
          },
          child: const Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Мен сатам',
                    style: TextStyle(
                      color: V2.terracotta,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: '  ·  I sell',
                    style: TextStyle(color: V2.muted, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
