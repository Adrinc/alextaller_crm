import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/empleados_globales_provider.dart';
import 'package:nethive_neo/models/talleralex/empleados_globales_models.dart';

class EmpleadosGlobalesTable extends StatefulWidget {
  final EmpleadosGlobalesProvider provider;

  const EmpleadosGlobalesTable({
    super.key,
    required this.provider,
  });

  @override
  State<EmpleadosGlobalesTable> createState() => _EmpleadosGlobalesTableState();
}

class _EmpleadosGlobalesTableState extends State<EmpleadosGlobalesTable> {
  PlutoGridStateManager? stateManager;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: widget.provider.isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          : widget.provider.error != null
              ? _buildErrorState(theme)
              : widget.provider.empleados.isEmpty
                  ? _buildEmptyState(theme)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: PlutoGrid(
                        columns: _buildColumns(theme),
                        rows: widget.provider.empleadosRows,
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          stateManager = event.stateManager;
                        },
                        configuration: PlutoGridConfiguration(
                          localeText: const PlutoGridLocaleText.spanish(),
                          style: PlutoGridStyleConfig(
                            gridBackgroundColor: Colors.white,
                            rowHeight: 70,
                            columnHeight: 50,
                            borderColor: Colors.grey.shade200,
                            activatedBorderColor: theme.primaryColor,
                            activatedColor: theme.primaryColor.withOpacity(0.1),
                            checkedColor: theme.primaryColor.withOpacity(0.2),
                            cellTextStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: theme.primaryText,
                            ),
                            columnTextStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildErrorState(AppTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
            ),
            const SizedBox(height: 8),
            Text(
              widget.provider.error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.provider.cargarEmpleadosGlobales(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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

  List<PlutoColumn> _buildColumns(AppTheme theme) {
    return [
      PlutoColumn(
        title: '#',
        field: 'numero',
        type: PlutoColumnType.text(),
        width: 60,
        minWidth: 60,
        readOnly: true,
        renderer: (rendererContext) {
          return Container(
            alignment: Alignment.center,
            child: Text(
              rendererContext.cell.value.toString(),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Empleado',
        field: 'empleado',
        type: PlutoColumnType.text(),
        width: 350,
        minWidth: 150,
        readOnly: true,
        renderer: (rendererContext) {
          final empleadoId = rendererContext.row.cells['acciones']?.value;
          final empleado = widget.provider.getEmpleadoById(empleadoId);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Avatar/Imagen
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: empleado?.imagenPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            empleado!.imagenPath!,
                            width: 40,
                            height: 40,
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

                // Información del empleado
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        empleado?.empleadoNombre ?? 'Empleado',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryText,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (empleado?.correo != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          empleado!.correo!,
                          style: GoogleFonts.poppins(
                            color: theme.secondaryText,
                            fontSize: 11,
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
        title: 'Puesto',
        field: 'puesto',
        type: PlutoColumnType.text(),
        width: 150,
        minWidth: 100,
        readOnly: true,
        renderer: (rendererContext) {
          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                rendererContext.cell.value.toString(),
                style: GoogleFonts.poppins(
                  color: theme.primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Sucursal',
        field: 'sucursal',
        type: PlutoColumnType.text(),
        width: 250,
        minWidth: 120,
        readOnly: true,
        renderer: (rendererContext) {
          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              rendererContext.cell.value.toString(),
              style: GoogleFonts.poppins(
                color: theme.primaryText,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Estado de Turno',
        field: 'turno',
        type: PlutoColumnType.text(),
        width: 250,
        minWidth: 120,
        readOnly: true,
        renderer: (rendererContext) {
          final empleadoId = rendererContext.row.cells['acciones']?.value;
          final empleado = widget.provider.getEmpleadoById(empleadoId);

          Color indicatorColor = Colors.grey;
          IconData indicatorIcon = Icons.schedule;

          if (empleado != null) {
            switch (empleado.colorTurno) {
              case 'verde':
                indicatorColor = Colors.green;
                indicatorIcon = Icons.check_circle;
                break;
              case 'naranja':
                indicatorColor = Colors.orange;
                indicatorIcon = Icons.access_time;
                break;
              case 'gris':
                indicatorColor = Colors.grey;
                indicatorIcon = Icons.cancel;
                break;
            }
          }

          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  indicatorIcon,
                  size: 16,
                  color: indicatorColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rendererContext.cell.value.toString(),
                        style: GoogleFonts.poppins(
                          color: indicatorColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (empleado?.horarioTurno != 'Sin turno') ...[
                        Text(
                          empleado?.horarioTurno ?? '',
                          style: GoogleFonts.poppins(
                            color: theme.secondaryText,
                            fontSize: 10,
                          ),
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
        title: 'Carga de Trabajo',
        field: 'carga',
        type: PlutoColumnType.text(),
        width: 250,
        minWidth: 100,
        readOnly: true,
        renderer: (rendererContext) {
          final empleadoId = rendererContext.row.cells['acciones']?.value;
          final empleado = widget.provider.getEmpleadoById(empleadoId);

          Color badgeColor = Colors.green;
          if (empleado != null) {
            switch (empleado.colorCarga) {
              case 'verde':
                badgeColor = Colors.green;
                break;
              case 'azul':
                badgeColor = Colors.blue;
                break;
              case 'naranja':
                badgeColor = Colors.orange;
                break;
              case 'rojo':
                badgeColor = Colors.red;
                break;
            }
          }

          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rendererContext.cell.value.toString(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    empleado?.nivelCarga ?? '',
                    style: GoogleFonts.poppins(
                      color: theme.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Acciones',
        field: 'acciones',
        type: PlutoColumnType.text(),
        width: 250,
        minWidth: 140,
        readOnly: true,
        renderer: (rendererContext) {
          final empleadoId = rendererContext.cell.value.toString();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                // Botón Transferir
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _mostrarDialogoTransferencia(empleadoId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Transferir',
                      style: GoogleFonts.poppins(fontSize: 10),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // Botón Menú de opciones
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: theme.alternate),
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, empleadoId),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: theme.primaryText,
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'cambiar_rol',
                        child: Row(
                          children: [
                            Icon(Icons.admin_panel_settings, size: 16),
                            SizedBox(width: 8),
                            Text('Cambiar Rol'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'programar_turno',
                        child: Row(
                          children: [
                            Icon(Icons.schedule, size: 16),
                            SizedBox(width: 8),
                            Text('Programar Turno'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ];
  }

  void _mostrarDialogoTransferencia(String empleadoId) {
    final empleado = widget.provider.getEmpleadoById(empleadoId);
    if (empleado == null) return;

    showDialog(
      context: context,
      builder: (context) => _DialogoTransferencia(
        empleado: empleado,
        sucursales: widget.provider.sucursales,
        onTransferir: (nuevaSucursalId) =>
            widget.provider.transferirEmpleado(empleadoId, nuevaSucursalId),
      ),
    );
  }

  void _handleMenuAction(String action, String empleadoId) {
    switch (action) {
      case 'cambiar_rol':
        _mostrarDialogoCambiarRol(empleadoId);
        break;
      case 'programar_turno':
        _mostrarDialogoProgramarTurno(empleadoId);
        break;
    }
  }

  void _mostrarDialogoCambiarRol(String empleadoId) {
    final empleado = widget.provider.getEmpleadoById(empleadoId);
    if (empleado == null) return;

    showDialog(
      context: context,
      builder: (context) => _DialogoCambiarRol(
        empleado: empleado,
        onCambiarRol: (nuevoRoleId) => widget.provider
            .cambiarRolEmpleado(empleado.empleadoId, nuevoRoleId),
      ),
    );
  }

  void _mostrarDialogoProgramarTurno(String empleadoId) {
    final empleado = widget.provider.getEmpleadoById(empleadoId);
    if (empleado == null) return;

    showDialog(
      context: context,
      builder: (context) => _DialogoProgramarTurno(
        empleado: empleado,
        onProgramar: (inicio, fin, tipo) => widget.provider.programarTurno(
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

// Dialogo para transferir empleado
class _DialogoTransferencia extends StatefulWidget {
  final EmpleadoGlobalGrid empleado;
  final List<SucursalEmpleado> sucursales;
  final Future<bool> Function(String nuevaSucursalId) onTransferir;

  const _DialogoTransferencia({
    required this.empleado,
    required this.sucursales,
    required this.onTransferir,
  });

  @override
  State<_DialogoTransferencia> createState() => _DialogoTransferenciaState();
}

class _DialogoTransferenciaState extends State<_DialogoTransferencia> {
  SucursalEmpleado? _sucursalSeleccionada;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final sucursalesDisponibles = widget.sucursales
        .where((s) => s.id != widget.empleado.sucursalId)
        .toList();

    return AlertDialog(
      title: const Text('Transferir Empleado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Empleado: ${widget.empleado.empleadoNombre}'),
          Text('Sucursal actual: ${widget.empleado.sucursalNombre}'),
          const SizedBox(height: 16),
          const Text('Selecciona nueva sucursal:'),
          const SizedBox(height: 8),
          DropdownButtonFormField<SucursalEmpleado>(
            value: _sucursalSeleccionada,
            items: sucursalesDisponibles.map((sucursal) {
              return DropdownMenuItem(
                value: sucursal,
                child: Text(sucursal.nombre),
              );
            }).toList(),
            onChanged: _isProcessing
                ? null
                : (value) {
                    setState(() {
                      _sucursalSeleccionada = value;
                    });
                  },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Selecciona sucursal',
            ),
          ),
        ],
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

// Dialogo para cambiar rol
class _DialogoCambiarRol extends StatefulWidget {
  final EmpleadoGlobalGrid empleado;
  final Future<bool> Function(int nuevoRoleId) onCambiarRol;

  const _DialogoCambiarRol({
    required this.empleado,
    required this.onCambiarRol,
  });

  @override
  State<_DialogoCambiarRol> createState() => _DialogoCambiarRolState();
}

class _DialogoCambiarRolState extends State<_DialogoCambiarRol> {
  RolEmpleado? _rolSeleccionado;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar Rol'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Empleado: ${widget.empleado.empleadoNombre}'),
          const SizedBox(height: 16),
          ...RolEmpleado.rolesDisponibles.map(
            (rol) => RadioListTile<RolEmpleado>(
              title: Text(rol.nombre),
              subtitle: Text(rol.descripcion),
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

// Dialogo para programar turno
class _DialogoProgramarTurno extends StatefulWidget {
  final EmpleadoGlobalGrid empleado;
  final Future<bool> Function(DateTime inicio, DateTime fin, String tipo)
      onProgramar;

  const _DialogoProgramarTurno({
    required this.empleado,
    required this.onProgramar,
  });

  @override
  State<_DialogoProgramarTurno> createState() => _DialogoProgramarTurnoState();
}

class _DialogoProgramarTurnoState extends State<_DialogoProgramarTurno> {
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now().add(const Duration(hours: 8));
  String _tipoTurno = 'normal';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Programar Turno'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Empleado: ${widget.empleado.empleadoNombre}'),
          const SizedBox(height: 16),

          // Tipo de turno
          DropdownButtonFormField<String>(
            value: _tipoTurno,
            items: const [
              DropdownMenuItem(value: 'normal', child: Text('Turno Normal')),
              DropdownMenuItem(value: 'extra', child: Text('Turno Extra')),
              DropdownMenuItem(
                  value: 'nocturno', child: Text('Turno Nocturno')),
            ],
            onChanged: (value) => setState(() => _tipoTurno = value!),
            decoration: const InputDecoration(
              labelText: 'Tipo de Turno',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // Fecha y hora inicio
          ListTile(
            title: const Text('Inicio'),
            subtitle: Text(
                '${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year} ${_fechaInicio.hour}:${_fechaInicio.minute.toString().padLeft(2, '0')}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _seleccionarFecha(true),
          ),

          // Fecha y hora fin
          ListTile(
            title: const Text('Fin'),
            subtitle: Text(
                '${_fechaFin.day}/${_fechaFin.month}/${_fechaFin.year} ${_fechaFin.hour}:${_fechaFin.minute.toString().padLeft(2, '0')}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _seleccionarFecha(false),
          ),
        ],
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
