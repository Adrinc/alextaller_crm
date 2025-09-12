import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/pages/talleralex/dashboard_global_page.dart';
import 'package:nethive_neo/pages/talleralex/sucursales_page.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/sucursal_layout.dart';
import 'package:nethive_neo/pages/pages.dart';
import 'package:nethive_neo/services/navigation_service.dart';

// Importar páginas globales
import 'package:nethive_neo/pages/talleralex/global/usuarios_pendientes_page.dart';
import 'package:nethive_neo/pages/talleralex/global/empleados_globales_page.dart';
import 'package:nethive_neo/pages/talleralex/global/clientes_globales_page.dart';
import 'package:nethive_neo/pages/talleralex/global/historial_servicios_page.dart';
import 'package:nethive_neo/pages/talleralex/global/inventario_global_page.dart';
import 'package:nethive_neo/pages/talleralex/global/promociones_globales_page.dart';
import 'package:nethive_neo/pages/talleralex/global/reportes_ejecutivos_page.dart';
import 'package:nethive_neo/pages/talleralex/global/catalogos_corporativos_page.dart';
import 'package:nethive_neo/pages/talleralex/global/configuracion_visual_page.dart';
import 'package:nethive_neo/pages/talleralex/global/configuracion_sistema_page.dart';

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
    // Rutas de Gestión de Usuarios
    GoRoute(
      path: '/usuarios-pendientes',
      name: 'usuarios-pendientes',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const UsuariosPendientesPage(),
        );
      },
    ),
    GoRoute(
      path: '/empleados-globales',
      name: 'empleados-globales',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const EmpleadosGlobalesPage(),
        );
      },
    ),
    GoRoute(
      path: '/clientes-globales',
      name: 'clientes-globales',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const ClientesGlobalesPage(),
        );
      },
    ),
    GoRoute(
      path: '/historial-servicios',
      name: 'historial-servicios',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const HistorialServiciosPage(),
        );
      },
    ),

    // Rutas de Operaciones
    GoRoute(
      path: '/inventario-global',
      name: 'inventario-global',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const InventarioGlobalPage(),
        );
      },
    ),
    GoRoute(
      path: '/promociones-globales',
      name: 'promociones-globales',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const PromocionesGlobalesPage(),
        );
      },
    ),

    // Rutas de Reportes
    GoRoute(
      path: '/reportes-ejecutivos',
      name: 'reportes-ejecutivos',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const ReportesEjecutivosPage(),
        );
      },
    ),

    // Rutas de Administración
    GoRoute(
      path: '/catalogos-corporativos',
      name: 'catalogos-corporativos',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const CatalogosCorporativosPage(),
        );
      },
    ),

    // Rutas de Sistema
    GoRoute(
      path: '/configuracion-visual',
      name: 'configuracion-visual',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const ConfiguracionVisualPage(),
        );
      },
    ),
    GoRoute(
      path: '/configuracion-sistema',
      name: 'configuracion-sistema',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: const ConfiguracionSistemaPage(),
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
