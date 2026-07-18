import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/screens/create_profile_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/habits/presentation/providers/habits_controller.dart';
import '../../features/habits/presentation/screens/habit_detail_screen.dart';
import '../../features/habits/presentation/screens/habits_list_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/theme_settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../widgets/coming_soon_screen.dart';
import '../widgets/loading_view.dart';
import 'app_shell.dart';

/// Resolves a habit by id and shows its detail screen. Only entry point that
/// doesn't already have the [Habit] object in hand — a notification tap only
/// carries the id, so this looks it up from the already-loaded habits list.
class _HabitDeepLinkScreen extends ConsumerWidget {
  const _HabitDeepLinkScreen({required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsControllerProvider);
    return habitsAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, __) => const Scaffold(body: Center(child: Text("Couldn't load that habit."))),
      data: (state) {
        final match = state.habits.where((h) => h.id == habitId);
        if (match.isEmpty) {
          return const Scaffold(body: Center(child: Text('Habit not found — it may have been archived.')));
        }
        return HabitDetailScreen(habit: match.first);
      },
    );
  }
}

/// Reachable only while signed out. `/create-profile` is deliberately NOT
/// here: it requires an authenticated session (register() already saved
/// tokens by the time the user lands on it) but sits outside the main app
/// shell — see the redirect logic below.
final _preAuthOnlyPaths = {'/onboarding', '/login', '/register'};

/// Bridges Riverpod's async auth state to GoRouter's [Listenable]-based
/// refresh mechanism, so a login/logout anywhere in the app immediately
/// re-evaluates the redirect guard without manual navigation calls.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(isAuthenticatedProvider, (_, next) => notifyListeners());
    ref.listen(needsProfileSetupProvider, (_, next) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final path = state.matchedLocation;

      // Still resolving the cached session on cold start — stay on splash.
      if (isAuthenticated == null) {
        return path == '/splash' ? null : '/splash';
      }
      if (!isAuthenticated) {
        return _preAuthOnlyPaths.contains(path) ? null : '/onboarding';
      }
      // Authenticated but hasn't finished Create Profile yet (set by
      // register(), cleared by updateProfile()) — pin them there regardless
      // of where they were headed.
      if (ref.read(needsProfileSetupProvider)) {
        return path == '/create-profile' ? null : '/create-profile';
      }
      // Authenticated and profile complete: keep them out of
      // onboarding/login/register/splash/create-profile.
      if (_preAuthOnlyPaths.contains(path) || path == '/splash' || path == '/create-profile') {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/create-profile', builder: (context, state) => const CreateProfileScreen()),
      GoRoute(path: '/settings/theme', builder: (context, state) => const ThemeSettingsScreen()),
      GoRoute(
        path: '/habits/:id',
        builder: (context, state) => _HabitDeepLinkScreen(habitId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/habits', builder: (context, state) => const HabitsListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  const ComingSoonScreen(title: 'Profile', icon: Icons.person_rounded, milestone: 'a follow-up cross-cutting task'),
            ),
          ]),
        ],
      ),
    ],
  );
});
