import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../state/world_provider.dart';
import '../theme/world_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/malsat_header.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/sell/presentation/screens/sell_screen.dart';
// ignore: unused_import
import '../../features/messages/presentation/screens/messages_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/listing_detail/presentation/screens/listing_detail_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/profile/presentation/screens/public_profile_screen.dart';
import '../../features/messages/presentation/screens/chat_screen.dart';
import '../../features/herd/presentation/screens/animal_detail_screen.dart';
import '../../features/herd/presentation/screens/caretakers_screen.dart';
import '../../features/drops/presentation/screens/drop_detail_screen.dart';
import '../../features/drops/presentation/screens/my_orders_screen.dart';
import '../../features/drops/presentation/screens/order_detail_screen.dart';
import '../../features/drops/presentation/screens/create_drop_screen.dart';
import '../../features/drops/presentation/screens/seller_orders_screen.dart';
import '../../features/drops/presentation/screens/payment_setup_screen.dart';
import '../../features/auctions/presentation/screens/auction_detail_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/profile/presentation/screens/my_listings_screen.dart';
import '../../features/profile/presentation/screens/reviews_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/marketplace/presentation/screens/home_tab.dart';
import '../../features/marketplace/presentation/screens/explore_tab.dart';
import '../../features/marketplace/presentation/screens/activity_tab.dart';
import '../../features/shop/presentation/screens/duken_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Public accessor so non-widget code (e.g. auth interceptor) can navigate
/// on auth expiry without needing a BuildContext.
GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorExploreKey =
    GlobalKey<NavigatorState>(debugLabel: 'explore');
final _shellNavigatorSellKey = GlobalKey<NavigatorState>(debugLabel: 'sell');
final _shellNavigatorActivityKey =
    GlobalKey<NavigatorState>(debugLabel: 'activity');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _ShellScreen(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home — the active world's main page.
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              name: RouteNames.home,
              path: '/home',
              builder: (context, state) => const HomeTab(),
            ),
          ],
        ),
        // Tab 1: Explore — world-aware browse hub.
        StatefulShellBranch(
          navigatorKey: _shellNavigatorExploreKey,
          routes: [
            GoRoute(
              name: RouteNames.explore,
              path: '/explore',
              builder: (context, state) => const ExploreTab(),
            ),
          ],
        ),
        // Tab 2: + Sell — create a meat drop or list an animal.
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSellKey,
          routes: [
            GoRoute(
              name: RouteNames.sell,
              path: '/sell',
              builder: (context, state) => const SellScreen(),
            ),
          ],
        ),
        // Tab 3: Activity — meat orders, or the livestock herd.
        StatefulShellBranch(
          navigatorKey: _shellNavigatorActivityKey,
          routes: [
            GoRoute(
              name: RouteNames.activity,
              path: '/activity',
              builder: (context, state) => const ActivityTab(),
            ),
          ],
        ),
        // Tab 4: Profile.
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              name: RouteNames.profile,
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // Legacy-path redirects — keep older `context.go` callers working.
    GoRoute(path: '/', redirect: (_, _) => '/home'),
    GoRoute(path: '/meat', redirect: (_, _) => '/home'),
    GoRoute(path: '/livestock', redirect: (_, _) => '/home'),
    GoRoute(path: '/drops', redirect: (_, _) => '/home'),
    GoRoute(path: '/herd', redirect: (_, _) => '/activity'),
    // Дүкөн — supply shop placeholder, pushed over the shell (Sprint 2).
    GoRoute(
      name: RouteNames.duken,
      path: '/duken',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DukenScreen(),
    ),
    // Full-screen routes (outside shell)
    GoRoute(
      name: RouteNames.listingDetail,
      path: '/listing/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ListingDetailScreen(
        listingId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      name: RouteNames.login,
      path: '/auth/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      name: RouteNames.otpVerify,
      path: '/auth/verify',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => OtpScreen(
        phone: state.uri.queryParameters['phone'] ?? '',
      ),
    ),
    GoRoute(
      name: 'onboarding',
      path: '/onboarding',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      name: RouteNames.publicProfile,
      path: '/user/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PublicProfileScreen(
        userId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      name: RouteNames.chat,
      path: '/chat/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ChatScreen(
        conversationId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      name: RouteNames.animalDetail,
      path: '/herd/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          AnimalDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      name: RouteNames.caretakers,
      path: '/caretakers',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CaretakersScreen(),
    ),
    GoRoute(
      name: RouteNames.search,
      path: '/search',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final category = state.uri.queryParameters['category'];
        return SearchScreen(initialCategory: category);
      },
    ),
    GoRoute(
      name: RouteNames.dropDetail,
      path: '/drop/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => DropDetailScreen(
        dropId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      name: RouteNames.myOrders,
      path: '/orders/me',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MyOrdersScreen(),
    ),
    GoRoute(
      name: RouteNames.favorites,
      path: '/favorites',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      name: RouteNames.myListings,
      path: '/my-listings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MyListingsScreen(),
    ),
    GoRoute(
      name: RouteNames.reviews,
      path: '/reviews',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ReviewsScreen(),
    ),
    GoRoute(
      name: RouteNames.settings,
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      name: 'order-detail',
      path: '/order/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => OrderDetailScreen(
        orderId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      name: 'create-drop',
      path: '/create-drop',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateDropScreen(),
    ),
    GoRoute(
      name: 'seller-orders',
      path: '/seller-orders',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SellerOrdersScreen(),
    ),
    GoRoute(
      name: 'payment-setup',
      path: '/payment-setup',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PaymentSetupScreen(),
    ),
    GoRoute(
      name: 'auction-detail',
      path: '/auction/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => AuctionDetailScreen(
        auctionId: state.pathParameters['id']!,
      ),
    ),
  ],
);

/// The app shell — a fixed header (logo + world switch) and bottom nav,
/// with the active branch in between. The whole shell is wrapped in the
/// active world's theme, so one switch reskins everything at once.
class _ShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _ShellScreen({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final world = ref.watch(worldProvider);
    return Theme(
      data: worldTheme(world),
      child: Scaffold(
        appBar: const MalsatHeader(),
        body: navigationShell,
        bottomNavigationBar: BottomNavBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}
