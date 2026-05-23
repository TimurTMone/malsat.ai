import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/state/world_provider.dart';
import '../../../../core/theme/app_world.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../drops/presentation/providers/drops_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../providers/sell_provider.dart';

/// Sell tab — the 30-second listing flow. World-aware: a meat drop in the
/// Meat world, a live animal in the Livestock world. Photo-first, one
/// decision per step, big targets — built for a herder in a field.
class SellScreen extends ConsumerWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authed = ref.watch(isAuthenticatedProvider);
    final world = ref.watch(worldProvider);
    if (!authed) return const _AuthGate();
    return _SellFlow(world: world, key: ValueKey(world));
  }
}

/// Sign-in gate — shown only when the user reaches Sell unauthenticated.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    final accent = AppWorldPalette.of(context).accent;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppWorldPalette.of(context).accentSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.store, size: 34, color: accent),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(t(dict, 'quickSell.authTitle'),
                  textAlign: TextAlign.center, style: AppTypography.h1),
              const SizedBox(height: AppSpacing.xs),
              Text(t(dict, 'quickSell.authSub'),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMuted),
              const SizedBox(height: AppSpacing.xl),
              _PrimaryButton(
                label: t(dict, 'common.login'),
                accent: accent,
                onTap: () => context.push('/auth/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────

class _SellFlow extends ConsumerStatefulWidget {
  final AppWorld world;
  const _SellFlow({super.key, required this.world});

  @override
  ConsumerState<_SellFlow> createState() => _SellFlowState();
}

class _SellFlowState extends ConsumerState<_SellFlow> {
  static const _steps = 5;

  int _step = 0;
  final List<XFile> _photos = [];
  String? _category;
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _weight = TextEditingController();
  final _village = TextEditingController();
  DateTime _butcherDate = DateTime.now().add(const Duration(days: 3));
  bool _submitting = false;
  bool _done = false;
  String? _error;

  bool get _isMeat => widget.world == AppWorld.meat;

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _weight.dispose();
    _village.dispose();
    super.dispose();
  }

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _photos.isNotEmpty;
      case 1:
        return _category != null;
      case 2:
        final base =
            _title.text.trim().isNotEmpty && _price.text.trim().isNotEmpty;
        return _isMeat ? base && _weight.text.trim().isNotEmpty : base;
      case 3:
        return _village.text.trim().isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker()
        .pickImage(source: source, imageQuality: 80, maxWidth: 1200);
    if (picked != null) setState(() => _photos.add(picked));
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_step < _steps - 1) {
      setState(() => _step++);
    } else {
      _publish();
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _publish() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      if (_isMeat) {
        final api = ref.read(dropsApiProvider);
        for (final p in _photos) {
          await api.uploadPhoto(File(p.path), filename: p.name);
        }
        await api.createDrop(
          title: _title.text.trim(),
          category: _category!,
          totalWeightKg: double.parse(_weight.text.trim()),
          pricePerKg: int.parse(_price.text.trim()),
          butcherDate: _butcherDate,
          pickupAddress: _village.text.trim(),
          village: _village.text.trim(),
        );
        ref.invalidate(dropsListProvider);
      } else {
        final api = ref.read(sellApiProvider);
        final res = await api.createListing(
          category: _category!,
          title: _title.text.trim(),
          priceKgs: int.parse(_price.text.trim()),
          weightKg: double.tryParse(_weight.text.trim()),
          village: _village.text.trim(),
        );
        final listingId = res['id'] as String;
        for (var i = 0; i < _photos.length; i++) {
          await api.uploadMedia(
            filePath: _photos[i].path,
            fileName: _photos[i].name,
            listingId: listingId,
            isPrimary: i == 0,
          );
        }
        ref.invalidate(latestListingsProvider);
      }
      if (mounted) setState(() => _done = true);
    } catch (_) {
      final dict = ref.read(dictionaryProvider).valueOrNull;
      if (mounted) setState(() => _error = t(dict, 'quickSell.errGeneric'));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _reset() {
    setState(() {
      _step = 0;
      _photos.clear();
      _category = null;
      _title.clear();
      _price.clear();
      _weight.clear();
      _village.clear();
      _done = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    final accent = AppWorldPalette.of(context).accent;

    if (_done) return _SuccessView(accent: accent, onAnother: _reset);

    return SafeArea(
      child: Column(
        children: [
          _ProgressBar(step: _step, total: _steps, accent: accent),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: SingleChildScrollView(
                key: ValueKey(_step),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _stepContent(dict, accent),
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              child: Text(_error!,
                  style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          _BottomBar(
            showBack: _step > 0,
            canContinue: _canContinue && !_submitting,
            submitting: _submitting,
            isLast: _step == _steps - 1,
            accent: accent,
            nextLabel: _step == _steps - 1
                ? t(dict, 'quickSell.publish')
                : t(dict, 'common.next'),
            publishingLabel: t(dict, 'quickSell.publishing'),
            backLabel: t(dict, 'common.back'),
            onBack: _back,
            onNext: _next,
          ),
        ],
      ),
    );
  }

  Widget _stepContent(Map<String, dynamic>? dict, Color accent) {
    switch (_step) {
      case 0:
        return _stepHeader(
          t(dict, 'quickSell.stepPhoto'),
          t(dict, 'quickSell.stepPhotoSub'),
          _PhotoStep(
            photos: _photos,
            accent: accent,
            addLabel: t(dict, 'quickSell.addPhoto'),
            onAdd: _pickPhoto,
            onRemove: (i) => setState(() => _photos.removeAt(i)),
          ),
        );
      case 1:
        return _stepHeader(
          t(dict, 'quickSell.stepCategory'),
          null,
          _CategoryStep(
            isMeat: _isMeat,
            selected: _category,
            accent: accent,
            dict: dict,
            onPick: (c) => setState(() {
              _category = c;
              _step = 2;
            }),
          ),
        );
      case 2:
        return _stepHeader(
          t(
              dict,
              _isMeat
                  ? 'quickSell.stepDetailsMeat'
                  : 'quickSell.stepDetailsLivestock'),
          null,
          Column(
            children: [
              _Field(
                controller: _title,
                label: t(dict, 'quickSell.titleField'),
                icon: LucideIcons.tag,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _weight,
                label: t(
                    dict,
                    _isMeat
                        ? 'quickSell.totalWeight'
                        : 'quickSell.weightField'),
                icon: LucideIcons.scale,
                number: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                controller: _price,
                label: t(
                    dict,
                    _isMeat
                        ? 'quickSell.pricePerKg'
                        : 'quickSell.priceField'),
                icon: LucideIcons.banknote,
                number: true,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        );
      case 3:
        return _stepHeader(
          t(dict, 'quickSell.stepLocation'),
          null,
          Column(
            children: [
              _Field(
                controller: _village,
                label: t(dict, 'quickSell.villageField'),
                icon: LucideIcons.mapPin,
                onChanged: (_) => setState(() {}),
              ),
              if (_isMeat) ...[
                const SizedBox(height: AppSpacing.md),
                _DateField(
                  label: t(dict, 'quickSell.butcherDate'),
                  date: _butcherDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _butcherDate,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 60)),
                    );
                    if (picked != null) {
                      setState(() => _butcherDate = picked);
                    }
                  },
                ),
              ],
            ],
          ),
        );
      default:
        return _stepHeader(
          t(dict, 'quickSell.stepReview'),
          null,
          _ReviewCard(
            photo: _photos.isNotEmpty ? File(_photos.first.path) : null,
            category: t(dict, 'categories.${_category?.toLowerCase()}'),
            title: _title.text.trim(),
            price: _price.text.trim(),
            priceUnit: t(dict, _isMeat ? 'common.somPerKg' : 'common.som'),
            weight: _weight.text.trim(),
            village: _village.text.trim(),
          ),
        );
    }
  }

  Widget _stepHeader(String title, String? sub, Widget body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h1),
        if (sub != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(sub, style: AppTypography.bodyMuted),
        ],
        const SizedBox(height: AppSpacing.xl),
        body,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────── components

class _ProgressBar extends StatelessWidget {
  final int step;
  final int total;
  final Color accent;

  const _ProgressBar(
      {required this.step, required this.total, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                height: 5,
                decoration: BoxDecoration(
                  color: i <= step ? accent : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhotoStep extends StatelessWidget {
  final List<XFile> photos;
  final Color accent;
  final String addLabel;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _PhotoStep({
    required this.photos,
    required this.accent,
    required this.addLabel,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onAdd,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppWorldPalette.of(context).accentSurface,
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                  color: accent.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.camera, size: 40, color: accent),
                const SizedBox(height: AppSpacing.sm),
                Text(addLabel,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: accent)),
              ],
            ),
          ),
        ),
        if (photos.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < photos.length; i++)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.mdAll,
                      child: Image.file(File(photos[i].path),
                          width: 84, height: 84, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => onRemove(i),
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle),
                          padding: const EdgeInsets.all(3),
                          child: const Icon(LucideIcons.x,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CategoryStep extends StatelessWidget {
  final bool isMeat;
  final String? selected;
  final Color accent;
  final Map<String, dynamic>? dict;
  final ValueChanged<String> onPick;

  const _CategoryStep({
    required this.isMeat,
    required this.selected,
    required this.accent,
    required this.dict,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final cats = <List<dynamic>>[
      ['CATTLE', LucideIcons.beef, 'categories.cattle'],
      ['SHEEP', LucideIcons.cloud, 'categories.sheep'],
      ['HORSE', LucideIcons.wind, 'categories.horse'],
      if (!isMeat) ['ARASHAN', LucideIcons.star, 'categories.arashan'],
    ];
    return Column(
      children: [
        for (final c in cats)
          PressableScale(
            onTap: () => onPick(c[0] as String),
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.lgAll,
                border: Border.all(
                  color: selected == c[0] ? accent : AppColors.border,
                  width: selected == c[0] ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(c[1] as IconData, size: 24, color: accent),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(t(dict, c[2] as String),
                        style: AppTypography.title.copyWith(fontSize: 16)),
                  ),
                  const Icon(LucideIcons.chevronRight,
                      size: 20, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool number;
  final ValueChanged<String> onChanged;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.number = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 19),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: AppRadius.mdAll,
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.calendar,
                size: 19, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Text('$label:  ', style: AppTypography.bodyMuted),
            Text('${date.day}.${date.month}.${date.year}',
                style: AppTypography.body
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final File? photo;
  final String category;
  final String title;
  final String price;
  final String priceUnit;
  final String weight;
  final String village;

  const _ReviewCard({
    required this.photo,
    required this.category,
    required this.title,
    required this.price,
    required this.priceUnit,
    required this.weight,
    required this.village,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppWorldPalette.of(context).accent;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photo != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg)),
              child: Image.file(photo!,
                  height: 168, width: double.infinity, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.toUpperCase(),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: accent)),
                const SizedBox(height: AppSpacing.xs),
                Text(title, style: AppTypography.h2),
                const SizedBox(height: AppSpacing.sm),
                Text('$price $priceUnit',
                    style:
                        AppTypography.priceLarge.copyWith(color: accent)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(LucideIcons.scale,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('$weight kg', style: AppTypography.bodyMuted),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(LucideIcons.mapPin,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(village,
                          style: AppTypography.bodyMuted,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool showBack;
  final bool canContinue;
  final bool submitting;
  final bool isLast;
  final Color accent;
  final String nextLabel;
  final String publishingLabel;
  final String backLabel;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomBar({
    required this.showBack,
    required this.canContinue,
    required this.submitting,
    required this.isLast,
    required this.accent,
    required this.nextLabel,
    required this.publishingLabel,
    required this.backLabel,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border:
            Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          if (showBack) ...[
            GestureDetector(
              onTap: onBack,
              child: Container(
                height: 52,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(backLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: _PrimaryButton(
              label: submitting ? publishingLabel : nextLabel,
              accent: accent,
              enabled: canContinue,
              loading: submitting,
              icon: isLast && !submitting ? LucideIcons.check : null,
              onTap: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final Color accent;
  final bool enabled;
  final bool loading;
  final IconData? icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.accent,
    required this.onTap,
    this.enabled = true,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled && !loading ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.4,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: AppRadius.pillAll,
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              else ...[
                if (icon != null) ...[
                  Icon(icon, size: 19, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(label,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends ConsumerWidget {
  final Color accent;
  final VoidCallback onAnother;

  const _SuccessView({required this.accent, required this.onAnother});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dict = ref.watch(dictionaryProvider).valueOrNull;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration:
                    BoxDecoration(color: accent, shape: BoxShape.circle),
                child: const Icon(LucideIcons.check,
                    size: 44, color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(t(dict, 'quickSell.doneTitle'),
                  style: AppTypography.h1, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xs),
              Text(t(dict, 'quickSell.doneSub'),
                  style: AppTypography.bodyMuted,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xl),
              _PrimaryButton(
                label: t(dict, 'quickSell.doneAnother'),
                accent: accent,
                onTap: onAnother,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  final world = ref.read(worldProvider);
                  context.go(world == AppWorld.meat ? '/meat' : '/livestock');
                },
                child: Text(t(dict, 'common.done')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
