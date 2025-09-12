import 'package:flutter/material.dart';
import '../widgets/global_placeholder_page.dart';

/// Página para configuración visual
class ConfiguracionVisualPage extends StatelessWidget {
  const ConfiguracionVisualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlobalPlaceholderPage(
      title: 'Configuración Visual',
      subtitle: 'Personalización de temas y branding',
      icon: Icons.palette,
      route: '/global/configuracion-visual',
      description:
          'Configuración global de temas, colores corporativos y elementos de branding',
      features: [
        'Temas claro y oscuro',
        'Colores corporativos',
        'Logotipos por sucursal',
        'Fuentes y tipografías',
        'Plantillas de documentos',
        'Elementos de branding',
        'Vista previa en tiempo real',
        'Aplicación global automática',
      ],
    );
  }
}
