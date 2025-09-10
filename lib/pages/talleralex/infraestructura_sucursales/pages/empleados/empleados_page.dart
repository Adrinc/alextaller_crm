import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/empleados_provider.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/empleados_table.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/nuevo_empleado_dialog.dart';
import 'package:nethive_neo/models/talleralex/empleados_models.dart';

class EmpleadosPage extends StatefulWidget {
  final String sucursalId;

  const EmpleadosPage({
    super.key,
    required this.sucursalId,
  });

  @override
  State<EmpleadosPage> createState() => _EmpleadosPageState();
}

class _EmpleadosPageState extends State<EmpleadosPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Cargar empleados al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmpleadosProvider>().cargarEmpleados(widget.sucursalId);
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: const Offset(-12, -12),
              blurRadius: 24,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.grey.shade400.withOpacity(0.4),
              offset: const Offset(12, 12),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header con gradiente
            _buildHeader(theme),

            // Barra de filtros y acciones
            _buildFiltersBar(theme),

            // Tabla de empleados
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Consumer<EmpleadosProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return _buildLoadingState(theme);
                    }

                    if (provider.error != null) {
                      return _buildErrorState(theme, provider.error!);
                    }

                    return EmpleadosTable(
                      provider: provider,
                      sucursalId: widget.sucursalId,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.secondaryColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Título e información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestión de Empleados',
                            style: theme.title1.override(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Administración de personal y turnos de trabajo',
                            style: theme.bodyText1.override(
                              fontFamily: 'Poppins',
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
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

          // Botón para agregar empleado
          InkWell(
            onTap: _mostrarDialogoNuevoEmpleado,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_add,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nuevo Empleado',
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersBar(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Consumer<EmpleadosProvider>(
        builder: (context, provider, child) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Búsqueda por texto
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  onChanged: provider.aplicarFiltroTexto,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre...',
                    prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: theme.primaryColor.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: theme.primaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // Filtro por puesto
              _buildFilterChip(
                context,
                theme,
                'Puesto',
                provider.filtroPuesto?.displayName ?? 'Todos',
                () => _mostrarFiltroPuesto(context, provider),
              ),

              // Filtro por estado activo
              _buildFilterChip(
                context,
                theme,
                'Estado',
                provider.filtroActivo == null
                    ? 'Todos'
                    : (provider.filtroActivo! ? 'Activos' : 'Inactivos'),
                () => _mostrarFiltroActivo(context, provider),
              ),

              // Filtro por en turno
              _buildFilterChip(
                context,
                theme,
                'Turno',
                provider.filtroEnTurno == null
                    ? 'Todos'
                    : (provider.filtroEnTurno! ? 'En turno' : 'Sin turno'),
                () => _mostrarFiltroTurno(context, provider),
              ),

              // Botón limpiar filtros
              if (provider.filtroTexto.isNotEmpty ||
                  provider.filtroPuesto != null ||
                  provider.filtroActivo != null ||
                  provider.filtroEnTurno != null)
                InkWell(
                  onTap: () {
                    provider.limpiarFiltros();
                    _searchController.clear();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.clear, color: theme.error, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Limpiar',
                          style: theme.bodyText2.override(
                            fontFamily: 'Poppins',
                            color: theme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Contador de resultados
              Text(
                '${provider.empleadosFiltrados.length} empleados',
                style: theme.bodyText2.override(
                  fontFamily: 'Poppins',
                  color: theme.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    AppTheme theme,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                color: theme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: theme.primaryColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando empleados...',
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              color: theme.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppTheme theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: theme.error,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar empleados',
            style: theme.title3.override(
              fontFamily: 'Poppins',
              color: theme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                context.read<EmpleadosProvider>().refrescarEmpleados(),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // Métodos para mostrar diálogos de filtros
  void _mostrarFiltroPuesto(BuildContext context, EmpleadosProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por puesto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              leading: Radio<PuestoEmpleado?>(
                value: null,
                groupValue: provider.filtroPuesto,
                onChanged: (value) {
                  provider.aplicarFiltroPuesto(value);
                  Navigator.of(context).pop();
                },
              ),
            ),
            ...PuestoEmpleado.values
                .map((puesto) => ListTile(
                      title: Text(puesto.displayName),
                      leading: Radio<PuestoEmpleado?>(
                        value: puesto,
                        groupValue: provider.filtroPuesto,
                        onChanged: (value) {
                          provider.aplicarFiltroPuesto(value);
                          Navigator.of(context).pop();
                        },
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  void _mostrarFiltroActivo(BuildContext context, EmpleadosProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              leading: Radio<bool?>(
                value: null,
                groupValue: provider.filtroActivo,
                onChanged: (value) {
                  provider.aplicarFiltroActivo(value);
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('Activos'),
              leading: Radio<bool?>(
                value: true,
                groupValue: provider.filtroActivo,
                onChanged: (value) {
                  provider.aplicarFiltroActivo(value);
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('Inactivos'),
              leading: Radio<bool?>(
                value: false,
                groupValue: provider.filtroActivo,
                onChanged: (value) {
                  provider.aplicarFiltroActivo(value);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarFiltroTurno(BuildContext context, EmpleadosProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por turno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              leading: Radio<bool?>(
                value: null,
                groupValue: provider.filtroEnTurno,
                onChanged: (value) {
                  provider.aplicarFiltroEnTurno(value);
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('En turno'),
              leading: Radio<bool?>(
                value: true,
                groupValue: provider.filtroEnTurno,
                onChanged: (value) {
                  provider.aplicarFiltroEnTurno(value);
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('Sin turno'),
              leading: Radio<bool?>(
                value: false,
                groupValue: provider.filtroEnTurno,
                onChanged: (value) {
                  provider.aplicarFiltroEnTurno(value);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoNuevoEmpleado() {
    showDialog(
      context: context,
      builder: (context) => NuevoEmpleadoDialog(
        sucursalId: widget.sucursalId,
        onEmpleadoCreado: () {
          context.read<EmpleadosProvider>().refrescarEmpleados();
        },
      ),
    );
  }
}
