import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import 'notifications_sheet.dart';

/// App header — just the MalSat wordmark and notifications. The Meat ⇄
/// Livestock world switch sits below this, at the top of the page content
/// (see `_ShellScreen`), not inside the nav bar.
class MalsatHeader extends StatelessWidget implements PreferredSizeWidget {
  const MalsatHeader({super.key});

  static const double _toolbar = 52;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbar);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _toolbar,
      titleSpacing: AppSpacing.lg,
      title: Text('MalSat', style: AppTypography.wordmark(size: 21)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: () => NotificationsSheet.show(context),
            icon: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.backgroundSecondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.bell,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
