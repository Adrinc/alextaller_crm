import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nethive_neo/theme/theme.dart';

class KpiCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String? subtitulo;
  final IconData icono;
  final Color color;
  final double? porcentaje;
  final bool showTrend;
  final bool isPositiveTrend;

  const KpiCard({
    super.key,
    required this.titulo,
    required this.valor,
    this.subtitulo,
    required this.icono,
    required this.color,
    this.porcentaje,
    this.showTrend = false,
    this.isPositiveTrend = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

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
          // Header con ícono y título
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icono,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: theme.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (showTrend)
                Icon(
                  isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                  color: isPositiveTrend ? theme.success : theme.error,
                  size: 20,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Valor principal
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [color, color.withOpacity(0.7)],
            ).createShader(bounds),
            child: Text(
              valor,
              style: theme.title1.override(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 32,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Subtítulo y porcentaje
          Row(
            children: [
              if (subtitulo != null)
                Expanded(
                  child: Text(
                    subtitulo!,
                    style: theme.bodyText2.override(
                      fontFamily: 'Poppins',
                      color: theme.tertiaryText,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (porcentaje != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${porcentaje!.toStringAsFixed(1)}%',
                    style: theme.bodyText2.override(
                      fontFamily: 'Poppins',
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class DonutChart extends StatelessWidget {
  final double percentage;
  final String label;
  final Color color;
  final Color backgroundColor;

  const DonutChart({
    super.key,
    required this.percentage,
    required this.label,
    required this.color,
    this.backgroundColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

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
        children: [
          Text(
            label,
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 0,
                    centerSpaceRadius: 35,
                    sections: [
                      PieChartSectionData(
                        value: percentage,
                        color: color,
                        radius: 15,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: 100 - percentage,
                        color: backgroundColor,
                        radius: 15,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: theme.title2.override(
                      fontFamily: 'Poppins',
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
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
