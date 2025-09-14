import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/clientes_globales_provider.dart';
import 'package:nethive_neo/providers/talleralex/navigation_provider.dart';
import 'package:nethive_neo/pages/talleralex/widgets/clientes_globales_table.dart';
import 'package:nethive_neo/pages/talleralex/widgets/clientes_globales_cards.dart';
import 'package:nethive_neo/pages/talleralex/widgets/global_sidebar.dart';
import 'package:nethive_neo/pages/talleralex/widgets/responsive_drawer.dart';
import 'package:nethive_neo/pages/talleralex/widgets/clientes_globales_widgets/clientes_globales_widgets.dart';

class ClientesGlobalesPage extends StatefulWidget {
  const ClientesGlobalesPage({super.key});

  @override
  State<ClientesGlobalesPage> createState() => _ClientesGlobalesPageState();
}

class _ClientesGlobalesPageState extends State<ClientesGlobalesPage> {
  late ClientesGlobalesProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<ClientesGlobalesProvider>();

    // Navegar a capa global y cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TallerAlexNavigationProvider>().irADashboardGlobal();
      _provider.cargarClientesGlobales();
      _provider.cargarMetricasGlobales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;
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
          // Sidebar global
          if (!isSmallScreen) GlobalSidebar(currentRoute: currentLocation),

