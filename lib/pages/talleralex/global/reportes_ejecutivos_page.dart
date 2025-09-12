import 'package:flutter/material.dart';
import '../widgets/global_placeholder_page.dart';

/// Página para reportes ejecutivos
class ReportesEjecutivosPage extends StatelessWidget {
  const ReportesEjecutivosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlobalPlaceholderPage(
      title: 'Reportes Ejecutivos',
      subtitle: 'Análisis y métricas estratégicas',
      icon: Icons.analytics,
      route: '/global/reportes-ejecutivos',
      description:
          'Dashboard ejecutivo con KPIs estratégicos y análisis predictivo para toma de decisiones',
      features: [
        'KPIs consolidados por sucursal',
        'Análisis de rentabilidad',
        'Tendencias de crecimiento',
        'Predicciones financieras',
        'Benchmarking entre sucursales',
        'Reportes personalizables',
        'Exportación a Excel/PDF',
        'Alertas de desempeño',
      ],
    );
  }
}
