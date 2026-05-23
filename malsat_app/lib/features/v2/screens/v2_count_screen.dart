import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../v2_state.dart';
import '../v2_theme.dart';

/// MalSat v2 — Guest count.
///
/// One enormous number, one slider. The number IS the interface;
/// chrome is reduced to a back chip and a CTA.
class V2CountScreen extends StatefulWidget {
  final V2Occasion occasion;
  const V2CountScreen({super.key, required this.occasion});

  @override
  State<V2CountScreen> createState() => _V2CountScreenState();
}

class _V2CountScreenState extends State<V2CountScreen> {
  late int _count = widget.occasion.defaultGuests;

  @override
  Widget build(BuildContext context) {
    final clamped = _count.clamp(2, 500);
    return Scaffold(
      backgroundColor: V2.paper,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  V2BackButton(onTap: () => context.pop()),
                  const SizedBox(height: 32),
                  Text('1 / 2', style: V2.step),
                  const SizedBox(height: 16),
                  Text(widget.occasion.ky, style: V2.display),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.occasion.en} · How many guests?',
                    style: V2.body,
                  ),
                  const SizedBox(height: 64),
                  Center(
                    child: Text(
                      '$clamped',
                      style: const TextStyle(
                        fontSize: 96,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -3,
                        height: 1,
                        color: V2.ink,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'guests',
                      style: V2.body.copyWith(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: V2.terracotta,
                      inactiveTrackColor: V2.mist,
                      thumbColor: V2.terracotta,
                      overlayColor: V2.terracotta.withValues(alpha: 0.16),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 14,
                      ),
                    ),
                    child: Slider(
                      min: 2,
                      max: 500,
                      divisions: 498,
                      value: clamped.toDouble(),
                      onChanged: (v) {
                        setState(() => _count = v.round());
                        HapticFeedback.selectionClick();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: V2Cta(
                label: 'Continue',
                onTap: () {
                  HapticFeedback.mediumImpact();
                  final draft = V2OrderDraft(
                    occasion: widget.occasion,
                    guests: clamped,
                  );
                  context.push('/v2/proposal', extra: draft);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
