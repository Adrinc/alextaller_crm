import 'package:flutter/material.dart';
import '../widgets/global_placeholder_page.dart';

/// Página para historial de servicios global
class HistorialServiciosPage extends StatelessWidget {
  const HistorialServiciosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlobalPlaceholderPage(
      title: 'Historial de Servicios',
      subtitle: 'Registro completo de servicios',
      icon: Icons.history,
      route: '/global/historial-servicios',
      description:
          'Historial completo de servicios realizados en todas las sucursales con análisis de tendencias',
      features: [
        'Historial unificado de servicios',
        'Análisis de tendencias por región',
        'Servicios más demandados',
        'Tiempos promedio de servicio',
        'Análisis de rentabilidad',
        'Predicción de mantenimientos',
        'Reportes de garantías',
        'KPIs de calidad de servicio',
      ],
    );
  }
}
