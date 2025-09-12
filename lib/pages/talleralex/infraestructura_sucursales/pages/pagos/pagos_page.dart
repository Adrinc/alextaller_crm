import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/pagos_provider.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/pagos_table.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/facturas_table.dart';

class PagosPage extends StatefulWidget {
  final String sucursalId;

  const PagosPage({
    super.key,
    required this.sucursalId,
  });

  @override
  State<PagosPage> createState() => _PagosPageState();
}

class _PagosPageState extends State<PagosPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late PagosProvider _pagosProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pagosProvider = context.read<PagosProvider>();

    // Cargar datos inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pagosProvider.cargarDatos(widget.sucursalId);
    });

    // Escuchar cambios de tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _pagosProvider.cambiarTab(_tabController.index);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    return Consumer<PagosProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState(theme);
        }

        if (provider.error != null) {
          return _buildErrorState(theme, provider.error!);
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F3),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // Header con KPIs
              _buildHeaderKPIs(context, theme, provider, isSmallScreen),

              // Tabs y filtros
              _buildTabsAndFilters(context, theme, provider, isSmallScreen),

              // Contenido de las tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab de Pagos
                    PagosTable(
                      provider: provider,
                      sucursalId: widget.sucursalId,
                    ),
                    // Tab de Facturas
                    FacturasTable(
                      provider: provider,
                      sucursalId: widget.sucursalId,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(AppTheme theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(24),
      ),
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
                        colors: [theme.primaryColor, theme.secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.payment,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(theme.primaryColor),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando datos de pagos...',
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
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(24),
      ),
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
                'Error al cargar pagos',
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
                onTap: () => _pagosProvider.refrescarDatos(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.secondaryColor],
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

  Widget _buildHeaderKPIs(
    BuildContext context,
    AppTheme theme,
    PagosProvider provider,
    bool isSmallScreen,
  ) {
    final kpis = provider.kpis;
    if (kpis == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
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
                  Icons.payment,
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
                      'Pagos y Facturación',
                      style: theme.title2.override(
                        fontFamily: 'Poppins',
                        color: theme.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestión integral de pagos y facturación',
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              // Botón refrescar
              InkWell(
                onTap: () => provider.refrescarDatos(),
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
                    Icons.refresh,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // KPIs Cards
          if (isSmallScreen)
            _buildKPIsVertical(theme, kpis)
          else
            _buildKPIsHorizontal(theme, kpis),
        ],
      ),
    );
  }

  Widget _buildKPIsHorizontal(AppTheme theme, kpis) {
    return Row(
      children: [
        Expanded(
            child: _buildKPICard(theme, 'Total Pagado Hoy',
                kpis.totalPagadoHoyTexto, Icons.today, Colors.green)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildKPICard(theme, 'Total Pagado Mes',
                kpis.totalPagadoMesTexto, Icons.calendar_month, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildKPICard(theme, 'Pagos Pendientes',
                kpis.totalPendienteTexto, Icons.pending, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildKPICard(theme, '% Facturado',
                kpis.porcentajeFacturadoTexto, Icons.receipt, Colors.purple)),
      ],
    );
  }

  Widget _buildKPIsVertical(AppTheme theme, kpis) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildKPICard(theme, 'Total Pagado Hoy',
                    kpis.totalPagadoHoyTexto, Icons.today, Colors.green)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildKPICard(
                    theme,
                    'Total Pagado Mes',
                    kpis.totalPagadoMesTexto,
                    Icons.calendar_month,
                    Colors.blue)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildKPICard(theme, 'Pagos Pendientes',
                    kpis.totalPendienteTexto, Icons.pending, Colors.orange)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildKPICard(
                    theme,
                    '% Facturado',
                    kpis.porcentajeFacturadoTexto,
                    Icons.receipt,
                    Colors.purple)),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(
      AppTheme theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.title3.override(
              fontFamily: 'Poppins',
              color: theme.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsAndFilters(
    BuildContext context,
    AppTheme theme,
    PagosProvider provider,
    bool isSmallScreen,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Tabs
          Container(
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
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Pagos (${provider.pagosFiltrados.length})',
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Facturas (${provider.facturasFiltradasList.length})',
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
              ],
              labelColor: theme.primaryColor,
              unselectedLabelColor: theme.secondaryText,
              indicatorColor: theme.primaryColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Filtros
          if (isSmallScreen)
            _buildFiltersMobile(theme, provider)
          else
            _buildFiltersDesktop(theme, provider),
        ],
      ),
    );
  }

  Widget _buildFiltersDesktop(AppTheme theme, PagosProvider provider) {
    return Container(
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
      child: Row(
        children: [
          // Búsqueda
          Expanded(
            flex: 2,
            child: _buildSearchField(theme, provider),
          ),
          const SizedBox(width: 16),

          // Filtro Estado
          Expanded(
            child: _buildEstadoDropdown(theme, provider),
          ),
          const SizedBox(width: 16),

          // Filtro Método
          Expanded(
            child: _buildMetodoDropdown(theme, provider),
          ),
          const SizedBox(width: 16),

          // Filtro Factura
          Expanded(
            child: _buildFacturaDropdown(theme, provider),
          ),
          const SizedBox(width: 16),

          // Botón limpiar filtros
          InkWell(
            onTap: provider.limpiarFiltros,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Icon(
                Icons.clear,
                color: Colors.red.shade600,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersMobile(AppTheme theme, PagosProvider provider) {
    return Container(
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
          // Búsqueda
          _buildSearchField(theme, provider),
          const SizedBox(height: 12),

          // Filtros en fila
          Row(
            children: [
              Expanded(child: _buildEstadoDropdown(theme, provider)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetodoDropdown(theme, provider)),
              const SizedBox(width: 12),
              InkWell(
                onTap: provider.limpiarFiltros,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Icon(
                    Icons.clear,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppTheme theme, PagosProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        onChanged: provider.aplicarFiltroTexto,
        decoration: InputDecoration(
          hintText: 'Buscar por cliente, orden, placa, factura...',
          prefixIcon: Icon(Icons.search, color: theme.primaryColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: TextStyle(
            color: theme.secondaryText,
            fontFamily: 'Poppins',
          ),
        ),
        style: TextStyle(
          color: theme.primaryText,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildEstadoDropdown(AppTheme theme, PagosProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.filtroEstado,
          hint: Text(
            'Estado',
            style: TextStyle(
              color: theme.secondaryText,
              fontFamily: 'Poppins',
            ),
          ),
          onChanged: provider.aplicarFiltroEstado,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Todos los estados'),
            ),
            ...provider.estadosDisponibles
                .map((estado) => DropdownMenuItem<String>(
                      value: estado,
                      child:
                          Text(estado[0].toUpperCase() + estado.substring(1)),
                    )),
          ],
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildMetodoDropdown(AppTheme theme, PagosProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.filtroMetodo,
          hint: Text(
            'Método',
            style: TextStyle(
              color: theme.secondaryText,
              fontFamily: 'Poppins',
            ),
          ),
          onChanged: provider.aplicarFiltroMetodo,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Todos los métodos'),
            ),
            ...provider.metodosDisponibles
                .map((metodo) => DropdownMenuItem<String>(
                      value: metodo,
                      child:
                          Text(metodo[0].toUpperCase() + metodo.substring(1)),
                    )),
          ],
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildFacturaDropdown(AppTheme theme, PagosProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool>(
          value: provider.filtroTieneFactura,
          hint: Text(
            'Factura',
            style: TextStyle(
              color: theme.secondaryText,
              fontFamily: 'Poppins',
            ),
          ),
          onChanged: provider.aplicarFiltroTieneFactura,
          items: const [
            DropdownMenuItem<bool>(
              value: null,
              child: Text('Todas'),
            ),
            DropdownMenuItem<bool>(
              value: true,
              child: Text('Con factura'),
            ),
            DropdownMenuItem<bool>(
              value: false,
              child: Text('Sin factura'),
            ),
          ],
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }
}
