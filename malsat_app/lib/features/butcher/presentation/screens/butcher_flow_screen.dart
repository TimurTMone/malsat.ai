import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../domain/butcher_partner.dart';
import '../../domain/cut.dart';
import '../../domain/occasion.dart';
import '../providers/butcher_provider.dart';

/// The butcher-service flow — one scrolling screen, one decision.
///
/// Sections (top → bottom):
///   1. Animal — category + weight + optional description
///   2. Occasion — Жаназа / Той / Тушоо той / Кудай тамак / Башка
///   3. Cuts — checkbox list, defaults set per occasion
///   4. Halal — imam toggle, qibla trust line, optional special dua
///   5. Delivery — address, date, contact phone, optional note
///   6. Review — receipt + submit CTA
class ButcherFlowScreen extends ConsumerStatefulWidget {
  const ButcherFlowScreen({super.key});

  @override
  ConsumerState<ButcherFlowScreen> createState() => _ButcherFlowScreenState();
}

class _ButcherFlowScreenState extends ConsumerState<ButcherFlowScreen> {
  // Form state.
  String _animalCategory = 'CATTLE';
  final _weightController = TextEditingController();
  final _descController = TextEditingController();
  Occasion? _occasion;
  Set<Cut> _cuts = const {};
  bool _imamRequested = true;
  final _specialDuaController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _deliveryDate = _defaultDeliveryDate();
  bool _submitting = false;

  static DateTime _defaultDeliveryDate() {
    // Default to tomorrow 9am local time.
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 9);
    return tomorrow;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _descController.dispose();
    _specialDuaController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onOccasionPicked(Occasion o) {
    setState(() {
      _occasion = o;
      // Only seed defaults if the user hasn't customised cuts yet.
      if (_cuts.isEmpty) {
        _cuts = defaultCutsForOccasion(o.wireName).toSet();
      }
    });
  }

  void _toggleCut(Cut c) {
    setState(() {
      final next = Set<Cut>.from(_cuts);
      if (c == Cut.whole) {
        // Whole is exclusive — picking it clears everything else.
        next.clear();
        next.add(Cut.whole);
      } else {
        next.remove(Cut.whole);
        if (next.contains(c)) {
          next.remove(c);
        } else {
          // Bone-in / boneless are mutually exclusive.
          if (c == Cut.boneIn) next.remove(Cut.boneless);
          if (c == Cut.boneless) next.remove(Cut.boneIn);
          next.add(c);
        }
      }
      _cuts = next;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final earliest = now.add(const Duration(hours: 5));
    final latest = now.add(const Duration(hours: 47));
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate.isBefore(earliest) ? earliest : _deliveryDate,
      firstDate: earliest,
      lastDate: latest,
    );
    if (picked == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _deliveryDate.hour, minute: _deliveryDate.minute),
    );
    if (time == null || !mounted) return;
    final combined = DateTime(
      picked.year,
      picked.month,
      picked.day,
      time.hour,
      time.minute,
    );
    setState(() {
      _deliveryDate = combined.isBefore(earliest) ? earliest : combined;
    });
  }

  bool get _isValid {
    final w = double.tryParse(_weightController.text.replaceAll(',', '.'));
    return w != null &&
        w > 0 &&
        _occasion != null &&
        _cuts.isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty;
  }

