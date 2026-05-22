import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../theme/app_world.dart';

/// One option in a [SegmentedControl].
class SegmentItem {
  final IconData icon;
  final String label;

  const SegmentItem({required this.icon, required this.label});
}

/// A reusable pill segmented control. Promotes the `_SectionChip` row that
/// previously lived inside the (now retired) Bazaar screen.
///
/// The selected pill fills with the active world accent (or an explicit
/// [accent] override); haptic feedback fires on change.
class SegmentedControl extends StatelessWidget {
  final List<SegmentItem> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Accent for the selected pill. Defaults to the active world accent.
  final Color? accent;

  const SegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = accent ?? AppWorldPalette.of(context).accent;

    return Row(
      children: [
        for (var i = 0; i < segments.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          _SegmentPill(
            item: segments[i],
            isActive: i == selectedIndex,
            accent: activeColor,
            onTap: () {
              if (i == selectedIndex) return;
              HapticFeedback.selectionClick();
              onChanged(i);
            },
          ),
        ],
      ],
    );
  }
}

class _SegmentPill extends StatelessWidget {
  final SegmentItem item;
  final bool isActive;
  final Color accent;
  final VoidCallback onTap;

  const _SegmentPill({
    required this.item,
    required this.isActive,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? accent : AppColors.backgroundSecondary,
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: isActive ? accent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 16,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
