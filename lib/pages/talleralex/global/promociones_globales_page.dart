import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/providers/talleralex/promociones_globales_provider.dart';
import 'package:nethive_neo/pages/talleralex/widgets/promociones_header.dart';
import 'package:nethive_neo/pages/talleralex/widgets/promociones_tabs.dart';
import 'package:nethive_neo/pages/talleralex/widgets/promociones_tables.dart';
import 'package:nethive_neo/pages/talleralex/widgets/global_sidebar.dart';
import 'package:nethive_neo/pages/talleralex/widgets/responsive_drawer.dart';
import 'package:nethive_neo/pages/talleralex/widgets/promociones_globales_widgets/crear_promocion_modal.dart';
import 'package:nethive_neo/theme/theme.dart';

class PromocionesGlobalesPage extends StatefulWidget {
  const PromocionesGlobalesPage({super.key});

  @override
  State<PromocionesGlobalesPage> createState() =>
      _PromocionesGlobalesPageState();
}

class _PromocionesGlobalesPageState extends State<PromocionesGlobalesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Inicializar datos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<PromocionesGlobalesProvider>(context, listen: false);
      provider.inicializar();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;
    final theme = AppTheme.of(context);
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      drawer: isSmallScreen
          ? Drawer(
              child: ResponsiveDrawer(
                currentRoute: currentLocation,
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar
          if (!isSmallScreen) GlobalSidebar(currentRoute: currentLocation),

          // Contenido principal
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.primaryBackground,
                    theme.primaryBackground.withOpacity(0.8),
                  ],
                ),
              ),
              child: Consumer<PromocionesGlobalesProvider>(
                builder: (context, provider, child) {
                  return CustomScrollView(
                    slivers: [
                      // Header con efectos visuales mejorados
                      SliverToBoxAdapter(
                        child: _buildHeader(context, theme, isSmallScreen),
                      ),

                      // Contenido principal
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16 : 32,
                            vertical: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header con filtros y KPIs
                              PromocionesHeader(
                                onCrearPromocion: _onCrearPromocion,
                                onRefresh: _onRefresh,
                              ),

                              const SizedBox(height: 24),

                              // TabBar personalizado
                              PromocionesTabBar(
                                tabController: _tabController,
                                onTabChanged: (index) {
                                  setState(() {
                                    _selectedTabIndex = index;
                                  });
                                },
                              ),

                              const SizedBox(height: 16),

                              // Contenido de pestañas
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: 600,
                                  maxHeight:
                                      MediaQuery.of(context).size.height - 300,
                                ),
                                child: _buildTabContent(provider),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AppTheme theme, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 32,
        24,
        isSmallScreen ? 16 : 32,
        16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.secondaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        children: [
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
                          boxShadow: theme.neumorphicShadows,
                        ),
                        child: IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
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
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.local_offer_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Promociones Globales',
                            style: theme.bodyText1.override(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 16 : 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Gestiona promociones corporativas y cupones para todas las sucursales',
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: theme.secondaryText,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
          if (!isSmallScreen) ...[
            const SizedBox(width: 24),
            _buildActionButtons(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppTheme theme) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => context.go('/dashboard-global'),
          icon: const Icon(Icons.dashboard_rounded, size: 18),
          label: const Text('Dashboard'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.secondaryBackground,
            foregroundColor: theme.primaryText,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadowColor: theme.primaryColor.withOpacity(0.3),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _onCrearPromocion,
          icon: const Icon(Icons.add_circle_rounded, size: 18),
          label: const Text('Nueva Promoción'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadowColor: theme.primaryColor.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(PromocionesGlobalesProvider provider) {
    switch (_selectedTabIndex) {
      case 0: // Promociones Activas
        return _buildPromocionesActivasContent(provider);
      case 1: // Gestión
        return _buildGestionContent(provider);
      case 2: // Cupones
        return _buildCuponesContent(provider);
      case 3: // ROI
        return _buildROIContent(provider);
      default:
        return _buildPromocionesActivasContent(provider);
    }
  }

  Widget _buildPromocionesActivasContent(PromocionesGlobalesProvider provider) {
    final theme = AppTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.1),
            offset: const Offset(0, 8),
            blurRadius: 25,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            offset: const Offset(-4, -4),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header de la pestaña
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withOpacity(0.05),
                  theme.secondaryColor.withOpacity(0.03),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(
                  color: theme.primaryColor.withOpacity(0.1),
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066CC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.campaign,
                    color: Color(0xFF0066CC),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promociones Activas',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A0A0A),
                        ),
                      ),
                      Text(
                        'Gestiona las promociones publicadas en tus sucursales (${provider.promocionesActivasFiltradas.length} promociones)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildContenidoPromocionesActivas(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenidoPromocionesActivas(
      PromocionesGlobalesProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0066CC)),
            ),
            SizedBox(height: 16),
            Text('Cargando promociones...'),
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
              size: 48,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar las promociones',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066CC),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.promocionesActivasFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay promociones activas',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera promoción para comenzar',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _onCrearPromocion,
              icon: const Icon(Icons.add),
              label: const Text('Crear Promoción'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066CC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return PromocionesActivasTable(
      onEditarPromocion: _onEditarPromocion,
      onPublicarPromocion: _onPublicarPromocion,
      onEmitirCupones: _onEmitirCupones,
      onEliminarPromocion: _onEliminarPromocion,
    );
  }

  Widget _buildGestionContent(PromocionesGlobalesProvider provider) {
    return PromocionesTabContent(
      selectedTab: 1,
      onCrearPromocion: _onCrearPromocion,
      onEditarPromocion: _onEditarPromocion,
    );
  }

  Widget _buildCuponesContent(PromocionesGlobalesProvider provider) {
    final theme = AppTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.tertiaryColor.withOpacity(0.15),
            offset: const Offset(0, 8),
            blurRadius: 25,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            offset: const Offset(-4, -4),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.qr_code,
                    color: Color(0xFFFF6B00),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cupones y Códigos QR',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A0A0A),
                        ),
                      ),
                      Text(
                        'Gestiona cupones individuales y códigos QR (${provider.cupones.length} cupones)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: provider.cupones.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.qr_code_outlined,
                      title: 'No hay cupones disponibles',
                      subtitle:
                          'Los cupones se generan desde las promociones activas',
                      buttonText: 'Ver Promociones',
                      onButtonPressed: () {
                        _tabController.animateTo(0);
                      },
                    )
                  : CuponesTable(
                      onGenerarQR: _onGenerarQR,
                      onDescargarQR: _onDescargarQR,
                      onProbarCanje: _onProbarCanje,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildROIContent(PromocionesGlobalesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2D95).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Color(0xFFFF2D95),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Análisis de ROI',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A0A0A),
                        ),
                      ),
                      Text(
                        'Rendimiento y métricas de tus promociones (${provider.promocionesROI.length} registros)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: provider.promocionesROI.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.trending_up_outlined,
                      title: 'No hay datos de ROI disponibles',
                      subtitle:
                          'Los datos aparecerán cuando las promociones tengan canjes',
                      buttonText: 'Actualizar Datos',
                      onButtonPressed: () => provider.cargarPromocionesROI(),
                    )
                  : PromocionesROITable(
                      onVerDetalle: _onVerDetalleROI,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066CC),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // =======================================
  // MÉTODOS DE ACCIONES
  // =======================================

  void _onCrearPromocion() {
    _showCrearPromocionModal();
  }

  void _onEditarPromocion() {
    // TODO: Implementar modal de editar promoción
    _showNotImplementedDialog('Editar Promoción');
  }

  void _onPublicarPromocion(String promocionId) {
    // TODO: Implementar modal de publicar promoción
    _showNotImplementedDialog('Publicar Promoción');
  }

  void _onEmitirCupones(String promocionId) {
    // TODO: Implementar modal de emitir cupones
    _showNotImplementedDialog('Emitir Cupones');
  }

  void _onEliminarPromocion(String promocionId) {
    // TODO: Implementar confirmación de eliminación
    _showNotImplementedDialog('Eliminar Promoción');
  }

  void _onGenerarQR(String cuponId) {
    // TODO: Implementar modal de QR
    _showNotImplementedDialog('Generar QR');
  }

  void _onDescargarQR(String cuponId) {
    // TODO: Implementar descarga de QR
    _showNotImplementedDialog('Descargar QR');
  }

  void _onProbarCanje(String cuponId) {
    // TODO: Implementar modal de probar canje
    _showNotImplementedDialog('Probar Canje');
  }

  void _onVerDetalleROI(String promocionId) {
    // TODO: Implementar modal de detalle ROI
    _showNotImplementedDialog('Ver Detalle ROI');
  }

  void _onRefresh() {
    final provider =
        Provider.of<PromocionesGlobalesProvider>(context, listen: false);
    provider.refrescar();
  }

  void _showCrearPromocionModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CrearPromocionModal(),
    );
  }

  void _showNotImplementedDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Color(0xFF0066CC),
            ),
            const SizedBox(width: 8),
            Text(
              'Función en Desarrollo',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'La función "$feature" está en desarrollo y estará disponible próximamente.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendido',
              style: GoogleFonts.poppins(
                color: const Color(0xFF0066CC),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
