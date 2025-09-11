// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/inventario_provider.dart';

class InventarioTable extends StatelessWidget {
  final InventarioProvider provider;
  final String sucursalId;

  const InventarioTable({
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
      rows: provider.inventarioRows,
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                sku,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: theme.primaryText,
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
        width: 220,
        minWidth: 180,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final refaccion = provider.refaccionesFiltradas.firstWhere(
            (r) => r.nombre == rendererContext.cell.value,
            orElse: () => provider.refaccionesFiltradas.first,
          );

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Imagen o placeholder
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: _buildRefaccionImage(refaccion),
                ),
                const SizedBox(width: 12),
                // Información de la refacción
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        refaccion.nombre,
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
                      Text(
                        refaccion.descripcion,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: theme.secondaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
        title: 'Proveedor',
        field: 'proveedor',
        type: PlutoColumnType.text(),
        width: 140,
        minWidth: 120,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final proveedor = rendererContext.cell.value.toString();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.business,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    proveedor,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
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
        title: 'Precio Unit.',
        field: 'precio_unitario',
        type: PlutoColumnType.text(),
        width: 100,
        minWidth: 90,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final precio = rendererContext.cell.value.toString();

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.shade200,
                  width: 1,
                ),
              ),
              child: Text(
                precio,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.green.shade700,
                ),
              ),
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
          final refaccion = provider.refaccionesFiltradas.firstWhere(
            (r) => r.existencias == existencias,
            orElse: () => provider.refaccionesFiltradas.first,
          );

          Color backgroundColor;
          Color textColor;
          Color borderColor;

          if (refaccion.enAlerta) {
            backgroundColor = Colors.red.shade50;
            textColor = Colors.red.shade700;
            borderColor = Colors.red.shade200;
          } else if (existencias <= refaccion.minimoAlerta * 2) {
            backgroundColor = Colors.orange.shade50;
            textColor = Colors.orange.shade700;
            borderColor = Colors.orange.shade200;
          } else {
            backgroundColor = Colors.blue.shade50;
            textColor = Colors.blue.shade700;
            borderColor = Colors.blue.shade200;
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
              child: Text(
                existencias.toString(),
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
        title: 'Mín. Alerta',
        field: 'minimo_alerta',
        type: PlutoColumnType.number(),
        width: 90,
        minWidth: 80,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final minimo = rendererContext.cell.value as int;

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
                minimo.toString(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.grey.shade700,
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
        width: 90,
        minWidth: 80,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final estado = rendererContext.cell.value.toString();
          final isActive = estado == 'Activo';

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      isActive ? Colors.green.shade200 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    estado,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Valor Inventario',
        field: 'valor_inventario',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final valor = rendererContext.cell.value.toString();

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.shade200,
                  width: 1,
                ),
              ),
              child: Text(
                valor,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.amber.shade700,
                ),
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _verDetallesRefaccion(
                      rendererContext.stateManager.gridFocusNode.context!,
                      rendererContext.cell.value.toString(),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Icon(
                      Icons.visibility,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ),
                // Botón editar existencias
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _editarExistencias(
                      rendererContext.stateManager.gridFocusNode.context!,
                      rendererContext.cell.value.toString(),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ),
                // Botón historial
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.purple.shade200,
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _verHistorialRefaccion(
                      rendererContext.stateManager.gridFocusNode.context!,
                      rendererContext.cell.value.toString(),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Icon(
                      Icons.history,
                      size: 16,
                      color: Colors.purple.shade600,
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

  Widget _buildRefaccionImage(refaccion) {
    if (refaccion.imagenPath != null && refaccion.imagenPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          refaccion.imagenPath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildRefaccionPlaceholder();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey.shade400,
              ),
            );
          },
        ),
      );
    }

    return _buildRefaccionPlaceholder();
  }

  Widget _buildRefaccionPlaceholder() {
    return Center(
      child: Icon(
        Icons.build,
        size: 20,
        color: Colors.grey.shade400,
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
                    Icons.inventory,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Inventario de Refacciones',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      fontSize: 14,
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
    final valorTotal = provider.refaccionesFiltradas
        .where((r) => r.activo)
        .fold<double>(0, (sum, r) => sum + r.valorInventario);

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
              'Total de refacciones: ${provider.refaccionesFiltradas.length}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              'Valor total inventario: \$${valorTotal.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.grey.shade600,
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

  void _verDetallesRefaccion(BuildContext context, String refaccionId) {
    final refaccion = provider.refaccionesFiltradas.firstWhere(
      (r) => r.refaccionId == refaccionId,
    );

    provider.seleccionarRefaccion(refaccion);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver detalles de ${refaccion.nombre}'),
        backgroundColor: AppTheme.of(context).primaryColor,
      ),
    );
  }

  void _editarExistencias(BuildContext context, String refaccionId) {
    final refaccion = provider.refaccionesFiltradas.firstWhere(
      (r) => r.refaccionId == refaccionId,
    );

    _showEditarExistenciasDialog(context, refaccion);
  }

  void _verHistorialRefaccion(BuildContext context, String refaccionId) {
    final refaccion = provider.refaccionesFiltradas.firstWhere(
      (r) => r.refaccionId == refaccionId,
    );

    final historial = provider.obtenerHistorialRefaccion(refaccionId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Historial de ${refaccion.nombre}: ${historial.length} movimientos'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _showEditarExistenciasDialog(BuildContext context, refaccion) {
    final controller =
        TextEditingController(text: refaccion.existencias.toString());
    final theme = AppTheme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Actualizar Existencias',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              refaccion.nombre,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'SKU: ${refaccion.sku}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nuevas existencias',
                hintText: 'Ingrese la cantidad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
              final nuevasExistencias = int.tryParse(controller.text) ?? 0;
              if (nuevasExistencias >= 0) {
                provider.actualizarExistencias(
                    refaccion.refaccionId, nuevasExistencias);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Existencias actualizadas para ${refaccion.nombre}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
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
