import 'package:flutter/material.dart';
import 'package:bird_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'models/species_summary.dart';
import 'screens/ogrod_screen.dart';
import 'screens/aktywnosc_screen.dart';
import 'screens/gatunki_screen.dart';
import 'screens/gatunek_detail_screen.dart';
import 'screens/live_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';

GoRouter createRouter({required bool showOnboarding}) => GoRouter(
  initialLocation: showOnboarding ? '/onboarding' : '/ogrod',
  routes: [
    // ── 4 zakładki ──────────────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _NavScaffold(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/ogrod', builder: (c, s) => const OgrodScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/aktywnosc', builder: (c, s) => const AktywnoscScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/gatunki',
            builder: (c, s) => const GatunkiScreen(),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (c, s) => GatunekDetailScreen(
                  species: s.extra as SpeciesSummary,
                ),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/live', builder: (c, s) => const LiveScreen()),
        ]),
      ],
    ),

    // ── Settings ─────────────────────────────────────────────────────
    GoRoute(
      path: '/settings',
      builder: (c, s) => const SettingsScreen(),
    ),

    // ── Onboarding ────────────────────────────────────────────────────
    GoRoute(
      path: '/onboarding',
      builder: (c, s) => const OnboardingScreen(),
    ),
  ],
);

class _NavScaffold extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _NavScaffold({required this.shell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.tabGarden,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.tabActivity,
          ),
          NavigationDestination(
            icon: const Icon(Icons.star_outline),
            selectedIcon: const Icon(Icons.star),
            label: l10n.tabSpecies,
          ),
          NavigationDestination(
            icon: const Icon(Icons.videocam_outlined),
            selectedIcon: const Icon(Icons.videocam),
            label: l10n.tabLive,
          ),
        ],
      ),
    );
  }
}
