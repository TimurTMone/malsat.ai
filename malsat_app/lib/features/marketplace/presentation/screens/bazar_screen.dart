import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../drops/presentation/screens/drops_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../auctions/presentation/screens/auctions_screen.dart';

/// Unified Базар (Marketplace) tab — hosts the three marketplace surfaces
/// behind chip filters at the top. Replaces the previous Эт-Базар /
/// Мал-Базар / Аукцион split into separate bottom-nav tabs.
class BazarScreen extends ConsumerStatefulWidget {
  const BazarScreen({super.key});

  @override
  ConsumerState<BazarScreen> createState() => _BazarScreenState();
}

enum _BazarSection { meat, livestock, auction }

class _BazarScreenState extends ConsumerState<BazarScreen> {
  _BazarSection _section = _BazarSection.meat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildChipsRow(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildChipsRow() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _SectionChip(
              icon: LucideIcons.beef,
              label: 'Эт',
              isActive: _section == _BazarSection.meat,
              activeColor: const Color(0xFFB91C1C),
              onTap: () => setState(() => _section = _BazarSection.meat),
            ),
            const SizedBox(width: 8),
            _SectionChip(
              icon: LucideIcons.layers,
              label: 'Мал',
              isActive: _section == _BazarSection.livestock,
              activeColor: AppColors.primary,
              onTap: () => setState(() => _section = _BazarSection.livestock),
            ),
            const SizedBox(width: 8),
            _SectionChip(
              icon: LucideIcons.gavel,
              label: 'Аукцион',
              isActive: _section == _BazarSection.auction,
              activeColor: const Color(0xFF7C2D12),
              onTap: () => setState(() => _section = _BazarSection.auction),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_section) {
      case _BazarSection.meat:
        return const DropsScreen();
      case _BazarSection.livestock:
        return const HomeScreen();
      case _BazarSection.auction:
        return const AuctionsScreen();
    }
  }
}

class _SectionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _SectionChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isActive ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
