import 'package:flutter/material.dart';
import '../widgets/global_placeholder_page.dart';

/// Página para inventario global
class InventarioGlobalPage extends StatelessWidget {
  const InventarioGlobalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlobalPlaceholderPage(
      title: 'Inventario Global',
      subtitle: 'Control centralizado de inventarios',
      icon: Icons.inventory,
      route: '/global/inventario-global',
      description:
          'Gestión centralizada del inventario con alertas automáticas y redistribución inteligente',
      features: [
        'Vista consolidada de inventarios',
        'Alertas de stock crítico',
        'Redistribución entre sucursales',
        'Predicción de demanda',
        'Órdenes de compra automáticas',
        'Análisis de rotación',
        'Control de caducidades',
        'Optimización de almacén',
      ],
    );
  }
}
