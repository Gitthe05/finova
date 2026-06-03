import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/theme/app_surface_colors.dart';
import '../dashboard/viewmodel/dashboard_view_model.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _homeBranchIndex = 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = context.surfaces;
    return Scaffold(
      backgroundColor: surfaces.screenBackground,
      resizeToAvoidBottomInset: false,
      body: navigationShell,
      extendBody: false,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surfaces.screenBackground,
          border: Border(top: BorderSide(color: surfaces.border)),
        ),
        child: NavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          indicatorColor: context.accentHighlight.withValues(alpha: 0.2),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(index);
            if (index == _homeBranchIndex) {
              ref.read(dashboardViewModelProvider.notifier).load();
            }
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Symbols.home),
              selectedIcon: const Icon(Symbols.home, fill: 1),
              label: 'Início',
            ),
            NavigationDestination(
              icon: const Icon(Symbols.payments),
              selectedIcon: const Icon(Symbols.payments, fill: 1),
              label: 'Transações',
            ),
            NavigationDestination(
              icon: const Icon(Symbols.grid_view),
              selectedIcon: const Icon(Symbols.grid_view, fill: 1),
              label: 'Categorias',
            ),
            NavigationDestination(
              icon: const Icon(Symbols.article),
              selectedIcon: const Icon(Symbols.article, fill: 1),
              label: 'Notícias',
            ),
            NavigationDestination(
              icon: const Icon(Symbols.person),
              selectedIcon: const Icon(Symbols.person, fill: 1),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
