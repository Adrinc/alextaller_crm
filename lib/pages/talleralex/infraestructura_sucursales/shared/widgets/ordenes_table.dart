// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/citas_ordenes_provider.dart';
import 'package:nethive_neo/models/talleralex/citas_ordenes_models.dart';

class OrdenesTable extends StatelessWidget {
  final CitasOrdenesProvider provider;
  final String sucursalId;

  const OrdenesTable({
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
          rowHeight: 100,
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.scale,
          resizeMode: PlutoResizeMode.normal,
        ),
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveDown,
        tabKeyAction: PlutoGridTabKeyAction.normal,
      ),
      columns: _buildColumns(theme),
      rows: provider.ordenesRows,
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
        title: 'Folio',
        field: 'folio',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                rendererContext.cell.value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Poppins',
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
          final orden = provider.ordenesFiltradas.firstWhere(
            (o) => o.clienteNombre == clienteNombre,
            orElse: () => provider.ordenesFiltradas.first,
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
                      _getInitials(orden.clienteNombre),
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
                    orden.clienteNombre,
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
        title: 'Estado',
        field: 'estado',
        type: PlutoColumnType.text(),
        width: 140,
        minWidth: 120,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final estado = rendererContext.cell.value.toString();
          Color color;
          Color backgroundColor;
          IconData icono;

          switch (estado.toLowerCase()) {
            case 'creada':
              color = Colors.blue.shade600;
              backgroundColor = Colors.blue.shade50;
              icono = Icons.inbox;
              break;
            case 'en_proceso':
              color = Colors.teal.shade600;
              backgroundColor = Colors.teal.shade50;
              icono = Icons.build;
              break;
            case 'pausada':
              color = Colors.orange.shade600;
              backgroundColor = Colors.orange.shade50;
              icono = Icons.pause;
              break;
            case 'por_aprobar':
              color = Colors.purple.shade600;
              backgroundColor = Colors.purple.shade50;
              icono = Icons.check_circle_outline;
              break;
            case 'esperando_partes':
              color = Colors.amber.shade600;
              backgroundColor = Colors.amber.shade50;
              icono = Icons.inventory;
              break;
            case 'lista':
              color = Colors.indigo.shade600;
              backgroundColor = Colors.indigo.shade50;
              icono = Icons.task_alt;
              break;
            case 'entregada':
              color = Colors.green.shade600;
              backgroundColor = Colors.green.shade50;
              icono = Icons.handshake;
              break;
            case 'cerrada':
              color = Colors.grey.shade600;
              backgroundColor = Colors.grey.shade100;
              icono = Icons.check_circle;
              break;
            case 'cancelada':
              color = Colors.red.shade600;
              backgroundColor = Colors.red.shade50;
              icono = Icons.cancel;
              break;
            default:
              color = Colors.grey.shade600;
              backgroundColor = Colors.grey.shade100;
              icono = Icons.help_outline;
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icono,
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    estado,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
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
        title: 'Progreso',
        field: 'progreso',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final progreso =
              double.tryParse(rendererContext.cell.value.toString()) ?? 0.0;

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${progreso.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.primaryText,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progreso / 100,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progreso < 25
                            ? Colors.red.shade400
                            : progreso < 50
                                ? Colors.orange.shade400
                                : progreso < 75
                                    ? Colors.yellow.shade600
                                    : Colors.green.shade400,
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
        title: 'Fecha Inicio',
        field: 'fecha_inicio',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
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
                      size: 12,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rendererContext.cell.value.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.primaryColor,
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
        title: 'Total',
        field: 'total',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final total = rendererContext.cell.value.toString();

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 14,
                    color: Colors.green.shade600,
                  ),
                  Text(
                    total,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
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
        title: 'Saldo',
        field: 'saldo',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final saldo = rendererContext.cell.value.toString();
          final tieneSaldo = !saldo.contains('\$0.00');

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: tieneSaldo ? Colors.orange.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: tieneSaldo
                      ? Colors.orange.shade300
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tieneSaldo ? Icons.payment : Icons.check_circle,
                    size: 14,
                    color: tieneSaldo
                        ? Colors.orange.shade600
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    saldo,
                    style: TextStyle(
                      fontSize: 12,
                      color: tieneSaldo
                          ? Colors.orange.shade600
                          : Colors.grey.shade600,
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
        width: 160,
        minWidth: 160,
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
                      onTap: () => _verDetallesOrden(
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
                // Botón actualizar estado
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
                      onTap: () => _actualizarEstado(
                        rendererContext.stateManager.gridFocusNode.context!,
                        rendererContext.cell.value.toString(),
                      ),
                      child: Icon(
                        Icons.sync,
                        size: 14,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ),
                ),
                // Botón agregar refacciones
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
                      onTap: () => _agregarRefacciones(
                        rendererContext.stateManager.gridFocusNode.context!,
                        rendererContext.cell.value.toString(),
                      ),
                      child: Icon(
                        Icons.inventory,
                        size: 14,
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ),
                ),
                // Botón imprimir orden
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.purple.shade200,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => _imprimirOrden(
                        rendererContext.stateManager.gridFocusNode.context!,
                        rendererContext.cell.value.toString(),
                      ),
                      child: Icon(
                        Icons.print,
                        size: 14,
                        color: Colors.purple.shade600,
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
                    Icons.build,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Órdenes de Servicio (${provider.ordenesFiltradas.length})',
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
              'Total de órdenes: ${provider.ordenesFiltradas.length}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              'En proceso: ${provider.ordenesFiltradas.where((o) => o.estado == EstadoOrdenServicio.enProceso).length}',
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

  void _verDetallesOrden(BuildContext context, String ordenId) {
    final orden = provider.ordenesFiltradas.firstWhere(
      (o) => o.ordenId == ordenId,
    );
    provider.seleccionarOrden(orden);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver detalles de orden ${orden.numero}'),
        backgroundColor: AppTheme.of(context).primaryColor,
      ),
    );
  }

  void _actualizarEstado(BuildContext context, String ordenId) {
    final orden = provider.ordenesFiltradas.firstWhere(
      (o) => o.ordenId == ordenId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Actualizar estado de orden ${orden.numero}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _agregarRefacciones(BuildContext context, String ordenId) {
    final orden = provider.ordenesFiltradas.firstWhere(
      (o) => o.ordenId == ordenId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agregar refacciones a orden ${orden.numero}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _imprimirOrden(BuildContext context, String ordenId) {
    final orden = provider.ordenesFiltradas.firstWhere(
      (o) => o.ordenId == ordenId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Imprimir orden ${orden.numero}'),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
