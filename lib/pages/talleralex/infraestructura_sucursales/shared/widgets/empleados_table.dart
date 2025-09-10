// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/empleados_provider.dart';
import 'package:nethive_neo/models/talleralex/empleados_models.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/programar_turno_dialog.dart';

class EmpleadosTable extends StatelessWidget {
  final EmpleadosProvider provider;
  final String sucursalId;

  const EmpleadosTable({
    super.key,
    required this.provider,
    required this.sucursalId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return PlutoGrid(
      key: UniqueKey(),
      configuration: PlutoGridConfiguration(
        enableMoveDownAfterSelecting: true,
        enableMoveHorizontalInEditing: true,
        localeText: const PlutoGridLocaleText.spanish(),
        style: PlutoGridStyleConfig(
          enableGridBorderShadow: true,
          gridBackgroundColor: Colors.white,
          activatedBorderColor: theme.primaryColor,
          activatedColor: theme.primaryColor.withOpacity(0.1),
          inactivatedBorderColor: Colors.grey.shade300,
          rowColor: Colors.white,
          oddRowColor: const Color(0xFFFAFAFA),
          checkedColor: theme.primaryColor.withOpacity(0.1),
          cellColorInEditState: Colors.white,
          cellColorInReadOnlyState: const Color(0xFFF5F5F5),
          columnTextStyle: TextStyle(
            color: theme.primaryText,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            fontSize: 13,
          ),
          cellTextStyle: TextStyle(
            color: theme.primaryText,
            fontFamily: 'Poppins',
            fontSize: 12,
          ),
          iconColor: theme.primaryColor,
          menuBackgroundColor: Colors.white,
          gridBorderRadius: BorderRadius.circular(16),
        ),
      ),
      columns: _buildColumns(context, theme),
      rows: provider.empleadosRows,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        // Configuraciones adicionales si es necesario
      },
      onRowDoubleTap: (event) {
        final empleado = provider.empleadosFiltrados[event.rowIdx];
        _mostrarDetallesEmpleado(context, empleado);
      },
      createHeader: (stateManager) => _buildCustomHeader(context, theme),
      createFooter: (stateManager) =>
          _buildCustomFooter(context, theme, stateManager),
    );
  }