          // Contenido principal
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
              ),
              child: Consumer<ClientesGlobalesProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      // Header con métricas y filtros
                      _buildHeader(context, theme, provider, isSmallScreen),

                      // Contenido principal
                      Expanded(
                        child: _buildContent(
                            context, theme, provider, isSmallScreen),
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

  Widget _buildHeader(BuildContext context, AppTheme theme,
      ClientesGlobalesProvider provider, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.secondaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y botón de acciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Botón de menú para pantallas pequeñas
                  if (isSmallScreen)
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  // Título
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clientes Globales',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Base unificada de clientes y análisis integral',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  // Botón de actualizar
                  ElevatedButton.icon(
                    onPressed: provider.isLoading
                        ? null
                        : () {
                            provider.cargarClientesGlobales();
                            provider.cargarMetricasGlobales();
                          },
                    icon: provider.isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.primaryColor,
                              ),
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: const Text('Actualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Botón de filtros
                  ElevatedButton.icon(
                    onPressed: () => _mostrarFiltros(context, provider),
                    icon: Stack(
                      children: [
                        const Icon(Icons.filter_list),
                        if (provider.tieneFiltrosActivos)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: const Text('Filtros'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: theme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Dashboard de métricas
          _buildDashboardMetricas(theme, provider),
        ],
      ),
    );
  }

  Widget _buildDashboardMetricas(
      AppTheme theme, ClientesGlobalesProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    if (provider.metricas == null) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    final metricas = provider.metricas!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: isSmallScreen
          ? _buildMetricasMobile(metricas)
          : _buildMetricasDesktop(metricas),
    );
  }

  Widget _buildMetricasDesktop(dynamic metricas) {
    return Row(
      children: [
        _buildMetricaCard(
          'Total Clientes',
          metricas.totalClientes.toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildMetricaCard(
          'VIP',
          _provider.clientesVIP.toString(),
          Icons.star,
          Colors.amber,
        ),
        _buildMetricaCard(
          'Activos',
          _provider.clientesActivos.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildMetricaCard(
          'Ingresos Totales',
          metricas.ingresosTotalesTexto,
          Icons.attach_money,
          Colors.purple,
        ),
        _buildMetricaCard(
          'Órdenes Abiertas',
          metricas.ordenesAbiertas.toString(),
          Icons.trending_up,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildMetricasMobile(dynamic metricas) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricaCard(
                'Total',
                metricas.totalClientes.toString(),
                Icons.people,
                Colors.blue,
                isSmall: true,
              ),
            ),
            Expanded(
              child: _buildMetricaCard(
                'VIP',
                _provider.clientesVIP.toString(),
                Icons.star,
                Colors.amber,
                isSmall: true,
              ),
            ),
            Expanded(
              child: _buildMetricaCard(
                'Activos',
                _provider.clientesActivos.toString(),
                Icons.check_circle,
                Colors.green,
                isSmall: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricaCard(
                'Ingresos',
                metricas.ingresosTotalesTexto,
                Icons.attach_money,
                Colors.purple,
                isSmall: true,
              ),
            ),
            Expanded(
              child: _buildMetricaCard(
                'Órdenes',
                '${metricas.ordenesAbiertas}/${metricas.ordenesCerradas}',
                Icons.trending_up,
                Colors.orange,
                isSmall: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricaCard(
    String titulo,
    String valor,
    IconData icono,
    Color color, {
    bool isSmall = false,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icono,
                  color: color,
                  size: isSmall ? 16 : 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    titulo,
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 11 : 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              valor,
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 16 : 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppTheme theme,
    ClientesGlobalesProvider provider,
    bool isSmallScreen,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.5),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra de herramientas
          _buildToolbar(context, theme, provider, isSmallScreen),

          // Contenido de la tabla/cards
          Expanded(
            child: isSmallScreen
                ? ClientesGlobalesCardsView(provider: provider)
                : ClientesGlobalesTable(
                    provider: provider,
                    onVerDetalle: _verDetalleCliente,
                    onMostrarOpciones: _mostrarOpcionesCliente,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    AppTheme theme,
    ClientesGlobalesProvider provider,
    bool isSmallScreen,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Buscador
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    onChanged: provider.buscarClientes,
                    decoration: InputDecoration(
                      hintText:
                          'Buscar cliente por nombre, teléfono o email...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),

              if (!isSmallScreen) ...[
                const SizedBox(width: 16),

                // Selector de clasificación
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<String>(
                    value: provider.filtros.clasificacionSeleccionada,
                    onChanged: provider.filtrarPorClasificacion,
                    underline: const SizedBox(),
                    hint: const Text('Clasificación'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todas')),
                      DropdownMenuItem(value: 'VIP', child: Text('VIP')),
                      DropdownMenuItem(
                          value: 'Premium', child: Text('Premium')),
                      DropdownMenuItem(
                          value: 'Frecuente', child: Text('Frecuente')),
                      DropdownMenuItem(
                          value: 'Ocasional', child: Text('Ocasional')),
                      DropdownMenuItem(value: 'Nuevo', child: Text('Nuevo')),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Selector de estado
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<String>(
                    value: provider.filtros.estadoSeleccionado,
                    onChanged: provider.filtrarPorEstado,
                    underline: const SizedBox(),
                    hint: const Text('Estado'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todos')),
                      DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                      DropdownMenuItem(
                          value: 'Regular', child: Text('Regular')),
                      DropdownMenuItem(
                          value: 'En riesgo', child: Text('En riesgo')),
                      DropdownMenuItem(
                          value: 'Inactivo', child: Text('Inactivo')),
                    ],
                  ),
                ),
              ],
            ],
          ),

          if (isSmallScreen) ...[
            const SizedBox(height: 12),

            // Filtros móviles
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: provider.filtros.clasificacionSeleccionada,
                      onChanged: provider.filtrarPorClasificacion,
                      underline: const SizedBox(),
                      hint: const Text('Clasificación'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Todas')),
                        DropdownMenuItem(value: 'VIP', child: Text('VIP')),
                        DropdownMenuItem(
                            value: 'Premium', child: Text('Premium')),
                        DropdownMenuItem(
                            value: 'Frecuente', child: Text('Frecuente')),
                        DropdownMenuItem(
                            value: 'Ocasional', child: Text('Ocasional')),
                        DropdownMenuItem(value: 'Nuevo', child: Text('Nuevo')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: provider.filtros.estadoSeleccionado,
                      onChanged: provider.filtrarPorEstado,
                      underline: const SizedBox(),
                      hint: const Text('Estado'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Todos')),
                        DropdownMenuItem(
                            value: 'Activo', child: Text('Activo')),
                        DropdownMenuItem(
                            value: 'Regular', child: Text('Regular')),
                        DropdownMenuItem(
                            value: 'En riesgo', child: Text('En riesgo')),
                        DropdownMenuItem(
                            value: 'Inactivo', child: Text('Inactivo')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Resumen de filtros aplicados
          if (provider.tieneFiltrosActivos) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mostrando ${provider.clientesFiltrados.length} de ${provider.clientes.length} clientes',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: provider.limpiarFiltros,
                  child: Text(
                    'Limpiar filtros',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _mostrarFiltros(
      BuildContext context, ClientesGlobalesProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    if (isDesktop) {
      // Desktop: Mostrar diálogo lateral moderno
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => FiltrosAvanzadosDialog(provider: provider),
      );
    } else {
      // Mantener bottom sheet para móvil como fallback
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => FiltrosAvanzadosDialog(provider: provider),
      );
    }
  }

  void _verDetalleCliente(dynamic cliente) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ClienteDetalleDialog(
        clienteId: cliente.clienteId,
        provider: _provider,
      ),
    );
  }

  void _mostrarOpcionesCliente(dynamic cliente) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ClienteOpcionesDialog(
        cliente: cliente,
        onVerDetalle: () => _verDetalleCliente(cliente),
        onEditarCliente: () => _editarCliente(cliente),
        onCrearCita: () => _crearCitaCliente(cliente),
      ),
    );
  }

  void _editarCliente(dynamic cliente) {
    // TODO: Implementar edición de cliente
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              'Función de edición en desarrollo para: ${cliente.clienteNombre}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _crearCitaCliente(dynamic cliente) {
    // TODO: Implementar creación de cita
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              'Creando cita para: ${cliente.clienteNombre}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
