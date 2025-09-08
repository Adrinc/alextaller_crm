import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class DashboardActivityFeed extends StatelessWidget {
  final bool isLargeScreen;
  final bool isMediumScreen;
  final bool isSmallScreen;

  const DashboardActivityFeed({
    Key? key,
    required this.isLargeScreen,
    required this.isMediumScreen,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

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
            color: theme.primaryColor.withOpacity(0.2),
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
                Icons.timeline_rounded,
                color: theme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Actividad Reciente',
                style: theme.title3.override(
                  fontFamily: 'Poppins',
                  color: theme.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Lista de actividades simuladas
          ...List.generate(5, (index) => _buildActivityItem(theme, index)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(AppTheme theme, int index) {
    final activities = [
      {
        'icon': Icons.calendar_today,
        'title': 'Nueva cita programada',
        'subtitle': 'Sucursal Centro - 14:30',
        'time': 'Hace 5 min',
        'color': theme.primaryColor,
      },
      {
        'icon': Icons.build_circle,
        'title': 'Orden completada',
        'subtitle': 'Cambio de aceite - Cliente: Juan Pérez',
        'time': 'Hace 12 min',
        'color': theme.success,
      },
      {
        'icon': Icons.warning_amber,
        'title': 'Alerta de inventario',
        'subtitle': 'Filtros de aceite - Stock bajo',
        'time': 'Hace 30 min',
        'color': theme.warning,
      },
      {
        'icon': Icons.person_add,
        'title': 'Nuevo empleado',
        'subtitle': 'María González - Mecánica',
        'time': 'Hace 1 hora',
        'color': theme.tertiaryColor,
      },
      {
        'icon': Icons.attach_money,
        'title': 'Pago recibido',
        'subtitle': '\$2,450 - Sucursal Norte',
        'time': 'Hace 2 horas',
        'color': theme.success,
      },
    ];

    final activity = activities[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.alternate.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: theme.primaryText,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                Text(
                  activity['subtitle'] as String,
                  style: theme.bodyText2.override(
                    fontFamily: 'Poppins',
                    color: theme.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'] as String,
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
