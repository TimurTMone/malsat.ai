import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: dictAsync.when(
          data: (dict) => Text(
            t(dict, 'profile.settings'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          loading: () => const Text(''),
          error: (_, _) => const Text(''),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: dictAsync.when(
        data: (dict) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _SectionHeader(label: t(dict, 'profile.language')),
            _SettingsItem(
              icon: LucideIcons.globe,
              label: 'Кыргызча',
              selected: locale.languageCode == 'ky',
              onTap: () =>
                  ref.read(localeProvider.notifier).state = const Locale('ky'),
            ),
            _SettingsItem(
              icon: LucideIcons.globe,
              label: 'Русский',
              selected: locale.languageCode == 'ru',
              onTap: () =>
                  ref.read(localeProvider.notifier).state = const Locale('ru'),
            ),
            const SizedBox(height: 16),
            _SectionHeader(label: 'Программа'),
            const _SettingsItem(
              icon: LucideIcons.info,
              label: 'Версия',
              trailing: Text(
                '1.4.0',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            _SettingsItem(
              icon: LucideIcons.fileText,
              label: 'Колдонуу шарттары',
              onTap: () => _showUrlSnack(
                context,
                'https://malsat.altailabs.club/terms',
              ),
            ),
            _SettingsItem(
              icon: LucideIcons.shield,
              label: 'Купуялык саясаты',
              onTap: () => _showUrlSnack(
                context,
                'https://malsat.altailabs.club/privacy',
              ),
            ),
            const SizedBox(height: 16),
            _SectionHeader(label: t(dict, 'common.logout')),
            _SettingsItem(
              icon: LucideIcons.logOut,
              label: t(dict, 'common.logout'),
              isDestructive: true,
              onTap: () {
                ref.read(authProvider.notifier).logout();
                ref.read(favoritedIdsProvider.notifier).clear();
              },
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  void _showUrlSnack(BuildContext context, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(url)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final bool isDestructive;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.selected = false,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check, size: 18, color: AppColors.primary),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
