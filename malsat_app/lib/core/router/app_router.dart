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
import '../../features/butcher/presentation/screens/butcher_flow_screen.dart';
import '../../features/drops/presentation/screens/drops_screen.dart';
import '../../features/marketplace/presentation/screens/livestock_home_screen.dart';
import '../theme/app_world.dart';
import '../../features/auctions/presentation/screens/auction_detail_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/profile/presentation/screens/my_listings_screen.dart';
import '../../features/profile/presentation/screens/reviews_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/marketplace/presentation/screens/activity_tab.dart';
import '../../features/shop/presentation/screens/duken_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/v2/screens/v2_home_screen.dart';
import '../../features/v2/screens/v2_event_picker_screen.dart';
import '../../features/v2/screens/v2_listing_detail_screen.dart';
import '../../features/v2/screens/v2_count_screen.dart';
import '../../features/v2/screens/v2_proposal_screen.dart';
import '../../features/v2/screens/v2_sent_screen.dart';
import '../../features/v2/v2_state.dart';

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
  initialLocation: '/meat',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _ShellScreen(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Meat — the meat world (Drops feed).
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              name: RouteNames.meat,
              path: '/meat',
              builder: (context, state) => const DropsScreen(),
            ),
          ],
        ),
        // Tab 1: Livestock — the livestock world (Listings feed).
        StatefulShellBranch(
          navigatorKey: _shellNavigatorExploreKey,
          routes: [
            GoRoute(
              name: RouteNames.livestock,
              path: '/livestock',
              builder: (context, state) => const LivestockHomeScreen(),
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
    // ── v2.0 redesign preview ──
    //
    // Home is a clear fork between browse-the-marketplace and
    // order-for-an-event. The event flow (picker → count → proposal →
    // sent) lives as a secondary path; the primary flow is browse →
    // listing detail → CALL / BUY.
    GoRoute(
      path: '/v2',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const V2HomeScreen(),
    ),
    GoRoute(
      path: '/v2/listing/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          V2ListingDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/v2/event',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const V2EventPickerScreen(),
    ),
    GoRoute(
      path: '/v2/count',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          V2CountScreen(occasion: state.extra as V2Occasion),
    ),
    GoRoute(
      path: '/v2/proposal',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          V2ProposalScreen(draft: state.extra as V2OrderDraft),
    ),
    GoRoute(
      path: '/v2/sent',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const V2SentScreen(),
    ),

    // Legacy-path redirects — keep older `context.go` callers working.
    GoRoute(path: '/', redirect: (_, _) => '/meat'),
    GoRoute(path: '/home', redirect: (_, _) => '/meat'),
    GoRoute(path: '/explore', redirect: (_, _) => '/livestock'),
    GoRoute(path: '/drops', redirect: (_, _) => '/meat'),
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
      name: 'butcher-service',
      path: '/butcher',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ButcherFlowScreen(),
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

/// The app shell — a fixed header (wordmark + bell) and bottom nav, with
/// the active branch in between. The whole shell is wrapped in the
/// current world's theme. Tapping the Meat or Livestock tab also writes
/// the corresponding world into [worldProvider] so the rest of the app
/// (Activity label, Sell flow, accent tinting) follows along.
class _ShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _ShellScreen({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final world = ref.watch(worldProvider);
    final idx = navigationShell.currentIndex;

    // Keep worldProvider in sync with the active world tab on every
    // build — fixes the cold-boot case where the persisted world (e.g.
    // livestock) doesn't match the forced initialLocation ('/meat'), so
    // the shared tabs (Activity label/icon, Sell flow) follow the tab
    // the user actually sees. No-op when already in sync.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (idx == 0 && world != AppWorld.meat) {
        ref.read(worldProvider.notifier).setWorld(AppWorld.meat);
      } else if (idx == 1 && world != AppWorld.livestock) {
        ref.read(worldProvider.notifier).setWorld(AppWorld.livestock);
      }
    });

    return Theme(
      data: worldTheme(world),
      child: Scaffold(
        appBar: const MalsatHeader(),
        body: navigationShell,
        bottomNavigationBar: BottomNavBar(
          currentIndex: idx,
          onTap: (index) {
            if (index == 0) {
              ref.read(worldProvider.notifier).setWorld(AppWorld.meat);
            } else if (index == 1) {
              ref.read(worldProvider.notifier).setWorld(AppWorld.livestock);
            }
            navigationShell.goBranch(
              index,
              initialLocation: index == idx,
            );
          },
        ),
      ),
    );
  }
}
