// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/inventario_provider.dart';

class HistorialRefaccionesTable extends StatelessWidget {
  final InventarioProvider provider;
  final String sucursalId;

  const HistorialRefaccionesTable({
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
          activatedBorderColor: Colors.blue.shade600,
          activatedColor: Colors.blue.shade50,
          inactivatedBorderColor: Colors.grey.shade300,
          rowColor: Colors.white,
          oddRowColor: Colors.blue.shade50,
          checkedColor: Colors.blue.shade50,
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
          gridBorderColor: Colors.blue.shade200,
          borderColor: Colors.blue.shade200,
          gridBorderRadius: BorderRadius.circular(16),
          rowHeight: 70,
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.scale,
          resizeMode: PlutoResizeMode.normal,
        ),
        enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveDown,
        tabKeyAction: PlutoGridTabKeyAction.normal,
      ),
      columns: _buildColumns(theme),
      rows: provider.historialRows,
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
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.blue.shade300,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  rendererContext.cell.value.toString(),
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Fecha',
        field: 'fecha_movimiento',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final fechaStr = rendererContext.cell.value.toString();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fechaStr.split(' ')[0], // Solo la fecha
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 10,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      fechaStr.contains(' ')
                          ? fechaStr.split(' ')[1]
                          : '', // Solo la hora
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        color: Colors.grey.shade600,
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
        title: 'Refacción',
        field: 'nombre_refaccion',
        type: PlutoColumnType.text(),
        width: 240,
        minWidth: 200,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final historial = provider.historialMovimientos.firstWhere(
            (h) => h.nombreRefaccion == rendererContext.cell.value,
            orElse: () => provider.historialMovimientos.first,
          );

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Imagen o placeholder
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue.shade50,
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  child: _buildHistorialImage(historial),
                ),
                const SizedBox(width: 12),
                // Información de la refacción
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        historial.nombreRefaccion,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: theme.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SKU: ${historial.sku}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          color: Colors.grey.shade600,
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
        title: 'Tipo Movimiento',
        field: 'tipo_movimiento',
        type: PlutoColumnType.text(),
        width: 130,
        minWidth: 120,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final tipo = rendererContext.cell.value.toString();
          Color backgroundColor;
          Color textColor;
          Color borderColor;
          IconData icon;

          switch (tipo.toLowerCase()) {
            case 'entrada':
              backgroundColor = Colors.green.shade50;
              textColor = Colors.green.shade700;
              borderColor = Colors.green.shade200;
              icon = Icons.arrow_circle_up;
              break;
            case 'salida':
              backgroundColor = Colors.red.shade50;
              textColor = Colors.red.shade700;
              borderColor = Colors.red.shade200;
              icon = Icons.arrow_circle_down;
              break;
            case 'ajuste':
              backgroundColor = Colors.orange.shade50;
              textColor = Colors.orange.shade700;
              borderColor = Colors.orange.shade200;
              icon = Icons.tune;
              break;
            default:
              backgroundColor = Colors.grey.shade50;
              textColor = Colors.grey.shade700;
              borderColor = Colors.grey.shade200;
              icon = Icons.help_outline;
          }

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: textColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tipo,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Cantidad',
        field: 'cantidad',
        type: PlutoColumnType.number(),
        width: 100,
        minWidth: 90,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final cantidad = rendererContext.cell.value as int;
          final historial = provider.historialMovimientos.firstWhere(
            (h) => h.cantidad == cantidad,
            orElse: () => provider.historialMovimientos.first,
          );

          Color backgroundColor = Colors.blue.shade50;
          Color textColor = Colors.blue.shade700;
          String signo = '';

          if (historial.tipoMovimiento.toLowerCase() == 'entrada') {
            backgroundColor = Colors.green.shade50;
            textColor = Colors.green.shade700;
            signo = '+';
          } else if (historial.tipoMovimiento.toLowerCase() == 'salida') {
            backgroundColor = Colors.red.shade50;
            textColor = Colors.red.shade700;
            signo = '-';
          }

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: textColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '$signo$cantidad',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Usuario',
        field: 'usuario',
        type: PlutoColumnType.text(),
        width: 140,
        minWidth: 120,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final usuario = rendererContext.cell.value.toString();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.purple.shade300,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 14,
                    color: Colors.purple.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    usuario,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: theme.primaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Stock Anterior',
        field: 'stock_anterior',
        type: PlutoColumnType.number(),
        width: 110,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final stockAnterior = rendererContext.cell.value as int;

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                stockAnterior.toString(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Stock Actual',
        field: 'stock_actual',
        type: PlutoColumnType.number(),
        width: 110,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final stockActual = rendererContext.cell.value as int;

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory,
                    size: 12,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    stockActual.toString(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Motivo',
        field: 'motivo',
        type: PlutoColumnType.text(),
        width: 160,
        minWidth: 140,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final motivo =
              rendererContext.cell.value?.toString() ?? 'Sin especificar';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.description,
                      size: 12,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        motivo,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: theme.primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
        title: 'Acciones',
        field: 'acciones',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 120,
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
                  width: 36,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _verDetalleMovimiento(
                      rendererContext.stateManager.gridFocusNode.context!,
                      rendererContext.cell.value.toString(),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: const Icon(
                      Icons.visibility,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Botón generar reporte
                Container(
                  width: 36,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _generarReporteMovimiento(
                      rendererContext.stateManager.gridFocusNode.context!,
                      rendererContext.cell.value.toString(),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: const Icon(
                      Icons.print,
                      size: 16,
                      color: Colors.white,
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

  Widget _buildHistorialImage(historial) {
    if (historial.imagenPath != null && historial.imagenPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          historial.imagenPath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildHistorialPlaceholder();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue.shade400,
              ),
            );
          },
        ),
      );
    }

    return _buildHistorialPlaceholder();
  }

  Widget _buildHistorialPlaceholder() {
    return Center(
      child: Icon(
        Icons.history,
        size: 18,
        color: Colors.blue.shade400,
      ),
    );
  }

  Widget _buildCustomHeader(
    BuildContext context,
    AppTheme theme,
    PlutoGridStateManager stateManager,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.indigo.shade50,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.blue.shade200,
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.history,
                      color: Colors.blue.shade600,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Historial de Movimientos',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${provider.historialMovimientos.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Selector de período
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _filtrarPorPeriodo(context),
                  icon: const Icon(Icons.date_range, size: 16),
                  label: const Text(
                    'Filtrar Período',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _exportarHistorial(context),
                  icon: const Icon(Icons.file_download, size: 16),
                  label: const Text(
                    'Exportar',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildCustomFooter(
    BuildContext context,
    AppTheme theme,
    PlutoGridStateManager stateManager,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          top: BorderSide(
            color: Colors.blue.shade200,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Colors.blue.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Registro completo de movimientos de inventario',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            Text(
              'Total registros: ${provider.historialMovimientos.length}',
              style: TextStyle(
                color: Colors.blue.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _verDetalleMovimiento(BuildContext context, String movimientoId) {
    final movimiento = provider.historialMovimientos.firstWhere(
      (m) => m.movimientoId == movimientoId,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue.shade600,
            ),
            const SizedBox(width: 8),
            const Text(
              'Detalle del Movimiento',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetalleRow('Refacción:', movimiento.nombreRefaccion),
            _buildDetalleRow('SKU:', movimiento.sku),
            _buildDetalleRow('Tipo:', movimiento.tipoMovimiento),
            _buildDetalleRow('Cantidad:', '${movimiento.cantidad}'),
            _buildDetalleRow('Stock anterior:', '${movimiento.stockAnterior}'),
            _buildDetalleRow('Stock actual:', '${movimiento.stockActual}'),
            _buildDetalleRow('Usuario:', movimiento.usuario ?? 'Sistema'),
            _buildDetalleRow(
                'Fecha:',
                DateFormat('dd/MM/yyyy HH:mm')
                    .format(movimiento.fechaMovimiento)),
            if (movimiento.motivo != null)
              _buildDetalleRow('Motivo:', movimiento.motivo!),
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

  Widget _buildDetalleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _generarReporteMovimiento(BuildContext context, String movimientoId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Generando reporte del movimiento...'),
        backgroundColor: Colors.green.shade600,
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _filtrarPorPeriodo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Filtrar por período - Función en desarrollo'),
        backgroundColor: Colors.purple.shade600,
      ),
    );
  }

  void _exportarHistorial(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Exportando historial (${provider.historialMovimientos.length} registros)'),
        backgroundColor: Colors.green.shade600,
        action: SnackBarAction(
          label: 'Descargar',
          textColor: Colors.white,
          onPressed: () {
            // Aquí iría la lógica de descarga/export
          },
        ),
      ),
    );
  }
}
