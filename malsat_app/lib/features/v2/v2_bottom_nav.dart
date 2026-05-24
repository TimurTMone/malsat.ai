import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'v2_theme.dart';

/// Bottom nav — 4 tabs, big icons + text labels, no icon-only items.
/// The two left tabs are the "clear separation" between marketplace
/// browsing and event ordering.
class V2BottomNav extends StatelessWidget {
  final int currentIndex;

  const V2BottomNav({super.key, required this.currentIndex});

  static const _routes = ['/v2', '/v2/event', '/v2/sell', '/v2/account'];

  void _goTo(BuildContext context, int i) {
    if (i == currentIndex) return;
    HapticFeedback.selectionClick();
    if (i == 2 || i == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(i == 2
              ? 'v2: seller flow goes here'
              : 'v2: account flow goes here'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    context.go(_routes[i]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: V2.paper,
        border: Border(top: BorderSide(color: V2.mist, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _Tab(
                icon: Icons.storefront,
                kyLabel: 'Сатылат',
                ruLabel: 'Продаётся',
                active: currentIndex == 0,
                onTap: () => _goTo(context, 0),
              ),
              _Tab(
                icon: Icons.event,
                kyLabel: 'Иш-чарага',
                ruLabel: 'Заказ',
                active: currentIndex == 1,
                onTap: () => _goTo(context, 1),
              ),
              _Tab(
                icon: Icons.add_circle_outline,
                kyLabel: 'Сатуу',
                ruLabel: 'Продать',
                active: currentIndex == 2,
                onTap: () => _goTo(context, 2),
              ),
              _Tab(
                icon: Icons.person_outline,
                kyLabel: 'Эсеп',
                ruLabel: 'Профиль',
                active: currentIndex == 3,
                onTap: () => _goTo(context, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final IconData icon;
  final String kyLabel;
  final String ruLabel;
  final bool active;
  final VoidCallback onTap;

  const _Tab({
    required this.icon,
    required this.kyLabel,
    required this.ruLabel,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? V2.terracotta : V2.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              kyLabel,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
