import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/usuarios_pendientes_provider.dart';
import 'package:nethive_neo/models/talleralex/usuarios_pendientes_models.dart';

class UsuariosPendientesTable extends StatefulWidget {
  final UsuariosPendientesProvider provider;

  const UsuariosPendientesTable({
    super.key,
    required this.provider,
  });

  @override
  State<UsuariosPendientesTable> createState() =>
      _UsuariosPendientesTableState();
}

class _UsuariosPendientesTableState extends State<UsuariosPendientesTable> {
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
      child: Consumer<UsuariosPendientesProvider>(
        builder: (context, provider, child) {
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
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar usuarios',
                      style: theme.title2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: theme.bodyText2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.refresh(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.usuarios.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
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
                      '¡Excelente!',
                      style: theme.title2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No hay usuarios pendientes de aprobación',
                      style: theme.bodyText2,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PlutoGrid(
              columns: _buildColumns(theme),
              rows: provider.usuariosRows,
              onLoaded: (PlutoGridOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
              configuration: PlutoGridConfiguration(
                localeText: const PlutoGridLocaleText.spanish(),
                style: PlutoGridStyleConfig(
                  gridBackgroundColor: Colors.white,
                  rowHeight: 65,
                  columnHeight: 50,
                  borderColor: Colors.grey.shade200,
                  gridBorderColor: Colors.grey.shade200,
                  activatedBorderColor: theme.primaryColor,
                  activatedColor: theme.primaryColor.withOpacity(0.1),
                  checkedColor: theme.primaryColor.withOpacity(0.2),
                  cellColorInReadOnlyState: Colors.grey.shade50,
                  columnTextStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: theme.primaryText,
                    fontSize: 13,
                  ),
                  cellTextStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: theme.primaryText,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<PlutoColumn> _buildColumns(AppTheme theme) {
    return [
      PlutoColumn(
        title: '#',
        field: 'numero',
        type: PlutoColumnType.text(),
        width: 100,
        minWidth: 80,
        readOnly: true,
        renderer: (rendererContext) {
          return Container(
            alignment: Alignment.center,
            child: Text(
              rendererContext.cell.value.toString(),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Usuario',
        field: 'nombre',
        type: PlutoColumnType.text(),
        width: 350,
        minWidth: 250,
        readOnly: true,
        renderer: (rendererContext) {
          final usuarioId = rendererContext.row.cells['acciones']?.value;
          final usuario = widget.provider.getUsuarioById(usuarioId);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rendererContext.cell.value.toString(),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: theme.primaryText,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (usuario?.telefono != null)
                  Text(
                    usuario!.telefono!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: theme.secondaryText,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Fecha Registro',
        field: 'fecha_registro',
        type: PlutoColumnType.text(),
        /*     width: 120, */
        minWidth: 150,
        readOnly: true,
        renderer: (rendererContext) {
          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              rendererContext.cell.value.toString(),
              style: TextStyle(
                fontFamily: 'Poppins',
                color: theme.primaryText,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Tiempo Esperando',
        field: 'dias_esperando',
        type: PlutoColumnType.text(),
        /*   width: 130, */
        minWidth: 150,
        readOnly: true,
        renderer: (rendererContext) {
          final usuarioId = rendererContext.row.cells['acciones']?.value;
          final usuario = widget.provider.getUsuarioById(usuarioId);

          Color color = theme.primaryText;
          if (usuario != null) {
            if (usuario.diasEsperando > 7) {
              color = theme.error;
            } else if (usuario.diasEsperando > 3) {
              color = Colors.orange;
            }
          }

          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                rendererContext.cell.value.toString(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 11,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Estado',
        field: 'estado',
        type: PlutoColumnType.text(),
        /*   width: 150, */
        minWidth: 150,
        readOnly: true,
        renderer: (rendererContext) {
          final estado = rendererContext.cell.value.toString().toLowerCase();
          Color color = theme.primaryColor;
          IconData icon = Icons.hourglass_empty;

          switch (estado) {
            case 'pendiente':
              color = Colors.orange;
              icon = Icons.hourglass_empty;
              break;
            case 'aprobado':
              color = Colors.green;
              icon = Icons.check_circle;
              break;
            case 'rechazado':
              color = theme.error;
              icon = Icons.cancel;
              break;
          }

          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  rendererContext.cell.value.toString(),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 12,
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
        minWidth: 180,
        readOnly: true,
        renderer: (rendererContext) {
          final usuarioId = rendererContext.cell.value.toString();
          final usuario = widget.provider.getUsuarioById(usuarioId);

          if (usuario?.estado != 'pendiente') {
            return Container(
              alignment: Alignment.center,
              child: Text(
                usuario?.estadoTexto ?? '',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: theme.secondaryText,
                  fontSize: 12,
                ),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _mostrarDialogoAprobacion(usuarioId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 30),
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                    child: const Text('Aprobar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _rechazarUsuario(usuarioId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 30),
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                    child: const Text('Rechazar'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ];
  }

  void _mostrarDialogoAprobacion(String usuarioId) {
    final usuario = widget.provider.getUsuarioById(usuarioId);
    if (usuario == null) return;

    showDialog(
      context: context,
      builder: (context) => _DialogoAprobacion(
        usuario: usuario,
        onAprobar: (rolId) => widget.provider.aprobarUsuario(usuarioId, rolId),
      ),
    );
  }

  void _rechazarUsuario(String usuarioId) {
    final usuario = widget.provider.getUsuarioById(usuarioId);
    if (usuario == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Rechazo'),
        content: Text('¿Estás seguro de rechazar a ${usuario.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.provider.rechazarUsuario(usuarioId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Usuario ${usuario.nombreCompleto} rechazado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }
}

class _DialogoAprobacion extends StatefulWidget {
  final UsuarioPendienteGrid usuario;
  final Future<bool> Function(int rolId) onAprobar;

  const _DialogoAprobacion({
    required this.usuario,
    required this.onAprobar,
  });

  @override
  State<_DialogoAprobacion> createState() => _DialogoAprobacionState();
}

class _DialogoAprobacionState extends State<_DialogoAprobacion> {
  RolAprobacion? _rolSeleccionado;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return AlertDialog(
      title: Text('Aprobar Usuario'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usuario: ${widget.usuario.nombreCompleto}',
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.usuario.telefono != null)
              Text('Teléfono: ${widget.usuario.telefono}'),
            const SizedBox(height: 16),
            Text(
              'Selecciona el rol a asignar:',
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...RolAprobacion.rolesDisponibles
                .map((rol) => RadioListTile<RolAprobacion>(
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
                    )),
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
              _isProcessing || _rolSeleccionado == null ? null : _aprobar,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Aprobar'),
        ),
      ],
    );
  }

  Future<void> _aprobar() async {
    if (_rolSeleccionado == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final success = await widget.onAprobar(_rolSeleccionado!.id);
      if (mounted) {
        Navigator.of(context).pop();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Usuario ${widget.usuario.nombreCompleto} aprobado como ${_rolSeleccionado!.nombre}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al aprobar usuario'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
