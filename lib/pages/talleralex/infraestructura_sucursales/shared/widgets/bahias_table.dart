// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/agenda_bahias_provider.dart';
import 'package:nethive_neo/models/talleralex/bahias_models.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/reserva_bahia_dialog.dart';

class BahiasTable extends StatelessWidget {
  final AgendaBahiasProvider provider;
  final String sucursalId;

  const BahiasTable({
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
        scrollbar: PlutoGridScrollbarConfig(
          draggableScrollbar: true,
          isAlwaysShown: false,
          onlyDraggingThumb: true,
          enableScrollAfterDragEnd: true,
          scrollbarThickness: 12,
          scrollbarThicknessWhileDragging: 16,
          hoverWidth: 20,
          scrollBarColor: theme.primaryColor.withOpacity(0.7),
          scrollBarTrackColor: Colors.grey.withOpacity(0.2),
          scrollbarRadius: const Radius.circular(8),
          scrollbarRadiusWhileDragging: const Radius.circular(10),
        ),
        style: PlutoGridStyleConfig(
          gridBorderColor: Colors.grey.withOpacity(0.3),
          activatedBorderColor: theme.primaryColor,
          inactivatedBorderColor: Colors.grey.withOpacity(0.3),
          gridBackgroundColor: theme.primaryBackground,
          rowColor: theme.secondaryBackground,
          activatedColor: theme.primaryColor.withOpacity(0.1),
          checkedColor: theme.primaryColor.withOpacity(0.2),
          cellTextStyle: TextStyle(
            fontSize: 14,
            color: theme.primaryText,
          ),
          columnTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.primaryText,
          ),
          menuBackgroundColor: theme.secondaryBackground,
          gridBorderRadius: BorderRadius.circular(8),
          rowHeight: 100,
        ),
        columnFilter: const PlutoGridColumnFilterConfig(
          filters: [
            ...FilterHelper.defaultFilters,
          ],
        ),
      ),
      columns: [
        PlutoColumn(
          title: 'Nu.',
          field: 'numero',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 80,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          backgroundColor: theme.primaryColor,
          enableContextMenu: false,
          enableDropToResize: false,
          renderer: (rendererContext) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  rendererContext.cell.value.toString(),
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Nombre de Bahía',
          field: 'nombre',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.start,
          minWidth: 200,
          width: 250,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final ocupacion = provider.ocupaciones[rendererContext.rowIdx];
            return Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primaryColor, theme.secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.garage,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ocupacion.bahiaNombre,
                          style: theme.bodyText1.override(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ID: ${ocupacion.bahiaId.substring(0, 8)}...',
                          style: theme.bodyText2.override(
                            fontFamily: 'Poppins',
                            color: theme.secondaryText,
                            fontSize: 11,
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
          title: 'Estado',
          field: 'estado',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          minWidth: 200,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final ocupacion = provider.ocupaciones[rendererContext.rowIdx];
            final color = _getColorEstado(ocupacion.estado);

            return Container(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ocupacion.estadoTexto,
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Ocupación Hoy',
          field: 'ocupacion',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          minWidth: 200,
          type: PlutoColumnType.number(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final ocupacion = provider.ocupaciones[rendererContext.rowIdx];
            final porcentaje = ocupacion.porcentajeOcupacion;
            final color = _getColorPorcentaje(porcentaje);

            return Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${porcentaje.toStringAsFixed(1)}%',
                        style: theme.bodyText1.override(
                          fontFamily: 'Poppins',
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${ocupacion.reservasHoy})',
                        style: theme.bodyText2.override(
                          fontFamily: 'Poppins',
                          color: theme.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (porcentaje / 100).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withOpacity(0.7), color],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Tiempo Ocupado',
          field: 'tiempo_ocupado',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 140,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final ocupacion = provider.ocupaciones[rendererContext.rowIdx];
            return Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    color: theme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ocupacion.tiempoOcupado,
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Tiempo Disponible',
          field: 'tiempo_disponible',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          minWidth: 200,
          width: 250,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final ocupacion = provider.ocupaciones[rendererContext.rowIdx];
            return Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ocupacion.tiempoDisponible,
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Próximas Reservas',
          field: 'proximas_reservas',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.start,
          minWidth: 300,
          width: 350,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final ocupacion = provider.ocupaciones[rendererContext.rowIdx];
            final reservas = provider.getReservasPorBahia(ocupacion.bahiaId);
            final proximasReservas = reservas.take(3).toList();

            if (proximasReservas.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    'Sin reservas próximas',
                    style: theme.bodyText2.override(
                      fontFamily: 'Poppins',
                      color: theme.secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: proximasReservas.map((reserva) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: theme.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reserva.horarioFormateado,
                          style: theme.bodyText2.override(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reserva.clienteNombre,
                            style: theme.bodyText2.override(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: theme.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Acciones',
          field: 'acciones',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          minWidth: 300,
          width: 450,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          enableSorting: false,
          enableColumnDrag: false,
          enableContextMenu: false,
          renderer: (rendererContext) {
            final ocupacion = provider.ocupaciones[rendererContext.rowIdx];

            return Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    context,
                    'Ver',
                    Icons.visibility,
                    theme.primaryColor,
                    () => _mostrarDetallesBahia(context, ocupacion),
                  ),
                  _buildActionButton(
                    context,
                    'Reservar',
                    Icons.add_task,
                    theme.secondaryColor,
                    () => _mostrarDialogoReserva(context, ocupacion),
                  ),
                  _buildActionButton(
                    context,
                    'Historial',
                    Icons.history,
                    Colors.orange,
                    () => _mostrarHistorialBahia(context, ocupacion),
                  ),
                ],
              ),
            );
          },
        ),
      ],
      rows: _buildBahiasRows(),
      onLoaded: (event) {
        // Si necesitas acceso al stateManager, puedes guardarlo aquí
      },
      createFooter: (stateManager) {
        stateManager.setPageSize(10, notify: false);
        return PlutoPagination(
          stateManager,
          pageSizeToMove: null,
        );
      },
    );
  }

  List<PlutoRow> _buildBahiasRows() {
    final rows = <PlutoRow>[];

    for (int i = 0; i < provider.ocupaciones.length; i++) {
      final ocupacion = provider.ocupaciones[i];

      rows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'nombre': PlutoCell(value: ocupacion.bahiaNombre),
        'estado': PlutoCell(value: ocupacion.estadoTexto),
        'ocupacion': PlutoCell(value: ocupacion.porcentajeOcupacion),
        'tiempo_ocupado': PlutoCell(value: ocupacion.tiempoOcupado),
        'tiempo_disponible': PlutoCell(value: ocupacion.tiempoDisponible),
        'proximas_reservas': PlutoCell(
            value:
                '${provider.getReservasPorBahia(ocupacion.bahiaId).length} reservas'),
        'acciones': PlutoCell(value: ocupacion.bahiaId),
      }));
    }

    return rows;
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final theme = AppTheme.of(context);

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
                style: theme.bodyText2.override(
                  fontFamily: 'Poppins',
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorEstado(EstadoBahia estado) {
    switch (estado) {
      case EstadoBahia.libre:
        return Colors.green;
      case EstadoBahia.parcial:
        return Colors.blue;
      case EstadoBahia.ocupada:
        return Colors.orange;
      case EstadoBahia.casiCompleta:
        return Colors.deepOrange;
      case EstadoBahia.completa:
        return Colors.red;
    }
  }

  Color _getColorPorcentaje(double porcentaje) {
    if (porcentaje >= 100) return Colors.red;
    if (porcentaje >= 80) return Colors.deepOrange;
    if (porcentaje >= 40) return Colors.orange;
    if (porcentaje > 0) return Colors.blue;
    return Colors.green;
  }

  // Métodos de acción
  void _mostrarDetallesBahia(BuildContext context, OcupacionBahia ocupacion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de ${ocupacion.bahiaNombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado: ${ocupacion.estadoTexto}'),
            Text(
                'Ocupación: ${ocupacion.porcentajeOcupacion.toStringAsFixed(1)}%'),
            Text('Reservas hoy: ${ocupacion.reservasHoy}'),
            Text('Tiempo ocupado: ${ocupacion.tiempoOcupado}'),
            Text('Tiempo disponible: ${ocupacion.tiempoDisponible}'),
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

  void _mostrarDialogoReserva(
      BuildContext context, OcupacionBahia ocupacion) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ReservaBahiaDialog(
        ocupacion: ocupacion,
        sucursalId: sucursalId,
      ),
    );

    if (result == true) {
      // Recargar datos después de la reserva
      provider.cargarReservas(sucursalId);
    }
  }

  void _mostrarHistorialBahia(BuildContext context, OcupacionBahia ocupacion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Historial de ${ocupacion.bahiaNombre} (En desarrollo)'),
        backgroundColor: AppTheme.of(context).primaryColor,
      ),
    );
  }
}
