import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/meat_order_model.dart';
import '../providers/drops_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Заказ',
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
      body: orderAsync.when(
        data: (order) => _buildContent(order),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Маалымат жүктөлбөдү'),
              TextButton(
                onPressed: () =>
                    ref.refresh(orderDetailProvider(widget.orderId).future),
                child: const Text('Кайра аракет'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(MeatOrder order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order summary card
          _buildOrderSummary(order),
          const SizedBox(height: 20),

          // ═══ DELIVERY TRACKING TIMELINE ═══
          _DeliveryTimeline(order: order),
          const SizedBox(height: 24),

          // ═══ PAYMENT SECTION — QR code + receipt upload ═══
          if (order.awaitingPayment) ...[
            _buildPaymentSection(order),
            const SizedBox(height: 24),
          ],

          // Receipt uploaded confirmation
          if (order.receiptUrl != null && !order.awaitingPayment) ...[
            _buildReceiptSection(order),
            const SizedBox(height: 24),
          ],

          // Seller info
          if (order.drop?.seller != null) ...[
            _buildSellerInfo(order),
            const SizedBox(height: 24),
          ],

          // Delivery / pickup info
          _buildLocationInfo(order),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(MeatOrder order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.drop?.title ?? 'Заказ',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryChip(
                icon: LucideIcons.scale,
                label: '${order.weightKg.toStringAsFixed(0)} кг',
              ),
              const SizedBox(width: 10),
              _SummaryChip(
                icon: LucideIcons.banknote,
                label: '${order.totalPriceKgs} сом',
                isPrimary: true,
              ),
              const SizedBox(width: 10),
              _SummaryChip(
                icon: order.isDelivery
                    ? LucideIcons.truck
                    : LucideIcons.store,
                label: order.isDelivery ? 'Жеткирүү' : 'Өзүм алам',
              ),
            ],
          ),
          if (order.buyerNote != null && order.buyerNote!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(LucideIcons.messageSquare,
                    size: 13, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.buyerNote!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentSection(MeatOrder order) {
    final seller = order.drop?.seller;
    final qrUrl = seller?.paymentQrUrl;
    final paymentInfo = seller?.paymentInfo;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.qrCode, size: 22, color: Color(0xFF92400E)),
              SizedBox(width: 8),
              Text(
                'Төлөм жасаңыз',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${order.totalPriceKgs} сом — банк тиркемеңизден которуңуз',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(height: 16),

          // QR Code image
          if (qrUrl != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: qrUrl,
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const SizedBox(
                      width: 220,
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => const SizedBox(
                      width: 220,
                      height: 220,
                      child: Center(
                        child: Icon(LucideIcons.qrCode,
                            size: 80, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (qrUrl == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(LucideIcons.qrCode, size: 60, color: AppColors.textMuted),
                  SizedBox(height: 8),
                  Text(
                    'QR код жок — сатуучу менен байланышыңыз',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Payment info text
          if (paymentInfo != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.creditCard,
                      size: 16, color: Color(0xFF92400E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      paymentInfo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: paymentInfo));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Көчүрүлдү!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Icon(LucideIcons.copy,
                        size: 16, color: Color(0xFFB45309)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Seller phone
          if (seller?.phone != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.phone,
                      size: 16, color: Color(0xFF92400E)),
                  const SizedBox(width: 8),
                  Text(
                    seller!.phone!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: seller.phone!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Көчүрүлдү!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Icon(LucideIcons.copy,
                        size: 16, color: Color(0xFFB45309)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Upload receipt button
          const Text(
            'Төлөгөндөн кийин чекти жүктөңүз:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF92400E),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _uploading ? null : () => _pickAndUploadReceipt(order),
              icon: _uploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(LucideIcons.upload),
              label: Text(
                _uploading ? 'Жүктөлүүдө...' : 'Чек жүктөө (скриншот)',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF92400E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptSection(MeatOrder order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.checkCircle, size: 18, color: AppColors.success),
              SizedBox(width: 8),
              Text(
                'Чек жүктөлдү',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: order.receiptUrl!,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo(MeatOrder order) {
    final seller = order.drop!.seller!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.user, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Сатуучу',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  seller.name ?? 'Белгисиз',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (seller.phone != null)
            Text(
              seller.phone!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(MeatOrder order) {
    final isDelivery = order.isDelivery;

    return Column(
      children: [
        // Delivery address (if delivery)
        if (isDelivery && order.deliveryAddress != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.truck,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Жеткирүү дареги',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (order.deliveryFee > 0) ...[
                            const Spacer(),
                            Text(
                              '+${order.deliveryFee} сом',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (order.deliveryFee == 0) ...[
                            const Spacer(),
                            const Text(
                              'Акысыз',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.deliveryAddress!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Pickup address (if pickup or always as fallback)
        if (!isDelivery && order.drop?.pickupAddress != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.store,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
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
                      const SizedBox(height: 2),
                      Text(
                        order.drop!.pickupAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _pickAndUploadReceipt(MeatOrder order) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Камера'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Галерея'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final api = ref.read(dropsApiProvider);
      await api.uploadReceipt(order.id, File(picked.path));

      if (!mounted) return;

      ref.invalidate(orderDetailProvider(order.id));
      ref.invalidate(myOrdersProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Чек жүктөлдү! Сатуучу текшерет.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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
      if (mounted) setState(() => _uploading = false);
    }
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;

  const _SummaryChip({
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 15,
              color: isPrimary ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isPrimary ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full delivery tracking timeline — the core tracking UX
class _DeliveryTimeline extends StatelessWidget {
  final MeatOrder order;
  const _DeliveryTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.isCancelled) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(LucideIcons.xCircle, size: 20, color: AppColors.error),
            SizedBox(width: 10),
            Text(
              'Заказ жокко чыгарылды',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      _Step('PENDING', 'Заказ берилди', LucideIcons.shoppingCart, 'Төлөм күтүлүүдө'),
      _Step('PAID', 'Чек жүктөлдү', LucideIcons.receipt, 'Сатуучу текшерүүдө'),
      _Step('CONFIRMED', 'Төлөм кабыл алынды', LucideIcons.checkCircle, 'Союуга даярдануу'),
      _Step('BUTCHERING', 'Союлууда', LucideIcons.axe, 'Мал союлууда...'),
      _Step('PACKAGING', 'Таңгакталууда', LucideIcons.package, 'Эт бөлүнүп жатат'),
      _Step('DELIVERING', 'Жеткирилүүдө', LucideIcons.truck, 'Жолдо...'),
      _Step('DELIVERED', 'Жеткирилди!', LucideIcons.partyPopper, 'Тамак болсун!'),
    ];

    final currentIdx = steps.indexWhere((s) => s.status == order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Заказ абалы',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isComplete = i <= currentIdx;
            final isCurrent = i == currentIdx;
            final isLast = i == steps.length - 1;

            // Get stage photo if available
            String? stagePhoto;
            if (step.status == 'BUTCHERING') stagePhoto = order.butcheringPhotoUrl;
            if (step.status == 'PACKAGING') stagePhoto = order.packagingPhotoUrl;
            if (step.status == 'DELIVERING') stagePhoto = order.deliveringPhotoUrl;
            if (step.status == 'PAID') stagePhoto = order.receiptUrl;

            final lineHeight = (isComplete && stagePhoto != null) ? 90.0 : 28.0;

            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Circle + line
                    Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.primary
                                : isComplete
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : AppColors.backgroundSecondary,
                            shape: BoxShape.circle,
                            border: isCurrent
                                ? Border.all(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.3),
                                    width: 3)
                                : null,
                          ),
                          child: Icon(
                            step.icon,
                            size: 16,
                            color: isCurrent
                                ? Colors.white
                                : isComplete
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: lineHeight,
                            color: isComplete && i < currentIdx
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // Text + photo
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isCurrent
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isComplete
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                            ),
                            if (isCurrent)
                              Text(
                                step.subtitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            // Stage photo from seller
                            if (isComplete && stagePhoto != null) ...[
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: stagePhoto,
                                  height: 70,
                                  width: 120,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    height: 70, width: 120,
                                    color: AppColors.backgroundSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // Check mark
                    if (isComplete && !isCurrent)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Icon(Icons.check_circle,
                            size: 18, color: AppColors.primary),
                      ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _Step {
  final String status;
  final String label;
  final IconData icon;
  final String subtitle;
  _Step(this.status, this.label, this.icon, this.subtitle);
}
