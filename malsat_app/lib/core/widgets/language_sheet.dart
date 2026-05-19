import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../i18n/app_localizations.dart';

/// Quick language picker. Tapping a row sets the locale immediately and
/// dismisses the sheet — no extra confirm step.
class LanguageSheet extends ConsumerWidget {
  const LanguageSheet({super.key});

  static const _options = [
    _LangOption(code: 'ky', name: 'Кыргызча', flag: '🇰🇬'),
    _LangOption(code: 'ru', name: 'Русский', flag: '🇷🇺'),
    _LangOption(code: 'en', name: 'English', flag: '🇬🇧'),
  ];

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const LanguageSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    final current = ref.watch(localeProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t(dict, 'profile.language'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ..._options.map((opt) {
              final isActive = current.languageCode == opt.code;
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(localeProvider.notifier).state =
                      Locale(opt.code);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Text(
                        opt.flag,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          opt.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isActive
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isActive)
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.check,
                              size: 16, color: Colors.white),
                        )
                      else
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _LangOption {
  final String code;
  final String name;
  final String flag;
  const _LangOption({
    required this.code,
    required this.name,
    required this.flag,
  });
}
