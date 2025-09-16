import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/inventario_global_provider.dart';
import 'redistribucion_dialog.dart';

class InventarioGlobalTable extends StatelessWidget {
  final InventarioGlobalProvider provider;

  const InventarioGlobalTable({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
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
          scrollBarColor: AppTheme.of(context).primaryColor.withOpacity(0.7),
          scrollBarTrackColor: Colors.grey.withOpacity(0.2),
          scrollbarRadius: const Radius.circular(8),
          scrollbarRadiusWhileDragging: const Radius.circular(10),
        ),
        style: PlutoGridStyleConfig(
          gridBorderColor: Colors.grey.withOpacity(0.3),
          activatedBorderColor: AppTheme.of(context).primaryColor,
          inactivatedBorderColor: Colors.grey.withOpacity(0.3),
          gridBackgroundColor: AppTheme.of(context).primaryBackground,
          rowColor: AppTheme.of(context).secondaryBackground,
          activatedColor: AppTheme.of(context).primaryColor.withOpacity(0.1),
          checkedColor: AppTheme.of(context).primaryColor.withOpacity(0.2),
          cellTextStyle: TextStyle(
            fontSize: 14,
            color: AppTheme.of(context).primaryText,
          ),
          columnTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.of(context).primaryText,
          ),
          menuBackgroundColor: AppTheme.of(context).secondaryBackground,
          gridBorderRadius: BorderRadius.circular(8),
          rowHeight: 70,
        ),
        columnFilter: const PlutoGridColumnFilterConfig(
          filters: [
            ...FilterHelper.defaultFilters,
          ],
        ),
      ),
      columns: [
        PlutoColumn(
          title: '#',
          field: 'numero',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 80,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          backgroundColor: AppTheme.of(context).primaryColor,
          enableContextMenu: false,
          enableDropToResize: false,
          renderer: (rendererContext) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                rendererContext.cell.value.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.of(context).primaryColor,
                ),
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Refacción',
          field: 'nombre_refaccion',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.start,
          minWidth: 200,
          width: 250,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
        ),
        PlutoColumn(
          title: 'Categoría',
          field: 'categoria',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 120,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
        ),
        PlutoColumn(
          title: 'Sucursal',
          field: 'sucursal_nombre',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 150,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
        ),
        PlutoColumn(
          title: 'Stock Actual',
          field: 'stock_actual',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 100,
          type: PlutoColumnType.number(format: '#,###'),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final stock = rendererContext.cell.value ?? 0;
            final stockActual =
                stock is int ? stock : int.tryParse(stock.toString()) ?? 0;

            Color badgeColor;
            if (stockActual == 0) {
              badgeColor = AppTheme.of(context).error;
            } else if (stockActual <= 5) {
              badgeColor = AppTheme.of(context).warning;
            } else {
              badgeColor = AppTheme.of(context).success;
            }

            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  border: Border.all(color: badgeColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stockActual.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Stock Mín.',
          field: 'stock_minimo',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 90,
          type: PlutoColumnType.number(format: '#,###'),
          enableEditingMode: false,
        ),
        PlutoColumn(
          title: 'Precio Unit.',
          field: 'precio_unitario',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.right,
          width: 110,
          type: PlutoColumnType.currency(format: '\$#,###.00'),
          enableEditingMode: false,
        ),
        PlutoColumn(
          title: 'Valor Total',
          field: 'valor_total',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.right,
          width: 120,
          type: PlutoColumnType.currency(format: '\$#,###.00'),
          enableEditingMode: false,
        ),
        PlutoColumn(
          title: 'Estado',
          field: 'estado_stock',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 100,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            return _buildEstadoStockChip(rendererContext.cell.value.toString());
          },
        ),
        PlutoColumn(
          title: 'Acciones',
          field: 'acciones',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 120,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          enableSorting: false,
          enableColumnDrag: false,
          enableContextMenu: false,
          renderer: (rendererContext) {
            return _buildAccionesButtons(context, rendererContext);
          },
        ),
      ],
      rows: provider.inventarioRows,
      onLoaded: (event) {
        // Si necesitas acceso al stateManager, puedes guardarlo aquí
      },
      createFooter: (stateManager) {
        stateManager.setPageSize(15, notify: false);
        return PlutoPagination(stateManager);
      },
    );
  }

  Widget _buildEstadoStockChip(String estado) {
    Color backgroundColor;
    Color textColor;

    switch (estado) {
      case 'Sin Stock':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red.shade700;
        break;
      case 'Stock Bajo':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        break;
      case 'Sobrestock':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue.shade700;
        break;
      default:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildAccionesButtons(
      BuildContext context, PlutoColumnRendererContext rendererContext) {
    final item = rendererContext.cell.value;
    final stockActual =
        int.tryParse(item['stock_actual']?.toString() ?? '0') ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón de redistribuir (solo si tiene stock)
        if (stockActual > 0)
          IconButton(
            icon: const Icon(Icons.swap_horiz, size: 16),
            onPressed: () => _showRedistribucionDialog(context, item),
            tooltip: 'Redistribuir',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),

        // Botón de detalles
        IconButton(
          icon: const Icon(Icons.info_outline, size: 16),
          onPressed: () => _showDetallesItem(context, item),
          tooltip: 'Detalles',
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  void _showRedistribucionDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => RedistribucionDialog(
        refaccionId: item['refaccion_id']?.toString() ?? '',
        nombreRefaccion: item['nombre_refaccion']?.toString() ?? '',
        sucursalOrigenId: item['sucursal_id']?.toString() ?? '',
        sucursalOrigenNombre: item['sucursal_nombre']?.toString() ?? '',
        stockDisponible:
            int.tryParse(item['stock_actual']?.toString() ?? '0') ?? 0,
      ),
    );
  }

  void _showDetallesItem(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => _buildDetallesDialog(context, item),
    );
  }

  Widget _buildDetallesDialog(BuildContext context, dynamic item) {
    final theme = AppTheme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: theme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles de Inventario',
                        style: theme.title3.override(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item['nombre_refaccion']?.toString() ?? '',
                        style: theme.bodyText2.override(
                          fontFamily: 'Poppins',
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Información básica
            _buildDetalleItem(
                'Categoría', item['categoria']?.toString() ?? 'N/A', theme),
            _buildDetalleItem(
                'Marca', item['marca']?.toString() ?? 'N/A', theme),
            _buildDetalleItem(
                'Modelo', item['modelo']?.toString() ?? 'N/A', theme),
            _buildDetalleItem(
                'Sucursal', item['sucursal_nombre']?.toString() ?? '', theme),
            _buildDetalleItem(
                'Ubicación', item['ubicacion']?.toString() ?? 'N/A', theme),

            const Divider(height: 32),

            // Información de stock
            Row(
              children: [
                Expanded(
                  child: _buildDetalleItem(
                      'Stock Actual', '${item['stock_actual'] ?? 0}', theme),
                ),
                Expanded(
                  child: _buildDetalleItem(
                      'Stock Mínimo', '${item['stock_minimo'] ?? 0}', theme),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _buildDetalleItem('Precio Unitario',
                      '\$${item['precio_unitario'] ?? 0}', theme),
                ),
                Expanded(
                  child: _buildDetalleItem(
                      'Valor Total', '\$${item['valor_total'] ?? 0}', theme),
                ),
              ],
            ),

            if (item['proveedor']?.toString().isNotEmpty == true) ...[
              const Divider(height: 32),
              _buildDetalleItem(
                  'Proveedor', item['proveedor']?.toString() ?? '', theme),
            ],

            const SizedBox(height: 24),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cerrar',
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleItem(String label, String value, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label + ':',
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
