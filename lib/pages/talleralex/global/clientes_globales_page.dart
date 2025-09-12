import 'package:flutter/material.dart';
import '../widgets/global_placeholder_page.dart';

/// Página para gestión global de clientes
class ClientesGlobalesPage extends StatelessWidget {
  const ClientesGlobalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlobalPlaceholderPage(
      title: 'Clientes Globales',
      subtitle: 'Base consolidada de clientes',
      icon: Icons.people,
      route: '/global/clientes-globales',
      description:
          'Vista consolidada de todos los clientes del sistema con historial completo de servicios',
      features: [
        'Base unificada de clientes',
        'Historial completo de servicios',
        'Análisis de comportamiento',
        'Segmentación de clientes',
        'Programas de lealtad',
        'Comunicación multicanal',
        'Métricas de satisfacción',
        'Predicción de demanda',
      ],
    );
  }
}
