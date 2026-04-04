import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../i18n/app_localizations.dart';

class MalsatHeader extends ConsumerWidget implements PreferredSizeWidget {
  const MalsatHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final otherLocale = locale.languageCode == 'ky' ? 'ru' : 'ky';
    final otherLocaleName = otherLocale == 'ru' ? 'Рус' : 'Кыр';

    return AppBar(
      toolbarHeight: 52,
      title: const Text(
        'MalSat',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: AppColors.accent,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            ref.read(localeProvider.notifier).state = Locale(otherLocale);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderStrong),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.globe, size: 14, color: AppColors.textPrimary),
                const SizedBox(width: 4),
                Text(
                  otherLocaleName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
