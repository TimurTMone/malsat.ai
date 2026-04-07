import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/meat_order_model.dart';
import '../providers/drops_provider.dart';

class SellerOrdersScreen extends ConsumerWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Келген заказдар',
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
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () => ref.refresh(sellerOrdersProvider.future),
        child: ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.inbox,
                        size: 48, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text('Заказдар жок',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted)),
                    SizedBox(height: 4),
                    Text('Эт Drop жарыялаганда заказдар келет',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textMuted)),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) =>
                  _SellerOrderCard(order: orders[i], ref: ref),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Ката кетти'),
                TextButton(
                  onPressed: () =>
                      ref.refresh(sellerOrdersProvider.future),
                  child: const Text('Кайра аракет'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SellerOrderCard extends StatefulWidget {
  final MeatOrder order;
  final WidgetRef ref;
  const _SellerOrderCard({required this.order, required this.ref});

  @override
  State<_SellerOrderCard> createState() => _SellerOrderCardState();
}

class _SellerOrderCardState extends State<_SellerOrderCard> {
  bool _updating = false;

  MeatOrder get order => widget.order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _needsAction ? AppColors.accent : AppColors.border,
          width: _needsAction ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buyer + status
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.backgroundSecondary,
                child: Text(
                  (order.buyer?.name ?? '?')[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.buyer?.name ?? 'Сатып алуучу',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (order.buyer?.phone != null)
                      Text(
                        order.buyer!.phone!,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Order details
          Row(
            children: [
              _chip(LucideIcons.scale,
                  '${order.weightKg.toStringAsFixed(0)} кг'),
              const SizedBox(width: 8),
              _chip(LucideIcons.banknote, '${order.totalPriceKgs} сом'),
              if (order.isDelivery) ...[
                const SizedBox(width: 8),
                _chip(LucideIcons.truck, 'Жеткирүү'),
              ],
            ],
          ),

          // Delivery address
          if (order.deliveryAddress != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.mapPin,
                    size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.deliveryAddress!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // Buyer note
          if (order.buyerNote != null && order.buyerNote!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(LucideIcons.messageSquare,
                    size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '"${order.buyerNote}"',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Receipt image (for PAID orders)
          if (order.isPaid && order.receiptUrl != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.receipt,
                      size: 16, color: Color(0xFF92400E)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Чек жүктөлдү — текшериңиз',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action button — the next step for the seller
          if (_nextAction != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed:
                    _updating ? null : () => _advanceStatus(_nextAction!),
                icon: _updating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(_nextActionIcon, size: 18),
                label: Text(
                  _nextActionLabel,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _nextActionColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  bool get _needsAction =>
      order.isPaid || order.isConfirmed || order.isButchering ||
      order.isPackaging || order.isDelivering;

  String? get _nextAction {
    switch (order.status) {
      case 'PAID':
        return 'CONFIRMED';
      case 'CONFIRMED':
        return 'BUTCHERING';
      case 'BUTCHERING':
        return 'PACKAGING';
      case 'PACKAGING':
        return 'DELIVERING';
      case 'DELIVERING':
        return 'DELIVERED';
      default:
        return null;
    }
  }

  bool get _requiresPhoto =>
      order.status == 'CONFIRMED' ||
      order.status == 'BUTCHERING' ||
      order.status == 'PACKAGING';

  String get _nextActionLabel {
    switch (order.status) {
      case 'PAID':
        return 'Төлөмдү ырастоо';
      case 'CONFIRMED':
        return 'Союуну баштоо + сүрөт';
      case 'BUTCHERING':
        return 'Таңгактоо + сүрөт';
      case 'PACKAGING':
        return 'Жеткирүү + сүрөт';
      case 'DELIVERING':
        return 'Жеткирилди деп белгилөө';
      default:
        return '';
    }
  }

  IconData get _nextActionIcon {
    switch (order.status) {
      case 'PAID':
        return LucideIcons.checkCircle;
      case 'CONFIRMED':
        return LucideIcons.axe;
      case 'BUTCHERING':
        return LucideIcons.package;
      case 'PACKAGING':
        return LucideIcons.truck;
      case 'DELIVERING':
        return LucideIcons.partyPopper;
      default:
        return LucideIcons.check;
    }
  }

  Color get _nextActionColor {
    switch (order.status) {
      case 'PAID':
        return AppColors.boostBlue;
      case 'CONFIRMED':
        return const Color(0xFFB91C1C);
      case 'BUTCHERING':
        return const Color(0xFF7C3AED);
      case 'PACKAGING':
        return AppColors.primary;
      case 'DELIVERING':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  Color get _statusColor {
    switch (order.status) {
      case 'PENDING':
        return AppColors.textMuted;
      case 'PAID':
        return const Color(0xFF92400E);
      case 'CONFIRMED':
        return AppColors.boostBlue;
      case 'BUTCHERING':
        return const Color(0xFFB91C1C);
      case 'PACKAGING':
        return const Color(0xFF7C3AED);
      case 'DELIVERING':
        return AppColors.primary;
      case 'DELIVERED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case 'PENDING':
        return 'ТӨЛӨМ КҮТҮҮДӨ';
      case 'PAID':
        return 'ЧЕК КЕЛДИ';
      case 'CONFIRMED':
        return 'ЫРАСТАЛДЫ';
      case 'BUTCHERING':
        return 'СОЮЛУУДА';
      case 'PACKAGING':
        return 'ТАҢГАКТАЛУУДА';
      case 'DELIVERING':
        return 'ЖОЛДО';
      case 'DELIVERED':
        return 'ЖЕТКИРИЛДИ';
      case 'CANCELLED':
        return 'ЖОККО ЧЫГДЫ';
      default:
        return order.status;
    }
  }

  Future<void> _advanceStatus(String newStatus) async {
    String? photoUrl;

    // For butchering/packaging/delivering — require a photo
    if (_requiresPhoto) {
      final picker = ImagePicker();
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _photoPrompt,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(LucideIcons.camera, color: AppColors.primary),
                title: const Text('Камера менен тартуу'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(LucideIcons.image, color: AppColors.primary),
                title: const Text('Галереядан тандоо'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
      if (source == null) return; // cancelled

      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return; // cancelled

      setState(() => _updating = true);
      try {
        final api = widget.ref.read(dropsApiProvider);
        photoUrl = await api.uploadPhoto(File(picked.path), filename: 'stage_$newStatus.jpg');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Сүрөт жүктөлбөдү: $e'), backgroundColor: AppColors.error),
        );
        setState(() => _updating = false);
        return;
      }
    } else {
      setState(() => _updating = true);
    }

    try {
      final api = widget.ref.read(dropsApiProvider);
      await api.updateOrderStatus(order.id, newStatus, stagePhotoUrl: photoUrl);
      widget.ref.invalidate(sellerOrdersProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ката: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  String get _photoPrompt {
    switch (order.status) {
      case 'CONFIRMED':
        return 'Союу процессин сүрөткө тартыңыз';
      case 'BUTCHERING':
        return 'Таңгакталган этти сүрөткө тартыңыз';
      case 'PACKAGING':
        return 'Жеткирүү сүрөтүн тартыңыз';
      default:
        return 'Сүрөт тартыңыз';
    }
  }
}
