import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/clientes_provider.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/clientes_table.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/nuevo_cliente_dialog.dart';

class ClientesPage extends StatefulWidget {
  final String sucursalId;

  const ClientesPage({
    super.key,
    required this.sucursalId,
  });

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage>
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

    // Cargar clientes al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ClientesProvider>()
          .cargarClientesSucursal(widget.sucursalId);
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

            // Tabla de clientes
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Consumer<ClientesProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return _buildLoadingState(theme);
                    }

                    if (provider.error != null) {
                      return _buildErrorState(theme, provider.error!);
                    }

                    return ClientesTable(
                      provider: provider,
                      sucursalId: widget.sucursalId,
                      sucursalNombre: 'Sucursal ${widget.sucursalId}',
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
                        Icons.people_outline,
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
                            'Gestión de Clientes',
                            style: theme.title1.override(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Administración de clientes, vehículos e historial de servicios',
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

          // Botón para agregar cliente
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _mostrarDialogoNuevoCliente(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nuevo Cliente',
                        style: theme.bodyText1.override(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersBar(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Consumer<ClientesProvider>(
        builder: (context, provider, child) {
          return Row(
            children: [
              // Buscador
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Buscar clientes por nombre, teléfono, correo o RFC...',
                      hintStyle: theme.bodyText1.override(
                        fontFamily: 'Poppins',
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (value) {
                      provider.aplicarFiltroTexto(value);
                    },
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Filtro por vehículos
              _buildFilterChip(
                theme,
                label: 'Con vehículos',
                isSelected: provider.filtroConVehiculos == true,
                onTap: () {
                  provider.aplicarFiltroConVehiculos(
                    provider.filtroConVehiculos == true ? null : true,
                  );
                },
              ),

              const SizedBox(width: 8),

              // Filtro por citas próximas
              _buildFilterChip(
                theme,
                label: 'Con citas próximas',
                isSelected: provider.filtroConCitasProximas == true,
                onTap: () {
                  provider.aplicarFiltroConCitasProximas(
                    provider.filtroConCitasProximas == true ? null : true,
                  );
                },
              ),

              const SizedBox(width: 8),

              // Botón limpiar filtros
              if (provider.filtroTexto.isNotEmpty ||
                  provider.filtroConVehiculos != null ||
                  provider.filtroConCitasProximas != null ||
                  provider.filtroUltimaVisita != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _searchController.clear();
                        provider.limpiarFiltros();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.clear,
                              size: 16,
                              color: Colors.red.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Limpiar',
                              style: theme.bodyText1.override(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(width: 16),

              // Botón refrescar
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => provider.refrescarClientes(),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.refresh,
                        size: 20,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    AppTheme theme, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? theme.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? theme.primaryColor : Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Text(
              label,
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando clientes...',
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppTheme theme, String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.shade200,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar clientes',
              style: theme.title3.override(
                fontFamily: 'Poppins',
                color: Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<ClientesProvider>()
                    .cargarClientesSucursal(widget.sucursalId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoNuevoCliente(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NuevoClienteDialog(
        sucursalId: widget.sucursalId,
      ),
    );
  }
}
