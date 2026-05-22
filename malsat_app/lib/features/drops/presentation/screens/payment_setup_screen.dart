import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PaymentSetupScreen extends ConsumerStatefulWidget {
  const PaymentSetupScreen({super.key});

  @override
  ConsumerState<PaymentSetupScreen> createState() => _PaymentSetupScreenState();
}

class _PaymentSetupScreenState extends ConsumerState<PaymentSetupScreen> {
  final _paymentInfoC = TextEditingController();
  String? _qrUrl;
  bool _loading = true;
  bool _saving = false;
  bool _uploadingQr = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get(ApiEndpoints.me);
      final data = resp.data as Map<String, dynamic>;
      _paymentInfoC.text = data['paymentInfo'] as String? ?? '';
      _qrUrl = data['paymentQrUrl'] as String?;
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _paymentInfoC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          t(dict, 'paymentSetup.appBarTitle'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Explanation
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.info,
                            size: 20, color: Color(0xFF92400E)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t(dict, 'paymentSetup.explainer'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // QR Code section
                  Text(
                    t(dict, 'paymentSetup.qrSectionTitle'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t(dict, 'paymentSetup.qrSectionSub'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // QR image or upload button
                  GestureDetector(
                    onTap: _uploadingQr ? null : _pickQrImage,
                    child: Container(
                      width: double.infinity,
                      height: 240,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: _uploadingQr
                          ? const Center(child: CircularProgressIndicator())
                          : _qrUrl != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CachedNetworkImage(
                                        imageUrl: _qrUrl!,
                                        width: double.infinity,
                                        height: 240,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.6),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(LucideIcons.camera,
                                                size: 14,
                                                color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(t(dict, 'paymentSetup.replaceQr'),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(LucideIcons.qrCode,
                                        size: 48, color: AppColors.textMuted),
                                    const SizedBox(height: 8),
                                    Text(
                                      t(dict, 'paymentSetup.qrEmptyTitle'),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      t(dict, 'paymentSetup.qrEmptySub'),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment info text
                  Text(
                    t(dict, 'paymentSetup.paymentInfoTitle'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t(dict, 'paymentSetup.paymentInfoSub'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _paymentInfoC,
                    decoration: InputDecoration(
                      hintText: t(dict, 'paymentSetup.paymentInfoHint2'),
                      hintStyle: const TextStyle(
                          color: AppColors.textMuted, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.backgroundSecondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _savePaymentInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.meatAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              t(dict, 'common.save'),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _pickQrImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() => _uploadingQr = true);
    try {
      final dio = ref.read(dioProvider);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(picked.path,
            filename: 'qr_code.jpg'),
      });
      final resp = await dio.post(
        ApiEndpoints.upload,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final url = (resp.data as Map<String, dynamic>)['mediaUrl'] as String;

      // Save QR URL to profile
      await dio.patch(ApiEndpoints.me, data: {'paymentQrUrl': url});

      setState(() => _qrUrl = url);

      if (!mounted) return;
      final dict = ref.read(dictionaryProvider).valueOrNull;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(dict, 'paymentSetup.qrUploaded')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final dict = ref.read(dictionaryProvider).valueOrNull;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(dict, 'common.errorPrefix', {'message': '$e'})), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _uploadingQr = false);
    }
  }

  Future<void> _savePaymentInfo() async {
    setState(() => _saving = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.patch(ApiEndpoints.me, data: {
        'paymentInfo': _paymentInfoC.text.trim(),
      });

      if (!mounted) return;
      final dict = ref.read(dictionaryProvider).valueOrNull;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(dict, 'paymentSetup.savedMsg')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final dict = ref.read(dictionaryProvider).valueOrNull;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(dict, 'common.errorPrefix', {'message': '$e'})), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
