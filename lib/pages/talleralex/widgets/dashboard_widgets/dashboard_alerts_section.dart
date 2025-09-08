import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/talleralex/dashboard_global_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class DashboardAlertsSection extends StatelessWidget {
  final DashboardGlobalProvider provider;
  final bool isSmallScreen;

  const DashboardAlertsSection({
    Key? key,
    required this.provider,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final alertas = _generateAlertas(provider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.secondaryBackground.withOpacity(0.8),
            theme.primaryBackground.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          // Neumorphism shadows
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            offset: const Offset(-6, -6),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(6, 6),
            blurRadius: 16,
          ),
          // Accent glow
          BoxShadow(
            color: theme.warning.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: theme.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Alertas y Notificaciones',
                style: theme.title3.override(
                  fontFamily: 'Poppins',
                  color: theme.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${alertas.where((a) => a.prioridad == AlertPriority.alta).length}',
                  style: theme.bodyText2.override(
                    fontFamily: 'Poppins',
                    color: theme.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (alertas.isEmpty)
            _buildEmptyState(theme)
          else
            ...alertas.map((alerta) => _buildAlertItem(theme, alerta)).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: theme.success,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Todo en orden',
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              color: theme.success,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No hay alertas pendientes',
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(AppTheme theme, DashboardAlert alerta) {
    Color alertColor;
    IconData alertIcon;

    switch (alerta.prioridad) {
      case AlertPriority.alta:
        alertColor = theme.error;
        alertIcon = Icons.error_rounded;
        break;
      case AlertPriority.media:
        alertColor = theme.warning;
        alertIcon = Icons.warning_rounded;
        break;
      case AlertPriority.baja:
        alertColor = theme.primaryColor;
        alertIcon = Icons.info_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alertColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            alertIcon,
            color: alertColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerta.titulo,
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: theme.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (alerta.descripcion != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    alerta.descripcion!,
                    style: theme.bodyText2.override(
                      fontFamily: 'Poppins',
                      color: theme.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (alerta.sucursal != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      alerta.sucursal!,
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: theme.secondaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            alerta.tiempo,
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  List<DashboardAlert> _generateAlertas(DashboardGlobalProvider provider) {
    final alertas = <DashboardAlert>[];

    // Verificar sucursales con bajo rendimiento
    final sucursalesBajoRendimiento = provider.dashboardData
        .where(
            (s) => s.ingresosTotales < provider.promedioIngresosXSucursal * 0.7)
        .toList();

    for (final sucursal in sucursalesBajoRendimiento.take(2)) {
      alertas.add(DashboardAlert(
        titulo: 'Rendimiento bajo en sucursal',
        descripcion: 'Ingresos 30% por debajo del promedio',
        sucursal: sucursal.sucursalNombre,
        prioridad: AlertPriority.media,
        tiempo: '2h',
      ));
    }

    // Verificar sucursales sin empleados
    final sucursalesSinEmpleados =
        provider.dashboardData.where((s) => s.empleadosActivos == 0).toList();

    for (final sucursal in sucursalesSinEmpleados.take(1)) {
      alertas.add(DashboardAlert(
        titulo: 'Sucursal sin empleados activos',
        descripcion: 'No hay empleados registrados en esta sucursal',
        sucursal: sucursal.sucursalNombre,
        prioridad: AlertPriority.alta,
        tiempo: '30m',
      ));
    }

    // Verificar inventario bajo
    final sucursalesInventarioBajo =
        provider.dashboardData.where((s) => s.refaccionesAlerta > 5).toList();

    for (final sucursal in sucursalesInventarioBajo.take(2)) {
      alertas.add(DashboardAlert(
        titulo: 'Refacciones en alerta',
        descripcion:
            '${sucursal.refaccionesAlerta} refacciones requieren atención',
        sucursal: sucursal.sucursalNombre,
        prioridad: AlertPriority.baja,
        tiempo: '1h',
      ));
    }

    // Verificar si hay pocas citas hoy
    if (provider.citasHoyGlobal < 5) {
      alertas.add(DashboardAlert(
        titulo: 'Pocas citas programadas hoy',
        descripcion: 'Solo ${provider.citasHoyGlobal} citas para el día de hoy',
        prioridad: AlertPriority.media,
        tiempo: '15m',
      ));
    }

    return alertas
      ..sort((a, b) => b.prioridad.index.compareTo(a.prioridad.index));
  }
}

class DashboardAlert {
  final String titulo;
  final String? descripcion;
  final String? sucursal;
  final AlertPriority prioridad;
  final String tiempo;

  DashboardAlert({
    required this.titulo,
    this.descripcion,
    this.sucursal,
    required this.prioridad,
    required this.tiempo,
  });
}

enum AlertPriority { alta, media, baja }
