import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/providers/talleralex/dashboard_global_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:intl/intl.dart';

class DashboardTopSucursales extends StatelessWidget {
  final DashboardGlobalProvider provider;
  final bool isSmallScreen;

  const DashboardTopSucursales({
    Key? key,
    required this.provider,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final topSucursales =
        provider.getTopSucursales(criterio: 'ingresos', limite: 5);
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

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
            color: theme.success.withOpacity(0.3),
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
                Icons.emoji_events_rounded,
                color: theme.success,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Top Sucursales por Ingresos',
                style: theme.title3.override(
                  fontFamily: 'Poppins',
                  color: theme.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/sucursales'),
                child: Text(
                  'Ver todas',
                  style: theme.bodyText2.override(
                    fontFamily: 'Poppins',
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topSucursales.asMap().entries.map((entry) {
            final index = entry.key;
            final sucursal = entry.value;
            return _buildSucursalRankItem(
              theme,
              index + 1,
              sucursal.sucursalNombre,
              currencyFormat.format(sucursal.ingresosTotales),
              sucursal.citasHoy,
              sucursal.empleadosActivos,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSucursalRankItem(
    AppTheme theme,
    int rank,
    String nombre,
    String ingresos,
    int citas,
    int empleados,
  ) {
    Color rankColor;
    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFFD700); // Oro
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0); // Plata
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32); // Bronce
        break;
      default:
        rankColor = theme.secondaryText;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank <= 3
              ? rankColor.withOpacity(0.3)
              : theme.alternate.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: rankColor, width: 2),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Información de la sucursal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: theme.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: theme.success,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ingresos,
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: theme.success,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Métricas adicionales
          Column(
            children: [
              _buildMetricChip(theme, '$citas', 'Citas', theme.primaryColor),
              const SizedBox(height: 4),
              _buildMetricChip(
                  theme, '$empleados', 'Empleados', theme.tertiaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(
      AppTheme theme, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
