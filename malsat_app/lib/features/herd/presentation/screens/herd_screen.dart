import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/owned_animal_model.dart';
import '../providers/herd_provider.dart';

class HerdScreen extends ConsumerWidget {
  const HerdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(herdPortfolioProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: portfolioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Ката: $err',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (portfolio) {
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(herdPortfolioProvider.future),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _PortfolioHeader(summary: portfolio.summary),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Менин малым',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${portfolio.animals.length} баш',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: portfolio.animals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _AnimalCard(animal: portfolio.animals[i]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PortfolioHeader extends StatelessWidget {
  final HerdSummary summary;
  const _PortfolioHeader({required this.summary});

  @override
  Widget build(BuildContext context) {
    final isProfit = summary.unrealizedProfitKgs >= 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PORTFOLIO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              Icon(LucideIcons.trendingUp, color: Colors.white.withValues(alpha: 0.8), size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_fmt(summary.currentValueKgs)} сом',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isProfit ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight,
                size: 14,
                color: Colors.white.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 4),
              Text(
                '${isProfit ? '+' : ''}${_fmt(summary.unrealizedProfitKgs)} сом (${isProfit ? '+' : ''}${summary.profitPercent}%)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                label: 'Мал',
                value: '${summary.totalAnimals}',
                icon: LucideIcons.layers,
              ),
              _StatChip(
                label: 'Салмак +',
                value: '${summary.totalWeightGainKg}кг',
                icon: LucideIcons.scale,
              ),
              _StatChip(
                label: 'Пайыз',
                value: '${summary.totalLoyaltyPoints}',
                icon: LucideIcons.gift,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatChip({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  final OwnedAnimal animal;
  const _AnimalCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    final isProfit = animal.profitKgs >= 0;
    return GestureDetector(
      onTap: () => context.push('/herd/${animal.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: animal.photo,
                width: 84,
                height: 84,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 84,
                  height: 84,
                  color: AppColors.backgroundSecondary,
                  child: Center(
                    child: Icon(
                      _categoryIcon(animal.category),
                      size: 32,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      _categoryIcon(animal.category),
                      size: 32,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        animal.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _statusColor(animal.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _statusLabel(animal.status),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: _statusColor(animal.status),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${animal.breed} • ${animal.ageMonths} ай • ${animal.weightKg}кг',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 11, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        animal.locationVillage,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(LucideIcons.heart, size: 11, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        '${animal.healthScore}/100',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${_fmt(animal.currentValueKgs)}с',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${isProfit ? '+' : ''}${_fmt(animal.profitKgs)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isProfit ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _categoryIcon(String category) {
  switch (category) {
    case 'HORSE':
      return LucideIcons.wind;
    case 'CATTLE':
      return LucideIcons.beef;
    case 'SHEEP':
      return LucideIcons.cloud;
    case 'ARASHAN':
      return LucideIcons.award;
    default:
      return LucideIcons.heart;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'WITH_CARETAKER':
      return 'МАЛЧЫДА';
    case 'AT_OWNER':
      return 'ӨЗҮҢДӨ';
    case 'READY_TO_SELL':
      return 'САТЫЛАТ';
    case 'SOLD':
      return 'САТЫЛДЫ';
    case 'BUTCHERED':
      return 'СОЮЛДУ';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'WITH_CARETAKER':
      return AppColors.primary;
    case 'AT_OWNER':
      return AppColors.boostBlue;
    case 'READY_TO_SELL':
      return AppColors.premiumGold;
    case 'SOLD':
      return AppColors.textMuted;
    case 'BUTCHERED':
      return AppColors.error;
    default:
      return AppColors.textMuted;
  }
}

String _fmt(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '${n < 0 ? '-' : ''}${buf.toString()}';
}
