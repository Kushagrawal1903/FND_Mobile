import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import providers and screens (will be generated next)
import 'package:truthlens/features/auth/presentation/providers/auth_provider.dart';
import 'package:truthlens/features/auth/presentation/screens/login_screen.dart';
import 'package:truthlens/features/auth/presentation/screens/register_screen.dart';
import 'package:truthlens/features/auth/presentation/screens/logged_out_screen.dart';
import 'package:truthlens/features/verify/presentation/screens/verify_screen.dart';
import 'package:truthlens/features/verify/presentation/screens/report_screen.dart';
import 'package:truthlens/features/history/presentation/screens/history_screen.dart';
import 'package:truthlens/features/admin/presentation/screens/admin_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final isAuth = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';
      final isLoggedOutRoute = state.matchedLocation == '/logged-out';

      if (!isAuth && !isLoginRoute && !isRegisterRoute && !isLoggedOutRoute) {
        return '/login';
      }

      if (isAuth && (isLoginRoute || isRegisterRoute)) {
        return '/';
      }

      // Check admin routes
      if (state.matchedLocation.startsWith('/admin') && authState.user?.role != 'admin') {
        return '/'; // Non-admin users redirected to home
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/logged-out',
        builder: (context, state) => const LoggedOutScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const VerifyScreen(),
      ),
      GoRoute(
        path: '/report/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReportScreen(reportId: id);
        },
      ),
      GoRoute(
        path: '/saved',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
    ],
  );
});
