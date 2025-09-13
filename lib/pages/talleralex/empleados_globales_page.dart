import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/empleados_globales_provider.dart';

import 'package:nethive_neo/pages/talleralex/widgets/empleados_globales_table.dart';
import 'package:nethive_neo/pages/talleralex/widgets/empleados_globales_cards.dart';
import 'package:nethive_neo/pages/talleralex/widgets/global_sidebar.dart';
import 'widgets/responsive_drawer.dart';

class EmpleadosGlobalesPage extends StatefulWidget {
  const EmpleadosGlobalesPage({super.key});

  @override
  State<EmpleadosGlobalesPage> createState() => _EmpleadosGlobalesPageState();
}

class _EmpleadosGlobalesPageState extends State<EmpleadosGlobalesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<EmpleadosGlobalesProvider>(context, listen: false);
      provider.cargarEmpleadosGlobales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Row(
        children: [
          // GlobalSidebar para pantallas grandes
          if (!isSmallScreen)
            const GlobalSidebar(currentRoute: '/empleados-globales'),

          // Contenido principal
          Expanded(
            child: Consumer<EmpleadosGlobalesProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    // Header con filtros
                    _buildHeader(provider, isSmallScreen),

                    // Contenido principal
                    Expanded(
                      child: _buildContent(provider, isSmallScreen),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      // Drawer para pantallas pequeñas
      drawer: isSmallScreen
          ? const ResponsiveDrawer(currentRoute: '/empleados-globales')
          : null,
    );
  }

  Widget _buildHeader(EmpleadosGlobalesProvider provider, bool isSmallScreen) {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y stats
          Row(
            children: [
              // Botón de menú para móvil
              if (isSmallScreen) ...[
                Builder(
                  builder: (context) => IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Título principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor,
                                theme.primaryColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.groups,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Empleados Globales',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 20 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryText,
                                ),
                              ),
                              Text(
                                'Gestión integral de empleados en todas las sucursales',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: theme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats rápidas
              if (!isSmallScreen) ...[
                _buildStatCard(
                  icon: Icons.people,
                  label: 'Total',
                  value: provider.empleados.length.toString(),
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'Activos',
                  value: provider.empleados
                      .where((e) => e.activo)
                      .length
                      .toString(),
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  icon: Icons.access_time,
                  label: 'En Turno',
                  value: provider.empleados
                      .where((e) => e.estadoTurno == 'En turno')
                      .length
                      .toString(),
                  color: Colors.orange,
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Barra de búsqueda y filtros
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Búsqueda
              SizedBox(
                width: isSmallScreen ? double.infinity : 300,
                child: TextField(
                  onChanged: provider.filtrarPorTexto,
                  decoration: InputDecoration(
                    hintText: 'Buscar empleados...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.primaryBackground,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // Filtro por sucursal
              Container(
                constraints: BoxConstraints(
                  minWidth: isSmallScreen ? double.infinity : 200,
                ),
                child: DropdownButtonFormField<String>(
                  value: provider.filtros.sucursalId,
                  onChanged: provider.filtrarPorSucursal,
                  decoration: InputDecoration(
                    labelText: 'Sucursal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.primaryBackground,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todas las sucursales'),
                    ),
                    ...provider.sucursales.map(
                      (sucursal) => DropdownMenuItem<String>(
                        value: sucursal.id,
                        child: Text(sucursal.nombre),
                      ),
                    ),
                  ],
                ),
              ),

              // Filtro por estado de turno
              Container(
                constraints: BoxConstraints(
                  minWidth: isSmallScreen ? double.infinity : 160,
                ),
                child: DropdownButtonFormField<String>(
                  value: provider.filtros.estadoTurno,
                  onChanged: provider.filtrarPorEstadoTurno,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.primaryBackground,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todos los estados'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'En turno',
                      child: Text('En turno'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Próximo turno',
                      child: Text('Próximo turno'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Sin turno',
                      child: Text('Sin turno'),
                    ),
                  ],
                ),
              ),

              // Botón limpiar filtros
              ElevatedButton.icon(
                onPressed: provider.limpiarFiltros,
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.secondaryBackground,
                  foregroundColor: theme.primaryText,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.alternate),
                  ),
                ),
              ),

              // Botón refrescar
              ElevatedButton.icon(
                onPressed: provider.cargarEmpleadosGlobales,
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Actualizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          // Stats móvil
          if (isSmallScreen && provider.empleados.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.people,
                    label: 'Total',
                    value: provider.empleados.length.toString(),
                    color: theme.primaryColor,
                    isSmall: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.check_circle,
                    label: 'Activos',
                    value: provider.empleados
                        .where((e) => e.activo)
                        .length
                        .toString(),
                    color: Colors.green,
                    isSmall: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.access_time,
                    label: 'En Turno',
                    value: provider.empleados
                        .where((e) => e.estadoTurno == 'En turno')
                        .length
                        .toString(),
                    color: Colors.orange,
                    isSmall: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: isSmall
          ? Column(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: color,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildContent(EmpleadosGlobalesProvider provider, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: isSmallScreen
            ? EmpleadosGlobalesCards(provider: provider)
            : EmpleadosGlobalesTable(provider: provider),
      ),
    );
  }
}