  Future<void> _submit(ButcherPartner partner, Map<String, dynamic>? dict) async {
    if (!_isValid || _submitting) return;
    setState(() => _submitting = true);
    HapticFeedback.mediumImpact();
    try {
      final api = ref.read(butcherApiProvider);
      final weight = double.parse(_weightController.text.replaceAll(',', '.'));
      final result = await api.submitOrder(
        partnerId: partner.id,
        animalCategory: _animalCategory,
        animalWeightKg: weight,
        animalDescription: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        occasionType: _occasion!.wireName,
        imamRequested: _imamRequested,
        cuttingPreset: _cuts.map((c) => c.wireName).toList(),
        specialDua: _specialDuaController.text.trim().isEmpty
            ? null
            : _specialDuaController.text.trim(),
        deliveryAddress: _addressController.text.trim(),
        deliveryDate: _deliveryDate,
        buyerPhone: _phoneController.text.trim(),
        buyerNote: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(dict, 'butcher.success')),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/order/${result.order.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(dict, 'butcher.errors.submit')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final partnersAsync = ref.watch(butcherPartnersProvider);
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(t(dict, 'butcher.headerTitle'), style: AppTypography.h1.copyWith(fontSize: 18)),
        centerTitle: false,
      ),
      body: partnersAsync.when(
        loading: () => Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              t(dict, 'butcher.partner.loading'),
              style: AppTypography.bodyMuted,
            ),
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(t(dict, 'butcher.errors.noPartner'),
                style: AppTypography.bodyMuted),
          ),
        ),
        data: (partners) {
          if (partners.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(t(dict, 'butcher.errors.noPartner'),
                    style: AppTypography.bodyMuted),
              ),
            );
          }
          final partner = partners.first;
          return _Body(
            partner: partner,
            dict: dict,
            animalCategory: _animalCategory,
            onCategoryChanged: (c) => setState(() => _animalCategory = c),
            weightController: _weightController,
            descController: _descController,
            occasion: _occasion,
            onOccasion: _onOccasionPicked,
            cuts: _cuts,
            onCutToggle: _toggleCut,
            imamRequested: _imamRequested,
            onImamToggle: (v) => setState(() => _imamRequested = v),
            specialDuaController: _specialDuaController,
            addressController: _addressController,
            phoneController: _phoneController,
            noteController: _noteController,
            deliveryDate: _deliveryDate,
            onPickDate: _pickDate,
            isValid: _isValid,
            submitting: _submitting,
            onSubmit: () => _submit(partner, dict),
            onAnyChange: () => setState(() {}),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final ButcherPartner partner;
  final Map<String, dynamic>? dict;
  final String animalCategory;
  final ValueChanged<String> onCategoryChanged;
  final TextEditingController weightController;
  final TextEditingController descController;
  final Occasion? occasion;
  final ValueChanged<Occasion> onOccasion;
  final Set<Cut> cuts;
  final ValueChanged<Cut> onCutToggle;
  final bool imamRequested;
  final ValueChanged<bool> onImamToggle;
  final TextEditingController specialDuaController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController noteController;
  final DateTime deliveryDate;
  final VoidCallback onPickDate;
  final bool isValid;
  final bool submitting;
  final VoidCallback onSubmit;
  final VoidCallback onAnyChange;

  const _Body({
    required this.partner,
    required this.dict,
    required this.animalCategory,
    required this.onCategoryChanged,
    required this.weightController,
    required this.descController,
    required this.occasion,
    required this.onOccasion,
    required this.cuts,
    required this.onCutToggle,
    required this.imamRequested,
    required this.onImamToggle,
    required this.specialDuaController,
    required this.addressController,
    required this.phoneController,
    required this.noteController,
    required this.deliveryDate,
    required this.onPickDate,
    required this.isValid,
    required this.submitting,
    required this.onSubmit,
    required this.onAnyChange,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 32),
      children: [
        // Intro
        Text(t(dict, 'butcher.intro'),
            style: AppTypography.bodyMuted.copyWith(fontSize: 14)),
        const SizedBox(height: AppSpacing.xl),

        // 1. Animal
        _SectionHeader(text: t(dict, 'butcher.section.animal')),
        _AnimalSection(
          dict: dict,
          category: animalCategory,
          onCategoryChanged: onCategoryChanged,
          weightController: weightController,
          descController: descController,
          onAnyChange: onAnyChange,
        ),
        const SizedBox(height: AppSpacing.xl),

        // 2. Occasion
        _SectionHeader(text: t(dict, 'butcher.section.occasion')),
        _OccasionChips(
          dict: dict,
          selected: occasion,
          onPick: onOccasion,
        ),
        const SizedBox(height: AppSpacing.xl),

        // 3. Cuts
        _SectionHeader(text: t(dict, 'butcher.section.cuts')),
        _CutsSelector(
          dict: dict,
          selected: cuts,
          onToggle: onCutToggle,
        ),
        const SizedBox(height: AppSpacing.xl),

        // 4. Halal
        _SectionHeader(text: t(dict, 'butcher.section.halal')),
        _HalalSection(
          dict: dict,
          partner: partner,
          imamRequested: imamRequested,
          onImamToggle: onImamToggle,
          specialDuaController: specialDuaController,
          onAnyChange: onAnyChange,
        ),
        const SizedBox(height: AppSpacing.xl),

        // 5. Delivery
        _SectionHeader(text: t(dict, 'butcher.section.delivery')),
        _DeliverySection(
          dict: dict,
          addressController: addressController,
          phoneController: phoneController,
          noteController: noteController,
          deliveryDate: deliveryDate,
          onPickDate: onPickDate,
          onAnyChange: onAnyChange,
        ),
        const SizedBox(height: AppSpacing.xl),

        // 6. Review
        _SectionHeader(text: t(dict, 'butcher.section.review')),
        _Receipt(
          dict: dict,
          partner: partner,
          animalCategory: animalCategory,
          animalWeightKg:
              double.tryParse(weightController.text.replaceAll(',', '.')) ?? 0,
          imamRequested: imamRequested,
        ),
        const SizedBox(height: AppSpacing.lg),

        _SubmitButton(
          dict: dict,
          enabled: isValid,
          submitting: submitting,
          onTap: onSubmit,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(t(dict, 'butcher.receipt.payNote'),
            style: AppTypography.caption,
            textAlign: TextAlign.center),
      ],
    );
  }
}

