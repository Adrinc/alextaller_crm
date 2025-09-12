import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/helpers/scroll_behavior.dart';
import 'package:nethive_neo/internationalization/internationalization.dart';
import 'package:nethive_neo/router/router.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nethive_neo/providers/user_provider.dart';
import 'package:nethive_neo/providers/visual_state_provider.dart';
import 'package:nethive_neo/providers/users_provider.dart';
import 'package:nethive_neo/providers/talleralex/sucursales_provider.dart';
import 'package:nethive_neo/providers/talleralex/sucursal_provider.dart';
import 'package:nethive_neo/providers/talleralex/dashboard_sucursal_provider.dart';
import 'package:nethive_neo/providers/talleralex/agenda_bahias_provider.dart';
import 'package:nethive_neo/providers/talleralex/empleados_provider.dart';
import 'package:nethive_neo/providers/talleralex/clientes_provider.dart';
import 'package:nethive_neo/providers/talleralex/citas_ordenes_provider.dart';
import 'package:nethive_neo/providers/talleralex/inventario_provider.dart';
import 'package:nethive_neo/providers/talleralex/pagos_provider.dart';
import 'package:nethive_neo/providers/talleralex/promociones_provider.dart';
import 'package:nethive_neo/providers/talleralex/reportes_provider.dart';
import 'package:nethive_neo/providers/talleralex/navigation_provider.dart';
import 'package:nethive_neo/providers/talleralex/usuarios_pendientes_provider.dart';
import 'package:nethive_neo/providers/theme_config_provider.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:url_strategy/url_strategy.dart';

import 'package:nethive_neo/helpers/constants.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: anonKey,
    realtimeClientOptions: const RealtimeClientOptions(
      eventsPerSecond: 2,
    ),
  );

  supabaseLU = SupabaseClient(supabaseUrl, anonKey, schema: 'taller_alex');

  await initGlobals();

  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(
            create: (context) => VisualStateProvider(context)),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => SucursalesProvider()),
        ChangeNotifierProvider(create: (_) => SucursalProvider()),
        ChangeNotifierProvider(create: (_) => DashboardSucursalProvider()),
        ChangeNotifierProvider(create: (_) => AgendaBahiasProvider()),
        ChangeNotifierProvider(create: (_) => EmpleadosProvider()),
        ChangeNotifierProvider(create: (_) => ClientesProvider()),
        ChangeNotifierProvider(create: (_) => CitasOrdenesProvider()),
        ChangeNotifierProvider(create: (_) => InventarioProvider()),
        ChangeNotifierProvider(create: (_) => PagosProvider()),
        ChangeNotifierProvider(create: (_) => PromocionesProvider()),
        ChangeNotifierProvider(create: (_) => ReportesProvider()),
        ChangeNotifierProvider(create: (_) => TallerAlexNavigationProvider()),
        ChangeNotifierProvider(create: (_) => UsuariosPendientesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeConfigProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('es');
  ThemeMode _themeMode = AppTheme.themeMode;

  void setLocale(Locale value) => setState(() => _locale = value);
  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        AppTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeConfigProvider>(
      builder: (context, themeProvider, child) {
        return Portal(
          child: MaterialApp.router(
            title: 'TALLER ALEX',
            debugShowCheckedModeBanner: false,
            locale: _locale,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', 'US')],
            theme: ThemeData(
              brightness: Brightness.light,
              dividerColor: Colors.grey,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              dividerColor: Colors.grey,
            ),
            themeMode: _themeMode,
            routerConfig: router,
            scrollBehavior: MyCustomScrollBehavior(),
          ),
        );
      },
    );
  }
}
