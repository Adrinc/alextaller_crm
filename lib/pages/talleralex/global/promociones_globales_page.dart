import 'package:flutter/material.dart';
import '../widgets/global_placeholder_page.dart';

/// Página para promociones globales
class PromocionesGlobalesPage extends StatelessWidget {
  const PromocionesGlobalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlobalPlaceholderPage(
      title: 'Promociones Globales',
      subtitle: 'Gestión de promociones corporativas',
      icon: Icons.local_offer,
      route: '/global/promociones-globales',
      description:
          'Creación y gestión de promociones corporativas con distribución automática a sucursales',
      features: [
        'Crear promociones corporativas',
        'Distribución automática a sucursales',
        'Segmentación de audiencias',
        'Cupones digitales y códigos QR',
        'Seguimiento de efectividad',
        'A/B testing de promociones',
        'Análisis de ROI promocional',
        'Integración con redes sociales',
      ],
    );
  }
}
