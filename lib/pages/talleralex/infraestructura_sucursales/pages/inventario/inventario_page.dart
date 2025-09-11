import 'package:flutter/material.dart';
import 'package:nethive_neo/models/talleralex/inventario_models.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/alertas_inventario_table.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/historial_refacciones_table.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/inventario_table.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/inventario_provider.dart';
/* import '../../../shared/widgets/inventario_table.dart';
import '../../../shared/widgets/alertas_inventario_table.dart';
import '../../../shared/widgets/historial_refacciones_table.dart'; */

class InventarioPage extends StatefulWidget {
  final String sucursalId;

  const InventarioPage({
    super.key,
    required this.sucursalId,
  });

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late InventarioProvider _provider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _provider = InventarioProvider();

    // Cargar datos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.cargarDatos(widget.sucursalId);
    });

    // Listener para cambios de tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _provider.cambiarTab(_tabController.index);
      }
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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 1200;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<InventarioProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState(theme);
          }

          if (provider.error != null) {
            return _buildErrorState(theme, provider.error!);
          }

          return Column(
            children: [
              // Header con KPIs
              _buildKPIHeader(theme, provider, isSmallScreen),

              const SizedBox(height: 24),

              // Tabs y filtros
              _buildTabsAndFilters(theme, provider, isSmallScreen),

              const SizedBox(height: 16),

              // Contenido principal
              Expanded(
                child: _buildTabContent(theme, provider),
              ),
            ],
          );
        },
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
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-8, -8),
                    blurRadius: 16,
                  ),
                  BoxShadow(
                    color: Colors.grey.shade400.withOpacity(0.4),
                    offset: const Offset(8, 8),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: theme.primaryColor,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando inventario...',
                    style: TextStyle(
                      color: theme.primaryText,
                      fontFamily: 'Poppins',
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
              const BoxShadow(
                color: Colors.white,
                offset: Offset(-8, -8),
                blurRadius: 16,
              ),
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.4),
                offset: const Offset(8, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: theme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar inventario',
                style: theme.title3.override(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: theme.bodyText2.override(
                  color: theme.secondaryText,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _provider.refrescarDatos(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPIHeader(
      AppTheme theme, InventarioProvider provider, bool isSmallScreen) {
    final kpis = provider.kpis;
    if (kpis == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(8, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventario de Refacciones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryText,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Gestión completa de stock y alertas',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.secondaryText,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => provider.refrescarDatos(),
                icon: Icon(
                  Icons.refresh,
                  color: theme.primaryColor,
                ),
                tooltip: 'Actualizar datos',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // KPIs en cards
          if (isSmallScreen)
            Column(
              children: _buildKPICards(theme, kpis),
            )
          else
            Row(
              children: _buildKPICards(theme, kpis)
                  .map((card) => Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: card,
                      )))
                  .toList(),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildKPICards(AppTheme theme, KPIsInventario kpis) {
    return [
      _buildKPICard(
        theme,
        'Total Refacciones',
        kpis.totalRefacciones.toString(),
        Icons.inventory_2,
        Colors.blue,
        subtitle: '${kpis.refaccionesActivas} activas',
      ),
      _buildKPICard(
        theme,
        'En Alerta',
        kpis.refaccionesEnAlerta.toString(),
        Icons.warning,
        Colors.orange,
        subtitle: kpis.porcentajeEnAlertaTexto,
      ),
      _buildKPICard(
        theme,
        'Valor Total',
        kpis.valorTotalTexto,
        Icons.attach_money,
        Colors.green,
        subtitle: 'Stock activo',
      ),
      _buildKPICard(
        theme,
        'Movimientos 30d',
        kpis.movimientosUltimos30Dias.toString(),
        Icons.trending_up,
        Colors.purple,
        subtitle: 'Últimos días',
      ),
    ];
  }

  Widget _buildKPICard(
      AppTheme theme, String title, String value, IconData icon, Color color,
      {String? subtitle}) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.secondaryText,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryText,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontFamily: 'Poppins',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabsAndFilters(
      AppTheme theme, InventarioProvider provider, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(8, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: theme.primaryColor,
            unselectedLabelColor: theme.secondaryText,
            indicatorColor: theme.primaryColor,
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(
                icon: const Icon(Icons.inventory),
                text: 'Inventario (${provider.refaccionesFiltradas.length})',
              ),
              Tab(
                icon: const Icon(Icons.warning),
                text: 'Alertas (${provider.refaccionesEnAlerta.length})',
              ),
              Tab(
                icon: const Icon(Icons.history),
                text: 'Historial (${provider.historialFiltrado.length})',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Filtros según el tab activo
          _buildActiveTabFilters(theme, provider, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildActiveTabFilters(
      AppTheme theme, InventarioProvider provider, bool isSmallScreen) {
    switch (provider.tabSeleccionado) {
      case 0: // Inventario
        return _buildInventarioFilters(theme, provider, isSmallScreen);
      case 1: // Alertas
        return const SizedBox
            .shrink(); // Las alertas no necesitan filtros adicionales
      case 2: // Historial
        return _buildHistorialFilters(theme, provider, isSmallScreen);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInventarioFilters(
      AppTheme theme, InventarioProvider provider, bool isSmallScreen) {
    if (isSmallScreen) {
      return Column(
        children: [
          _buildSearchField(theme, provider),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildEstadoFilter(theme, provider)),
              const SizedBox(width: 8),
              Expanded(child: _buildAlertaFilter(theme, provider)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildProveedorFilter(theme, provider)),
              const SizedBox(width: 8),
              _buildClearFiltersButton(theme, provider),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 3, child: _buildSearchField(theme, provider)),
        const SizedBox(width: 12),
        Expanded(child: _buildEstadoFilter(theme, provider)),
        const SizedBox(width: 12),
        Expanded(child: _buildAlertaFilter(theme, provider)),
        const SizedBox(width: 12),
        Expanded(child: _buildProveedorFilter(theme, provider)),
        const SizedBox(width: 12),
        _buildClearFiltersButton(theme, provider),
      ],
    );
  }

  Widget _buildHistorialFilters(
      AppTheme theme, InventarioProvider provider, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Período: ${provider.rangoFechas.start.day}/${provider.rangoFechas.start.month} - ${provider.rangoFechas.end.day}/${provider.rangoFechas.end.month}',
            style: TextStyle(
              color: theme.secondaryText,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _selectDateRange(provider),
          icon: const Icon(Icons.date_range, size: 16),
          label: const Text('Cambiar período'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(AppTheme theme, InventarioProvider provider) {
    return TextFormField(
      onChanged: provider.aplicarFiltroTexto,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, SKU, descripción...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildEstadoFilter(AppTheme theme, InventarioProvider provider) {
    return DropdownButtonFormField<bool?>(
      value: provider.filtroActivo,
      onChanged: provider.aplicarFiltroActivo,
      decoration: InputDecoration(
        labelText: 'Estado',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('Todos')),
        DropdownMenuItem(value: true, child: Text('Activos')),
        DropdownMenuItem(value: false, child: Text('Inactivos')),
      ],
    );
  }

  Widget _buildAlertaFilter(AppTheme theme, InventarioProvider provider) {
    return DropdownButtonFormField<bool?>(
      value: provider.filtroEnAlerta,
      onChanged: provider.aplicarFiltroEnAlerta,
      decoration: InputDecoration(
        labelText: 'Alerta',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('Todos')),
        DropdownMenuItem(value: true, child: Text('En alerta')),
        DropdownMenuItem(value: false, child: Text('Stock normal')),
      ],
    );
  }

  Widget _buildProveedorFilter(AppTheme theme, InventarioProvider provider) {
    return DropdownButtonFormField<String?>(
      value: provider.filtroProveedor,
      onChanged: provider.aplicarFiltroProveedor,
      decoration: InputDecoration(
        labelText: 'Proveedor',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos')),
        ...provider.proveedoresDisponibles.map(
          (proveedor) => DropdownMenuItem(
            value: proveedor,
            child: Text(proveedor),
          ),
        ),
      ],
    );
  }

  Widget _buildClearFiltersButton(AppTheme theme, InventarioProvider provider) {
    return IconButton(
      onPressed: provider.limpiarFiltros,
      icon: const Icon(Icons.clear),
      tooltip: 'Limpiar filtros',
      style: IconButton.styleFrom(
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildTabContent(AppTheme theme, InventarioProvider provider) {
    switch (provider.tabSeleccionado) {
      case 0: // Inventario
        return InventarioTable(
          provider: provider,
          sucursalId: widget.sucursalId,
        );
      case 1: // Alertas
        return AlertasInventarioTable(
          provider: provider,
          sucursalId: widget.sucursalId,
        );
      case 2: // Historial
        return HistorialRefaccionesTable(
          provider: provider,
          sucursalId: widget.sucursalId,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _selectDateRange(InventarioProvider provider) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: provider.rangoFechas,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.of(context).primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      provider.cambiarRangoFechas(picked);
      // Recargar historial con el nuevo rango
      provider.refrescarDatos();
    }
  }
}
