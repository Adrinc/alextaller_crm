import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/providers/talleralex/sucursales_provider.dart';
import 'package:nethive_neo/providers/talleralex/navigation_provider.dart';
import 'package:nethive_neo/pages/talleralex/widgets/sucursal_selector_sidebar.dart';
import 'package:nethive_neo/pages/talleralex/widgets/sucursales_table.dart';
import 'package:nethive_neo/pages/talleralex/widgets/sucursales_cards_view.dart';
import 'package:nethive_neo/pages/talleralex/widgets/sucursales_map_view.dart';
import 'package:nethive_neo/theme/theme.dart';

class SucursalesPage extends StatefulWidget {
  const SucursalesPage({super.key});

  @override
  State<SucursalesPage> createState() => _SucursalesPageState();
}

class _SucursalesPageState extends State<SucursalesPage>
    with TickerProviderStateMixin {
  bool showMapView = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Configurar navegación y cargar datos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TallerAlexNavigationProvider>().irASelectorSucursales();
      context.read<SucursalesProvider>().cargarSucursales();
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F3), // Fondo blanco neumórfico
      body: Container(
        color: const Color(0xFFF0F0F3), // Fondo blanco neumórfico
        child: Consumer<SucursalesProvider>(
          builder: (context, provider, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: isLargeScreen
                    ? _buildDesktopLayout(provider)
                    : _buildMobileLayout(provider),
              ),
            );
          },
        ),
      ),
      // FAB para vista móvil
      floatingActionButton: MediaQuery.of(context).size.width <= 800
          ? _buildMobileFAB(context)
          : null,
    );
  }

  Widget _buildDesktopLayout(SucursalesProvider provider) {
    return Row(
      children: [
        // Sidebar de sucursales
        SizedBox(
          width: 350,
          child: SucursalSelectorSidebar(
            provider: provider,
            onSucursalSelected: (sucursalId) {
              final navigationProvider =
                  context.read<TallerAlexNavigationProvider>();
              navigationProvider.setSucursalSeleccionada(sucursalId);
            },
          ),
        ),

        // Contenido principal
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: _buildMainContent(provider),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(SucursalesProvider provider) {
    return Column(
      children: [
        _buildEnhancedHeader(provider),
        const SizedBox(height: 16),
        Expanded(
          child: _buildCurrentView(provider),
        ),
      ],
    );
  }

  Widget _buildCurrentView(SucursalesProvider provider) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;

    if (showMapView) {
      return _buildMapView();
    } else {
      // En pantallas grandes mostrar tabla, en móviles mostrar cards
      if (isLargeScreen) {
        return _buildTableView(provider);
      } else {
        return SucursalesCardsView(provider: provider);
      }
    }
  }

  Widget _buildMobileLayout(SucursalesProvider provider) {
    return Column(
      children: [
        _buildMobileHeader(provider),
        Expanded(
          child: _buildCurrentView(provider),
        ),
      ],
    );
  }

  Widget _buildEnhancedHeader(SucursalesProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-8, -8),
            blurRadius: 16,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(8, 8),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón de regresar neumórfico
          InkWell(
            onTap: () => context.go('/'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F3),
                borderRadius: BorderRadius.circular(12),
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
              child: Icon(
                Icons.arrow_back,
                color: AppTheme.of(context).primaryColor,
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Información del header
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F3),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(-3, -3),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.grey.shade400.withOpacity(0.4),
                            offset: const Offset(3, 3),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.store,
                        color: AppTheme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sucursales',
                      style: AppTheme.of(context).title2.override(
                            fontFamily: 'Poppins',
                            color: AppTheme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  provider.sucursales.isNotEmpty
                      ? '${provider.sucursales.length} sucursales registradas'
                      : 'No hay sucursales registradas',
                  style: AppTheme.of(context).bodyText2.override(
                        fontFamily: 'Poppins',
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ],
            ),
          ),

          // Toggle de vista neumórfico
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F3),
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
            child: Column(
              children: [
                _buildViewToggleButton(
                  icon: showMapView ? Icons.map : Icons.table_chart,
                  label: showMapView ? 'Mapa' : 'Tabla',
                  isSelected: true,
                  onTap: () => setState(() => showMapView = !showMapView),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.grey.shade400.withOpacity(0.4),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.white,
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.grey.shade400.withOpacity(0.4),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.of(context).primaryColor
                  : AppTheme.of(context).secondaryText,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.of(context).bodyText2.override(
                    fontFamily: 'Poppins',
                    color: isSelected
                        ? AppTheme.of(context).primaryColor
                        : AppTheme.of(context).secondaryText,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader(SucursalesProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      decoration: BoxDecoration(
        gradient: AppTheme.of(context).primaryGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => context.go('/'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppTheme.of(context).primaryText,
                    size: 24,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewToggleButton(
                      icon: Icons.map,
                      label: 'Mapa',
                      isSelected: showMapView,
                      onTap: () => setState(() => showMapView = true),
                    ),
                    _buildViewToggleButton(
                      icon: Icons.table_rows,
                      label: 'Tabla',
                      isSelected: !showMapView,
                      onTap: () => setState(() => showMapView = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.store,
                color: AppTheme.of(context).primaryText,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Sucursales',
                style: AppTheme.of(context).title1.override(
                      fontFamily: 'Poppins',
                      color: AppTheme.of(context).primaryText,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            provider.sucursales.isNotEmpty
                ? '${provider.sucursales.length} sucursales registradas'
                : 'No hay sucursales registradas',
            style: AppTheme.of(context).bodyText2.override(
                  fontFamily: 'Poppins',
                  color: AppTheme.of(context).primaryText.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(SucursalesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header de tabla
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.of(context).tertiaryBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.table_rows,
                  color: AppTheme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Lista de Sucursales',
                  style: AppTheme.of(context).title3.override(
                        fontFamily: 'Poppins',
                        color: AppTheme.of(context).primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${provider.sucursales.length} sucursales',
                    style: AppTheme.of(context).bodyText2.override(
                          fontFamily: 'Poppins',
                          color: AppTheme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Tabla de sucursales
          Expanded(
            child: provider.sucursales.isEmpty
                ? _buildEmptyTableState()
                : SucursalesTable(provider: provider),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTableState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: AppTheme.of(context).secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay sucursales registradas',
            style: AppTheme.of(context).title3.override(
                  fontFamily: 'Poppins',
                  color: AppTheme.of(context).primaryText,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera sucursal para comenzar',
            style: AppTheme.of(context).bodyText2.override(
                  fontFamily: 'Poppins',
                  color: AppTheme.of(context).secondaryText,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Consumer<SucursalesProvider>(
      builder: (context, provider, child) {
        return SucursalesMapView(provider: provider);
      },
    );
  }

  Widget _buildMobileFAB(BuildContext context) {
    return Consumer<SucursalesProvider>(
      builder: (context, provider, child) {
        return FloatingActionButton.extended(
          onPressed: () {
            // TODO: Implementar selector móvil
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selector móvil en desarrollo'),
              ),
            );
          },
          backgroundColor: AppTheme.of(context).primaryColor,
          icon: Icon(
            Icons.store,
            color: AppTheme.of(context).primaryText,
          ),
          label: Text(
            'Sucursales',
            style: AppTheme.of(context).bodyText1.override(
                  fontFamily: 'Poppins',
                  color: AppTheme.of(context).primaryText,
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      },
    );
  }
}
