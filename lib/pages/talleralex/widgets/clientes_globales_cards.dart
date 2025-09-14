import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/clientes_globales_provider.dart';

class ClientesGlobalesCardsView extends StatelessWidget {
  final ClientesGlobalesProvider provider;

  const ClientesGlobalesCardsView({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

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

    // Determinar número de columnas basado en el ancho de pantalla
    int crossAxisCount;
    if (screenWidth > 1400) {
      crossAxisCount = 3;
    } else if (screenWidth > 900) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 3.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: provider.clientesFiltrados.length,
        itemBuilder: (context, index) {
          final cliente = provider.clientesFiltrados[index];
          return _ClienteCard(
            cliente: cliente,
            provider: provider,
            onTap: () => _mostrarDetalleCliente(context, cliente.clienteId),
          );
        },
      ),
    );
  }

  void _mostrarDetalleCliente(BuildContext context, String clienteId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _DialogoDetalleClienteMobile(
        clienteId: clienteId,
        provider: provider,
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final dynamic cliente; // ClienteGlobalGrid
  final ClientesGlobalesProvider provider;
  final VoidCallback onTap;

  const _ClienteCard({
    required this.cliente,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // Sombra superior izquierda (luz)
            BoxShadow(
              color: Colors.white,
              offset: const Offset(-4, -4),
              blurRadius: 8,
              spreadRadius: 0,
            ),
            // Sombra inferior derecha (sombra)
            BoxShadow(
              color: Colors.grey.shade400.withOpacity(0.4),
              offset: const Offset(4, 4),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar del cliente
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: cliente.imagenPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.network(
                          cliente.imagenPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              color: theme.primaryColor,
                              size: 30,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: theme.primaryColor,
                        size: 30,
                      ),
              ),

              const SizedBox(width: 16),

              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nombre y clasificación
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cliente.clienteNombre,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Badge de clasificación
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getClasificacionColor(
                                cliente.clasificacionCliente),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            cliente.clasificacionCliente,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Información de contacto
                    Row(
                      children: [
                        if (cliente.telefono != null) ...[
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: theme.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              cliente.telefono!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: theme.primaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.email,
                            size: 14,
                            color: theme.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              cliente.correo ?? 'Sin contacto',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: theme.primaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Total gastado y última visita
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Total gastado
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Gastado',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: theme.secondaryText,
                              ),
                            ),
                            Text(
                              cliente.totalGastadoTexto,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getClasificacionColor(
                                    cliente.clasificacionCliente),
                              ),
                            ),
                          ],
                        ),

                        // Última visita
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Última Visita',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: theme.secondaryText,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getEstadoColor(cliente.estadoCliente)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                cliente.ultimaVisitaTexto,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: _getEstadoColor(cliente.estadoCliente),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Acciones rápidas
              Column(
                children: [
                  // Contactar
                  InkWell(
                    onTap: () => _contactarCliente(context, cliente),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.phone,
                        size: 18,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Más opciones
                  InkWell(
                    onTap: () => _mostrarMenuOpciones(context, cliente),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getClasificacionColor(String clasificacion) {
    switch (clasificacion) {
      case 'VIP':
        return Colors.amber.shade700;
      case 'Premium':
        return Colors.purple;
      case 'Frecuente':
        return Colors.green;
      case 'Ocasional':
        return Colors.blue;
      case 'Nuevo':
        return Colors.grey;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Activo':
        return Colors.green;
      case 'Regular':
        return Colors.blue;
      case 'En riesgo':
        return Colors.orange;
      case 'Inactivo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _contactarCliente(BuildContext context, dynamic cliente) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
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
              'Contactar Cliente',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cliente.clienteNombre,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            if (cliente.telefono != null) ...[
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.phone, color: Colors.green),
                ),
                title: const Text('Llamar'),
                subtitle: Text(cliente.telefono!),
                onTap: () {
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
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.email, color: Colors.blue),
                ),
                title: const Text('Enviar Email'),
                subtitle: Text(cliente.correo!),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Enviando email a ${cliente.correo}...')),
                  );
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _mostrarMenuOpciones(BuildContext context, dynamic cliente) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
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
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.history, color: Colors.blue),
              ),
              title: const Text('Ver historial completo'),
              onTap: () {
                Navigator.of(context).pop();
                provider.cargarHistorialCompleto(cliente.clienteId);

                showDialog(
                  context: context,
                  builder: (context) => _DialogoDetalleClienteMobile(
                    clienteId: cliente.clienteId,
                    provider: provider,
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.star, color: Colors.orange),
              ),
              title: Text(cliente.clasificacionCliente == 'VIP'
                  ? 'Quitar VIP'
                  : 'Marcar como VIP'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clasificación actualizada')),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.grey),
              ),
              title: const Text('Editar información'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función en desarrollo')),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DialogoDetalleClienteMobile extends StatefulWidget {
  final String clienteId;
  final ClientesGlobalesProvider provider;

  const _DialogoDetalleClienteMobile({
    required this.clienteId,
    required this.provider,
  });

  @override
  State<_DialogoDetalleClienteMobile> createState() =>
      _DialogoDetalleClienteMobileState();
}

class _DialogoDetalleClienteMobileState
    extends State<_DialogoDetalleClienteMobile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(cliente.clienteNombre),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Técnico'),
              Tab(text: 'Financiero'),
              Tab(text: 'Sucursales'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildHistorialTecnico(),
            _buildHistorialFinanciero(),
            _buildSucursalesFrecuentes(),
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
                    Expanded(
                      child: Text(
                        registro.vehiculoTexto,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        registro.totalGeneralTexto,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
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
                    Expanded(
                      child: Text(
                        registro.sucursalNombre,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        registro.totalPagadoTexto,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
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
