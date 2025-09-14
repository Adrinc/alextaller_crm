import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/clientes_globales_provider.dart';

class ClientesGlobalesTable extends StatelessWidget {
  final ClientesGlobalesProvider provider;
  final Function(dynamic cliente)? onVerDetalle;
  final Function(dynamic cliente)? onMostrarOpciones;

  const ClientesGlobalesTable({
    super.key,
    required this.provider,
    this.onVerDetalle,
    this.onMostrarOpciones,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar clientes',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                provider.error!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: theme.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.cargarClientesGlobales(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.clientes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: theme.secondaryText,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay clientes registrados',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildPlutoGrid(context, theme);
  }

  Widget _buildPlutoGrid(BuildContext context, AppTheme theme) {
    return PlutoGrid(
      columns: _buildColumns(context, theme),
      rows: provider.clientesRows,
      onChanged: (PlutoGridOnChangedEvent event) {
        // Manejar cambios si es necesario
      },
      onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
        final clienteId = event.row.cells['acciones']?.value as String?;
        if (clienteId != null) {
          _mostrarDetalleCliente(context, clienteId);
        }
      },
      configuration: PlutoGridConfiguration(
        localeText: const PlutoGridLocaleText.spanish(),
        style: PlutoGridStyleConfig(
          gridBackgroundColor: Colors.white,
          rowHeight: 80,
          columnHeight: 50,
          borderColor: theme.alternate.withOpacity(0.3),
          activatedBorderColor: theme.primaryColor,
          gridBorderColor: theme.alternate.withOpacity(0.2),
          columnTextStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
          cellTextStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: theme.primaryText,
          ),
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.scale,
        ),
        scrollbar: const PlutoGridScrollbarConfig(
          isAlwaysShown: true,
        ),
      ),
    );
  }

  List<PlutoColumn> _buildColumns(BuildContext context, AppTheme theme) {
    return [
      PlutoColumn(
        title: '#',
        field: 'numero',
        type: PlutoColumnType.text(),
        width: 60,
        minWidth: 60,
        enableSorting: false,
        enableContextMenu: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Cliente',
        field: 'nombre',
        type: PlutoColumnType.text(),
        width: 200,
        minWidth: 150,
        renderer: (rendererContext) {
          final cliente = provider.getClienteById(
              rendererContext.row.cells['acciones']?.value as String? ?? '');

          return Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Avatar o imagen del cliente
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: cliente?.imagenPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            cliente!.imagenPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                color: theme.primaryColor,
                                size: 20,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                ),

                const SizedBox(width: 12),

                // Información del cliente
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        rendererContext.cell.value.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (cliente?.telefono != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          cliente!.telefono!,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: theme.secondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Contacto',
        field: 'correo',
        type: PlutoColumnType.text(),
        width: 180,
        minWidth: 150,
        renderer: (rendererContext) {
          final cliente = provider.getClienteById(
              rendererContext.row.cells['acciones']?.value as String? ?? '');

          return Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (cliente?.correo != null) ...[
                  Row(
                    children: [
                      Icon(Icons.email, size: 12, color: theme.secondaryText),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          cliente!.correo!,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: theme.primaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (cliente?.rfc != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.receipt, size: 12, color: theme.secondaryText),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          cliente!.rfc!,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: theme.secondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Total Gastado',
        field: 'total_gastado',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        textAlign: PlutoColumnTextAlign.right,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final cliente = provider.getClienteById(
              rendererContext.row.cells['acciones']?.value as String? ?? '');

          Color montoColor = theme.primaryColor;
          if (cliente != null) {
            switch (cliente.clasificacionCliente) {
              case 'VIP':
                montoColor = Colors.amber.shade700;
                break;
              case 'Premium':
                montoColor = Colors.purple;
                break;
              case 'Frecuente':
                montoColor = Colors.green;
                break;
              case 'Ocasional':
                montoColor = Colors.blue;
                break;
              default:
                montoColor = theme.secondaryText;
            }
          }

          return Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              rendererContext.cell.value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: montoColor,
              ),
              textAlign: TextAlign.right,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Última Visita',
        field: 'ultima_visita',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final cliente = provider.getClienteById(
              rendererContext.row.cells['acciones']?.value as String? ?? '');

          Color fechaColor = theme.primaryText;
          if (cliente != null) {
            switch (cliente.estadoCliente) {
              case 'Activo':
                fechaColor = Colors.green;
                break;
              case 'Regular':
                fechaColor = Colors.blue;
                break;
              case 'En riesgo':
                fechaColor = Colors.orange;
                break;
              case 'Inactivo':
                fechaColor = Colors.red;
                break;
              default:
                fechaColor = theme.secondaryText;
            }
          }

          return Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              rendererContext.cell.value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: fechaColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Sucursal',
        field: 'sucursal',
        type: PlutoColumnType.text(),
        width: 150,
        minWidth: 120,
        renderer: (rendererContext) {
          return Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: theme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    rendererContext.cell.value.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Estado',
        field: 'clasificacion',
        type: PlutoColumnType.text(),
        width: 100,
        minWidth: 80,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final cliente = provider.getClienteById(
              rendererContext.row.cells['acciones']?.value as String? ?? '');

          if (cliente == null) {
            return Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                rendererContext.cell.value.toString(),
                style: GoogleFonts.poppins(fontSize: 10),
              ),
            );
          }

          Color badgeColor;
          Color textColor = Colors.white;

          switch (cliente.clasificacionCliente) {
            case 'VIP':
              badgeColor = Colors.amber.shade700;
              break;
            case 'Premium':
              badgeColor = Colors.purple;
              break;
            case 'Frecuente':
              badgeColor = Colors.green;
              break;
            case 'Ocasional':
              badgeColor = Colors.blue;
              break;
            case 'Nuevo':
              badgeColor = Colors.grey;
              break;
            default:
              badgeColor = theme.secondaryText;
          }

          return Container(
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                cliente.clasificacionCliente,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Vehículos',
        field: 'total_visitas',
        type: PlutoColumnType.text(),
        width: 80,
        minWidth: 70,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Acciones',
        field: 'acciones',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableSorting: false,
        enableContextMenu: false,
        renderer: (rendererContext) {
          final clienteId = rendererContext.cell.value.toString();

          return Container(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Ver historial
                Tooltip(
                  message: 'Ver historial completo',
                  child: InkWell(
                    onTap: () {
                      final cliente = provider.clientesFiltrados
                          .firstWhere((c) => c.clienteId == clienteId);
                      onVerDetalle?.call(cliente);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.history,
                        size: 16,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ),

                // Contactar
                Tooltip(
                  message: 'Contactar cliente',
                  child: InkWell(
                    onTap: () {
                      final cliente = provider.clientesFiltrados
                          .firstWhere((c) => c.clienteId == clienteId);
                      onMostrarOpciones?.call(cliente);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.phone,
                        size: 16,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),

                // Más opciones
                Tooltip(
                  message: 'Más opciones',
                  child: InkWell(
                    onTap: () {
                      final cliente = provider.clientesFiltrados
                          .firstWhere((c) => c.clienteId == clienteId);
                      onMostrarOpciones?.call(cliente);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.secondaryText.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        size: 16,
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ];
  }

  void _mostrarDetalleCliente(BuildContext context, String clienteId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _DialogoDetalleCliente(
        clienteId: clienteId,
        provider: provider,
      ),
    );
  }

  void _contactarCliente(BuildContext context, String clienteId) {
    final cliente = provider.getClienteById(clienteId);
    if (cliente == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contactar Cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${cliente.clienteNombre}'),
            const SizedBox(height: 8),
            if (cliente.telefono != null) ...[
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(cliente.telefono!),
                onTap: () {
                  // Implementar llamada telefónica
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Llamando a ${cliente.telefono}...')),
                  );
                },
              ),
            ],
            if (cliente.correo != null) ...[
              ListTile(
                leading: const Icon(Icons.email),
                title: Text(cliente.correo!),
                onTap: () {
                  // Implementar envío de email
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Enviando email a ${cliente.correo}...')),
                  );
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarMenuOpciones(BuildContext context, String clienteId) {
    final cliente = provider.getClienteById(clienteId);
    if (cliente == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Opciones para ${cliente.clienteNombre}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Ver historial completo'),
              onTap: () {
                Navigator.of(context).pop();
                _mostrarDetalleCliente(context, clienteId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: Text(cliente.clasificacionCliente == 'VIP'
                  ? 'Quitar VIP'
                  : 'Marcar como VIP'),
              onTap: () {
                Navigator.of(context).pop();
                // Implementar cambio de clasificación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Clasificación actualizada')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar información'),
              onTap: () {
                Navigator.of(context).pop();
                // Implementar edición de cliente
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Función en desarrollo')),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DialogoDetalleCliente extends StatefulWidget {
  final String clienteId;
  final ClientesGlobalesProvider provider;

  const _DialogoDetalleCliente({
    required this.clienteId,
    required this.provider,
  });

  @override
  State<_DialogoDetalleCliente> createState() => _DialogoDetalleClienteState();
}

class _DialogoDetalleClienteState extends State<_DialogoDetalleCliente>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Cargar historial completo del cliente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.provider.cargarHistorialCompleto(widget.clienteId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final cliente = widget.provider.getClienteById(widget.clienteId);

    if (cliente == null) {
      return AlertDialog(
        title: const Text('Error'),
        content: const Text('Cliente no encontrado'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      );
    }

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header con información del cliente
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.secondaryColor],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: cliente.imagenPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              cliente.imagenPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 30,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                  ),

                  const SizedBox(width: 16),

                  // Información básica
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente.clienteNombre,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                cliente.clasificacionCliente,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cliente.totalGastadoTexto,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Botón cerrar
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: theme.primaryColor,
              unselectedLabelColor: theme.secondaryText,
              indicatorColor: theme.primaryColor,
              tabs: const [
                Tab(text: 'Historial Técnico'),
                Tab(text: 'Historial Financiero'),
                Tab(text: 'Sucursales Frecuentes'),
              ],
            ),

            // Contenido de tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHistorialTecnico(),
                  _buildHistorialFinanciero(),
                  _buildSucursalesFrecuentes(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorialTecnico() {
    if (widget.provider.historialTecnico.isEmpty) {
      return const Center(
        child: Text('No hay historial técnico disponible'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.provider.historialTecnico.length,
      itemBuilder: (context, index) {
        final registro = widget.provider.historialTecnico[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      registro.vehiculoTexto,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      registro.totalGeneralTexto,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Placa: ${registro.placa}'),
                Text('Estado: ${registro.estado}'),
                Text('Fecha: ${registro.fechaInicioTexto}'),
                if (registro.fechaFinReal != null)
                  Text('Terminado: ${registro.fechaFinTexto}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistorialFinanciero() {
    if (widget.provider.historialFinanciero.isEmpty) {
      return const Center(
        child: Text('No hay historial financiero disponible'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.provider.historialFinanciero.length,
      itemBuilder: (context, index) {
        final registro = widget.provider.historialFinanciero[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      registro.sucursalNombre,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      registro.totalPagadoTexto,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Estado: ${registro.ordenEstado}'),
                Text('Fecha: ${registro.fechaInicioTexto}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSucursalesFrecuentes() {
    if (widget.provider.sucursalesFrecuentes.isEmpty) {
      return const Center(
        child: Text('No hay información de sucursales disponible'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.provider.sucursalesFrecuentes.length,
      itemBuilder: (context, index) {
        final sucursal = widget.provider.sucursalesFrecuentes[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sucursal.sucursalNombre,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text('${sucursal.totalVisitas} visitas'),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${sucursal.porcentajeVisitas.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
