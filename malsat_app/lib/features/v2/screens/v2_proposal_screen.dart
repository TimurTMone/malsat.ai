import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../v2_state.dart';
import '../v2_theme.dart';

/// MalSat v2 — Proposal.
///
/// A receipt, not a checkout. We propose the typical answer for this
/// occasion + headcount; the buyer approves the whole thing in one
/// tap, or drills into specific animals via a secondary affordance.
class V2ProposalScreen extends StatelessWidget {
  final V2OrderDraft draft;
  const V2ProposalScreen({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final p = V2Proposal.from(draft);

    return Scaffold(
      backgroundColor: V2.paper,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 240),
            children: [
              _ProposalHero(draft: draft),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROPOSAL', style: V2.step),
                    const SizedBox(height: 8),
                    Text(
                      'For ${draft.guests} guests, families typically order:',
                      style: V2.displaySmall.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 24),
                    ...p.lines.map((l) => _Line(line: l)),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.only(top: 24),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: V2.ink, width: 2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'TOTAL  ·  ЖАЛПЫ',
                            style: V2.step.copyWith(letterSpacing: 1.4),
                          ),
                          Text(
                            _formatPrice(p.total),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.6,
                              color: V2.ink,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Includes halal slaughter by an imam, your choice of '
                      'cuts (казы, чучук, ала-кесек), and delivery to your '
                      'venue 24 hours before the event. You approve every '
                      'step — nothing happens until you confirm.',
                      style: V2.body.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            top: 8,
            child: SafeArea(
              child: V2BackButton(
                onTap: () => context.pop(),
                color: V2.paper,
              ),
            ),
          ),
          // Bottom action area — gradient fade so receipt copy stays
          // legible underneath without a hard line dividing them.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00FAF7F2), Color(0xFFFAF7F2)],
                    stops: [0.0, 0.35],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('v2: drill into animals & farms'),
                            ),
                          );
                        },
                        child: const Text(
                          'Show me the animals',
                          style: TextStyle(
                            color: V2.terracotta,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      V2Cta(
                        label: 'Send order',
                        accent: true,
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          context.push('/v2/sent');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int kgs) {
    final s = kgs.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '$buf KGS';
  }
}

class _ProposalHero extends StatelessWidget {
  final V2OrderDraft draft;
  const _ProposalHero({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: const BoxDecoration(gradient: V2.heroGradientDeep),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.4, -0.4),
                  radius: 0.9,
                  colors: [Color(0x4DFFC896), Color(0x00000000)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0x801A1614)],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 32,
            bottom: 24,
            right: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${draft.occasion.en.toUpperCase()} · ${draft.guests} GUESTS',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 1.4,
                    color: V2.paper.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "We'll handle it.",
                  style: TextStyle(
                    color: V2.paper,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final V2ProposalLine line;
  const _Line({required this.line});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  line.label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: V2.ink,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Text(
                _formatKgs(line.kgs),
                style: const TextStyle(
                  fontSize: 17,
                  color: V2.ink,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(line.detail, style: V2.body.copyWith(fontSize: 13)),
          const SizedBox(height: 12),
          const Divider(height: 1, color: V2.hairline),
        ],
      ),
    );
  }

  String _formatKgs(int kgs) {
    final s = kgs.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '$buf';
  }
}
