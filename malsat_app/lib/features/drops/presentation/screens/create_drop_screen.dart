import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../providers/drops_provider.dart';

class CreateDropScreen extends ConsumerStatefulWidget {
  const CreateDropScreen({super.key});

  @override
  ConsumerState<CreateDropScreen> createState() => _CreateDropScreenState();
}

class _CreateDropScreenState extends ConsumerState<CreateDropScreen> {
  String? _category;
  final List<File> _photos = [];
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final _breedC = TextEditingController();
  final _weightC = TextEditingController();
  final _priceC = TextEditingController();
  final _minC = TextEditingController(text: '3');
  final _addressC = TextEditingController();
  final _villageC = TextEditingController();
  final _deliveryRadiusC = TextEditingController();
  final _deliveryFeeC = TextEditingController(text: '0');
  DateTime _butcherDate = DateTime.now().add(const Duration(days: 3));
  bool _deliveryAvailable = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    _breedC.dispose();
    _weightC.dispose();
    _priceC.dispose();
    _minC.dispose();
    _addressC.dispose();
    _villageC.dispose();
    _deliveryRadiusC.dispose();
    _deliveryFeeC.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _photos.isNotEmpty &&
      _category != null &&
      _titleC.text.isNotEmpty &&
      _weightC.text.isNotEmpty &&
      _priceC.text.isNotEmpty &&
      _addressC.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          t(dict, 'createDrop.title'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.meatAccentDark, AppColors.meatAccent],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.beef, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t(dict, 'createDrop.headerTitle'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          t(dict, 'createDrop.headerSubtitle'),
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Photo picker — REQUIRED
            _label(t(dict, 'createDrop.photosRequired')),
            const SizedBox(height: 4),
            Text(
              t(dict, 'createDrop.photosHint'),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add photo button
                  GestureDetector(
                    onTap: _pickPhotos,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border, width: 1.5),
                        borderRadius: BorderRadius.circular(14),
                        color: AppColors.backgroundSecondary,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.camera, size: 28, color: AppColors.meatAccent),
                          const SizedBox(height: 4),
                          Text(t(dict, 'createDrop.addPhotoBtn'),
                              style: const TextStyle(fontSize: 11, color: AppColors.meatAccent, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  // Photos
                  ..._photos.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(e.value, width: 110, height: 110, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4, right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _photos.removeAt(e.key)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.x, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                        if (e.key == 0)
                          Positioned(
                            bottom: 4, left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.meatAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(t(dict, 'createDrop.mainPhoto'), style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category
            _label(t(dict, 'createDrop.categoryRequired')),
            const SizedBox(height: 8),
            Row(
              children: [
                _catBtn('CATTLE', t(dict, 'createDrop.catCattle'), LucideIcons.beef,
                    AppColors.cattleBackground, AppColors.cattleForeground),
                const SizedBox(width: 8),
                _catBtn('SHEEP', t(dict, 'createDrop.catSheep'), LucideIcons.cloud,
                    AppColors.sheepBackground, AppColors.sheepForeground),
                const SizedBox(width: 8),
                _catBtn('HORSE', t(dict, 'createDrop.catHorse'), LucideIcons.wind,
                    AppColors.horseBackground, AppColors.horseForeground),
                const SizedBox(width: 8),
                _catBtn('ARASHAN', t(dict, 'createDrop.catGoat'), LucideIcons.award,
                    AppColors.arashanBackground, AppColors.arashanForeground),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            _label(t(dict, 'createDrop.titleRequired')),
            const SizedBox(height: 6),
            _field(_titleC, t(dict, 'createDrop.titlePlaceholder')),
            const SizedBox(height: 16),

            // Description
            _label(t(dict, 'listing.description')),
            const SizedBox(height: 6),
            _field(_descC, t(dict, 'createDrop.descriptionPlaceholder'), lines: 3),
            const SizedBox(height: 16),

            // Breed
            _label(t(dict, 'listing.breed')),
            const SizedBox(height: 6),
            _field(_breedC, t(dict, 'createDrop.breedPlaceholder')),
            const SizedBox(height: 16),

            // Weight + Price per kg
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(t(dict, 'createDrop.totalWeightRequired')),
                      const SizedBox(height: 6),
                      _field(_weightC, t(dict, 'createDrop.weightPlaceholder'), keyboard: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(t(dict, 'createDrop.priceRequired')),
                      const SizedBox(height: 6),
                      _field(_priceC, t(dict, 'createDrop.pricePlaceholder'), keyboard: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Min order
            _label(t(dict, 'createDrop.minOrder')),
            const SizedBox(height: 6),
            _field(_minC, t(dict, 'createDrop.minPlaceholder'), keyboard: TextInputType.number),
            const SizedBox(height: 16),

            // Butcher date
            _label(t(dict, 'createDrop.butcherDateRequired')),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _butcherDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (picked != null) setState(() => _butcherDate = picked);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.calendar,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      '${_butcherDate.day}.${_butcherDate.month.toString().padLeft(2, '0')}.${_butcherDate.year}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pickup address
            _label(t(dict, 'createDrop.pickupRequired')),
            const SizedBox(height: 6),
            _field(_addressC, t(dict, 'createDrop.pickupPlaceholder')),
            const SizedBox(height: 6),
            _label(t(dict, 'createDrop.village')),
            const SizedBox(height: 6),
            _field(_villageC, t(dict, 'createDrop.villagePlaceholder')),
            const SizedBox(height: 20),

            // Delivery toggle
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.truck,
                          size: 20, color: AppColors.meatAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t(dict, 'createDrop.deliveryToggleTitle'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Switch.adaptive(
                        value: _deliveryAvailable,
                        onChanged: (v) =>
                            setState(() => _deliveryAvailable = v),
                        activeTrackColor: AppColors.meatAccent,
                      ),
                    ],
                  ),
                  if (_deliveryAvailable) ...[
                    const SizedBox(height: 10),
                    _field(_deliveryFeeC, t(dict, 'createDrop.deliveryFeePlaceholder'),
                        keyboard: TextInputType.number),
                    const SizedBox(height: 8),
                    _field(_deliveryRadiusC, t(dict, 'createDrop.deliveryRadiusPlaceholder')),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Error
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!,
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 13)),
              ),

            // Total preview
            if (_weightC.text.isNotEmpty && _priceC.text.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.meatAccent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t(dict, 'createDrop.totalPriceLabel'),
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textSecondary)),
                    Text(
                      '${((double.tryParse(_weightC.text) ?? 0) * (int.tryParse(_priceC.text) ?? 0)).round()} ${t(dict, 'common.som')}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.meatAccent,
                      ),
                    ),
                  ],
                ),
              ),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isValid && !_submitting ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.meatAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        t(dict, 'createDrop.publishBtn'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );

  Widget _field(TextEditingController c, String hint,
      {int lines = 1, TextInputType? keyboard}) {
    return TextField(
      controller: c,
      maxLines: lines,
      keyboardType: keyboard,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }

  Widget _catBtn(String value, String label, IconData icon, Color bg, Color fg) {
    final sel = _category == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _category = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: sel ? AppColors.meatAccent : bg,
            borderRadius: BorderRadius.circular(12),
            border:
                sel ? Border.all(color: AppColors.meatAccent, width: 2) : null,
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: sel ? Colors.white : fg),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80, maxWidth: 1200);
    if (picked.isNotEmpty) {
      setState(() {
        _photos.addAll(picked.map((p) => File(p.path)));
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final api = ref.read(dropsApiProvider);

      // 1. Upload photos first
      final photoUrls = <String>[];
      for (final photo in _photos) {
        final url = await api.uploadPhoto(photo, filename: 'drop_photo.jpg');
        photoUrls.add(url);
      }

      // 2. Create the drop
      await api.createDrop(
        title: _titleC.text.trim(),
        description:
            _descC.text.trim().isEmpty ? null : _descC.text.trim(),
        category: _category!,
        breed:
            _breedC.text.trim().isEmpty ? null : _breedC.text.trim(),
        totalWeightKg: double.parse(_weightC.text.trim()),
        pricePerKg: int.parse(_priceC.text.trim()),
        minOrderKg: double.tryParse(_minC.text.trim()) ?? 3,
        butcherDate: _butcherDate,
        pickupAddress: _addressC.text.trim(),
        village:
            _villageC.text.trim().isEmpty ? null : _villageC.text.trim(),
        deliveryAvailable: _deliveryAvailable,
        deliveryFee: int.tryParse(_deliveryFeeC.text.trim()) ?? 0,
        deliveryRadius: _deliveryRadiusC.text.trim().isEmpty
            ? null
            : _deliveryRadiusC.text.trim(),
      );

      // 3. Attach photos to the drop via upload endpoint with dropId
      // (photos already uploaded, urls stored — drop cards will show them)

      if (!mounted) return;
      final dict = ref.read(dictionaryProvider).valueOrNull;
      ref.invalidate(dropsListProvider);
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(dict, 'createDrop.publishedToast')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
