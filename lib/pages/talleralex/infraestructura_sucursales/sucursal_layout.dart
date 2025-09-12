import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/providers/talleralex/navigation_provider.dart';
import 'package:nethive_neo/providers/talleralex/sucursal_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/sucursal_header.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/sucursal_sidebar.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/pages/dashboard/dashboard_sucursal_page.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/pages/agenda/agenda_bahias_page.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/pages/empleados/empleados_page.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/pages/clientes/clientes_page.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/pages/citas_ordenes/citas_ordenes_page.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/pages/inventario/inventario_page.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/pages/pagos/pagos_page.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/pages/promociones/promociones_page.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/pages/reportes/reportes_page.dart';

class SucursalLayout extends StatefulWidget {
  final String sucursalId;

  const SucursalLayout({
    super.key,
    required this.sucursalId,
  });

  @override
  State<SucursalLayout> createState() => _SucursalLayoutState();
}

class _SucursalLayoutState extends State<SucursalLayout>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Cargar datos de la sucursal e inicializar dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SucursalProvider>().cargarSucursal(widget.sucursalId);

      // Establecer dashboard como módulo por defecto
      final navProvider = context.read<TallerAlexNavigationProvider>();
      if (navProvider.moduloActual != TallerAlexModulo.dashboard) {
        navProvider.cambiarModulo(TallerAlexModulo.dashboard);
      }

      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    return ChangeNotifierProvider(
      create: (context) => SucursalProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F0F3),
        drawer: isSmallScreen
            ? Drawer(
                child: SucursalSidebar(sucursalId: widget.sucursalId),
              )
            : null,
        body: Consumer<SucursalProvider>(
          builder: (context, sucursalProvider, child) {
            if (sucursalProvider.isLoading) {
              return _buildLoadingState(theme);
            }

            if (sucursalProvider.error != null) {
              return _buildErrorState(theme, sucursalProvider.error!);
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header personalizado
                  SucursalHeader(sucursalId: widget.sucursalId),

                  // Contenido principal
                  Expanded(
                    child: Row(
                      children: [
                        // Sidebar (solo en desktop)
                        if (!isSmallScreen)
                          SucursalSidebar(sucursalId: widget.sucursalId),

                        // Contenido principal
                        Expanded(
                          child: _buildMainContent(context, theme),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppTheme theme) {
    return Container(
      color: const Color(0xFFF0F0F3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F3),
                borderRadius: BorderRadius.circular(24),
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
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.primaryColor,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando sucursal...',
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      color: theme.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AppTheme theme, String error) {
    return Container(
      color: const Color(0xFFF0F0F3),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F3),
            borderRadius: BorderRadius.circular(24),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: theme.error,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Error al cargar la sucursal',
                style: theme.title3.override(
                  fontFamily: 'Poppins',
                  color: theme.primaryText,
                  fontWeight: FontWeight.bold,
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
              InkWell(
                onTap: () {
                  context
                      .read<SucursalProvider>()
                      .cargarSucursal(widget.sucursalId);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Reintentar',
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, AppTheme theme) {
    return Consumer<TallerAlexNavigationProvider>(
      builder: (context, navProvider, child) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del módulo actual con gradiente
              /*      ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.secondaryColor,
                  ],
                ).createShader(bounds),
                child: Text(
                  navProvider.getNombreModulo(navProvider.moduloActual),
                  style: theme.title1.override(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Gestión avanzada de ${navProvider.getNombreModulo(navProvider.moduloActual).toLowerCase()}',
                style: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  color: theme.secondaryText,
                  fontSize: 16,
                ),
              ), */

              /*      const SizedBox(height: 32), */

              // Contenido del módulo
              Expanded(
                child: _buildModuleContent(
                  context,
                  theme,
                  navProvider.moduloActual,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModuleContent(
    BuildContext context,
    AppTheme theme,
    TallerAlexModulo modulo,
  ) {
    // Contenido específico para el dashboard
    if (modulo == TallerAlexModulo.dashboard) {
      return DashboardSucursalPage(sucursalId: widget.sucursalId);
    }

    // Contenido específico para agenda/bahías
    if (modulo == TallerAlexModulo.agenda) {
      return AgendaBahiasPage(sucursalId: widget.sucursalId);
    }

    // Contenido específico para empleados
    if (modulo == TallerAlexModulo.empleados) {
      return EmpleadosPage(sucursalId: widget.sucursalId);
    }

    // Contenido específico para clientes
    if (modulo == TallerAlexModulo.clientes) {
      return ClientesPage(sucursalId: widget.sucursalId);
    }

    // Contenido específico para citas y órdenes
    if (modulo == TallerAlexModulo.citas) {
      return CitasOrdenesPage(sucursalId: widget.sucursalId);
    }

    // Contenido específico para inventario
    if (modulo == TallerAlexModulo.inventario) {
      return InventarioPage(sucursalId: widget.sucursalId);
    }

    // Contenido específico para pagos y facturación
    if (modulo == TallerAlexModulo.pagos) {
      return PagosPage(sucursalId: widget.sucursalId);
    }

    // Contenido específico para promociones
    if (modulo == TallerAlexModulo.promociones) {
      return PromocionesPage(sucursalId: widget.sucursalId);
    }

    // Contenido específico para reportes locales
    if (modulo == TallerAlexModulo.reportes) {
      return ReportesPage(sucursalId: widget.sucursalId);
    }

    // Placeholder para otros módulos
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-12, -12),
            blurRadius: 24,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(12, 12),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono del módulo con animación
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor,
                  theme.secondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              context
                  .read<TallerAlexNavigationProvider>()
                  .getIconoModulo(modulo),
              color: Colors.white,
              size: 64,
            ),
          ),

          const SizedBox(height: 32),

          // Título del módulo
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                theme.primaryColor,
                theme.secondaryColor,
              ],
            ).createShader(bounds),
            child: Text(
              'Módulo ${context.read<TallerAlexNavigationProvider>().getNombreModulo(modulo)}',
              style: theme.title2.override(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Descripción
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              _getDescripcionModulo(modulo),
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                color: theme.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Botón de desarrollo
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.secondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.construction,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'En desarrollo',
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDescripcionModulo(TallerAlexModulo modulo) {
    switch (modulo) {
      case TallerAlexModulo.dashboard:
        return 'Panel de control con métricas en tiempo real, estado de bahías, alertas de inventario y resúmenes de actividad diaria.';
      case TallerAlexModulo.agenda:
        return 'Gestión visual de citas por bahía, asignación de técnicos, programación de servicios y control de disponibilidad.';
      case TallerAlexModulo.empleados:
        return 'Administración de personal, turnos, especialidades, rendimiento y asignaciones por sucursal.';
      case TallerAlexModulo.clientes:
        return 'Base completa de clientes con historial de servicios, vehículos asociados y seguimiento de satisfacción.';
      case TallerAlexModulo.citas:
        return 'Control integral de citas y órdenes de servicio, desde diagnóstico hasta entrega del vehículo.';
      case TallerAlexModulo.inventario:
        return 'Gestión de refacciones, control de stock, alertas de mínimos, movimientos y análisis de rotación.';
      case TallerAlexModulo.pagos:
        return 'Procesamiento de pagos, generación de facturas, cuentas por cobrar y reportes financieros.';
      case TallerAlexModulo.promociones:
        return 'Creación y gestión de promociones, cupones de descuento y campañas de marketing.';
      case TallerAlexModulo.reportes:
        return 'Análisis avanzado con reportes operacionales, financieros y de satisfacción del cliente.';
      case TallerAlexModulo.configuracion:
        return 'Configuración específica de la sucursal: servicios, precios, horarios y personal autorizado.';
      default:
        return 'Módulo especializado para la gestión eficiente de su taller automotriz.';
    }
  }
}
