import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/citas_ordenes_provider.dart';
import 'package:nethive_neo/models/talleralex/citas_ordenes_models.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/citas_table.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/ordenes_table.dart';

class CitasOrdenesPage extends StatefulWidget {
  final String sucursalId;

  const CitasOrdenesPage({
    super.key,
    required this.sucursalId,
  });

  @override
  State<CitasOrdenesPage> createState() => _CitasOrdenesPageState();
}

class _CitasOrdenesPageState extends State<CitasOrdenesPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<CitasOrdenesProvider>().cambiarTab(_tabController.index);
      }
    });

    // Cargar datos al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CitasOrdenesProvider>().cargarDatos(widget.sucursalId);
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        height: double.infinity,
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
          children: [
            // Header con KPIs
            _buildHeader(theme),

            // Tab bar y filtros
            _buildTabBarAndFilters(theme),

            // Contenido de las tabs
            Expanded(
              child: Consumer<CitasOrdenesProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return _buildLoadingState(theme);
                  }

                  if (provider.error != null) {
                    return _buildErrorState(theme, provider.error!);
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab de Citas
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: CitasTable(
                          provider: provider,
                          sucursalId: widget.sucursalId,
                        ),
                      ),
                      // Tab de Órdenes
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: OrdenesTable(
                          provider: provider,
                          sucursalId: widget.sucursalId,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.secondaryColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Título principal
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.event_note,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Citas y Órdenes de Servicio',
                      style: theme.title1.override(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Operación diaria, seguimiento y control de servicios',
                      style: theme.bodyText1.override(
                        fontFamily: 'Poppins',
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // KPIs
          Consumer<CitasOrdenesProvider>(
            builder: (context, provider, child) {
              final kpis = provider.kpis;
              if (kpis == null) return const SizedBox.shrink();

              return Column(
                children: [
                  // Primera fila de KPIs - Citas
                  Row(
                    children: [
                      Expanded(
                        child: _buildKPICard(
                          theme,
                          'Citas Pendientes',
                          kpis.citasPendientes.toString(),
                          Icons.schedule,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKPICard(
                          theme,
                          'Citas Confirmadas',
                          kpis.citasConfirmadas.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKPICard(
                          theme,
                          'No Asistieron',
                          kpis.citasNoAsistio.toString(),
                          Icons.cancel,
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKPICard(
                          theme,
                          'Completadas',
                          kpis.citasCompletadas.toString(),
                          Icons.done_all,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Segunda fila de KPIs - Órdenes
                  Row(
                    children: [
                      Expanded(
                        child: _buildKPICard(
                          theme,
                          'En Proceso',
                          kpis.ordenesEnProceso.toString(),
                          Icons.build,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKPICard(
                          theme,
                          'Por Aprobar',
                          kpis.ordenesPorAprobar.toString(),
                          Icons.approval,
                          Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKPICard(
                          theme,
                          'Bahías',
                          '${kpis.bahiasOcupadas}/${kpis.bahiasTotales}',
                          Icons.garage,
                          Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKPICard(
                          theme,
                          'Ingresos',
                          kpis.ingresosPeriodoTexto,
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(
    AppTheme theme,
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icono,
                color: Colors.white,
                size: 24,
              ),
              Text(
                valor,
                style: theme.title2.override(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarAndFilters(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Tab Bar personalizada
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: theme.bodyText1.override(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: theme.bodyText1.override(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.event, size: 20),
                  text: 'Citas',
                ),
                Tab(
                  icon: Icon(Icons.build, size: 20),
                  text: 'Órdenes',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Barra de filtros dinámicos según el tab
          Consumer<CitasOrdenesProvider>(
            builder: (context, provider, child) {
              return provider.tabSeleccionado == 0
                  ? _buildCitasFilters(theme, provider)
                  : _buildOrdenesFilters(theme, provider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCitasFilters(AppTheme theme, CitasOrdenesProvider provider) {
    return Row(
      children: [
        // Buscador
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar citas por cliente, placa o servicio...',
                hintStyle: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                provider.aplicarFiltroCitaTexto(value);
              },
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Filtro por estado
        _buildEstadoCitaDropdown(theme, provider),

        const SizedBox(width: 16),

        // Botón refrescar
        _buildRefreshButton(theme, provider),
      ],
    );
  }

  Widget _buildOrdenesFilters(AppTheme theme, CitasOrdenesProvider provider) {
    return Row(
      children: [
        // Buscador
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar órdenes por folio, cliente o placa...',
                hintStyle: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                provider.aplicarFiltroOrdenTexto(value);
              },
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Filtro por estado
        _buildEstadoOrdenDropdown(theme, provider),

        const SizedBox(width: 16),

        // Botón refrescar
        _buildRefreshButton(theme, provider),
      ],
    );
  }

  Widget _buildEstadoCitaDropdown(
      AppTheme theme, CitasOrdenesProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<EstadoCita?>(
        value: provider.filtroCitaEstado,
        hint: Text(
          'Estado',
          style: theme.bodyText1.override(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        underline: const SizedBox.shrink(),
        items: [
          const DropdownMenuItem<EstadoCita?>(
            value: null,
            child: Text('Todos'),
          ),
          ...EstadoCita.values.map((estado) => DropdownMenuItem(
                value: estado,
                child: Text(estado.texto),
              )),
        ],
        onChanged: (value) => provider.aplicarFiltroCitaEstado(value),
      ),
    );
  }

  Widget _buildEstadoOrdenDropdown(
      AppTheme theme, CitasOrdenesProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<EstadoOrdenServicio?>(
        value: provider.filtroOrdenEstado,
        hint: Text(
          'Estado',
          style: theme.bodyText1.override(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        underline: const SizedBox.shrink(),
        items: [
          const DropdownMenuItem<EstadoOrdenServicio?>(
            value: null,
            child: Text('Todos'),
          ),
          ...EstadoOrdenServicio.values.map((estado) => DropdownMenuItem(
                value: estado,
                child: Text(estado.texto),
              )),
        ],
        onChanged: (value) => provider.aplicarFiltroOrdenEstado(value),
      ),
    );
  }

  Widget _buildRefreshButton(AppTheme theme, CitasOrdenesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => provider.refrescarDatos(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.refresh,
              size: 20,
              color: theme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando citas y órdenes...',
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppTheme theme, String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.shade200,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: theme.title3.override(
                fontFamily: 'Poppins',
                color: Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<CitasOrdenesProvider>()
                    .cargarDatos(widget.sucursalId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
