import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_habit_app/core/providers/auth_provider.dart';
import 'package:water_habit_app/core/widgets/app_bottom_nav.dart';
import 'package:water_habit_app/routing/route_names.dart';
import 'package:water_habit_app/features/splash/presentation/splash_screen.dart';
import 'package:water_habit_app/features/auth/presentation/login_screen.dart';
import 'package:water_habit_app/features/auth/presentation/register_screen.dart';
import 'package:water_habit_app/features/water_tracking/presentation/home_screen.dart';
import 'package:water_habit_app/features/friends/presentation/friends_screen.dart';
import 'package:water_habit_app/features/friends/presentation/friend_search_screen.dart';
import 'package:water_habit_app/features/feed/presentation/feed_screen.dart';
import 'package:water_habit_app/features/profile/presentation/profile_screen.dart';
import 'package:water_habit_app/features/profile/presentation/edit_profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.whenOrNull(data: (user) => user != null) ?? false;
      final isAuthRoute = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register ||
          state.matchedLocation == RouteNames.splash;

      if (!isLoggedIn && !isAuthRoute) return RouteNames.login;
      if (isLoggedIn && isAuthRoute && state.matchedLocation != RouteNames.splash) {
        return RouteNames.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNav(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.friends,
                builder: (context, state) => const FriendsScreen(),
                routes: [
                  GoRoute(
                    path: 'search',
                    builder: (context, state) => const FriendSearchScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.feed,
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.leaderboard,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('🏆 Bảng xếp hạng - Coming soon')),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.userProfile,
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
    ],
  );
});

class ScaffoldWithNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNav({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
