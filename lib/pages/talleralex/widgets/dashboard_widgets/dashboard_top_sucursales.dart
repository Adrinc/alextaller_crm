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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: theme.neumorphicShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.success.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: theme.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Top Sucursales por Ingresos',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: theme.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/sucursales'),
                child: Text(
                  'Ver todas',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: theme.neumorphicInsetShadows,
        border: rank <= 3
            ? Border.all(
                color: rankColor.withOpacity(0.5),
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // Rank badge mejorado
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  rankColor,
                  rankColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: rankColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rank <= 3 ? Colors.white : theme.primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Información de la sucursal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nombre,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: theme.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.success.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: theme.success,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          ingresos,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: theme.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
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
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
