import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../v2_bottom_nav.dart';
import '../v2_state.dart';
import '../v2_theme.dart';

/// MalSat v2 — Event picker (entered from the home's second card).
///
/// One question, five answers, in Kyrgyz + Russian. Big tappable rows
/// for thumb-reach and reading distance — designed for parents and
/// older farmers, not designers.
class V2EventPickerScreen extends StatelessWidget {
  const V2EventPickerScreen({super.key});

  static const _occasions = <_OccasionItem>[
    _OccasionItem(
      data: V2Occasion.janaza,
      ky: 'Жаназа',
      ru: 'Похороны',
    ),
    _OccasionItem(
      data: V2Occasion.toi,
      ky: 'Той',
      ru: 'Свадьба',
    ),
    _OccasionItem(
      data: V2Occasion.tushoo,
      ky: 'Тушоо той',
      ru: 'Тушоо той',
    ),
    _OccasionItem(
      data: V2Occasion.kudai,
      ky: 'Кудай тамак',
      ru: 'Поминальный обед',
    ),
    _OccasionItem(
      data: V2Occasion.today,
      ky: 'Бугүн жейм',
      ru: 'На сегодня',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V2.paper,
      body: Column(
        children: [
          const _PickerHero(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: _occasions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final o = _occasions[i];
                return _OccasionRow(item: o);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const V2BottomNav(currentIndex: 1),
    );
  }
}

class _OccasionItem {
  final V2Occasion data;
  final String ky;
  final String ru;
  const _OccasionItem({
    required this.data,
    required this.ky,
    required this.ru,
  });
}

class _PickerHero extends StatelessWidget {
  const _PickerHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 24, 24),
      decoration: const BoxDecoration(gradient: V2.heroGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Кандай иш-чарага?',
              style: TextStyle(
                color: V2.paper,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Для какого мероприятия?',
              style: TextStyle(
                color: V2.paper.withValues(alpha: 0.85),
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _OccasionRow extends StatelessWidget {
  final _OccasionItem item;
  const _OccasionRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: V2.paper,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/v2/count', extra: item.data);
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: V2.mist, width: 1.2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.ky,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: V2.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.ru,
                      style: const TextStyle(
                        fontSize: 15,
                        color: V2.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: V2.muted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
