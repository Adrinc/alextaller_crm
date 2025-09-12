import 'package:flutter/material.dart';
import '../widgets/global_placeholder_page.dart';

/// Página para catálogos corporativos
class CatalogosCorporativosPage extends StatelessWidget {
  const CatalogosCorporativosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlobalPlaceholderPage(
      title: 'Catálogos Corporativos',
      subtitle: 'Administración de catálogos maestros',
      icon: Icons.library_books,
      route: '/global/catalogos-corporativos',
      description:
          'Gestión centralizada de catálogos maestros utilizados por todas las sucursales',
      features: [
        'Catálogo de servicios corporativos',
        'Lista maestra de refacciones',
        'Clasificación de vehículos',
        'Tipos de mantenimiento',
        'Políticas de garantía',
        'Estándares de calidad',
        'Precios corporativos',
        'Sincronización automática',
      ],
    );
  }
}