  List<PlutoColumn> _buildColumns(BuildContext context, AppTheme theme) {
    return [
      PlutoColumn(
        title: '#',
        field: 'numero',
        type: PlutoColumnType.text(),
        width: 60,
        enableSorting: false,
        enableContextMenu: false,
        enableDropToResize: false,
        enableColumnDrag: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          return Container(
            alignment: Alignment.center,
            child: Text(
              rendererContext.cell.value.toString(),
              style: TextStyle(
                color: theme.secondaryText,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                fontSize: 11,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Empleado',
        field: 'nombre',
        type: PlutoColumnType.text(),
        width: 300,
        renderer: (rendererContext) {
          final empleado = provider.empleadosFiltrados[rendererContext.rowIdx];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIconPuesto(empleado.puesto),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        empleado.empleadoNombre,
                        style: TextStyle(
                          color: theme.primaryText,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        empleado.puesto.displayName,
                        style: TextStyle(
                          color: theme.secondaryText,
                          fontFamily: 'Poppins',
                          fontSize: 10,
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
      PlutoColumn(
        title: 'Correo',
        field: 'correo',
        type: PlutoColumnType.text(),
        minWidth: 200,
        width: 250,
        renderer: (rendererContext) {
          final empleado = provider.empleadosFiltrados[rendererContext.rowIdx];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            alignment: Alignment.centerLeft,
            child: Text(
              empleado.correo ?? 'Sin correo',
              style: TextStyle(
                color: empleado.correo != null
                    ? theme.primaryText
                    : theme.secondaryText,
                fontFamily: 'Poppins',
                fontSize: 11,
                fontStyle: empleado.correo == null
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Teléfono',
        field: 'telefono',
        type: PlutoColumnType.text(),
        width: 150,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final empleado = provider.empleadosFiltrados[rendererContext.rowIdx];
          return Container(
            alignment: Alignment.center,
            child: Text(
              empleado.telefono ?? 'Sin teléfono',
              style: TextStyle(
                color: empleado.telefono != null
                    ? theme.primaryText
                    : theme.secondaryText,
                fontFamily: 'Poppins',
                fontSize: 11,
                fontStyle: empleado.telefono == null
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Dirección',
        field: 'direccion',
        type: PlutoColumnType.text(),
        width: 200,
        renderer: (rendererContext) {
          final empleado = provider.empleadosFiltrados[rendererContext.rowIdx];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            alignment: Alignment.centerLeft,
            child: Text(
              empleado.direccion ?? 'Sin dirección',
              style: TextStyle(
                color: empleado.direccion != null
                    ? theme.primaryText
                    : theme.secondaryText,
                fontFamily: 'Poppins',
                fontSize: 11,
                fontStyle: empleado.direccion == null
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Estado',
        field: 'activo',
        type: PlutoColumnType.text(),
        width: 100,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final empleado = provider.empleadosFiltrados[rendererContext.rowIdx];
          return Container(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: empleado.activo
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: empleado.activo
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Text(
                empleado.activo ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color: empleado.activo
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  fontSize: 10,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Puesto',
        field: 'puesto',
        type: PlutoColumnType.text(),
        width: 200,
        minWidth: 100,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final empleado = provider.empleadosFiltrados[rendererContext.rowIdx];
          return Container(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getColorPuesto(empleado.puesto).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getColorPuesto(empleado.puesto).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIconPuesto(empleado.puesto),
                    color: _getColorPuesto(empleado.puesto),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    empleado.puesto.displayName,
                    style: TextStyle(
                      color: _getColorPuesto(empleado.puesto),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'En Turno',
        field: 'en_turno',
        type: PlutoColumnType.text(),
        width: 100,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final empleado = provider.empleadosFiltrados[rendererContext.rowIdx];
          return Container(
            alignment: Alignment.center,
            child: Icon(
              empleado.enTurnoNow ? Icons.work : Icons.work_off,
              color: empleado.enTurnoNow ? Colors.green : Colors.grey,
              size: 20,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Turno Actual',
        field: 'turno_actual',
        type: PlutoColumnType.text(),
        width: 120,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final empleado = provider.empleadosFiltrados[rendererContext.rowIdx];
          return Container(
            alignment: Alignment.center,
            child: Text(
              empleado.turnoTexto,
              style: TextStyle(
                color: empleado.enTurnoNow
                    ? theme.primaryText
                    : theme.secondaryText,
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight:
                    empleado.enTurnoNow ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Órdenes Abiertas',
        field: 'ordenes_abiertas',
        type: PlutoColumnType.number(),
        width: 120,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final empleado = provider.empleadosFiltrados[rendererContext.rowIdx];
          return Container(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: empleado.ordenesAbiertas > 0
                    ? theme.primaryColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                empleado.ordenesAbiertas.toString(),
                style: TextStyle(
                  color: empleado.ordenesAbiertas > 0
                      ? theme.primaryColor
                      : theme.secondaryText,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Horas Hoy',
        field: 'minutos_hoy',
        type: PlutoColumnType.text(),
        width: 100,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final empleado = provider.empleadosFiltrados[rendererContext.rowIdx];
          return Container(
            alignment: Alignment.center,
            child: Text(
              empleado.horasHoyTexto,
              style: TextStyle(
                color: theme.primaryText,
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Acciones',
        field: 'acciones',
        type: PlutoColumnType.text(),
        width: 500,
        minWidth: 300,
        enableSorting: false,
        enableContextMenu: false,
        enableDropToResize: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final empleado = provider.empleadosFiltrados[rendererContext.rowIdx];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                _buildActionButton(
                  context,
                  'Turno',
                  Icons.schedule,
                  Colors.blue,
                  () => _programarTurno(context, empleado),
                ),
                _buildActionButton(
                  context,
                  'Agenda',
                  Icons.calendar_today,
                  Colors.purple,
                  () => _verAgenda(context, empleado),
                ),
                _buildActionButton(
                  context,
                  'Desempeño',
                  Icons.analytics,
                  Colors.orange,
                  () => _verDesempeno(context, empleado),
                ),
                _buildActionButton(
                  context,
                  empleado.activo ? 'Desactivar' : 'Activar',
                  empleado.activo ? Icons.person_off : Icons.person,
                  empleado.activo ? Colors.red : Colors.green,
                  () => _cambiarEstadoEmpleado(context, empleado),
                ),
              ],
            ),
          );
        },
      ),
    ];
  }

  Widget _buildCustomHeader(BuildContext context, AppTheme theme) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.table_chart,
            color: theme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Lista de Empleados',
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              fontSize: 16,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => _exportarCSV(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download, color: theme.primaryColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Exportar CSV',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      fontSize: 12,
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

  Widget _buildCustomFooter(BuildContext context, AppTheme theme,
      PlutoGridStateManager stateManager) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Total: ${provider.empleadosFiltrados.length} empleados',
            style: TextStyle(
              color: theme.secondaryText,
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (provider.empleadosFiltrados.isNotEmpty) ...[
            const SizedBox(width: 20),
            Text(
              'Activos: ${provider.empleadosFiltrados.where((e) => e.activo).length}',
              style: TextStyle(
                color: Colors.green.shade700,
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              'En turno: ${provider.empleadosFiltrados.where((e) => e.enTurnoNow).length}',
              style: TextStyle(
                color: theme.primaryColor,
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: text,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconPuesto(PuestoEmpleado puesto) {
    switch (puesto) {
      case PuestoEmpleado.tecnico:
        return Icons.build;
      case PuestoEmpleado.recepcion:
        return Icons.support_agent;
      case PuestoEmpleado.gerente:
        return Icons.manage_accounts;
    }
  }

  Color _getColorPuesto(PuestoEmpleado puesto) {
    switch (puesto) {
      case PuestoEmpleado.tecnico:
        return Colors.blue;
      case PuestoEmpleado.recepcion:
        return Colors.green;
      case PuestoEmpleado.gerente:
        return Colors.purple;
    }
  }

  // Métodos de acciones
  void _mostrarDetallesEmpleado(BuildContext context, EmpleadoGrid empleado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de ${empleado.empleadoNombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetalleItem('Puesto:', empleado.puesto.displayName),
            _buildDetalleItem('Correo:', empleado.correo ?? 'Sin correo'),
            _buildDetalleItem('Teléfono:', empleado.telefono ?? 'Sin teléfono'),
            _buildDetalleItem(
                'Dirección:', empleado.direccion ?? 'Sin dirección'),
            _buildDetalleItem(
                'Estado:', empleado.activo ? 'Activo' : 'Inactivo'),
            _buildDetalleItem('En turno:', empleado.enTurnoNow ? 'Sí' : 'No'),
            _buildDetalleItem('Turno actual:', empleado.turnoTexto),
            _buildDetalleItem(
                'Órdenes abiertas:', empleado.ordenesAbiertas.toString()),
            _buildDetalleItem('Horas hoy:', empleado.horasHoyTexto),
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

  Widget _buildDetalleItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _programarTurno(BuildContext context, EmpleadoGrid empleado) {
    showDialog(
      context: context,
      builder: (context) => ProgramarTurnoDialog(
        empleado: empleado,
        sucursalId: sucursalId,
        onTurnoProgramado: () {
          provider.refrescarEmpleados();
        },
      ),
    );
  }

  void _verAgenda(BuildContext context, EmpleadoGrid empleado) {
    // TODO: Implementar vista de agenda de empleado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Ver agenda de ${empleado.empleadoNombre} - Por implementar'),
      ),
    );
  }

  void _verDesempeno(BuildContext context, EmpleadoGrid empleado) {
    // TODO: Implementar vista de desempeño
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Ver desempeño de ${empleado.empleadoNombre} - Por implementar'),
      ),
    );
  }

  void _cambiarEstadoEmpleado(BuildContext context, EmpleadoGrid empleado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${empleado.activo ? 'Desactivar' : 'Activar'} empleado'),
        content: Text(
          '¿Está seguro de que desea ${empleado.activo ? 'desactivar' : 'activar'} a ${empleado.empleadoNombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.cambiarEstadoEmpleado(
                empleado.empleadoId,
                !empleado.activo,
              );

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Empleado ${empleado.activo ? 'desactivado' : 'activado'} correctamente',
                    ),
                  ),
                );
              }
            },
            child: Text(empleado.activo ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }

  void _exportarCSV(BuildContext context) {
    // TODO: Implementar exportación a CSV
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportar CSV - Por implementar'),
      ),
    );
  }
}
