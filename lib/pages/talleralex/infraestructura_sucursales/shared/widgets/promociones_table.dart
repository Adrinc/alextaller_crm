import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/promociones_provider.dart';

class PromocionesTable extends StatefulWidget {
  final PromocionesProvider provider;
  final String sucursalId;

  const PromocionesTable({
    super.key,
    required this.provider,
    required this.sucursalId,
  });

  @override
  State<PromocionesTable> createState() => _PromocionesTableState();
}

class _PromocionesTableState extends State<PromocionesTable> {
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
                rows: widget.provider.promocionesRows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  _configureGrid();
                },
                onRowDoubleTap: (event) => _mostrarDetallePromocion(event.row),
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
              Icons.local_offer,
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
                  'Gestión de Promociones',
                  style: theme.title3.override(
                    fontFamily: 'Poppins',
                    color: theme.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.provider.promocionesFiltradas.length} promociones encontradas',
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
            // Botón nueva promoción
            _buildActionButton(
              theme,
              'Nueva Promoción',
              Icons.add,
              Colors.green,
              _mostrarDialogoNuevaPromocion,
            ),
            const SizedBox(width: 12),
            // Botón exportar
            _buildActionButton(
              theme,
              'Exportar',
              Icons.download,
              Colors.blue,
              _exportarDatos,
            ),
          ] else ...[
            // Menú de acciones para móvil
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'nueva':
                    _mostrarDialogoNuevaPromocion();
                    break;
                  case 'exportar':
                    _exportarDatos();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'nueva',
                  child: ListTile(
                    leading: Icon(Icons.add, color: Colors.green),
                    title: Text('Nueva Promoción'),
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
          title: 'Título',
          field: 'titulo',
          type: PlutoColumnType.text(),
          width: 150,
          minWidth: 120,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildCellRenderer(
            rendererContext.cell.value?.toString() ?? '',
            Icons.local_offer,
            theme.primaryColor,
          ),
        ),
        PlutoColumn(
          title: 'Descuento',
          field: 'valor_descuento',
          type: PlutoColumnType.text(),
          width: 100,
          minWidth: 80,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildDescuentoRenderer(
            rendererContext.cell.value?.toString() ?? '',
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
          title: '#',
          field: 'numero',
          type: PlutoColumnType.text(),
          width: 60,
          minWidth: 50,
          enableSorting: false,
          enableColumnDrag: false,
          renderer: (rendererContext) => Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              rendererContext.cell.value?.toString() ?? '',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: theme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        PlutoColumn(
          title: 'Título',
          field: 'titulo',
          type: PlutoColumnType.text(),
          width: 180,
          minWidth: 150,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildCellRenderer(
            rendererContext.cell.value?.toString() ?? '',
            Icons.local_offer,
            theme.primaryColor,
          ),
        ),
        PlutoColumn(
          title: 'Descripción',
          field: 'descripcion',
          type: PlutoColumnType.text(),
          width: 200,
          minWidth: 150,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildDescripcionRenderer(
            rendererContext.cell.value?.toString() ?? '',
            theme,
          ),
        ),
        PlutoColumn(
          title: 'Tipo',
          field: 'tipo_descuento',
          type: PlutoColumnType.text(),
          width: 120,
          minWidth: 100,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildTipoRenderer(
            rendererContext.cell.value?.toString() ?? '',
            theme,
          ),
        ),
        PlutoColumn(
          title: 'Descuento',
          field: 'valor_descuento',
          type: PlutoColumnType.text(),
          width: 100,
          minWidth: 80,
          enableSorting: true,
          enableColumnDrag: false,
          textAlign: PlutoColumnTextAlign.center,
          renderer: (rendererContext) => _buildDescuentoRenderer(
            rendererContext.cell.value?.toString() ?? '',
            theme,
          ),
        ),
        PlutoColumn(
          title: 'Vigencia',
          field: 'vigencia',
          type: PlutoColumnType.text(),
          width: 140,
          minWidth: 120,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildCellRenderer(
            rendererContext.cell.value?.toString() ?? '',
            Icons.date_range,
            Colors.orange,
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
          title: 'Ámbito',
          field: 'ambito',
          type: PlutoColumnType.text(),
          width: 80,
          minWidth: 70,
          enableSorting: true,
          enableColumnDrag: false,
          renderer: (rendererContext) => _buildAmbitoRenderer(
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

  Widget _buildDescripcionRenderer(String descripcion, AppTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        descripcion,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: theme.secondaryText,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  Widget _buildTipoRenderer(String tipo, AppTheme theme) {
    IconData icon;
    Color color;

    switch (tipo.toLowerCase()) {
      case 'porcentaje':
        icon = Icons.percent;
        color = Colors.blue;
        break;
      case 'monto fijo':
        icon = Icons.attach_money;
        color = Colors.green;
        break;
      case 'descuento especial':
        icon = Icons.star;
        color = Colors.purple;
        break;
      default:
        icon = Icons.local_offer;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              tipo,
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

  Widget _buildDescuentoRenderer(String descuento, AppTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        descuento,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.green.shade700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEstadoRenderer(String estado, AppTheme theme) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (estado.toLowerCase()) {
      case 'vigente':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      case 'próxima':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        icon = Icons.schedule;
        break;
      case 'expirada':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        icon = Icons.event_busy;
        break;
      case 'inactiva':
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        icon = Icons.pause_circle;
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
            estado,
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

  Widget _buildAmbitoRenderer(String ambito, AppTheme theme) {
    final esGlobal = ambito.toLowerCase() == 'global';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: esGlobal ? Colors.purple.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            esGlobal ? Icons.public : Icons.location_on,
            size: 10,
            color: esGlobal ? Colors.purple.shade600 : Colors.blue.shade600,
          ),
          const SizedBox(width: 2),
          Text(
            ambito,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: esGlobal ? Colors.purple.shade600 : Colors.blue.shade600,
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
            onTap: () => _mostrarDetallePromocion(row),
            tooltip: 'Ver detalles',
          ),
          // Editar
          _buildActionButton2(
            icon: Icons.edit,
            color: Colors.orange,
            onTap: () => _editarPromocion(row),
            tooltip: 'Editar promoción',
          ),
          if (!isSmallScreen) ...[
            // Toggle activo/inactivo
            _buildActionButton2(
              icon: Icons.power_settings_new,
              color: Colors.green,
              onTap: () => _toggleEstadoPromocion(row),
              tooltip: 'Cambiar estado',
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
                  value: 'servicios',
                  child: ListTile(
                    leading: Icon(Icons.build, size: 16),
                    title:
                        Text('Ver servicios', style: TextStyle(fontSize: 12)),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'eliminar',
                  child: ListTile(
                    leading: Icon(Icons.delete, size: 16, color: Colors.red),
                    title: Text('Eliminar',
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
  void _mostrarDialogoNuevaPromocion() {
    // TODO: Implementar diálogo de nueva promoción
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Funcionalidad de nueva promoción en desarrollo')),
    );
  }

  void _exportarDatos() {
    // TODO: Implementar exportación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Funcionalidad de exportación en desarrollo')),
    );
  }

  void _mostrarDetallePromocion(PlutoRow row) {
    // TODO: Implementar vista de detalles
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Ver detalles de promoción: ${row.cells['titulo']?.value}')),
    );
  }

  void _editarPromocion(PlutoRow row) {
    // TODO: Implementar edición
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Editar promoción: ${row.cells['titulo']?.value}')),
    );
  }

  void _toggleEstadoPromocion(PlutoRow row) {
    // TODO: Implementar toggle de estado
    // final promocionId = row.cells['acciones']?.value as String;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Cambiar estado de promoción: ${row.cells['titulo']?.value}')),
    );
  }

  void _ejecutarAccion(String accion, PlutoRow row) {
    switch (accion) {
      case 'duplicar':
        // TODO: Implementar duplicación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Duplicar promoción: ${row.cells['titulo']?.value}')),
        );
        break;
      case 'servicios':
        // TODO: Implementar vista de servicios
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Ver servicios de: ${row.cells['titulo']?.value}')),
        );
        break;
      case 'eliminar':
        // TODO: Implementar eliminación con confirmación
        _confirmarEliminacion(row);
        break;
    }
  }

  void _confirmarEliminacion(PlutoRow row) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Estás seguro de que deseas eliminar la promoción "${row.cells['titulo']?.value}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar eliminación real
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Promoción eliminada')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
