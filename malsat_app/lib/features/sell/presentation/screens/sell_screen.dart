import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/sell_provider.dart';

class SellScreen extends ConsumerWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);
    final isAuth = ref.watch(isAuthenticatedProvider);

    if (!isAuth) {
      return dictAsync.when(
        data: (dict) => SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.logIn,
                    size: 48, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  t(dict, 'common.login'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/auth/login'),
                  child: Text(t(dict, 'common.login')),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Error')),
      );
    }

    return dictAsync.when(
      data: (dict) => _SellChooser(dict: dict),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Center(child: Text('Error')),
    );
  }
}

class _SellChooser extends ConsumerWidget {
  final Map<String, dynamic> dict;
  const _SellChooser({required this.dict});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(dict, 'listing.create'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Эмнени сатасыз?',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Option 1: Sell live animal (existing listing)
            _SellOption(
              icon: LucideIcons.heart,
              title: 'Тирүү мал сатуу',
              subtitle: 'Жылкы, уй, кой — бүтүн мал сатуу',
              color: AppColors.primary,
              bgColor: AppColors.primary.withValues(alpha: 0.06),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(
                      title: Text(t(dict, 'listing.create')),
                      backgroundColor: AppColors.surface,
                      elevation: 0,
                    ),
                    body: _SellForm(dict: dict),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Option 2: Sell meat (create a drop)
            _SellOption(
              icon: LucideIcons.beef,
              title: 'Эт сатуу (Drop)',
              subtitle: 'Союп, килограмм менен саттыруу',
              color: const Color(0xFFB91C1C),
              bgColor: const Color(0xFFFEE2E2),
              onTap: () => context.push('/create-drop'),
            ),
            const SizedBox(height: 24),

            // Seller tools section
            const Text(
              'Сатуучу куралдары',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _ToolTile(
              icon: LucideIcons.inbox,
              title: 'Келген заказдар',
              subtitle: 'Сатып алуучулардын заказдарын башкаруу',
              onTap: () => context.push('/seller-orders'),
            ),
            _ToolTile(
              icon: LucideIcons.qrCode,
              title: 'Төлөм QR коду',
              subtitle: 'Банк QR кодуңузду жүктөңүз',
              onTap: () => context.push('/payment-setup'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SellOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _SellOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight,
                size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _SellForm extends ConsumerWidget {
  final Map<String, dynamic> dict;

  const _SellForm({required this.dict});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(sellFormProvider);
    final notifier = ref.read(sellFormProvider.notifier);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(dict, 'listing.create'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t(dict, 'auth.loginSubtitle'),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Photo picker grid
            _PhotoPickerGrid(
              images: form.images,
              dict: dict,
              onAdd: () async {
                final picker = ImagePicker();
                final picked = await picker.pickMultiImage(
                  imageQuality: 80,
                  maxWidth: 1200,
                );
                for (final file in picked) {
                  notifier.addImage(PickedImage(
                    path: file.path,
                    name: file.name,
                  ));
                }
              },
              onRemove: (index) => notifier.removeImage(index),
            ),

            // AI auto-fill button (appears when photos are picked)
            if (form.images.isNotEmpty && form.category == null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: form.isSubmitting
                        ? null
                        : () async {
                            final locale = ref.read(localeProvider);
                            final result = await notifier
                                .analyzeWithAi(locale.languageCode);
                            if (result != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result.confidence == 'high'
                                        ? 'AI: Form auto-filled'
                                        : 'AI: Check the details',
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                    icon: form.isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.sparkles, size: 18),
                    label: Text(form.isSubmitting
                        ? 'AI analyzing...'
                        : 'Auto-fill with AI'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.boostBlue,
                      side: const BorderSide(color: AppColors.boostBlue),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Category selector
            Text(
              t(dict, 'listing.category'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _CategoryButton(
                  icon: LucideIcons.wind,
                  label: t(dict, 'categories.horse'),
                  value: 'HORSE',
                  isSelected: form.category == 'HORSE',
                  bgColor: AppColors.horseBackground,
                  fgColor: AppColors.horseForeground,
                  onTap: () => notifier.setCategory('HORSE'),
                ),
                const SizedBox(width: 8),
                _CategoryButton(
                  icon: LucideIcons.beef,
                  label: t(dict, 'categories.cattle'),
                  value: 'CATTLE',
                  isSelected: form.category == 'CATTLE',
                  bgColor: AppColors.cattleBackground,
                  fgColor: AppColors.cattleForeground,
                  onTap: () => notifier.setCategory('CATTLE'),
                ),
                const SizedBox(width: 8),
                _CategoryButton(
                  icon: LucideIcons.cloud,
                  label: t(dict, 'categories.sheep'),
                  value: 'SHEEP',
                  isSelected: form.category == 'SHEEP',
                  bgColor: AppColors.sheepBackground,
                  fgColor: AppColors.sheepForeground,
                  onTap: () => notifier.setCategory('SHEEP'),
                ),
                const SizedBox(width: 8),
                _CategoryButton(
                  icon: LucideIcons.award,
                  label: t(dict, 'categories.arashan'),
                  value: 'ARASHAN',
                  isSelected: form.category == 'ARASHAN',
                  bgColor: AppColors.arashanBackground,
                  fgColor: AppColors.arashanForeground,
                  onTap: () => notifier.setCategory('ARASHAN'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            _FieldLabel(t(dict, 'listing.title')),
            const SizedBox(height: 6),
            TextField(
              onChanged: notifier.setTitle,
              decoration: InputDecoration(
                hintText: t(dict, 'listing.title'),
              ),
            ),
            const SizedBox(height: 16),

            // Price
            _FieldLabel(t(dict, 'listing.price')),
            const SizedBox(height: 6),
            TextField(
              onChanged: notifier.setPrice,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                suffixText: t(dict, 'common.som'),
              ),
            ),
            const SizedBox(height: 16),

            // Breed
            _FieldLabel(t(dict, 'listing.breed')),
            const SizedBox(height: 6),
            TextField(
              onChanged: (v) => notifier.setBreed(v.isEmpty ? null : v),
              decoration: InputDecoration(
                hintText: t(dict, 'listing.breed'),
              ),
            ),
            const SizedBox(height: 16),

            // Age + Weight row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(t(dict, 'listing.age')),
                      const SizedBox(height: 6),
                      TextField(
                        onChanged: (v) =>
                            notifier.setAge(v.isEmpty ? null : v),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          suffixText: t(dict, 'common.months'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(t(dict, 'listing.weight')),
                      const SizedBox(height: 6),
                      TextField(
                        onChanged: (v) =>
                            notifier.setWeight(v.isEmpty ? null : v),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          suffixText: t(dict, 'common.kg'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gender
            _FieldLabel(t(dict, 'common.all')),
            const SizedBox(height: 6),
            Row(
              children: [
                _GenderChip(
                  label: t(dict, 'gender.male'),
                  isSelected: form.gender == 'MALE',
                  onTap: () => notifier.setGender(
                      form.gender == 'MALE' ? null : 'MALE'),
                ),
                const SizedBox(width: 8),
                _GenderChip(
                  label: t(dict, 'gender.female'),
                  isSelected: form.gender == 'FEMALE',
                  onTap: () => notifier.setGender(
                      form.gender == 'FEMALE' ? null : 'FEMALE'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            _FieldLabel(t(dict, 'listing.description')),
            const SizedBox(height: 6),
            TextField(
              onChanged: (v) =>
                  notifier.setDescription(v.isEmpty ? null : v),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: t(dict, 'listing.description'),
              ),
            ),
            const SizedBox(height: 24),

            // Error
            if (form.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  form.error!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
              ),

            // Submit
            ElevatedButton(
              onPressed: form.isValid && !form.isSubmitting
                  ? () async {
                      final success = await ref
                          .read(sellFormProvider.notifier)
                          .submit();
                      if (success && context.mounted) {
                        context.go('/');
                      }
                    }
                  : null,
              child: form.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(t(dict, 'listing.publish')),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSelected;
  final Color bgColor;
  final Color fgColor;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSelected,
    required this.bgColor,
    required this.fgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : bgColor,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: isSelected ? Colors.white : fgColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : fgColor,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPickerGrid extends StatelessWidget {
  final List<PickedImage> images;
  final Map<String, dynamic> dict;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _PhotoPickerGrid({
    required this.images,
    required this.dict,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Add button
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.camera,
                      size: 28, color: AppColors.textMuted),
                  const SizedBox(height: 4),
                  Text(
                    t(dict, 'listing.addPhoto'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Picked images
          ...images.asMap().entries.map((entry) {
            final index = entry.key;
            final img = entry.value;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: kIsWeb
                          ? Image.network(img.path, fit: BoxFit.cover)
                          : Image.file(File(img.path), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onRemove(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.x,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Main',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
