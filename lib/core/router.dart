import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/splash/splash_screen.dart';
import '../l10n/gen/app_localizations.dart';
import '../widgets/placeholder_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

Widget _placeholder(
  String Function(AppLocalizations l) title, {
  PlaceholderLeading leading = PlaceholderLeading.none,
}) => Builder(
  builder: (context) => PlaceholderScreen(
    title: title(AppLocalizations.of(context)),
    leading: leading,
  ),
);

final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, _) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'day',
                  builder: (_, _) => _placeholder(
                    (l) => l.screenDay,
                    leading: PlaceholderLeading.back,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/operations',
              builder: (_, _) => _placeholder((l) => l.navOperations),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/report',
              builder: (_, _) => _placeholder((l) => l.navReport),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/plans',
              builder: (_, _) => _placeholder((l) => l.screenPlan),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/add',
      parentNavigatorKey: _rootKey,
      pageBuilder: (_, _) => MaterialPage(
        fullscreenDialog: true,
        child: _placeholder(
          (l) => l.screenAddCash,
          leading: PlaceholderLeading.close,
        ),
      ),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootKey,
      builder: (_, _) => const SettingsScreen(),
    ),
  ],
);
