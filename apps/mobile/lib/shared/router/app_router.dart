// lib/shared/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/children/screens/child_profiles_screen.dart';
import '../../features/children/screens/add_edit_child_screen.dart';
import '../../features/children/screens/pin_entry_screen.dart';
import '../../features/children/screens/child_home_screen.dart';
import '../../features/quiz/screens/quiz_screen.dart';
import '../../features/quiz/screens/results_screen.dart';
import '../../features/dashboard/screens/parent_dashboard_screen.dart';
import '../../features/rewards/screens/cosmetics_shop_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../repositories/auth_repository.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/signup');

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/children';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/children',
        name: 'children',
        builder: (context, state) => const ChildProfilesScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'addChild',
            builder: (context, state) => const AddEditChildScreen(),
          ),
          GoRoute(
            path: 'edit/:childId',
            name: 'editChild',
            builder: (context, state) => AddEditChildScreen(
              childId: state.pathParameters['childId'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/pin/:childId',
        name: 'pinEntry',
        builder: (context, state) => PinEntryScreen(
          childId: state.pathParameters['childId']!,
        ),
      ),
      GoRoute(
        path: '/child-home/:childId',
        name: 'childHome',
        builder: (context, state) => ChildHomeScreen(
          childId: state.pathParameters['childId']!,
        ),
      ),
      GoRoute(
        path: '/quiz/:childId',
        name: 'quiz',
        builder: (context, state) => QuizScreen(
          childId: state.pathParameters['childId']!,
        ),
      ),
      GoRoute(
        path: '/results/:childId',
        name: 'results',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ResultsScreen(
            childId: state.pathParameters['childId']!,
            correctCount: extra['correctCount'] as int? ?? 0,
            totalCount: extra['totalCount'] as int? ?? 0,
            xpEarned: extra['xpEarned'] as int? ?? 0,
            coinsEarned: extra['coinsEarned'] as int? ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const ParentDashboardScreen(),
      ),
      GoRoute(
        path: '/shop/:childId',
        name: 'shop',
        builder: (context, state) => CosmeticsShopScreen(
          childId: state.pathParameters['childId']!,
        ),
      ),
      GoRoute(
        path: '/settings/:childId',
        name: 'settings',
        builder: (context, state) => SettingsScreen(
          childId: state.pathParameters['childId']!,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
