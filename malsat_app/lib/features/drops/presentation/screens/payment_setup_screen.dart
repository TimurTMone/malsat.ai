import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_endpoints.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Төлөм жөндөөлөрү',
          style: TextStyle(
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
                    child: const Row(
                      children: [
                        Icon(LucideIcons.info,
                            size: 20, color: Color(0xFF92400E)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Сатып алуучулар сиздин QR кодуңузду көрүп, банк тиркемеси аркылуу төлөм жасашат.',
                            style: TextStyle(
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
                  const Text(
                    'QR код (банк тиркемеңизден)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Mbank, O!Деньги, Optima — QR кодуңуздун скриншотун жүктөңүз',
                    style: TextStyle(
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
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(LucideIcons.camera,
                                                size: 14,
                                                color: Colors.white),
                                            SizedBox(width: 4),
                                            Text('Алмаштыруу',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.qrCode,
                                        size: 48, color: AppColors.textMuted),
                                    SizedBox(height: 8),
                                    Text(
                                      'QR код жүктөө',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Сүрөтүңүздү тандаңыз',
                                      style: TextStyle(
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
                  const Text(
                    'Төлөм маалыматы',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Банк аталышы жана номериңиз (мис: "Mbank: +996555123456")',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _paymentInfoC,
                    decoration: InputDecoration(
                      hintText: 'Mbank: +996555123456',
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
                        backgroundColor: AppColors.primary,
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
                          : const Text(
                              'Сактоо',
                              style: TextStyle(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('QR код жүктөлдү!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ката: $e'), backgroundColor: AppColors.error),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Сакталды!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ката: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
