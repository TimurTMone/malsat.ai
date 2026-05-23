import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import 'notifications_sheet.dart';

/// App header — wordmark + notifications. The Meat ⇄ Livestock context
/// now lives as first-class tabs in the bottom nav, so the header no
/// longer carries a world switch.
class MalsatHeader extends StatelessWidget implements PreferredSizeWidget {
  const MalsatHeader({super.key});

  static const double _toolbar = 56;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbar);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _toolbar,
      titleSpacing: AppSpacing.lg,
      title: Text('MalSat', style: AppTypography.wordmark(size: 19)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: () => NotificationsSheet.show(context),
            icon: const Icon(
              LucideIcons.bell,
              size: 22,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
