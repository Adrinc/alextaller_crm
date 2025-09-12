import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/pagos_provider.dart';

class FacturasTable extends StatefulWidget {
  final PagosProvider provider;
  final String sucursalId;

  const FacturasTable({
    super.key,
    required this.provider,
    required this.sucursalId,
  });

  @override
  State<FacturasTable> createState() => _FacturasTableState();
}

class _FacturasTableState extends State<FacturasTable> {
  late PlutoGridStateManager stateManager;

  // Colores del tema neumorphic
  static const Color backgroundColor = Color(0xFFF0F0F3);
  static const Color cardColor = Color(0xFFF0F0F3);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-8, -8),
            blurRadius: 16,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(8, 8),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Header de la tabla
            _buildTableHeader(theme, isSmallScreen),

            // Grid
            Expanded(
              child: PlutoGrid(
                columns: _buildColumns(theme, isSmallScreen),
                rows: widget.provider.facturasRows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  _configureGrid();
                },
                onRowDoubleTap: (event) => _mostrarDetalleFactura(event.row),
                configuration: PlutoGridConfiguration(
                  style: PlutoGridStyleConfig(
                    gridBackgroundColor: backgroundColor,
                    rowColor: cardColor,
                    activatedColor: theme.primaryColor.withOpacity(0.1),
                    checkedColor: theme.primaryColor.withOpacity(0.2),
                    cellColorInEditState: Colors.white,
                    borderColor: Colors.grey.shade300,
                    activatedBorderColor: theme.primaryColor,
                    gridBorderColor: Colors.transparent,
                    iconColor: theme.primaryText,
                    cellTextStyle: TextStyle(
                      color: theme.primaryText,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    columnTextStyle: TextStyle(
                      color: theme.primaryText,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  columnSize: const PlutoGridColumnSizeConfig(
                    autoSizeMode: PlutoAutoSizeMode.scale,
                    resizeMode: PlutoResizeMode.pushAndPull,
                  ),
                  scrollbar: const PlutoGridScrollbarConfig(
                    isAlwaysShown: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(AppTheme theme, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial de Facturas',
                  style: theme.title3.override(
                    fontFamily: 'Poppins',
                    color: theme.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.provider.facturasFiltradasList.length} facturas encontradas',
                  style: theme.bodyText2.override(
                    fontFamily: 'Poppins',
                    color: theme.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!isSmallScreen) ...[
            // Botón nueva factura
            _buildActionButton(
              theme,
              'Nueva Factura',
              Icons.add,
              Colors.green,
              _mostrarDialogoNuevaFactura,
            ),
            const SizedBox(width: 12),
            // Botón exportar
            _buildActionButton(
              theme,
              'Exportar',
              Icons.download,
              Colors.blue,
              _exportarFacturas,
            ),
            const SizedBox(width: 12),
            // Botón reportes
            _buildActionButton(
              theme,
              'Reportes',
              Icons.analytics,
              Colors.purple,
              _generarReportes,
            ),
          ] else ...[
            // Menú de acciones para móvil
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'nueva':
                    _mostrarDialogoNuevaFactura();
                    break;
                  case 'exportar':
                    _exportarFacturas();
                    break;
                  case 'reportes':
                    _generarReportes();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'nueva',
                  child: ListTile(
                    leading: Icon(Icons.add, color: Colors.green),
                    title: Text('Nueva Factura'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'exportar',
                  child: ListTile(
                    leading: Icon(Icons.download, color: Colors.blue),
                    title: Text('Exportar'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'reportes',
                  child: ListTile(
                    leading: Icon(Icons.analytics, color: Colors.purple),
                    title: Text('Reportes'),
                    dense: true,
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      offset: const Offset(-2, -2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.grey.shade400.withOpacity(0.4),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.more_vert,
                  color: theme.primaryColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    AppTheme theme,
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: const Offset(-2, -2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.grey.shade400.withOpacity(0.4),
              offset: const Offset(2, 2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              text,
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PlutoColumn> _buildColumns(AppTheme theme, bool isSmallScreen) {
    final List<PlutoColumn> columns = [];

    if (isSmallScreen) {
      // Columnas para móvil
      columns.addAll([
        PlutoColumn(
          title: 'Factura',
          field: 'numero_factura',
          type: PlutoColumnType.text(),
          width: 100,
          minWidth: 80,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildCellRenderer(
            rendererContext.cell.value?.toString() ?? '',
            Icons.receipt,
            theme.primaryColor,
          ),
        ),
        PlutoColumn(
          title: 'Cliente',
          field: 'cliente',
          type: PlutoColumnType.text(),
          width: 140,
          minWidth: 120,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildCellRenderer(
            rendererContext.cell.value?.toString() ?? '',
            Icons.person,
            theme.primaryColor,
          ),
        ),
        PlutoColumn(
          title: 'Total',
          field: 'total',
          type: PlutoColumnType.text(),
          width: 100,
          minWidth: 80,
          enableSorting: true,
          enableColumnDrag: false,
          textAlign: PlutoColumnTextAlign.right,
          renderer: (rendererContext) => _buildMontoRenderer(
            rendererContext.cell.value?.toString() ?? '0',
            theme,
          ),
        ),
        PlutoColumn(
          title: 'Estado',
          field: 'estado',
          type: PlutoColumnType.text(),
          width: 100,
          minWidth: 80,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildEstadoRenderer(
            rendererContext.cell.value?.toString() ?? '',
            theme,
          ),
        ),
        PlutoColumn(
          title: 'Acciones',
          field: 'acciones',
          type: PlutoColumnType.text(),
          width: 120,
          minWidth: 100,
          enableSorting: false,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildActionButtons(
            rendererContext.row,
            theme,
            isSmallScreen,
          ),
        ),
      ]);
    } else {
      // Columnas para escritorio
      columns.addAll([
        PlutoColumn(
          title: 'Número',
          field: 'numero_factura',
          type: PlutoColumnType.text(),
          width: 120,
          minWidth: 100,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildCellRenderer(
            rendererContext.cell.value?.toString() ?? '',
            Icons.receipt,
            theme.primaryColor,
          ),
        ),
        PlutoColumn(
          title: 'Cliente',
          field: 'cliente',
          type: PlutoColumnType.text(),
          width: 160,
          minWidth: 120,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildCellRenderer(
            rendererContext.cell.value?.toString() ?? '',
            Icons.person,
            theme.primaryColor,
          ),
        ),
        PlutoColumn(
          title: 'RUC/CI',
          field: 'ruc_ci',
          type: PlutoColumnType.text(),
          width: 120,
          minWidth: 100,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildCellRenderer(
            rendererContext.cell.value?.toString() ?? '',
            Icons.badge,
            Colors.blue,
          ),
        ),
        PlutoColumn(
          title: 'Fecha',
          field: 'fecha_factura',
          type: PlutoColumnType.text(),
          width: 100,
          minWidth: 80,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildCellRenderer(
            rendererContext.cell.value?.toString() ?? '',
            Icons.calendar_today,
            Colors.orange,
          ),
        ),
        PlutoColumn(
          title: 'Subtotal',
          field: 'subtotal',
          type: PlutoColumnType.text(),
          width: 100,
          minWidth: 80,
          enableSorting: true,
          enableColumnDrag: false,
          textAlign: PlutoColumnTextAlign.right,
          renderer: (rendererContext) => _buildMontoRenderer(
            rendererContext.cell.value?.toString() ?? '0',
            theme,
          ),
        ),
        PlutoColumn(
          title: 'IVA',
          field: 'iva',
          type: PlutoColumnType.text(),
          width: 80,
          minWidth: 60,
          enableSorting: true,
          enableColumnDrag: false,
          textAlign: PlutoColumnTextAlign.right,
          renderer: (rendererContext) => _buildMontoRenderer(
            rendererContext.cell.value?.toString() ?? '0',
            theme,
          ),
        ),
        PlutoColumn(
          title: 'Total',
          field: 'total',
          type: PlutoColumnType.text(),
          width: 100,
          minWidth: 80,
          enableSorting: true,
          enableColumnDrag: false,
          textAlign: PlutoColumnTextAlign.right,
          renderer: (rendererContext) => _buildMontoRenderer(
            rendererContext.cell.value?.toString() ?? '0',
            theme,
          ),
        ),
        PlutoColumn(
          title: 'Estado',
          field: 'estado',
          type: PlutoColumnType.text(),
          width: 100,
          minWidth: 80,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildEstadoRenderer(
            rendererContext.cell.value?.toString() ?? '',
            theme,
          ),
        ),
        PlutoColumn(
          title: 'Timbrado',
          field: 'timbrado',
          type: PlutoColumnType.text(),
          width: 100,
          minWidth: 80,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildTimbradoRenderer(
            rendererContext.cell.value?.toString() ?? '',
            theme,
          ),
        ),
        PlutoColumn(
          title: 'Acciones',
          field: 'acciones',
          type: PlutoColumnType.text(),
          width: 150,
          minWidth: 120,
          enableSorting: false,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildActionButtons(
            rendererContext.row,
            theme,
            isSmallScreen,
          ),
        ),
      ]);
    }

    return columns;
  }

  Widget _buildCellRenderer(String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMontoRenderer(String value, AppTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.attach_money,
            size: 14,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoRenderer(String estado, AppTheme theme) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (estado.toLowerCase()) {
      case 'emitida':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      case 'anulada':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        icon = Icons.cancel;
        break;
      case 'borrador':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        icon = Icons.edit;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        icon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            estado[0].toUpperCase() + estado.substring(1),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimbradoRenderer(String timbrado, AppTheme theme) {
    final tieneTimbrado = timbrado.isNotEmpty && timbrado != 'null';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(
            tieneTimbrado ? Icons.verified : Icons.verified_outlined,
            size: 14,
            color: tieneTimbrado ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              tieneTimbrado ? timbrado : 'Sin timbrado',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: tieneTimbrado ? theme.primaryText : Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PlutoRow row, AppTheme theme, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Ver detalles
          _buildActionButton2(
            icon: Icons.visibility,
            color: Colors.blue,
            onTap: () => _mostrarDetalleFactura(row),
            tooltip: 'Ver detalles',
          ),
          // Descargar PDF
          _buildActionButton2(
            icon: Icons.picture_as_pdf,
            color: Colors.red,
            onTap: () => _descargarPDF(row),
            tooltip: 'Descargar PDF',
          ),
          if (!isSmallScreen) ...[
            // Imprimir
            _buildActionButton2(
              icon: Icons.print,
              color: Colors.green,
              onTap: () => _imprimirFactura(row),
              tooltip: 'Imprimir',
            ),
            // Enviar por email
            _buildActionButton2(
              icon: Icons.email,
              color: Colors.orange,
              onTap: () => _enviarEmail(row),
              tooltip: 'Enviar por email',
            ),
            // Más opciones
            PopupMenuButton<String>(
              onSelected: (value) => _ejecutarAccion(value, row),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'duplicar',
                  child: ListTile(
                    leading: Icon(Icons.copy, size: 16),
                    title: Text('Duplicar', style: TextStyle(fontSize: 12)),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'editar',
                  child: ListTile(
                    leading: Icon(Icons.edit, size: 16),
                    title: Text('Editar', style: TextStyle(fontSize: 12)),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'anular',
                  child: ListTile(
                    leading: Icon(Icons.cancel, size: 16, color: Colors.red),
                    title: Text('Anular',
                        style: TextStyle(fontSize: 12, color: Colors.red)),
                    dense: true,
                  ),
                ),
              ],
              child: _buildActionButton2(
                icon: Icons.more_horiz,
                color: Colors.grey,
                onTap: () {},
                tooltip: 'Más opciones',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton2({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                offset: const Offset(-1, -1),
                blurRadius: 2,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.4),
                offset: const Offset(1, 1),
                blurRadius: 2,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }

  void _configureGrid() {
    stateManager.setSelectingMode(PlutoGridSelectingMode.row);
  }

  // Métodos de acciones
  void _mostrarDialogoNuevaFactura() {
    // TODO: Implementar diálogo de nueva factura
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Funcionalidad de nueva factura en desarrollo')),
    );
  }

  void _exportarFacturas() {
    // TODO: Implementar exportación de facturas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Funcionalidad de exportación en desarrollo')),
    );
  }

  void _generarReportes() {
    // TODO: Implementar generación de reportes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de reportes en desarrollo')),
    );
  }

  void _mostrarDetalleFactura(PlutoRow row) {
    // TODO: Implementar vista de detalles de factura
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Ver detalles de factura: ${row.cells['numero_factura']?.value}')),
    );
  }

  void _descargarPDF(PlutoRow row) {
    // TODO: Implementar descarga de PDF
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Descargar PDF: ${row.cells['numero_factura']?.value}')),
    );
  }

  void _imprimirFactura(PlutoRow row) {
    // TODO: Implementar impresión
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Imprimir factura: ${row.cells['numero_factura']?.value}')),
    );
  }

  void _enviarEmail(PlutoRow row) {
    // TODO: Implementar envío por email
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Enviar por email: ${row.cells['numero_factura']?.value}')),
    );
  }

  void _ejecutarAccion(String accion, PlutoRow row) {
    switch (accion) {
      case 'duplicar':
        // TODO: Implementar duplicación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Duplicar factura: ${row.cells['numero_factura']?.value}')),
        );
        break;
      case 'editar':
        // TODO: Implementar edición
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Editar factura: ${row.cells['numero_factura']?.value}')),
        );
        break;
      case 'anular':
        // Confirmar anulación
        _confirmarAnulacion(row);
        break;
    }
  }

  void _confirmarAnulacion(PlutoRow row) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar anulación'),
        content: Text(
            '¿Estás seguro de que deseas anular la factura ${row.cells['numero_factura']?.value}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar anulación real
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Factura anulada')),
              );
            },
            child: const Text('Anular', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
