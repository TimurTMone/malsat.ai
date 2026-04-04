import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/owned_animal_model.dart';
import '../providers/herd_provider.dart';
import '../widgets/qr_token_card.dart';

class AnimalDetailScreen extends ConsumerWidget {
  final String id;
  const AnimalDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(animalDetailProvider(id));
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ката: $e')),
        data: (animal) => _Body(animal: animal),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final OwnedAnimal animal;
  const _Body({required this.animal});

  @override
  Widget build(BuildContext context) {
    final isProfit = animal.profitKgs >= 0;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: AppColors.surface,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: animal.photo,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.backgroundSecondary),
                  errorWidget: (_, __, ___) => Container(color: AppColors.backgroundSecondary),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animal.name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${animal.breed} • ${animal.locationVillage}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Value card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Азыркы баасы',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '${_fmt(animal.currentValueKgs)} сом',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isProfit ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                          size: 14,
                          color: isProfit ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isProfit ? '+' : ''}${_fmt(animal.profitKgs)} сом (${isProfit ? '+' : ''}${animal.profitPercent.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isProfit ? AppColors.success : AppColors.error,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Алынды: ${_fmt(animal.purchasePriceKgs)}с',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Stats grid
              Row(
                children: [
                  _StatBox(icon: LucideIcons.heart, label: 'Ден соолук', value: '${animal.healthScore}/100', color: AppColors.success),
                  const SizedBox(width: 12),
                  _StatBox(icon: LucideIcons.scale, label: 'Салмак +', value: '+${animal.weightGainKg}кг', color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatBox(icon: LucideIcons.stethoscope, label: 'Ветеринар', value: '${animal.vetVisits} жолу', color: AppColors.boostBlue),
                  const SizedBox(width: 12),
                  _StatBox(icon: LucideIcons.gift, label: 'Пайыз', value: '${animal.loyaltyPoints}', color: AppColors.premiumGold),
                ],
              ),

              // Caretaker card
              if (animal.caretakerName != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('МАЛЧЫ',
                          style: TextStyle(fontSize: 10, color: AppColors.textMuted, letterSpacing: 0.8, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                animal.caretakerName!.substring(0, 1),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  animal.caretakerName!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${animal.locationRegion} • карап турат',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(LucideIcons.messageCircle, size: 20, color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Next milestone
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.premiumGoldLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 18, color: AppColors.premiumGold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Кийинки этап',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.premiumGold, letterSpacing: 0.5)),
                          const SizedBox(height: 2),
                          Text(
                            animal.nextMilestone,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Token / QR certificate
              const SizedBox(height: 20),
              QrTokenCard(tokenId: animal.tokenId, animalName: animal.name),

              // Actions
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: LucideIcons.tag,
                      label: 'Сатуу',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: LucideIcons.utensils,
                      label: 'Союу',
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ActionButton({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
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
