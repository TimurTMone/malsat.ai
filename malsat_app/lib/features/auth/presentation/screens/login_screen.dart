import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizePhone(String input) {
    var phone = input.replaceAll(RegExp(r'\s+'), '');
    if (phone.startsWith('0')) {
      phone = '+996${phone.substring(1)}';
    }
    if (!phone.startsWith('+')) {
      phone = '+996$phone';
    }
    return phone;
  }

  bool get _isPhoneValid => _phoneController.text.replaceAll(' ', '').length >= 9;

  Future<void> _handleSubmit() async {
    if (!_isPhoneValid) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final phone = _normalizePhone(_phoneController.text);
      final normalizedPhone =
          await ref.read(authProvider.notifier).sendOtp(phone);
      if (mounted) {
        context.pushNamed(
          RouteNames.otpVerify,
          queryParameters: {'phone': normalizedPhone},
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDemoLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      const demoPhone = '+996555000000';
      await ref.read(authProvider.notifier).sendOtp(demoPhone);
      // Auto-verify with magic OTP code
      await ref.read(authProvider.notifier).verifyOtp(demoPhone, '000000');
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dictAsync = ref.watch(dictionaryProvider);

    return dictAsync.when(
      data: (dict) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.background,
                    shape: const CircleBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // Logo
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  t(dict, 'auth.loginTitle'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t(dict, 'auth.loginSubtitle'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Phone input
                Text(
                  t(dict, 'auth.phoneLabel'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _handleSubmit(),
                  decoration: InputDecoration(
                    hintText: t(dict, 'auth.phonePlaceholder'),
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ],

                const Spacer(),

                ElevatedButton(
                  onPressed:
                      _isPhoneValid && !_isLoading ? _handleSubmit : null,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(t(dict, 'auth.sendOtp')),
                ),
                const SizedBox(height: 12),
                // Demo login — for App Store reviewers and quick demo
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleDemoLogin,
                  icon: const Icon(Icons.bolt, size: 18),
                  label: const Text('Демо режим — заматта кирүү'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => const Scaffold(
        body: Center(child: Text('Error')),
      ),
    );
  }
}
