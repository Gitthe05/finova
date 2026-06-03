import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_surface_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/view_status.dart';
import '../../shared/widgets/app_gradient_background.dart';
import '../../shared/widgets/brand_logo.dart';
import '../../presentation/auth/view/login_page.dart';
import '../../presentation/auth/view/register_page.dart';
import '../../presentation/auth/viewmodel/auth_view_model.dart';
import '../../presentation/categories/view/categories_page.dart';
import '../../presentation/dashboard/view/dashboard_page.dart';
import '../../presentation/news/view/news_page.dart';
import '../../presentation/profile/view/profile_page.dart';
import '../../presentation/shell/home_shell.dart';
import '../../presentation/transactions/view/transactions_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authViewModelProvider);
      final location = state.matchedLocation;
      final loggedIn = auth.user != null;
      final onAuth =
          location == '/login' || location == '/register';
      final onSplash = location == '/splash';

      if (onSplash) {
        if (auth.status == ViewStatus.initial ||
            auth.status == ViewStatus.loading) {
          return null;
        }
        return loggedIn ? '/home' : '/login';
      }

      if (!loggedIn && !onAuth) return '/login';
      if (loggedIn && onAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const _SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const DashboardPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (_, __) => const TransactionsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                builder: (_, __) => const CategoriesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/news', builder: (_, __) => const NewsPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

class _SplashPage extends ConsumerStatefulWidget {
  const _SplashPage();

  @override
  ConsumerState<_SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<_SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authViewModelProvider.notifier).checkSession(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;

    return Scaffold(
      backgroundColor: surfaces.screenBackground,
      body: AppGradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BrandLogo(compact: true),
              const SizedBox(height: AppTokens.spaceXl),
              CircularProgressIndicator(color: context.accentHighlight),
              const SizedBox(height: AppTokens.spaceMd),
              Text(
                'Preparando sua conta...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: surfaces.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this.ref) {
    ref.listen(authViewModelProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}
