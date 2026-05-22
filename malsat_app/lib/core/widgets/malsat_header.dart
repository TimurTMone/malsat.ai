import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import 'notifications_sheet.dart';
import 'world_switch.dart';

/// App header — the MalSat wordmark, notifications, and the pinned
/// Meat ⇄ Livestock world switch beneath. The switch is always visible,
/// so the app's two-marketplace structure is the first thing a user
/// (or an investor) sees.
class MalsatHeader extends ConsumerWidget implements PreferredSizeWidget {
  const MalsatHeader({super.key});

  static const double _toolbar = 58;
  // World switch (46) + generous breathing room above it (32) + below (14).
  static const double _switchBand = 92;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbar + _switchBand);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(_switchBand),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xxxl,
            AppSpacing.lg,
            14,
          ),
          child: WorldSwitch(),
        ),
      ),
    );
  }
}
