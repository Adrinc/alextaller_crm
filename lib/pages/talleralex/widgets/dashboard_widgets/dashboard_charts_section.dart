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
              height: 320,
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
                          Icons.trending_up_rounded,
                          color: theme.success,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Ingresos por Sucursal',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: theme.primaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
              height: 320,
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
                          color: theme.tertiaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.tertiaryColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.pie_chart_rounded,
                          color: theme.tertiaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Estado de Órdenes',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: theme.primaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: theme.neumorphicInsetShadows,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: theme.tertiaryText,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'No hay datos',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: theme.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: theme.neumorphicInsetShadows,
            ),
            padding: const EdgeInsets.all(16),
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 45,
                sections: [
                  PieChartSectionData(
                    color: theme.primaryColor,
                    value: abiertas.toDouble() * _chartAnimation.value,
                    title: '${abiertas}',
                    radius: 50,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                    titlePositionPercentageOffset: 0.6,
                  ),
                  PieChartSectionData(
                    color: theme.success,
                    value: cerradas.toDouble() * _chartAnimation.value,
                    title: '${cerradas}',
                    radius: 50,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                    titlePositionPercentageOffset: 0.6,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                theme,
                'Abiertas',
                '$abiertas',
                theme.primaryColor,
              ),
              const SizedBox(height: 12),
              _buildLegendItem(
                theme,
                'Cerradas',
                '$cerradas',
                theme.success,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: theme.neumorphicInsetShadows,
                ),
                child: Column(
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: theme.secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$total',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: theme.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(8),
        boxShadow: theme.neumorphicInsetShadows,
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: theme.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
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
      ),
    );
  }
}
