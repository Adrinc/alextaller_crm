// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/models/talleralex/citas_ordenes_models.dart';
import 'package:nethive_neo/models/talleralex/clientes_models.dart';
import 'package:nethive_neo/providers/talleralex/citas_ordenes_provider.dart';
import 'package:nethive_neo/helpers/globals.dart';

class CitaDetalleDialog extends StatefulWidget {
  final CitaActiva cita;
  final String sucursalId;

  const CitaDetalleDialog({
    super.key,
    required this.cita,
    required this.sucursalId,
  });

  @override
  State<CitaDetalleDialog> createState() => _CitaDetalleDialogState();
}

class _CitaDetalleDialogState extends State<CitaDetalleDialog> {
  ClienteGrid? cliente;
  List<HistorialCliente> historial = [];
  bool isLoadingCliente = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _cargarDetallesCliente();
  }

  Future<void> _cargarDetallesCliente() async {
    try {
      setState(() {
        isLoadingCliente = true;
        error = null;
      });

      // Cargar detalles del cliente desde vw_clientes_sucursal
      final clienteResponse = await supabaseLU
          .from('vw_clientes_sucursal')
          .select()
          .eq('cliente_id', widget.cita.clienteId)
          .eq('sucursal_id', widget.sucursalId)
          .single();

      cliente = ClienteGrid.fromJson(clienteResponse);

      // Cargar historial del cliente desde vw_historial_cliente
      final historialResponse = await supabaseLU
          .from('vw_historial_cliente')
          .select()
          .eq('cliente_id', widget.cita.clienteId)
          .order('fecha_inicio', ascending: false)
          .limit(5);

      historial = (historialResponse as List<dynamic>)
          .map((json) => HistorialCliente.fromJson(json))
          .toList();

      setState(() {
        isLoadingCliente = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al cargar detalles: $e';
        isLoadingCliente = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenSize.width * 0.8,
        height: screenSize.height * 0.8,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header del dialog
            _buildHeader(theme),

            // Contenido principal
            Expanded(
              child: isLoadingCliente
                  ? _buildLoadingState(theme)
                  : error != null
                      ? _buildErrorState(theme)
                      : _buildContent(theme),
            ),

            // Footer con acciones
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.secondaryColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event,
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
                  'Detalles de la Cita',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${widget.cita.citaId}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda - Información de la cita
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildCitaInfoCard(theme),
                const SizedBox(height: 16),
                _buildVehiculoInfoCard(theme),
                const SizedBox(height: 16),
                _buildServiciosCard(theme),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Columna derecha - Información del cliente
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildClienteInfoCard(theme),
                const SizedBox(height: 16),
                _buildHistorialCard(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitaInfoCard(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(8, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Información de la Cita',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryText,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Fecha y Hora:', widget.cita.fechaHoraTexto, theme),
          _buildInfoRow('Duración:', widget.cita.duracionTexto, theme),
          _buildInfoRow('Estado:', widget.cita.estado.texto, theme,
              isStatus: true, status: widget.cita.estado),
          _buildInfoRow('Fuente:', widget.cita.fuente.texto, theme),
          _buildInfoRow('Bahía:',
              widget.cita.tieneBahia ? 'Asignada' : 'Sin asignar', theme),
          if (widget.cita.retrasoTexto.isNotEmpty)
            _buildInfoRow('Retraso:', widget.cita.retrasoTexto, theme,
                isError: true),
        ],
      ),
    );
  }

  Widget _buildVehiculoInfoCard(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(8, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Información del Vehículo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryText,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Placa:', widget.cita.placa, theme),
          _buildInfoRow('Marca:', widget.cita.marca, theme),
          _buildInfoRow('Modelo:', widget.cita.modelo, theme),
          _buildInfoRow('Año:', widget.cita.anio.toString(), theme),
        ],
      ),
    );
  }

  Widget _buildServiciosCard(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(8, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.build,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Servicios Programados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryText,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.cita.servicios.isEmpty)
            Text(
              'Sin servicios especificados',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
                fontFamily: 'Poppins',
              ),
            )
          else
            ...widget.cita.servicios.map((servicio) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          servicio,
                          style: TextStyle(
                            color: theme.primaryText,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildClienteInfoCard(AppTheme theme) {
    if (cliente == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(8, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar del cliente con imagen
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.secondaryColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: _buildClienteImage(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cliente',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      cliente!.clienteNombre,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryText,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (cliente!.telefono != null)
            _buildInfoRow('Teléfono:', cliente!.telefono!, theme),
          if (cliente!.correo != null)
            _buildInfoRow('Correo:', cliente!.correo!, theme),
          if (cliente!.direccion != null)
            _buildInfoRow('Dirección:', cliente!.direccion!, theme),
          _buildInfoRow(
              'Vehículos:', cliente!.totalVehiculos.toString(), theme),
          _buildInfoRow('Total Gastado:', cliente!.totalGastadoTexto, theme),
          _buildInfoRow('Última Visita:', cliente!.ultimaVisitaTexto, theme),
        ],
      ),
    );
  }

  Widget _buildClienteImage() {
    if (cliente?.imagenPath != null && cliente!.imagenPath!.isNotEmpty) {
      return Image.network(
        cliente!.imagenPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildClienteInitials();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          );
        },
      );
    }

    return _buildClienteInitials();
  }

  Widget _buildClienteInitials() {
    return Center(
      child: Text(
        _getInitials(cliente?.clienteNombre ?? widget.cita.clienteNombre),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildHistorialCard(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(8, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Historial Reciente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryText,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (historial.isEmpty)
            Text(
              'Sin historial previo',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
                fontFamily: 'Poppins',
              ),
            )
          else
            ...historial.map((orden) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            orden.vehiculoTexto,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: theme.primaryText,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            orden.totalTexto,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.green.shade600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orden.estado.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, AppTheme theme,
      {bool isStatus = false, EstadoCita? status, bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
            child: isStatus
                ? _buildStatusChip(value, status!, theme)
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isError ? Colors.red.shade600 : theme.primaryText,
                      fontFamily: 'Poppins',
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, EstadoCita estado, AppTheme theme) {
    Color color;
    Color backgroundColor;

    switch (estado) {
      case EstadoCita.pendiente:
        color = Colors.orange.shade600;
        backgroundColor = Colors.orange.shade50;
        break;
      case EstadoCita.confirmada:
        color = Colors.green.shade600;
        backgroundColor = Colors.green.shade50;
        break;
      case EstadoCita.completada:
        color = Colors.indigo.shade600;
        backgroundColor = Colors.indigo.shade50;
        break;
      case EstadoCita.cancelada:
        color = Colors.red.shade600;
        backgroundColor = Colors.red.shade50;
        break;
      case EstadoCita.noAsistio:
        color = Colors.grey.shade600;
        backgroundColor = Colors.grey.shade100;
        break;
      default:
        color = Colors.grey.shade600;
        backgroundColor = Colors.grey.shade100;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
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
            color: theme.primaryColor,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando detalles...',
            style: TextStyle(
              color: theme.primaryText,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: theme.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            error!,
            style: TextStyle(
              color: theme.error,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _cargarDetallesCliente,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón confirmar cita
          if (widget.cita.estado == EstadoCita.pendiente)
            ElevatedButton.icon(
              onPressed: () => _confirmarCita(),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Confirmar Cita'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

          const SizedBox(width: 12),

          // Botón crear orden
          if (widget.cita.estado == EstadoCita.confirmada)
            ElevatedButton.icon(
              onPressed: () => _crearOrden(),
              icon: const Icon(Icons.build, size: 18),
              label: const Text('Crear Orden'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

          const SizedBox(width: 12),

          // Botón cerrar
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: TextStyle(
                color: theme.primaryColor,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String nombre) {
    final words = nombre.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  void _confirmarCita() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Confirmar cita de ${widget.cita.clienteNombre}'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
  }

  void _crearOrden() {
    final provider = context.read<CitasOrdenesProvider>();

    provider.crearOrdenDesdeCita(widget.cita.citaId).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Orden creada para ${widget.cita.clienteNombre}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error al crear orden para ${widget.cita.clienteNombre}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      Navigator.of(context).pop();
    });
  }
}
