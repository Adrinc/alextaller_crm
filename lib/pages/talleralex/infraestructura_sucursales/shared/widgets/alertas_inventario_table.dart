// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/inventario_provider.dart';

class AlertasInventarioTable extends StatelessWidget {
  final InventarioProvider provider;
  final String sucursalId;

  const AlertasInventarioTable({
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
          activatedBorderColor: Colors.orange.shade600,
          activatedColor: Colors.orange.shade50,
          inactivatedBorderColor: Colors.grey.shade300,
          rowColor: Colors.white,
          oddRowColor: Colors.red.shade50,
          checkedColor: Colors.orange.shade50,
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
          gridBorderColor: Colors.orange.shade200,
          borderColor: Colors.orange.shade200,
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
      rows: provider.alertasRows,
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
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.red.shade300,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  rendererContext.cell.value.toString(),
                  style: TextStyle(
                    color: Colors.red.shade700,
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
        title: 'SKU',
        field: 'sku',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final sku = rendererContext.cell.value.toString();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                sku,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Colors.orange.shade800,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Refacción',
        field: 'nombre',
        type: PlutoColumnType.text(),
        width: 280,
        minWidth: 220,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final alerta = provider.refaccionesEnAlerta.firstWhere(
            (a) => a.nombre == rendererContext.cell.value,
            orElse: () => provider.refaccionesEnAlerta.first,
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
                    color: Colors.red.shade50,
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: _buildAlertaImage(alerta),
                ),
                const SizedBox(width: 12),
                // Información de la refacción
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        alerta.nombre,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: theme.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            size: 12,
                            color: Colors.red.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Stock crítico',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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
        title: 'Existencias',
        field: 'existencias',
        type: PlutoColumnType.number(),
        width: 100,
        minWidth: 90,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final existencias = rendererContext.cell.value as int;

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory,
                    size: 14,
                    color: Colors.red.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    existencias.toString(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Mín. Requerido',
        field: 'minimo_alerta',
        type: PlutoColumnType.number(),
        width: 110,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final minimo = rendererContext.cell.value as int;

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 14,
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    minimo.toString(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Faltantes',
        field: 'faltantes',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final faltantes = rendererContext.cell.value.toString();

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade400,
                    Colors.red.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    faltantes,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.white,
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
                // Botón actualizar stock
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
                    onTap: () => _actualizarStock(
                      rendererContext.stateManager.gridFocusNode.context!,
                      rendererContext.cell.value.toString(),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: const Icon(
                      Icons.add,
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
                    onTap: () => _generarReporte(
                      rendererContext.stateManager.gridFocusNode.context!,
                      rendererContext.cell.value.toString(),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: const Icon(
                      Icons.description,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Botón ver detalles
                Container(
                  width: 36,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.purple.shade600],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _verDetalles(
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
              ],
            ),
          );
        },
      ),
    ];
  }

  Widget _buildAlertaImage(alerta) {
    if (alerta.imagenPath != null && alerta.imagenPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          alerta.imagenPath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildAlertaPlaceholder();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.red.shade400,
              ),
            );
          },
        ),
      );
    }

    return _buildAlertaPlaceholder();
  }

  Widget _buildAlertaPlaceholder() {
    return Center(
      child: Icon(
        Icons.warning,
        size: 18,
        color: Colors.red.shade400,
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
            Colors.red.shade50,
            Colors.orange.shade50,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.red.shade200,
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
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.warning,
                      color: Colors.red.shade600,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Refacciones con Stock Crítico',
                    style: TextStyle(
                      color: Colors.red.shade700,
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
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${provider.refaccionesEnAlerta.length}',
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
          // Botón exportar lista de compras
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _exportarListaCompras(context),
              icon: const Icon(Icons.file_download, size: 16),
              label: const Text(
                'Exportar Lista',
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
        color: Colors.red.shade50,
        border: Border(
          top: BorderSide(
            color: Colors.red.shade200,
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
                  Icons.priority_high,
                  color: Colors.red.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Refacciones que requieren reabastecimiento inmediato',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            Text(
              'Total en alerta: ${provider.refaccionesEnAlerta.length}',
              style: TextStyle(
                color: Colors.red.shade600,
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

  void _actualizarStock(BuildContext context, String refaccionId) {
    final alerta = provider.refaccionesEnAlerta.firstWhere(
      (a) => a.refaccionId == refaccionId,
    );

    _showActualizarStockDialog(context, alerta);
  }

  void _generarReporte(BuildContext context, String refaccionId) {
    final alerta = provider.refaccionesEnAlerta.firstWhere(
      (a) => a.refaccionId == refaccionId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generar reporte para ${alerta.nombre}'),
        backgroundColor: Colors.blue.shade600,
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _verDetalles(BuildContext context, String refaccionId) {
    final alerta = provider.refaccionesEnAlerta.firstWhere(
      (a) => a.refaccionId == refaccionId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalles de ${alerta.nombre}'),
        backgroundColor: Colors.purple.shade600,
      ),
    );
  }

  void _exportarListaCompras(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Exportando lista de compras (${provider.refaccionesEnAlerta.length} elementos)'),
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

  void _showActualizarStockDialog(BuildContext context, alerta) {
    final controller =
        TextEditingController(text: alerta.existencias.toString());
    final theme = AppTheme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.orange.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Actualizar Stock Crítico',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alerta.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${alerta.sku}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontFamily: 'Poppins',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Stock actual: ',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        '${alerta.existencias}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        ' / ${alerta.minimoAlerta} mínimo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nuevo stock',
                hintText: 'Ingrese la nueva cantidad',
                prefixIcon: const Icon(Icons.add_circle_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final nuevoStock = int.tryParse(controller.text) ?? 0;
              if (nuevoStock >= 0) {
                provider.actualizarExistencias(alerta.refaccionId, nuevoStock);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              Text('Stock actualizado para ${alerta.nombre}'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}
