import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/malsat_header.dart';
import '../../features/home/presentation/screens/home_screen.dart';
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
import '../../features/herd/presentation/screens/herd_screen.dart';
import '../../features/herd/presentation/screens/animal_detail_screen.dart';
import '../../features/herd/presentation/screens/caretakers_screen.dart';
import '../../features/drops/presentation/screens/drops_screen.dart';
import '../../features/drops/presentation/screens/drop_detail_screen.dart';
import '../../features/drops/presentation/screens/my_orders_screen.dart';
import '../../features/drops/presentation/screens/order_detail_screen.dart';
import '../../features/drops/presentation/screens/create_drop_screen.dart';
import '../../features/drops/presentation/screens/seller_orders_screen.dart';
import '../../features/drops/presentation/screens/payment_setup_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorDropsKey = GlobalKey<NavigatorState>(debugLabel: 'drops');
final _shellNavigatorSellKey = GlobalKey<NavigatorState>(debugLabel: 'sell');
final _shellNavigatorMessagesKey =
    GlobalKey<NavigatorState>(debugLabel: 'messages');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _ShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              name: RouteNames.home,
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorDropsKey,
          routes: [
            GoRoute(
              name: RouteNames.drops,
              path: '/drops',
              builder: (context, state) => const DropsScreen(),
            ),
          ],
        ),
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
        StatefulShellBranch(
          navigatorKey: _shellNavigatorMessagesKey,
          routes: [
            GoRoute(
              name: RouteNames.herd,
              path: '/herd',
              builder: (context, state) => const HerdScreen(),
            ),
          ],
        ),
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
  ],
);

class _ShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ShellScreen({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MalsatHeader(),
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
