// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/citas_ordenes_provider.dart';
import 'package:nethive_neo/models/talleralex/citas_ordenes_models.dart';
import 'cita_detalle_dialog.dart';

class CitasTable extends StatelessWidget {
  final CitasOrdenesProvider provider;
  final String sucursalId;

  const CitasTable({
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
          gridBorderColor: Colors.grey.shade300,
          borderColor: Colors.grey.shade300,
          gridBorderRadius: BorderRadius.circular(16),
          rowHeight: 80,
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.scale,
          resizeMode: PlutoResizeMode.normal,
        ),
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveDown,
        tabKeyAction: PlutoGridTabKeyAction.normal,
      ),
      columns: _buildColumns(theme),
      rows: provider.citasRows,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        // Configuraciones adicionales si son necesarias
      },
      createHeader: (stateManager) {
        return _buildCustomHeader(context, theme, stateManager);
      },
      createFooter: (stateManager) {
        return _buildCustomFooter(context, theme, stateManager);
      },
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
        enableSorting: false,
        enableColumnDrag: false,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  rendererContext.cell.value.toString(),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Cliente',
        field: 'cliente',
        type: PlutoColumnType.text(),
        width: 180,
        minWidth: 150,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final clienteNombre = rendererContext.cell.value.toString();
          final cita = provider.citasFiltradas.firstWhere(
            (c) => c.clienteNombre == clienteNombre,
            orElse: () => provider.citasFiltradas.first,
          );

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Avatar con iniciales
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
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(cita.clienteNombre),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Información del cliente
                Expanded(
                  child: Text(
                    cita.clienteNombre,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: theme.primaryText,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Vehículo',
        field: 'vehiculo',
        type: PlutoColumnType.text(),
        width: 200,
        minWidth: 160,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final vehiculoTexto = rendererContext.cell.value.toString();
          final parts = vehiculoTexto.split(' - ');
          final placa = parts.isNotEmpty ? parts[0] : '';
          final vehiculo = parts.length > 1 ? parts[1] : '';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.shade300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        placa,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  vehiculo,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Fecha y Hora',
        field: 'fecha_hora',
        type: PlutoColumnType.text(),
        width: 140,
        minWidth: 120,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rendererContext.cell.value.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.primaryText,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Duración',
        field: 'duracion',
        type: PlutoColumnType.text(),
        width: 80,
        minWidth: 70,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.purple.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                rendererContext.cell.value.toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.purple.shade600,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
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
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final estado = rendererContext.cell.value.toString();
          Color color;
          Color backgroundColor;

          switch (estado.toLowerCase()) {
            case 'pendiente':
              color = Colors.orange.shade600;
              backgroundColor = Colors.orange.shade50;
              break;
            case 'confirmada':
              color = Colors.green.shade600;
              backgroundColor = Colors.green.shade50;
              break;
            case 'completada':
              color = Colors.indigo.shade600;
              backgroundColor = Colors.indigo.shade50;
              break;
            case 'cancelada':
              color = Colors.red.shade600;
              backgroundColor = Colors.red.shade50;
              break;
            case 'no_asistio':
              color = Colors.grey.shade600;
              backgroundColor = Colors.grey.shade100;
              break;
            default:
              color = Colors.grey.shade600;
              backgroundColor = Colors.grey.shade100;
          }

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                estado,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Fuente',
        field: 'fuente',
        type: PlutoColumnType.text(),
        width: 100,
        minWidth: 80,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final fuente = rendererContext.cell.value.toString();
          IconData icono;
          Color color;

          switch (fuente.toLowerCase()) {
            case 'web':
              icono = Icons.web;
              color = Colors.blue.shade600;
              break;
            case 'app':
              icono = Icons.phone_android;
              color = Colors.green.shade600;
              break;
            case 'recepción':
              icono = Icons.person;
              color = Colors.orange.shade600;
              break;
            case 'teléfono':
              icono = Icons.phone;
              color = Colors.purple.shade600;
              break;
            default:
              icono = Icons.help_outline;
              color = Colors.grey.shade600;
          }

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icono,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  fuente,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Servicios',
        field: 'servicios',
        type: PlutoColumnType.text(),
        width: 250,
        minWidth: 200,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final servicios = rendererContext.cell.value.toString();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              servicios.isNotEmpty ? servicios : 'Sin servicios especificados',
              style: TextStyle(
                fontSize: 11,
                color: servicios.isNotEmpty
                    ? theme.primaryText
                    : Colors.grey.shade500,
                fontFamily: 'Poppins',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Bahía',
        field: 'bahia',
        type: PlutoColumnType.text(),
        width: 100,
        minWidth: 80,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final bahia = rendererContext.cell.value.toString();
          final tieneBahia = bahia == 'Asignada';

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    tieneBahia ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: tieneBahia
                      ? Colors.green.shade300
                      : Colors.orange.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tieneBahia ? Icons.check_circle : Icons.schedule,
                    size: 12,
                    color: tieneBahia
                        ? Colors.green.shade600
                        : Colors.orange.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    bahia,
                    style: TextStyle(
                      fontSize: 10,
                      color: tieneBahia
                          ? Colors.green.shade600
                          : Colors.orange.shade600,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Retraso',
        field: 'retraso',
        type: PlutoColumnType.text(),
        width: 100,
        minWidth: 80,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final retraso = rendererContext.cell.value.toString();

          if (retraso.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning,
                    size: 12,
                    color: Colors.red.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    retraso,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Acciones',
        field: 'acciones',
        type: PlutoColumnType.text(),
        width: 140,
        minWidth: 140,
        enableSorting: false,
        enableColumnDrag: false,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón ver detalles
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => _verDetallesCita(
                        rendererContext.stateManager.gridFocusNode.context!,
                        rendererContext.cell.value.toString(),
                      ),
                      child: Icon(
                        Icons.visibility,
                        size: 14,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
                ),
                // Botón confirmar
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.green.shade200,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => _confirmarCita(
                        rendererContext.stateManager.gridFocusNode.context!,
                        rendererContext.cell.value.toString(),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ),
                ),
                // Botón crear orden
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => _crearOrden(
                        rendererContext.stateManager.gridFocusNode.context!,
                        rendererContext.cell.value.toString(),
                      ),
                      child: Icon(
                        Icons.build,
                        size: 14,
                        color: Colors.orange.shade600,
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

  Widget _buildCustomHeader(
    BuildContext context,
    AppTheme theme,
    PlutoGridStateManager stateManager,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: theme.primaryColor.withOpacity(0.2),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Citas (${provider.citasFiltradas.length})',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Poppins',
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

  Widget _buildCustomFooter(
    BuildContext context,
    AppTheme theme,
    PlutoGridStateManager stateManager,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.03),
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total de citas: ${provider.citasFiltradas.length}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              'Confirmadas: ${provider.citasFiltradas.where((c) => c.estado == EstadoCita.confirmada).length}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
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

  void _verDetallesCita(BuildContext context, String citaId) {
    final cita = provider.citasFiltradas.firstWhere(
      (c) => c.citaId == citaId,
    );
    provider.seleccionarCita(cita);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CitaDetalleDialog(
          cita: cita,
          sucursalId: sucursalId,
        );
      },
    );
  }

  void _confirmarCita(BuildContext context, String citaId) {
    final cita = provider.citasFiltradas.firstWhere(
      (c) => c.citaId == citaId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Confirmar cita de ${cita.clienteNombre}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _crearOrden(BuildContext context, String citaId) {
    final cita = provider.citasFiltradas.firstWhere(
      (c) => c.citaId == citaId,
    );

    // Usar la función del provider para crear orden
    provider.crearOrdenDesdeCita(citaId).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Orden creada para ${cita.clienteNombre}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear orden para ${cita.clienteNombre}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}
