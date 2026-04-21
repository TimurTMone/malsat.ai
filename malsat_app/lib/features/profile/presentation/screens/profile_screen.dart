import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/widgets/listing_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);
    final authState = ref.watch(authProvider);

    return dictAsync.when(
      data: (dict) {
        if (authState is Authenticated) {
          return _LoggedInProfile(dict: dict, user: authState.user);
        }
        return _LoggedOutProfile(dict: dict);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Center(child: Text('Error')),
    );
  }
}

class _LoggedOutProfile extends StatelessWidget {
  final Map<String, dynamic> dict;

  const _LoggedOutProfile({required this.dict});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.user,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t(dict, 'common.login'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: ElevatedButton(
                onPressed: () => context.push('/auth/login'),
                child: Text(t(dict, 'common.login')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoggedInProfile extends ConsumerWidget {
  final Map<String, dynamic> dict;
  final dynamic user;

  const _LoggedInProfile({required this.dict, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final locale = ref.watch(localeProvider);

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.refresh(myProfileProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.phone,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              if (user.isVerifiedBreeder) ...[
                const SizedBox(height: 8),
                _VerifiedBadge(dict: dict),
              ],

              // Stats row from profile data
              profileAsync.when(
                data: (profile) {
                  if (profile == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          value: '${profile.listingsCount}',
                          label: t(dict, 'profile.myListings'),
                        ),
                        _StatItem(
                          value: '${profile.reviewsCount}',
                          label: t(dict, 'profile.reviews'),
                        ),
                        _StatItem(
                          value: profile.trustScore.toStringAsFixed(1),
                          label: t(dict, 'profile.trustScore'),
                          icon: Icons.star,
                          iconColor: Colors.amber,
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (e, st) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // ═══ SELLER DASHBOARD SECTION ═══
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.store, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Сатуучу панели',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Эт сатуу, заказдарды башкаруу',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _SellerActionButton(
                            icon: LucideIcons.plusCircle,
                            label: 'Эт Drop\nжарыялоо',
                            onTap: () => context.push('/create-drop'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SellerActionButton(
                            icon: LucideIcons.clipboardList,
                            label: 'Келген\nзаказдар',
                            onTap: () => context.push('/seller-orders'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SellerActionButton(
                            icon: LucideIcons.qrCode,
                            label: 'Төлөм\nQR код',
                            onTap: () => context.push('/payment-setup'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ═══ BUYER SECTION ═══
              _MenuItem(
                icon: LucideIcons.shoppingBag,
                label: 'Менин заказдарым',
                onTap: () => context.push('/orders/me'),
              ),

              // Menu items
              _MenuItem(
                icon: LucideIcons.package,
                label: t(dict, 'profile.myListings'),
                onTap: () => context.push('/my-listings'),
              ),
              _MenuItem(
                icon: LucideIcons.heart,
                label: t(dict, 'listing.favorites'),
                onTap: () => context.push('/favorites'),
              ),
              _MenuItem(
                icon: LucideIcons.star,
                label: t(dict, 'profile.reviews'),
                onTap: () => context.push('/reviews'),
              ),
              _MenuItem(
                icon: LucideIcons.globe,
                label: t(dict, 'profile.language'),
                trailing: Text(
                  locale.languageCode == 'ky' ? 'Кыргызча' : 'Русский',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  final other =
                      locale.languageCode == 'ky' ? 'ru' : 'ky';
                  ref.read(localeProvider.notifier).state = Locale(other);
                },
              ),
              _MenuItem(
                icon: LucideIcons.settings,
                label: t(dict, 'profile.settings'),
                onTap: () => context.push('/settings'),
              ),
              const SizedBox(height: 16),
              _MenuItem(
                icon: LucideIcons.logOut,
                label: t(dict, 'common.logout'),
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                  ref.read(favoritedIdsProvider.notifier).clear();
                },
                isDestructive: true,
              ),

              // My listings section
              profileAsync.when(
                data: (profile) {
                  if (profile == null || profile.listings.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        t(dict, 'profile.myListings'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.62,
                        ),
                        itemCount: profile.listings.length,
                        itemBuilder: (context, index) => ListingCard(
                          listing: profile.listings[index],
                          dict: dict,
                          locale: locale.languageCode,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  final Map<String, dynamic> dict;
  const _VerifiedBadge({required this.dict});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.badgeCheck,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            t(dict, 'profile.verifiedBreeder'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  const _StatItem({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 3),
            ],
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _SellerActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SellerActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            ?trailing,
            if (!isDestructive && trailing == null)
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