// ─── Section header ──────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader({required this.text});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Text(text, style: AppTypography.h2),
      );
}

// ─── 1. Animal ───────────────────────────────────────────────

class _AnimalSection extends StatelessWidget {
  final Map<String, dynamic>? dict;
  final String category;
  final ValueChanged<String> onCategoryChanged;
  final TextEditingController weightController;
  final TextEditingController descController;
  final VoidCallback onAnyChange;

  const _AnimalSection({
    required this.dict,
    required this.category,
    required this.onCategoryChanged,
    required this.weightController,
    required this.descController,
    required this.onAnyChange,
  });

  static const _categories = ['CATTLE', 'SHEEP', 'HORSE', 'ARASHAN'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((c) {
            final selected = c == category;
            return _Chip(
              label: t(dict, 'categories.${c.toLowerCase()}'),
              selected: selected,
              onTap: () => onCategoryChanged(c),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        _Field(
          controller: weightController,
          label: t(dict, 'butcher.animal.weightLabel'),
          hint: t(dict, 'butcher.animal.weightHint'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => onAnyChange(),
        ),
        const SizedBox(height: AppSpacing.md),
        _Field(
          controller: descController,
          label: t(dict, 'butcher.animal.descriptionLabel'),
          hint: t(dict, 'butcher.animal.descriptionHint'),
          maxLines: 2,
          onChanged: (_) => onAnyChange(),
        ),
      ],
    );
  }
}

// ─── 2. Occasion chips ───────────────────────────────────────

class _OccasionChips extends StatelessWidget {
  final Map<String, dynamic>? dict;
  final Occasion? selected;
  final ValueChanged<Occasion> onPick;
  const _OccasionChips({
    required this.dict,
    required this.selected,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Occasion.values.map((o) {
        return _Chip(
          label: t(dict, 'butcher.occasion.${o.i18nKey}'),
          selected: o == selected,
          onTap: () => onPick(o),
        );
      }).toList(),
    );
  }
}

// ─── 3. Cuts selector ────────────────────────────────────────

class _CutsSelector extends StatelessWidget {
  final Map<String, dynamic>? dict;
  final Set<Cut> selected;
  final ValueChanged<Cut> onToggle;
  const _CutsSelector({
    required this.dict,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: Cut.values.map((c) {
        final isSelected = selected.contains(c);
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: InkWell(
            borderRadius: AppRadius.mdAll,
            onTap: () => onToggle(c),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: AppRadius.mdAll,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? LucideIcons.checkSquare
                        : LucideIcons.square,
                    size: 18,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t(dict, 'butcher.cut.${c.i18nKey}'),
                      style: AppTypography.body.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── 4. Halal section ────────────────────────────────────────

class _HalalSection extends StatelessWidget {
  final Map<String, dynamic>? dict;
  final ButcherPartner partner;
  final bool imamRequested;
  final ValueChanged<bool> onImamToggle;
  final TextEditingController specialDuaController;
  final VoidCallback onAnyChange;

  const _HalalSection({
    required this.dict,
    required this.partner,
    required this.imamRequested,
    required this.onImamToggle,
    required this.specialDuaController,
    required this.onAnyChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trust line — non-negotiable, just shown.
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.livestockAccentSurface,
            borderRadius: AppRadius.mdAll,
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.compass,
                  size: 18, color: AppColors.livestockAccentDark),
              const SizedBox(width: 10),
              Expanded(
                child: Text(t(dict, 'butcher.halal.trust'),
                    style: AppTypography.bodyMuted.copyWith(
                      color: AppColors.livestockAccentDark,
                    )),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Imam toggle
        InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: () => onImamToggle(!imamRequested),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t(dict, 'butcher.halal.imamToggle'),
                          style: AppTypography.title),
                      const SizedBox(height: 2),
                      Text(t(dict, 'butcher.halal.imamHelp'),
                          style: AppTypography.caption),
                      const SizedBox(height: 2),
                      Text(
                        t(dict, 'butcher.partner.imamFeeNote', {
                          'fee': '${partner.imamFeeKgs}',
                        }),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: imamRequested,
                  onChanged: onImamToggle,
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _Field(
          controller: specialDuaController,
          label: t(dict, 'butcher.halal.specialDuaLabel'),
          hint: t(dict, 'butcher.halal.specialDuaHint'),
          maxLines: 2,
          onChanged: (_) => onAnyChange(),
        ),
      ],
    );
  }
}

// ─── 5. Delivery section ─────────────────────────────────────

class _DeliverySection extends StatelessWidget {
  final Map<String, dynamic>? dict;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController noteController;
  final DateTime deliveryDate;
  final VoidCallback onPickDate;
  final VoidCallback onAnyChange;

  const _DeliverySection({
    required this.dict,
    required this.addressController,
    required this.phoneController,
    required this.noteController,
    required this.deliveryDate,
    required this.onPickDate,
    required this.onAnyChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Field(
          controller: addressController,
          label: t(dict, 'butcher.delivery.addressLabel'),
          hint: t(dict, 'butcher.delivery.addressHint'),
          onChanged: (_) => onAnyChange(),
        ),
        const SizedBox(height: AppSpacing.md),
        InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onPickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.calendar,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t(dict, 'butcher.delivery.dateLabel'),
                          style: AppTypography.caption),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(deliveryDate, dict),
                        style: AppTypography.title,
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight,
                    size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _Field(
          controller: phoneController,
          label: t(dict, 'butcher.delivery.phoneLabel'),
          hint: '+996 ___ ______',
          keyboardType: TextInputType.phone,
          onChanged: (_) => onAnyChange(),
        ),
        const SizedBox(height: AppSpacing.md),
        _Field(
          controller: noteController,
          label: t(dict, 'butcher.delivery.noteLabel'),
          hint: t(dict, 'butcher.delivery.noteHint'),
          maxLines: 2,
          onChanged: (_) => onAnyChange(),
        ),
      ],
    );
  }
}

String _formatDate(DateTime d, Map<String, dynamic>? dict) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dayOnly = DateTime(d.year, d.month, d.day);
  String dayLabel;
  if (dayOnly == today) {
    dayLabel = t(dict, 'butcher.delivery.dateToday');
  } else if (dayOnly == today.add(const Duration(days: 1))) {
    dayLabel = t(dict, 'butcher.delivery.dateTomorrow');
  } else {
    dayLabel = '${d.day}.${d.month.toString().padLeft(2, '0')}';
  }
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$dayLabel · $hh:$mm';
}

// ─── 6. Receipt ──────────────────────────────────────────────

class _Receipt extends StatelessWidget {
  final Map<String, dynamic>? dict;
  final ButcherPartner partner;
  final String animalCategory;
  final double animalWeightKg;
  final bool imamRequested;

  const _Receipt({
    required this.dict,
    required this.partner,
    required this.animalCategory,
    required this.animalWeightKg,
    required this.imamRequested,
  });

  @override
  Widget build(BuildContext context) {
    final perKg = partner.pricePerKgFor(animalCategory);
    final butchering = (animalWeightKg * perKg).round();
    final imam = imamRequested ? partner.imamFeeKgs : 0;
    final delivery = partner.deliveryFeeKgs;
    final total = butchering + imam + delivery;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _Line(
            label: t(dict, 'butcher.receipt.butchering', {
              'weight': animalWeightKg > 0 ? animalWeightKg.toStringAsFixed(0) : '—',
              'perKg': '$perKg',
            }),
            value: animalWeightKg > 0 ? '$butchering с' : '— с',
          ),
          if (imamRequested) ...[
            const SizedBox(height: 6),
            _Line(
              label: t(dict, 'butcher.receipt.imamFee'),
              value: '$imam с',
            ),
          ],
          const SizedBox(height: 6),
          _Line(
            label: t(dict, 'butcher.receipt.delivery'),
            value: '$delivery с',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _Line(
            label: t(dict, 'butcher.receipt.total'),
            value: animalWeightKg > 0 ? '$total с' : '— с',
            emphasized: true,
          ),
          const SizedBox(height: 8),
          Text(t(dict, 'butcher.receipt.estimate'),
              style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;
  const _Line({
    required this.label,
    required this.value,
    this.emphasized = false,
  });
  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? AppTypography.title.copyWith(fontSize: 16, fontWeight: FontWeight.w700)
        : AppTypography.body;
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

// ─── Submit button ───────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final Map<String, dynamic>? dict;
  final bool enabled;
  final bool submitting;
  final VoidCallback onTap;
  const _SubmitButton({
    required this.dict,
    required this.enabled,
    required this.submitting,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final label = submitting
        ? t(dict, 'butcher.cta.creating')
        : t(dict, 'butcher.cta.submit');
    return GestureDetector(
      onTap: enabled && !submitting ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.borderStrong,
          borderRadius: AppRadius.pillAll,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

// ─── Generic primitives ──────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body
                .copyWith(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: AppRadius.mdAll,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdAll,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdAll,
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
