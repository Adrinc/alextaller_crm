import 'package:flutter/material.dart';
import '../widgets/global_placeholder_page.dart';

/// Página para configuración del sistema
class ConfiguracionSistemaPage extends StatelessWidget {
  const ConfiguracionSistemaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlobalPlaceholderPage(
      title: 'Configuración del Sistema',
      subtitle: 'Configuraciones técnicas y operativas',
      icon: Icons.settings,
      route: '/global/configuracion-sistema',
      description:
          'Configuraciones técnicas del sistema, integraciones y parámetros operativos globales',
      features: [
        'Configuración de base de datos',
        'Integraciones con APIs externas',
        'Políticas de seguridad',
        'Backup y recuperación',
        'Logs del sistema',
        'Parámetros de rendimiento',
        'Configuración de notificaciones',
        'Mantenimiento programado',
      ],
    );
  }
}
