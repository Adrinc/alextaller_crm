import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/promociones_provider.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/promociones_table.dart';

class PromocionesPage extends StatefulWidget {
  final String sucursalId;

  const PromocionesPage({
    super.key,
    required this.sucursalId,
  });

  @override
  State<PromocionesPage> createState() => _PromocionesPageState();
}

class _PromocionesPageState extends State<PromocionesPage> {
  late PromocionesProvider _promocionesProvider;

  @override
  void initState() {
    super.initState();
    _promocionesProvider = context.read<PromocionesProvider>();

    // Cargar datos inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promocionesProvider.cargarDatos(widget.sucursalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    return Consumer<PromocionesProvider>(
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

              // Filtros
              _buildFilters(context, theme, provider, isSmallScreen),

              // Tabla de promociones
              Expanded(
                child: PromocionesTable(
                  provider: provider,
                  sucursalId: widget.sucursalId,
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
                      Icons.local_offer,
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
                    'Cargando promociones...',
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
                'Error al cargar promociones',
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
                onTap: () => _promocionesProvider.refrescarDatos(),
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
    PromocionesProvider provider,
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
                  Icons.local_offer,
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
                      'Promociones y Ofertas',
                      style: theme.title2.override(
                        fontFamily: 'Poppins',
                        color: theme.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestión integral de promociones y descuentos',
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
            child: _buildKPICard(theme, 'Promociones Activas',
                kpis.totalActivasTexto, Icons.local_offer, Colors.green)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildKPICard(theme, 'Próximas a Vencer',
                kpis.proximasVencerTexto, Icons.schedule, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildKPICard(theme, 'Expiradas del Mes',
                kpis.expiradasMesTexto, Icons.event_busy, Colors.red)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildKPICard(
                theme,
                '% Servicios con Promoción',
                kpis.porcentajeServiciosConPromoTexto,
                Icons.percent,
                Colors.blue)),
      ],
    );
  }

  Widget _buildKPIsVertical(AppTheme theme, kpis) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildKPICard(theme, 'Promociones Activas',
                    kpis.totalActivasTexto, Icons.local_offer, Colors.green)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildKPICard(theme, 'Próximas a Vencer',
                    kpis.proximasVencerTexto, Icons.schedule, Colors.orange)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildKPICard(theme, 'Expiradas del Mes',
                    kpis.expiradasMesTexto, Icons.event_busy, Colors.red)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildKPICard(
                    theme,
                    '% Servicios con Promoción',
                    kpis.porcentajeServiciosConPromoTexto,
                    Icons.percent,
                    Colors.blue)),
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

  Widget _buildFilters(
    BuildContext context,
    AppTheme theme,
    PromocionesProvider provider,
    bool isSmallScreen,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
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
        child: isSmallScreen
            ? _buildFiltersMobile(theme, provider)
            : _buildFiltersDesktop(theme, provider),
      ),
    );
  }

  Widget _buildFiltersDesktop(AppTheme theme, PromocionesProvider provider) {
    return Row(
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

        // Filtro Tipo
        Expanded(
          child: _buildTipoDropdown(theme, provider),
        ),
        const SizedBox(width: 16),

        // Filtro Ámbito
        Expanded(
          child: _buildAmbitoDropdown(theme, provider),
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
    );
  }

  Widget _buildFiltersMobile(AppTheme theme, PromocionesProvider provider) {
    return Column(
      children: [
        // Búsqueda
        _buildSearchField(theme, provider),
        const SizedBox(height: 12),

        // Filtros en fila
        Row(
          children: [
            Expanded(child: _buildEstadoDropdown(theme, provider)),
            const SizedBox(width: 12),
            Expanded(child: _buildTipoDropdown(theme, provider)),
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
    );
  }

  Widget _buildSearchField(AppTheme theme, PromocionesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        onChanged: provider.aplicarFiltroTexto,
        decoration: InputDecoration(
          hintText: 'Buscar por título, descripción o sucursal...',
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

  Widget _buildEstadoDropdown(AppTheme theme, PromocionesProvider provider) {
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

  Widget _buildTipoDropdown(AppTheme theme, PromocionesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.filtroTipo,
          hint: Text(
            'Tipo',
            style: TextStyle(
              color: theme.secondaryText,
              fontFamily: 'Poppins',
            ),
          ),
          onChanged: provider.aplicarFiltroTipo,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Todos los tipos'),
            ),
            ...provider.tiposDisponibles.map((tipo) => DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(_getTipoDisplayName(tipo)),
                )),
          ],
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildAmbitoDropdown(AppTheme theme, PromocionesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.filtroAmbito,
          hint: Text(
            'Ámbito',
            style: TextStyle(
              color: theme.secondaryText,
              fontFamily: 'Poppins',
            ),
          ),
          onChanged: provider.aplicarFiltroAmbito,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Todos los ámbitos'),
            ),
            ...provider.ambitosDisponibles
                .map((ambito) => DropdownMenuItem<String>(
                      value: ambito,
                      child:
                          Text(ambito[0].toUpperCase() + ambito.substring(1)),
                    )),
          ],
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  String _getTipoDisplayName(String tipo) {
    switch (tipo) {
      case 'porcentaje':
        return 'Porcentaje';
      case 'monto_fijo':
        return 'Monto Fijo';
      case 'descuento_especial':
        return 'Descuento Especial';
      default:
        return tipo;
    }
  }
}
