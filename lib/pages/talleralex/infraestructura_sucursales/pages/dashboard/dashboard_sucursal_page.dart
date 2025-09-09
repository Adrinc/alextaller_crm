import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/dashboard_sucursal_provider.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/dashboard_widgets.dart';

class DashboardSucursalPage extends StatefulWidget {
  final String sucursalId;

  const DashboardSucursalPage({
    super.key,
    required this.sucursalId,
  });

  @override
  State<DashboardSucursalPage> createState() => _DashboardSucursalPageState();
}

class _DashboardSucursalPageState extends State<DashboardSucursalPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Cargar datos del dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<DashboardSucursalProvider>()
          .cargarDashboard(widget.sucursalId);
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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<DashboardSucursalProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.isLoading) {
            return _buildLoadingState(theme);
          }

          if (dashboardProvider.error != null) {
            return _buildErrorState(theme, dashboardProvider.error!);
          }

          final data = dashboardProvider.dashboardData;
          if (data == null) {
            return _buildEmptyState(theme);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con filtros
                _buildHeader(context, theme, dashboardProvider),

                const SizedBox(height: 32),

                // KPIs principales
                _buildKpiSection(theme, data),

                const SizedBox(height: 32),

                // Gráficos y métricas adicionales
                _buildChartsSection(theme, data),

                const SizedBox(height: 32),

                // Alertas y resumen
                _buildAlertsSection(theme, data),
              ],
            ),
          );
        },
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
            'Cargando dashboard...',
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
            'Error al cargar dashboard',
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
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard,
            color: theme.secondaryText,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay datos disponibles',
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

  Widget _buildHeader(BuildContext context, AppTheme theme,
      DashboardSucursalProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [theme.primaryColor, theme.secondaryColor],
                ).createShader(bounds),
                child: Text(
                  'Dashboard Operacional',
                  style: theme.title2.override(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Resumen ejecutivo de la sucursal',
                style: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  color: theme.secondaryText,
                ),
              ),
            ],
          ),
        ),
        // Filtros rápidos
        Row(
          children: [
            _buildFilterButton(context, theme, 'Hoy',
                () => provider.filtrarHoy(widget.sucursalId)),
            const SizedBox(width: 8),
            _buildFilterButton(context, theme, 'Semana',
                () => provider.filtrarSemana(widget.sucursalId)),
            const SizedBox(width: 8),
            _buildFilterButton(context, theme, 'Mes',
                () => provider.filtrarMes(widget.sucursalId)),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterButton(
      BuildContext context, AppTheme theme, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
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
        child: Text(
          label,
          style: theme.bodyText2.override(
            fontFamily: 'Poppins',
            color: theme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildKpiSection(AppTheme theme, dynamic data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1.2,
      children: [
        KpiCard(
          titulo: 'Citas Totales',
          valor: data.citasTotal.toString(),
          subtitulo: '${data.citasPendientes} pendientes',
          icono: Icons.calendar_today,
          color: theme.primaryColor,
          showTrend: true,
          isPositiveTrend: data.citasPendientes < data.citasTotal / 2,
        ),
        KpiCard(
          titulo: 'Órdenes Abiertas',
          valor: data.ordenesAbiertas.toString(),
          subtitulo: '${data.ordenesCerradas} cerradas',
          icono: Icons.build_circle,
          color: Colors.orange,
          showTrend: true,
          isPositiveTrend: data.ordenesCerradas > data.ordenesAbiertas,
        ),
        KpiCard(
          titulo: 'Ingresos',
          valor: data.ingresosFormateados,
          subtitulo: 'Período actual',
          icono: Icons.attach_money,
          color: Colors.green,
          showTrend: true,
          isPositiveTrend: true,
        ),
        KpiCard(
          titulo: 'Inventario Alerta',
          valor: data.refaccionesAlerta.toString(),
          subtitulo: 'Refacciones bajo mínimo',
          icono: Icons.warning,
          color: data.refaccionesAlerta > 0 ? theme.error : theme.success,
          showTrend: true,
          isPositiveTrend: data.refaccionesAlerta == 0,
        ),
      ],
    );
  }

  Widget _buildChartsSection(AppTheme theme, dynamic data) {
    return Row(
      children: [
        // Gráfico de ocupación de bahías
        Expanded(
          flex: 1,
          child: DonutChart(
            percentage: data.porcentajeOcupacionBahias,
            label: 'Ocupación de Bahías',
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(width: 20),
        // Métricas adicionales
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F3),
              borderRadius: BorderRadius.circular(20),
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
                Text(
                  'Métricas Operacionales',
                  style: theme.title3.override(
                    fontFamily: 'Poppins',
                    color: theme.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildMetricRow(theme, 'Bahías Totales',
                    data.bahiasTotales.toString(), Icons.garage),
                _buildMetricRow(theme, 'Bahías Ocupadas',
                    data.bahiasOcupadas.toString(), Icons.directions_car),
                _buildMetricRow(
                    theme,
                    'Tasa de Asistencia',
                    '${data.tasaAsistencia.toStringAsFixed(1)}%',
                    Icons.check_circle),
                _buildMetricRow(theme, 'Citas Completadas',
                    data.citasCompletadas.toString(), Icons.done_all),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(
      AppTheme theme, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                color: theme.secondaryText,
              ),
            ),
          ),
          Text(
            value,
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              color: theme.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(AppTheme theme, dynamic data) {
    final hasAlerts = data.refaccionesAlerta > 0 || data.citasNoAsistio > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(20),
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
              Icon(
                hasAlerts ? Icons.warning : Icons.check_circle,
                color: hasAlerts ? theme.error : theme.success,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                hasAlerts ? 'Alertas Activas' : 'Sistema Operativo',
                style: theme.title3.override(
                  fontFamily: 'Poppins',
                  color: theme.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasAlerts) ...[
            if (data.refaccionesAlerta > 0)
              _buildAlert(
                theme,
                'Inventario Bajo',
                '${data.refaccionesAlerta} refacciones necesitan reabastecimiento',
                Icons.inventory_2,
                theme.error,
              ),
            if (data.citasNoAsistio > 0)
              _buildAlert(
                theme,
                'Inasistencias',
                '${data.citasNoAsistio} citas sin asistencia',
                Icons.person_off,
                theme.warning,
              ),
          ] else
            _buildAlert(
              theme,
              'Todo en Orden',
              'No hay alertas activas en esta sucursal',
              Icons.verified,
              theme.success,
            ),
        ],
      ),
    );
  }

  Widget _buildAlert(AppTheme theme, String title, String description,
      IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: theme.bodyText2.override(
                    fontFamily: 'Poppins',
                    color: theme.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
