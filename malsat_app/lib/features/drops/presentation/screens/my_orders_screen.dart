import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/meat_order_model.dart';
import '../providers/drops_provider.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Менин заказдарым',
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
        onRefresh: () => ref.refresh(myOrdersProvider.future),
        child: ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.shoppingBag,
                        size: 48, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text(
                      'Заказдар жок',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Эт базардан заказ бериңиз',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _OrderCard(
                order: orders[index],
                onTap: () => context.push('/order/${orders[index].id}'),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Ката кетти'),
                TextButton(
                  onPressed: () => ref.refresh(myOrdersProvider.future),
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

class _OrderCard extends StatelessWidget {
  final MeatOrder order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.drop?.title ?? 'Заказ #${order.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabel(order.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Weight + price
            Row(
              children: [
                const Icon(LucideIcons.scale, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  '${order.weightKg.toStringAsFixed(0)} кг',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${order.totalPriceKgs} сом',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Icon(LucideIcons.chevronRight,
                    size: 18, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 10),

            // Mini status timeline
            _MiniTimeline(status: order.status),

            // Action hint for pending orders
            if (order.awaitingPayment) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.qrCode,
                        size: 14, color: Color(0xFF92400E)),
                    SizedBox(width: 6),
                    Text(
                      'Төлөм жасап, чек жүктөңүз →',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.premiumGold;
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

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'ТӨЛӨМ КҮТҮҮДӨ';
      case 'PAID':
        return 'ЧЕК ТЕКШЕРҮҮДӨ';
      case 'CONFIRMED':
        return 'КАБЫЛ АЛЫНДЫ';
      case 'BUTCHERING':
        return 'СОЮЛУУДА';
      case 'PACKAGING':
        return 'ТАҢГАКТАЛУУДА';
      case 'DELIVERING':
        return 'ЖЕТКИРИЛҮҮДӨ';
      case 'DELIVERED':
        return 'ЖЕТКИРИЛДИ';
      case 'CANCELLED':
        return 'ЖОККО ЧЫГДЫ';
      default:
        return status;
    }
  }
}

/// Compact horizontal timeline for the order card
class _MiniTimeline extends StatelessWidget {
  final String status;
  const _MiniTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == 'CANCELLED') {
      return Row(
        children: [
          const Icon(LucideIcons.xCircle, size: 14, color: AppColors.error),
          const SizedBox(width: 4),
          const Text(
            'Жокко чыгарылды',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final steps = [
      'PENDING',
      'PAID',
      'CONFIRMED',
      'BUTCHERING',
      'PACKAGING',
      'DELIVERING',
      'DELIVERED'
    ];
    final icons = [
      LucideIcons.shoppingCart,
      LucideIcons.receipt,
      LucideIcons.checkCircle,
      LucideIcons.axe,
      LucideIcons.package,
      LucideIcons.truck,
      LucideIcons.partyPopper,
    ];
    final currentIdx = steps.indexOf(status);

    return Row(
      children: List.generate(steps.length, (i) {
        final isComplete = i <= currentIdx;
        final isCurrent = i == currentIdx;
        final isLast = i == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.primary
                      : isComplete
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.backgroundSecondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icons[i],
                  size: 11,
                  color: isCurrent
                      ? Colors.white
                      : isComplete
                          ? AppColors.primary
                          : AppColors.textMuted,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isComplete && i < currentIdx
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
