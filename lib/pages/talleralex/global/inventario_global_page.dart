import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/pages/talleralex/widgets/global_sidebar.dart';
import 'package:nethive_neo/pages/talleralex/widgets/responsive_drawer.dart';
import 'package:nethive_neo/providers/talleralex/inventario_global_provider.dart';
import 'package:nethive_neo/pages/talleralex/global/inventario/widgets/inventario_global_header.dart';
import 'package:nethive_neo/pages/talleralex/global/inventario/widgets/inventario_global_table.dart';
import 'package:nethive_neo/pages/talleralex/global/inventario/widgets/inventario_global_cards.dart';
import 'package:nethive_neo/pages/talleralex/global/inventario/widgets/inventario_tabs_content.dart';

class InventarioGlobalPage extends StatefulWidget {
  const InventarioGlobalPage({Key? key}) : super(key: key);

  @override
  State<InventarioGlobalPage> createState() => _InventarioGlobalPageState();
}

class _InventarioGlobalPageState extends State<InventarioGlobalPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Tabs del inventario global
  final List<String> _tabs = [
    'Consolidado',
    'Alertas Stock',
    'Caducidad',
    'Rotación',
    'Sugerencias',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<InventarioGlobalProvider>(context, listen: false);
      provider.cargarInventarioGlobal();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;
    final currentLocation = GoRouterState.of(context).uri.toString();

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      drawer: isSmallScreen
          ? ResponsiveDrawer(currentRoute: currentLocation)
          : null,
      body: Consumer<InventarioGlobalProvider>(
        builder: (context, provider, child) {
          return Row(
            children: [
              // GlobalSidebar para pantallas grandes
              if (!isSmallScreen) GlobalSidebar(currentRoute: currentLocation),

              // Contenido principal
              Expanded(
                child: Column(
                  children: [
                    // Header con KPIs y filtros
                    InventarioGlobalHeader(),

                    // Tab bar
                    _buildTabBar(theme, isSmallScreen),

                    // Contenido de tabs
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: Inventario Consolidado
                          _buildInventarioConsolidadoTab(
                              provider, isSmallScreen),

                          // Tab 2: Alertas de Stock
                          InventarioTabsContent(
                            tabType: InventarioTabType.alertas,
                            isSmallScreen: isSmallScreen,
                          ),

                          // Tab 3: Caducidad
                          InventarioTabsContent(
                            tabType: InventarioTabType.caducidad,
                            isSmallScreen: isSmallScreen,
                          ),

                          // Tab 4: Rotación
                          InventarioTabsContent(
                            tabType: InventarioTabType.rotacion,
                            isSmallScreen: isSmallScreen,
                          ),

                          // Tab 5: Sugerencias de Compra
                          InventarioTabsContent(
                            tabType: InventarioTabType.sugerencias,
                            isSmallScreen: isSmallScreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar(AppTheme theme, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: isSmallScreen,
        labelColor: theme.primaryColor,
        unselectedLabelColor: theme.secondaryText,
        indicatorColor: theme.primaryColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: theme.bodyText1.override(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: isSmallScreen ? 12 : 14,
        ),
        unselectedLabelStyle: theme.bodyText2.override(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.normal,
          fontSize: isSmallScreen ? 11 : 13,
        ),
        tabs: _tabs
            .map((tab) => Tab(
                  text: tab,
                  height: isSmallScreen ? 40 : 48,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildInventarioConsolidadoTab(
    InventarioGlobalProvider provider,
    bool isSmallScreen,
  ) {
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando inventario global...',
              style: AppTheme.of(context).bodyText1.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.of(context).error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar inventario',
              style: AppTheme.of(context).title3.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: AppTheme.of(context).bodyText2.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.cargarInventarioGlobal(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Reintentar',
                style: AppTheme.of(context).bodyText1.override(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    // Contenido principal del inventario consolidado
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: isSmallScreen
          ? InventarioGlobalCards() // Vista móvil
          : InventarioGlobalTable(provider: provider), // Vista desktop
    );
  }
}
