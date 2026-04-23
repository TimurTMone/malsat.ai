import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _error;
  int _resendSeconds = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 0) {
        timer.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _handleVerify(String code) async {
    if (code.length != 6) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authProvider.notifier).verifyOtp(widget.phone, code);
      if (mounted) {
        // First-time login (no name set) → onboarding; otherwise → home
        final user = ref.read(currentUserProvider);
        final isFirstTime = user?.name == null || (user?.name?.isEmpty ?? true);
        context.go(isFirstTime ? '/onboarding' : '/');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        _pinController.clear();
        _focusNode.requestFocus();
      }
    }
  }

  Future<void> _handleResend() async {
    try {
      await ref.read(authProvider.notifier).sendOtp(widget.phone);
      _startResendTimer();
      setState(() => _error = null);
    } catch (e) {
      setState(() => _error = e.toString());
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

                Text(
                  t(dict, 'auth.verifyTitle'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t(dict, 'auth.verifySubtitle', {'phone': widget.phone}),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // OTP input
                Center(
                  child: Pinput(
                    length: 6,
                    controller: _pinController,
                    focusNode: _focusNode,
                    autofocus: true,
                    onCompleted: _handleVerify,
                    defaultPinTheme: PinTheme(
                      width: 48,
                      height: 56,
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 48,
                      height: 56,
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),

                const SizedBox(height: 32),

                // Resend
                Center(
                  child: _resendSeconds > 0
                      ? Text(
                          t(dict, 'auth.resendIn', {
                            'seconds': _resendSeconds.toString(),
                          }),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        )
                      : TextButton(
                          onPressed: _handleResend,
                          child: Text(
                            t(dict, 'auth.resendOtp'),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed: !_isLoading && _pinController.text.length == 6
                      ? () => _handleVerify(_pinController.text)
                      : null,
                  child: Text(t(dict, 'auth.verify')),
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
