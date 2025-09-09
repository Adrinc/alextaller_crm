import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/pages/talleralex/configuracion_page.dart';
import 'package:nethive_neo/pages/talleralex/dashboard_global_page.dart';
import 'package:nethive_neo/pages/talleralex/sucursales_page.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/sucursal_layout.dart';
import 'package:nethive_neo/pages/pages.dart';
import 'package:nethive_neo/services/navigation_service.dart';

/// The route configuration.
final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: NavigationService.navigatorKey,
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = currentUser != null;
    final bool isLoggingIn = state.matchedLocation.contains('/login');

    // If user is not logged in and not in the login page
    if (!loggedIn && !isLoggingIn) return '/login';

    // If user is logged in and in the login page, go to dashboard
    if (loggedIn && isLoggingIn) {
      return '/';
    }

    return null;
  },
  errorBuilder: (context, state) => const PageNotFoundPage(),
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'root',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const DashboardGlobalPage(),
        );
      },
    ),
    GoRoute(
      path: '/dashboard-global',
      name: 'dashboard-global',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const DashboardGlobalPage(),
        );
      },
    ),
    GoRoute(
      path: '/dashboard-global/configuracion',
      name: 'dashboard-global-configuracion',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const ConfiguracionPage(),
        );
      },
    ),
    GoRoute(
      path: '/sucursales',
      name: 'sucursales',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const SucursalesPage(),
        );
      },
    ),
    GoRoute(
      path: '/sucursal/:sucursalId',
      name: 'sucursal',
      pageBuilder: (BuildContext context, GoRouterState state) {
        final sucursalId = state.pathParameters['sucursalId']!;
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: SucursalLayout(sucursalId: sucursalId),
        );
      },
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const LoginPage(),
        );
      },
    ),
  ],
);
