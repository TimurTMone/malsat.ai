import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/drops_provider.dart';
import '../../domain/drop_model.dart';

class DropDetailScreen extends ConsumerStatefulWidget {
  final String dropId;
  const DropDetailScreen({super.key, required this.dropId});

  @override
  ConsumerState<DropDetailScreen> createState() => _DropDetailScreenState();
}

class _DropDetailScreenState extends ConsumerState<DropDetailScreen> {
  double _selectedKg = 0;
  bool _customMode = false;
  final _noteController = TextEditingController();
  final _addressController = TextEditingController();
  bool _delivery = false; // false = pickup, true = delivery
  bool _ordering = false;

  @override
  void dispose() {
    _noteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropAsync = ref.watch(dropDetailProvider(widget.dropId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: dropAsync.when(
        data: (drop) => _buildContent(context, drop),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Маалымат жүктөлбөдү'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.refresh(dropDetailProvider(widget.dropId).future),
                child: const Text('Кайра аракет'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ButcherDrop drop) {
    final photo = drop.media.isNotEmpty ? drop.media.first.mediaUrl : null;
    final daysLeft = drop.daysUntilButcher;

    // Initialize selected kg to first preset if not set
    if (_selectedKg == 0 && drop.portionPresets.isNotEmpty && !_customMode) {
      _selectedKg = drop.portionPresets.first.toDouble();
    }

    final deliveryFee = _delivery ? drop.deliveryFee : 0;
    final totalPrice = (_selectedKg * drop.pricePerKg).round() + deliveryFee;
    final needsAddress = _delivery && _addressController.text.trim().isEmpty;
    final canOrder = drop.isOpen && _selectedKg >= drop.minOrderKg && _selectedKg <= drop.remainingWeightKg && !needsAddress;

    return CustomScrollView(
      slivers: [
        // Image header
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppColors.surface,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: photo != null
                ? CachedNetworkImage(
                    imageUrl: photo,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: AppColors.backgroundSecondary,
                    child: const Icon(LucideIcons.beef,
                        size: 60, color: AppColors.textMuted),
                  ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status + countdown row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statusColor(drop.status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _statusLabel(drop.status),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (daysLeft >= 0) ...[
                      const Icon(LucideIcons.clock,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        daysLeft == 0
                            ? 'Бүгүн союлат'
                            : daysLeft == 1
                                ? 'Эртең союлат'
                                : '$daysLeft күндөн кийин',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  drop.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Price per kg — prominently displayed
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${drop.pricePerKg}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'сом',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'за 1 кг',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Progress section
                _buildProgressSection(drop),
                const SizedBox(height: 24),

                // Description
                if (drop.description != null) ...[
                  const Text(
                    'Маалымат',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    drop.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Seller info
                _buildSellerRow(drop),
                const SizedBox(height: 20),

                // Pickup location
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.mapPin,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Алуу жери',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              drop.pickupAddress,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ═══ PORTION SELECTOR — THE MAIN EVENT ═══
                if (drop.isOpen) ...[
                  const Text(
                    'Канча кг заказ берасыз?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Мин. ${drop.minOrderKg.toStringAsFixed(0)} кг • Калды: ${drop.remainingWeightKg.toStringAsFixed(0)} кг',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Preset buttons
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ...drop.portionPresets.map((preset) {
                        final kg = preset.toDouble();
                        final isSelected = !_customMode && _selectedKg == kg;
                        final isDisabled = kg > drop.remainingWeightKg;
                        return GestureDetector(
                          onTap: isDisabled
                              ? null
                              : () => setState(() {
                                    _selectedKg = kg;
                                    _customMode = false;
                                  }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isDisabled
                                  ? AppColors.backgroundSecondary
                                  : isSelected
                                      ? AppColors.primary
                                      : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${preset}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: isDisabled
                                        ? AppColors.textMuted
                                        : isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'кг',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDisabled
                                        ? AppColors.textMuted
                                        : isSelected
                                            ? Colors.white70
                                            : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      // Custom button
                      GestureDetector(
                        onTap: () => setState(() {
                          _customMode = true;
                          _selectedKg = drop.minOrderKg;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _customMode
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _customMode
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: _customMode ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.slidersHorizontal,
                                size: 22,
                                color: _customMode
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Башка',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _customMode
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Custom slider
                  if (_customMode) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '${_selectedKg.toStringAsFixed(0)} кг',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(_selectedKg * drop.pricePerKg).round()} сом',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _selectedKg,
                      min: drop.minOrderKg,
                      max: drop.maxOrderKg != null
                          ? drop.maxOrderKg!.clamp(
                              drop.minOrderKg, drop.remainingWeightKg)
                          : drop.remainingWeightKg,
                      divisions: ((drop.maxOrderKg ?? drop.remainingWeightKg) -
                              drop.minOrderKg)
                          .round()
                          .clamp(1, 100),
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.border,
                      onChanged: (v) =>
                          setState(() => _selectedKg = v.roundToDouble()),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Note field
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Кошумча (мис: "сөөк менен", "майсыз")...',
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundSecondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ═══ DELIVERY METHOD — pickup vs delivery ═══
                  const Text(
                    'Кантип аласыз?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _delivery = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: !_delivery
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: !_delivery
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: !_delivery ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(LucideIcons.store,
                                    size: 24,
                                    color: !_delivery
                                        ? AppColors.primary
                                        : AppColors.textMuted),
                                const SizedBox(height: 6),
                                Text(
                                  'Өзүм алам',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: !_delivery
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Базардан',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: !_delivery
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: drop.deliveryAvailable
                              ? () => setState(() => _delivery = true)
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: !drop.deliveryAvailable
                                  ? AppColors.backgroundSecondary
                                  : _delivery
                                      ? AppColors.primary.withValues(alpha: 0.08)
                                      : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: !drop.deliveryAvailable
                                    ? AppColors.border
                                    : _delivery
                                        ? AppColors.primary
                                        : AppColors.border,
                                width: _delivery ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(LucideIcons.truck,
                                    size: 24,
                                    color: !drop.deliveryAvailable
                                        ? AppColors.textMuted
                                        : _delivery
                                            ? AppColors.primary
                                            : AppColors.textMuted),
                                const SizedBox(height: 6),
                                Text(
                                  'Жеткирүү',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: !drop.deliveryAvailable
                                        ? AppColors.textMuted
                                        : _delivery
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  drop.deliveryAvailable
                                      ? drop.deliveryFee > 0
                                          ? '+${drop.deliveryFee} сом'
                                          : 'Акысыз'
                                      : 'Жок',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: !drop.deliveryAvailable
                                        ? AppColors.textMuted
                                        : _delivery
                                            ? AppColors.primary
                                            : AppColors.textMuted,
                                    fontWeight: drop.deliveryAvailable &&
                                            drop.deliveryFee == 0
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Delivery address input
                  if (_delivery) ...[
                    const SizedBox(height: 14),
                    TextField(
                      controller: _addressController,
                      onChanged: (_) => setState(() {}),
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Жеткирүү дареги (мис: Бишкек, 7-кичи район, 21-үй, 45-кв)',
                        hintStyle: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(LucideIcons.mapPin,
                            size: 18, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.backgroundSecondary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    if (drop.deliveryRadius != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(LucideIcons.info,
                              size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            'Жеткирүү аймагы: ${drop.deliveryRadius}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],

                  // Pickup address reminder
                  if (!_delivery) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.mapPin,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              drop.pickupAddress,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Order summary + button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Эт:',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${_selectedKg.toStringAsFixed(0)} кг × ${drop.pricePerKg} сом',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (deliveryFee > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Жеткирүү:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '+$deliveryFee сом',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_delivery && deliveryFee == 0) ...[
                          const SizedBox(height: 4),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Жеткирүү:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'Акысыз',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Жалпы:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '$totalPrice сом',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ORDER BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: canOrder && !_ordering
                                ? () => _placeOrder(drop)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _ordering
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Заказ берүү — ${_selectedKg.toStringAsFixed(0)} кг',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                // Sold out message
                if (drop.isSoldOut)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.alertCircle,
                            color: AppColors.accent, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Бардык эт алынып бүттү! Кийинки drop\'ту күтүңүз.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(ButcherDrop drop) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${drop.claimedWeightKg.toStringAsFixed(0)} кг алынды',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${drop.totalWeightKg.toStringAsFixed(0)} кг жалпы',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: LinearProgressIndicator(
                value: drop.progressPercent / 100,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(
                  drop.progressPercent >= 80
                      ? AppColors.accent
                      : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.users,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${drop.orderCount} заказ',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${drop.remainingWeightKg.toStringAsFixed(0)} кг калды',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: drop.remainingWeightKg <= 5
                      ? AppColors.accent
                      : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellerRow(ButcherDrop drop) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.backgroundSecondary,
          backgroundImage: drop.seller.avatarUrl != null
              ? CachedNetworkImageProvider(drop.seller.avatarUrl!)
              : null,
          child: drop.seller.avatarUrl == null
              ? const Icon(LucideIcons.user,
                  size: 18, color: AppColors.textMuted)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    drop.seller.name ?? 'Сатуучу',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (drop.seller.isVerifiedBreeder) ...[
                    const SizedBox(width: 4),
                    const Icon(LucideIcons.badgeCheck,
                        size: 16, color: AppColors.primary),
                  ],
                ],
              ),
              Row(
                children: [
                  const Icon(LucideIcons.star,
                      size: 12, color: AppColors.premiumGold),
                  const SizedBox(width: 3),
                  Text(
                    '${drop.seller.trustScore}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _placeOrder(ButcherDrop drop) async {
    setState(() => _ordering = true);
    try {
      final api = ref.read(dropsApiProvider);
      final order = await api.placeOrder(
        dropId: drop.id,
        weightKg: _selectedKg,
        deliveryMethod: _delivery ? 'delivery' : 'pickup',
        deliveryAddress: _delivery && _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        buyerNote: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      if (!mounted) return;

      // Refresh data
      ref.invalidate(dropDetailProvider(drop.id));
      ref.invalidate(dropsListProvider);
      ref.invalidate(myOrdersProvider);

      // Navigate to order detail → QR payment screen
      context.push('/order/${order.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ката: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _ordering = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'OPEN':
        return AppColors.success;
      case 'UPCOMING':
        return AppColors.boostBlue;
      case 'SOLD_OUT':
        return AppColors.accent;
      case 'FULFILLED':
        return AppColors.primaryDark;
      default:
        return AppColors.textMuted;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'OPEN':
        return 'АЧЫК';
      case 'UPCOMING':
        return 'ЖАКЫНДА';
      case 'SOLD_OUT':
        return 'БҮТТҮ';
      case 'FULFILLED':
        return 'БЕРИЛДИ';
      default:
        return status;
    }
  }
}
