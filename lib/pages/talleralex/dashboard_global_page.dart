import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/providers/talleralex/navigation_provider.dart';
import 'package:nethive_neo/providers/talleralex/dashboard_global_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/pages/talleralex/widgets/global_sidebar.dart';
import 'package:nethive_neo/pages/talleralex/widgets/responsive_drawer.dart';
import 'package:nethive_neo/pages/talleralex/widgets/dashboard_widgets/dashboard_stats_cards.dart';
import 'package:nethive_neo/pages/talleralex/widgets/dashboard_widgets/dashboard_charts_section.dart';
import 'package:nethive_neo/pages/talleralex/widgets/dashboard_widgets/dashboard_activity_feed.dart';
import 'package:nethive_neo/pages/talleralex/widgets/dashboard_widgets/dashboard_top_sucursales.dart';
import 'package:nethive_neo/pages/talleralex/widgets/dashboard_widgets/dashboard_alerts_section.dart';

class DashboardGlobalPage extends StatefulWidget {
  const DashboardGlobalPage({super.key});

  @override
  State<DashboardGlobalPage> createState() => _DashboardGlobalPageState();
}

class _DashboardGlobalPageState extends State<DashboardGlobalPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Configurar navegación inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TallerAlexNavigationProvider>().irADashboardGlobal();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 1200;

    return ChangeNotifierProvider(
      create: (context) => DashboardGlobalProvider(),
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        drawer: isSmallScreen
            ? Drawer(
                child: ResponsiveDrawer(
                  currentRoute: '/dashboard-global',
                ),
              )
            : null,
        body: Row(
          children: [
            // Sidebar
            if (!isSmallScreen)
              GlobalSidebar(currentRoute: '/dashboard-global'),

            // Contenido principal
            Expanded(
              child: Consumer<DashboardGlobalProvider>(
                builder: (context, dashboardProvider, child) {
                  if (dashboardProvider.isLoading) {
                    return _buildLoadingState(theme);
                  }

                  if (dashboardProvider.error != null) {
                    return _buildErrorState(theme, dashboardProvider.error!);
                  }

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildDashboardContent(
                      context,
                      theme,
                      dashboardProvider,
                      isSmallScreen,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando dashboard global...',
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppTheme theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: theme.error,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar el dashboard',
            style: theme.title3.override(
              fontFamily: 'Poppins',
              color: theme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<DashboardGlobalProvider>().refrescar();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.primaryText,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    AppTheme theme,
    DashboardGlobalProvider provider,
    bool isSmallScreen,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
      ),
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _buildHeader(context, theme, isSmallScreen),
          ),

          // Stats Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: 8,
              ),
              child: DashboardStatsCards(
                provider: provider,
                isLargeScreen:
                    !isSmallScreen && MediaQuery.of(context).size.width > 1400,
                isMediumScreen:
                    !isSmallScreen && MediaQuery.of(context).size.width <= 1400,
                isSmallScreen: isSmallScreen,
              ),
            ),
          ),

          // Charts y Top Sucursales
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: 8,
              ),
              child: isSmallScreen
                  ? Column(
                      children: [
                        DashboardChartsSection(
                          provider: provider,
                          isLargeScreen: false,
                          isMediumScreen: false,
                          isSmallScreen: isSmallScreen,
                        ),
                        const SizedBox(height: 16),
                        DashboardTopSucursales(
                          provider: provider,
                          isSmallScreen: isSmallScreen,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: DashboardChartsSection(
                            provider: provider,
                            isLargeScreen:
                                MediaQuery.of(context).size.width > 1400,
                            isMediumScreen:
                                MediaQuery.of(context).size.width <= 1400,
                            isSmallScreen: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: DashboardTopSucursales(
                            provider: provider,
                            isSmallScreen: false,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Activity Feed y Alertas
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: 8,
              ),
              child: isSmallScreen
                  ? Column(
                      children: [
                        DashboardActivityFeed(
                          isLargeScreen: false,
                          isMediumScreen: false,
                          isSmallScreen: isSmallScreen,
                        ),
                        const SizedBox(height: 16),
                        DashboardAlertsSection(
                          provider: provider,
                          isSmallScreen: isSmallScreen,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: DashboardActivityFeed(
                            isLargeScreen:
                                MediaQuery.of(context).size.width > 1400,
                            isMediumScreen:
                                MediaQuery.of(context).size.width <= 1400,
                            isSmallScreen: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: DashboardAlertsSection(
                            provider: provider,
                            isSmallScreen: false,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Espacio final
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AppTheme theme, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        24,
        isSmallScreen ? 16 : 24,
        16,
      ),
      child: Row(
        children: [
          // Título y subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isSmallScreen)
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.alternate.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: Icon(
                            Icons.menu_rounded,
                            color: theme.primaryText,
                            size: 22,
                          ),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.primaryColor,
                            theme.secondaryColor,
                            theme.tertiaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.dashboard_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'DASHBOARD GLOBAL',
                            style: theme.bodyText1.override(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Visión general de Taller Alex',
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: theme.secondaryText,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),

          // Botones de acción
          if (!isSmallScreen) ...[
            const SizedBox(width: 16),
            _buildActionButton(
              context,
              theme,
              'Refrescar',
              Icons.refresh,
              () => context.read<DashboardGlobalProvider>().refrescar(),
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              context,
              theme,
              'Sucursales',
              Icons.store,
              () => context.go('/sucursales'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    AppTheme theme,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.secondaryBackground,
        foregroundColor: theme.primaryText,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: theme.alternate.withOpacity(0.3)),
        ),
      ),
    );
  }
}
