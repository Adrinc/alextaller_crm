import 'package:flutter/material.dart';
import '../widgets/global_placeholder_page.dart';

/// Página para gestión global de empleados
class EmpleadosGlobalesPage extends StatelessWidget {
  const EmpleadosGlobalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlobalPlaceholderPage(
      title: 'Empleados Globales',
      subtitle: 'Gestión centralizada de empleados',
      icon: Icons.groups,
      route: '/global/empleados-globales',
      description:
          'Administración global de empleados con capacidad de transferencia entre sucursales',
      features: [
        'Visualizar empleados de todas las sucursales',
        'Transferir empleados entre sucursales',
        'Gestionar perfiles y competencias',
        'Historial de asignaciones',
        'Evaluaciones de desempeño',
        'Certificaciones y capacitaciones',
        'Control de nómina global',
        'Reportes de productividad',
      ],
    );
  }
}
