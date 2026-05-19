import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../state/view_mode.dart';

/// Marketplace view-mode picker, Unaa-style: three flat icon buttons,
/// active one filled with a black rounded square. No container chrome,
/// drops cleanly into any row.
class ViewModeToggle extends ConsumerWidget {
  /// When true the row tightens itself; otherwise it lays the buttons
  /// out at their natural square sizes.
  final bool compact;

  const ViewModeToggle({super.key, this.compact = false});

  static const _modes = [
    ListingViewMode.grid,
    ListingViewMode.large,
    ListingViewMode.list,
  ];

  static const _icons = [
    LucideIcons.layoutGrid,
    LucideIcons.rectangleHorizontal,
    LucideIcons.list,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(listingViewModeProvider);
    final notifier = ref.read(listingViewModeProvider.notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_modes.length, (i) {
        final mode = _modes[i];
        final isActive = mode == current;
        return Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
          child: _ViewModeIconButton(
            icon: _icons[i],
            isActive: isActive,
            compact: compact,
            onTap: () {
              if (isActive) return;
              HapticFeedback.selectionClick();
              notifier.state = mode;
            },
          ),
        );
      }),
    );
  }
}

class _ViewModeIconButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool compact;
  final VoidCallback onTap;

  const _ViewModeIconButton({
    required this.icon,
    required this.isActive,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 34.0 : 40.0;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF111111) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(anim),
              child: child,
            ),
          ),
          child: Icon(
            icon,
            key: ValueKey(isActive),
            size: compact ? 17 : 19,
            color: isActive ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
