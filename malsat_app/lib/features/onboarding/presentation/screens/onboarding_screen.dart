import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// 3-question onboarding shown after the user's first OTP verification
/// (when their account has no `name` set). Lets us segment the user from
/// day one for tab defaults, notifications, and analytics.
///
/// Persists:
///   • name        → backend (PATCH /api/users/me)
///   • herd_size   → secure storage (until we add a Prisma column)
///   • user_role   → secure storage
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  String? _herdSize; // '0-10' | '11-50' | '51-200' | '200+'
  String? _role; // 'SELLER' | 'BUYER' | 'BOTH'
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      _herdSize != null &&
      _role != null &&
      !_saving;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _saving = true);
    try {
      // Save name to backend
      final dio = ref.read(dioProvider);
      await dio.patch(
        ApiEndpoints.me,
        data: {'name': _nameController.text.trim()},
      );

      // Save segmentation locally
      const storage = FlutterSecureStorage();
      await storage.write(key: 'onboarding_herd_size', value: _herdSize);
      await storage.write(key: 'onboarding_role', value: _role);
      await storage.write(key: 'onboarding_completed', value: '1');

      if (!mounted) return;
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Сактоо ишке ашпады: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'M',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Кош келиңиз!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Сизге ылайыктуу жөндөө үчүн 3 суроо',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Q1: Name
              _SectionLabel('1. Сиздин атыңыз?'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'мис: Бакыт',
                  prefixIcon: const Icon(LucideIcons.user, size: 20),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Q2: Herd size
              _SectionLabel('2. Канча малыңыз бар?'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _OptionChip(
                    label: '0–10',
                    sub: 'Аз',
                    isSelected: _herdSize == '0-10',
                    onTap: () => setState(() => _herdSize = '0-10'),
                  ),
                  _OptionChip(
                    label: '11–50',
                    sub: 'Орточо',
                    isSelected: _herdSize == '11-50',
                    onTap: () => setState(() => _herdSize = '11-50'),
                  ),
                  _OptionChip(
                    label: '51–200',
                    sub: 'Чоң',
                    isSelected: _herdSize == '51-200',
                    onTap: () => setState(() => _herdSize = '51-200'),
                  ),
                  _OptionChip(
                    label: '200+',
                    sub: 'Чарба',
                    isSelected: _herdSize == '200+',
                    onTap: () => setState(() => _herdSize = '200+'),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Q3: Role
              _SectionLabel('3. Эмне кылгыңыз келет?'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _OptionChip(
                    label: 'Сатам',
                    sub: 'Сатуучу',
                    icon: LucideIcons.tag,
                    isSelected: _role == 'SELLER',
                    onTap: () => setState(() => _role = 'SELLER'),
                  ),
                  _OptionChip(
                    label: 'Сатып алам',
                    sub: 'Сатып алуучу',
                    icon: LucideIcons.shoppingCart,
                    isSelected: _role == 'BUYER',
                    onTap: () => setState(() => _role = 'BUYER'),
                  ),
                  _OptionChip(
                    label: 'Экөөбү',
                    sub: 'Алам жана сатам',
                    icon: LucideIcons.refreshCw,
                    isSelected: _role == 'BOTH',
                    onTap: () => setState(() => _role = 'BOTH'),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.border,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Уланта берүү',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _saving ? null : () => context.go('/'),
                  child: const Text(
                    'Кийинчерээк',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final String sub;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionChip({
    required this.label,
    required this.sub,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white70 : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
