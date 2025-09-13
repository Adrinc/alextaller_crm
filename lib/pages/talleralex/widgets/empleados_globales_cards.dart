import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/empleados_globales_provider.dart';
import 'package:nethive_neo/models/talleralex/empleados_globales_models.dart';

class EmpleadosGlobalesCards extends StatelessWidget {
  final EmpleadosGlobalesProvider provider;

  const EmpleadosGlobalesCards({
    super.key,
    required this.provider,
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
                'Error al cargar empleados',
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
                onPressed: () => provider.cargarEmpleadosGlobales(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.empleados.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.groups_outlined,
                size: 64,
                color: theme.secondaryText,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay empleados registrados',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.empleadosFiltrados.length,
      itemBuilder: (context, index) {
        final empleado = provider.empleadosFiltrados[index];
        return _EmpleadoCard(
          empleado: empleado,
          provider: provider,
        );
      },
    );
  }
}

class _EmpleadoCard extends StatelessWidget {
  final EmpleadoGlobalGrid empleado;
  final EmpleadosGlobalesProvider provider;

  const _EmpleadoCard({
    required this.empleado,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    // Colores para indicadores
    Color turnoColor = Colors.grey;
    IconData turnoIcon = Icons.schedule;
    Color cargaColor = Colors.green;

    switch (empleado.colorTurno) {
      case 'verde':
        turnoColor = Colors.green;
        turnoIcon = Icons.check_circle;
        break;
      case 'naranja':
        turnoColor = Colors.orange;
        turnoIcon = Icons.access_time;
        break;
      case 'gris':
        turnoColor = Colors.grey;
        turnoIcon = Icons.cancel;
        break;
    }

    switch (empleado.colorCarga) {
      case 'verde':
        cargaColor = Colors.green;
        break;
      case 'azul':
        cargaColor = Colors.blue;
        break;
      case 'naranja':
        cargaColor = Colors.orange;
        break;
      case 'rojo':
        cargaColor = Colors.red;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con información principal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.1),
                  theme.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.primaryColor.withOpacity(0.2),
                  child: empleado.imagenPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            empleado.imagenPath!,
                            width: 60,
                            height: 60,
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
                    children: [
                      Text(
                        empleado.empleadoNombre,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          empleado.puesto,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (empleado.correo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          empleado.correo!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Estado activo/inactivo
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: empleado.activo ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    empleado.activo ? 'Activo' : 'Inactivo',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Información de la sucursal
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sucursal
                Row(
                  children: [
                    Icon(
                      Icons.store,
                      size: 16,
                      color: theme.secondaryText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sucursal: ${empleado.sucursalNombre}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: theme.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Indicadores de turno y carga
                Row(
                  children: [
                    // Estado de turno
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: turnoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: turnoColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  turnoIcon,
                                  size: 16,
                                  color: turnoColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  empleado.estadoTurno,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: turnoColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            if (empleado.horarioTurno != 'Sin turno') ...[
                              const SizedBox(height: 4),
                              Text(
                                empleado.horarioTurno,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: theme.secondaryText,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Carga de trabajo
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cargaColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: cargaColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cargaColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    empleado.ordenesAbiertas.toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  empleado.nivelCarga,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: cargaColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              empleado.descripcionCarga,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: theme.secondaryText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (empleado.telefono != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: theme.secondaryText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        empleado.telefono!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: theme.primaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Botones de acción
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoTransferencia(context),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Transferir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _mostrarMenuOpciones(context),
                  icon: const Icon(Icons.more_vert, size: 16),
                  label: const Text('Más'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.secondaryBackground,
                    foregroundColor: theme.primaryText,
                    side: BorderSide(color: theme.alternate),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoTransferencia(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _DialogoTransferenciaMobile(
        empleado: empleado,
        sucursales: provider.sucursales,
        onTransferir: (nuevaSucursalId) =>
            provider.transferirEmpleado(empleado.empleadoId, nuevaSucursalId),
      ),
    );
  }

  void _mostrarMenuOpciones(BuildContext context) {
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
              'Opciones para ${empleado.empleadoNombre}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Cambiar Rol'),
              onTap: () {
                Navigator.of(context).pop();
                _mostrarDialogoCambiarRol(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Programar Turno'),
              onTap: () {
                Navigator.of(context).pop();
                _mostrarDialogoProgramarTurno(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoCambiarRol(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _DialogoCambiarRolMobile(
        empleado: empleado,
        onCambiarRol: (nuevoRoleId) =>
            provider.cambiarRolEmpleado(empleado.empleadoId, nuevoRoleId),
      ),
    );
  }

  void _mostrarDialogoProgramarTurno(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _DialogoProgramarTurnoMobile(
        empleado: empleado,
        onProgramar: (inicio, fin, tipo) => provider.programarTurno(
          empleadoId: empleado.empleadoId,
          sucursalId: empleado.sucursalId,
          fechaInicio: inicio,
          fechaFin: fin,
          tipoTurno: tipo,
        ),
      ),
    );
  }
}

// Versiones móviles de los diálogos (más compactas)
class _DialogoTransferenciaMobile extends StatefulWidget {
  final EmpleadoGlobalGrid empleado;
  final List<SucursalEmpleado> sucursales;
  final Future<bool> Function(String nuevaSucursalId) onTransferir;

  const _DialogoTransferenciaMobile({
    required this.empleado,
    required this.sucursales,
    required this.onTransferir,
  });

  @override
  State<_DialogoTransferenciaMobile> createState() =>
      _DialogoTransferenciaMobileState();
}

class _DialogoTransferenciaMobileState
    extends State<_DialogoTransferenciaMobile> {
  SucursalEmpleado? _sucursalSeleccionada;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final sucursalesDisponibles = widget.sucursales
        .where((s) => s.id != widget.empleado.sucursalId)
        .toList();

    return AlertDialog(
      title: Text(
        'Transferir Empleado',
        style: GoogleFonts.poppins(fontSize: 16),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Empleado:',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    widget.empleado.empleadoNombre,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sucursal actual:',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    widget.empleado.sucursalNombre,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nueva sucursal:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...sucursalesDisponibles.map(
              (sucursal) => RadioListTile<SucursalEmpleado>(
                title: Text(sucursal.nombre),
                value: sucursal,
                groupValue: _sucursalSeleccionada,
                onChanged: _isProcessing
                    ? null
                    : (value) {
                        setState(() {
                          _sucursalSeleccionada = value;
                        });
                      },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isProcessing || _sucursalSeleccionada == null
              ? null
              : _transferir,
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Transferir'),
        ),
      ],
    );
  }

  Future<void> _transferir() async {
    if (_sucursalSeleccionada == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final success = await widget.onTransferir(_sucursalSeleccionada!.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Empleado transferido a ${_sucursalSeleccionada!.nombre}'
                : 'Error al transferir empleado'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

class _DialogoCambiarRolMobile extends StatefulWidget {
  final EmpleadoGlobalGrid empleado;
  final Future<bool> Function(int nuevoRoleId) onCambiarRol;

  const _DialogoCambiarRolMobile({
    required this.empleado,
    required this.onCambiarRol,
  });

  @override
  State<_DialogoCambiarRolMobile> createState() =>
      _DialogoCambiarRolMobileState();
}

class _DialogoCambiarRolMobileState extends State<_DialogoCambiarRolMobile> {
  RolEmpleado? _rolSeleccionado;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Cambiar Rol',
        style: GoogleFonts.poppins(fontSize: 16),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.empleado.empleadoNombre,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...RolEmpleado.rolesDisponibles.map(
              (rol) => RadioListTile<RolEmpleado>(
                title: Text(rol.nombre),
                subtitle: Text(
                  rol.descripcion,
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                value: rol,
                groupValue: _rolSeleccionado,
                onChanged: _isProcessing
                    ? null
                    : (value) {
                        setState(() {
                          _rolSeleccionado = value;
                        });
                      },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed:
              _isProcessing || _rolSeleccionado == null ? null : _cambiarRol,
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Cambiar'),
        ),
      ],
    );
  }

  Future<void> _cambiarRol() async {
    if (_rolSeleccionado == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final success = await widget.onCambiarRol(_rolSeleccionado!.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Rol cambiado a ${_rolSeleccionado!.nombre}'
                : 'Error al cambiar rol'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

class _DialogoProgramarTurnoMobile extends StatefulWidget {
  final EmpleadoGlobalGrid empleado;
  final Future<bool> Function(DateTime inicio, DateTime fin, String tipo)
      onProgramar;

  const _DialogoProgramarTurnoMobile({
    required this.empleado,
    required this.onProgramar,
  });

  @override
  State<_DialogoProgramarTurnoMobile> createState() =>
      _DialogoProgramarTurnoMobileState();
}

class _DialogoProgramarTurnoMobileState
    extends State<_DialogoProgramarTurnoMobile> {
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now().add(const Duration(hours: 8));
  String _tipoTurno = 'normal';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Programar Turno',
        style: GoogleFonts.poppins(fontSize: 16),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    widget.empleado.empleadoNombre,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipoTurno,
              decoration: const InputDecoration(
                labelText: 'Tipo de Turno',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 'normal', child: Text('Turno Normal')),
                DropdownMenuItem(value: 'extra', child: Text('Turno Extra')),
                DropdownMenuItem(
                    value: 'nocturno', child: Text('Turno Nocturno')),
              ],
              onChanged: (value) => setState(() => _tipoTurno = value!),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Inicio'),
              subtitle: Text(
                  '${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year} ${_fechaInicio.hour}:${_fechaInicio.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _seleccionarFecha(true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fin'),
              subtitle: Text(
                  '${_fechaFin.day}/${_fechaFin.month}/${_fechaFin.year} ${_fechaFin.hour}:${_fechaFin.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _seleccionarFecha(false),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _programar,
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Programar'),
        ),
      ],
    );
  }

  Future<void> _seleccionarFecha(bool esInicio) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: esInicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fecha != null) {
      final hora = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(esInicio ? _fechaInicio : _fechaFin),
      );

      if (hora != null) {
        final nuevaFecha = DateTime(
          fecha.year,
          fecha.month,
          fecha.day,
          hora.hour,
          hora.minute,
        );

        setState(() {
          if (esInicio) {
            _fechaInicio = nuevaFecha;
          } else {
            _fechaFin = nuevaFecha;
          }
        });
      }
    }
  }

  Future<void> _programar() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final success =
          await widget.onProgramar(_fechaInicio, _fechaFin, _tipoTurno);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Turno programado exitosamente'
                : 'Error al programar turno'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
