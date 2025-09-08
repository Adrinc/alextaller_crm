import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nethive_neo/providers/talleralex/dashboard_global_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class DashboardChartsSection extends StatefulWidget {
  final DashboardGlobalProvider provider;
  final bool isLargeScreen;
  final bool isMediumScreen;
  final bool isSmallScreen;

  const DashboardChartsSection({
    Key? key,
    required this.provider,
    required this.isLargeScreen,
    required this.isMediumScreen,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  State<DashboardChartsSection> createState() => _DashboardChartsSectionState();
}

class _DashboardChartsSectionState extends State<DashboardChartsSection>
    with TickerProviderStateMixin {
  late AnimationController _chartAnimationController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _chartAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _chartAnimationController.forward();
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Column(
      children: [
        if (widget.isLargeScreen)
          Row(
            children: [
              Expanded(flex: 2, child: _buildIncomesChart(theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildOrdersStatusChart(theme)),
            ],
          )
        else ...[
          _buildIncomesChart(theme),
          const SizedBox(height: 16),
          _buildOrdersStatusChart(theme),
        ],
      ],
    );
  }

  Widget _buildIncomesChart(AppTheme theme) {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _chartAnimation.value,
          child: Opacity(
            opacity: _chartAnimation.value,
            child: Container(
              height: 300,
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
                        Icons.trending_up_rounded,
                        color: theme.success,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Ingresos por Sucursal',
                        style: theme.title3.override(
                          fontFamily: 'Poppins',
                          color: theme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _buildBarChart(theme)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersStatusChart(AppTheme theme) {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _chartAnimation.value,
          child: Opacity(
            opacity: _chartAnimation.value,
            child: Container(
              height: 300,
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
                    color: theme.tertiaryColor.withOpacity(0.2),
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
                        Icons.pie_chart_rounded,
                        color: theme.tertiaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Estado de Órdenes',
                        style: theme.title3.override(
                          fontFamily: 'Poppins',
                          color: theme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _buildPieChart(theme)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChart(AppTheme theme) {
    final topSucursales = widget.provider.getTopSucursales(
      criterio: 'ingresos',
      limite: 5,
    );

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: topSucursales.isNotEmpty
            ? topSucursales.first.ingresosTotales * 1.2
            : 100,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex < topSucursales.length) {
                final sucursal = topSucursales[groupIndex];
                return BarTooltipItem(
                  '${sucursal.sucursalNombre}\n\$${sucursal.ingresosTotales.toStringAsFixed(0)}',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }
              return null;
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < topSucursales.length) {
                  final sucursal = topSucursales[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      sucursal.sucursalNombre.length > 8
                          ? '${sucursal.sucursalNombre.substring(0, 8)}...'
                          : sucursal.sucursalNombre,
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: theme.secondaryText,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: topSucursales.asMap().entries.map((entry) {
          final index = entry.key;
          final sucursal = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: sucursal.ingresosTotales * _chartAnimation.value,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    theme.primaryColor,
                    theme.success,
                  ],
                ),
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart(AppTheme theme) {
    final total = widget.provider.totalOrdenesGlobal;
    final abiertas = widget.provider.ordenesAbiertasGlobal;
    final cerradas = widget.provider.ordenesCerradasGlobal;

    if (total == 0) {
      return Center(
        child: Text(
          'No hay datos de órdenes',
          style: theme.bodyText1.override(
            fontFamily: 'Poppins',
            color: theme.secondaryText,
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: theme.tertiaryColor,
                  value: abiertas.toDouble() * _chartAnimation.value,
                  title: '${((abiertas / total) * 100).toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: theme.success,
                  value: cerradas.toDouble() * _chartAnimation.value,
                  title: '${((cerradas / total) * 100).toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                theme,
                'Abiertas',
                abiertas.toString(),
                theme.tertiaryColor,
              ),
              const SizedBox(height: 12),
              _buildLegendItem(
                theme,
                'Cerradas',
                cerradas.toString(),
                theme.success,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    AppTheme theme,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.bodyText2.override(
                  fontFamily: 'Poppins',
                  color: theme.secondaryText,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  color: theme.primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
