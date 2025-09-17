import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nethive_neo/providers/talleralex/promociones_globales_provider.dart';
import 'package:nethive_neo/models/talleralex/promociones_models.dart';

class PromocionesActivasTable extends StatefulWidget {
  final VoidCallback? onEditarPromocion;
  final Function(String promocionId)? onPublicarPromocion;
  final Function(String promocionId)? onEmitirCupones;
  final Function(String promocionId)? onEliminarPromocion;

  const PromocionesActivasTable({
    Key? key,
    this.onEditarPromocion,
    this.onPublicarPromocion,
    this.onEmitirCupones,
    this.onEliminarPromocion,
  }) : super(key: key);

  @override
  State<PromocionesActivasTable> createState() =>
      _PromocionesActivasTableState();
}

class _PromocionesActivasTableState extends State<PromocionesActivasTable> {
  PlutoGridStateManager? stateManager;

  @override
  Widget build(BuildContext context) {
    return Consumer<PromocionesGlobalesProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: PlutoGrid(
            columns: _buildColumns(),
            rows: provider.promocionesActivasRows,
            onLoaded: (PlutoGridOnLoadedEvent event) {
              stateManager = event.stateManager;
              stateManager!.setShowColumnFilter(true);
            },
            onRowDoubleTap: (event) {
              final promocionId = event.row.cells['acciones']?.value as String?;
              if (promocionId != null) {
                _mostrarModalAcciones(context, promocionId, provider);
              }
            },
            configuration: PlutoGridConfiguration(
              localeText: const PlutoGridLocaleText.spanish(),
              style: PlutoGridStyleConfig(
                gridBackgroundColor: Colors.white,
                rowHeight: 80,
                columnHeight: 50,
                borderColor: Colors.grey.shade200,
                activatedBorderColor: const Color(0xFF0066CC),
                gridBorderRadius: BorderRadius.circular(8),
                cellTextStyle: GoogleFonts.poppins(fontSize: 13),
                columnTextStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                columnAscendingIcon: const Icon(
                  Icons.arrow_upward,
                  color: Color(0xFF0066CC),
                  size: 16,
                ),
                columnDescendingIcon: const Icon(
                  Icons.arrow_downward,
                  color: Color(0xFF0066CC),
                  size: 16,
                ),
              ),
              columnSize: const PlutoGridColumnSizeConfig(
                autoSizeMode: PlutoAutoSizeMode.scale,
                resizeMode: PlutoResizeMode.normal,
              ),
              scrollbar: const PlutoGridScrollbarConfig(
                isAlwaysShown: false,
              ),
            ),
          ),
        );
      },
    );
  }

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: '#',
        field: 'numero',
        type: PlutoColumnType.text(),
        width: 60,
        enableSorting: false,
        enableColumnDrag: false,
        enableEditingMode: false,
        renderer: (rendererContext) {
          return Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Text(
              rendererContext.cell.value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Promoción',
        field: 'titulo',
        type: PlutoColumnType.text(),
        width: 200,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final promocion = _getPromocionFromRow(rendererContext.row);
          if (promocion == null) return Container();

          return Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  promocion.titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0A0A0A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  promocion.descripcion,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Descuento',
        field: 'tipo',
        type: PlutoColumnType.text(),
        width: 130,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final promocion = _getPromocionFromRow(rendererContext.row);
          if (promocion == null) return Container();

          final color = promocion.tipoDescuento == TipoDescuento.porcentaje
              ? const Color(0xFF2ECC71)
              : const Color(0xFFFF6B00);

          return Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    promocion.tipoDescuento.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  promocion.valorDescuentoTexto,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0A0A0A),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Sucursal',
        field: 'sucursal',
        type: PlutoColumnType.text(),
        width: 120,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final sucursalNombre = rendererContext.cell.value.toString();
          return Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(
                  sucursalNombre == 'Todas' ? Icons.business : Icons.store,
                  size: 16,
                  color: sucursalNombre == 'Todas'
                      ? const Color(0xFF0066CC)
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    sucursalNombre,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0A0A0A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Vigencia',
        field: 'inicio',
        type: PlutoColumnType.date(),
        width: 150,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final promocion = _getPromocionFromRow(rendererContext.row);
          if (promocion == null) return Container();

          return Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Inicio: ${promocion.fechaInicio.toIso8601String().split('T')[0]}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fin: ${promocion.fechaFin.toIso8601String().split('T')[0]}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${promocion.diasRestantes} días',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: promocion.diasRestantes <= 7
                        ? Colors.red.shade600
                        : const Color(0xFF2ECC71),
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
        type: PlutoColumnType.text(),
        width: 100,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final promocion = _getPromocionFromRow(rendererContext.row);
          if (promocion == null) return Container();

          Color estadoColor;
          IconData estadoIcon;

          if (!promocion.activo) {
            estadoColor = Colors.grey.shade600;
            estadoIcon = Icons.pause_circle;
          } else if (promocion.estaVigente) {
            estadoColor = const Color(0xFF2ECC71);
            estadoIcon = Icons.check_circle;
          } else if (DateTime.now().isBefore(promocion.fechaInicio)) {
            estadoColor = const Color(0xFFFF6B00);
            estadoIcon = Icons.schedule;
          } else {
            estadoColor = Colors.red.shade600;
            estadoIcon = Icons.cancel;
          }

          return Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  estadoIcon,
                  color: estadoColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  promocion.estadoTexto,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: estadoColor,
                  ),
                  textAlign: TextAlign.center,
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
        enableSorting: false,
        enableColumnDrag: false,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final promocionId = rendererContext.cell.value.toString();
          return Container(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  color: const Color(0xFF0066CC),
                  onPressed: () => widget.onEditarPromocion?.call(),
                  tooltip: 'Editar',
                ),
                _buildActionButton(
                  icon: Icons.more_vert,
                  color: Colors.grey.shade600,
                  onPressed: () => _mostrarModalAcciones(
                    context,
                    promocionId,
                    Provider.of<PromocionesGlobalesProvider>(context,
                        listen: false),
                  ),
                  tooltip: 'Más acciones',
                ),
              ],
            ),
          );
        },
      ),
    ];
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onPressed,
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  PromocionActiva? _getPromocionFromRow(PlutoRow row) {
    final promocionId = row.cells['acciones']?.value as String?;
    if (promocionId == null) return null;

    final provider =
        Provider.of<PromocionesGlobalesProvider>(context, listen: false);
    try {
      return provider.promocionesActivasFiltradas.firstWhere(
        (p) => p.promocionId == promocionId,
      );
    } catch (e) {
      return null;
    }
  }

  void _mostrarModalAcciones(BuildContext context, String promocionId,
      PromocionesGlobalesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Acciones de Promoción',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAccionItem(
              icon: Icons.publish,
              titulo: 'Publicar en Sucursales',
              subtitulo: 'Distribuir a sucursales seleccionadas',
              color: const Color(0xFF2ECC71),
              onTap: () {
                Navigator.pop(context);
                widget.onPublicarPromocion?.call(promocionId);
              },
            ),
            const Divider(),
            _buildAccionItem(
              icon: Icons.qr_code,
              titulo: 'Emitir Cupones',
              subtitulo: 'Generar códigos QR masivos',
              color: const Color(0xFFFF6B00),
              onTap: () {
                Navigator.pop(context);
                widget.onEmitirCupones?.call(promocionId);
              },
            ),
            const Divider(),
            _buildAccionItem(
              icon: Icons.delete,
              titulo: 'Eliminar Promoción',
              subtitulo: 'Acción irreversible',
              color: Colors.red.shade600,
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminacion(context, promocionId);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccionItem({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        titulo,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitulo,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      onTap: onTap,
      dense: true,
    );
  }

  void _confirmarEliminacion(BuildContext context, String promocionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red.shade600,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Confirmar Eliminación',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar esta promoción? Esta acción no se puede deshacer.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onEliminarPromocion?.call(promocionId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TABLA ROI
// ============================================================================

class PromocionesROITable extends StatefulWidget {
  final Function(String promocionId)? onVerDetalle;

  const PromocionesROITable({
    Key? key,
    this.onVerDetalle,
  }) : super(key: key);

  @override
  State<PromocionesROITable> createState() => _PromocionesROITableState();
}

class _PromocionesROITableState extends State<PromocionesROITable> {
  PlutoGridStateManager? stateManager;

  @override
  Widget build(BuildContext context) {
    return Consumer<PromocionesGlobalesProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: PlutoGrid(
            columns: _buildColumns(),
            rows: provider.promocionesROIRows,
            onLoaded: (PlutoGridOnLoadedEvent event) {
              stateManager = event.stateManager;
              stateManager!.setShowColumnFilter(true);
            },
            onRowDoubleTap: (event) {
              final promocionId = event.row.cells['acciones']?.value as String?;
              if (promocionId != null) {
                widget.onVerDetalle?.call(promocionId);
              }
            },
            configuration: PlutoGridConfiguration(
              localeText: const PlutoGridLocaleText.spanish(),
              style: PlutoGridStyleConfig(
                gridBackgroundColor: Colors.white,
                rowHeight: 60,
                columnHeight: 50,
                borderColor: Colors.grey.shade200,
                activatedBorderColor: const Color(0xFFFF2D95),
                gridBorderRadius: BorderRadius.circular(8),
                cellTextStyle: GoogleFonts.poppins(fontSize: 13),
                columnTextStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              columnSize: const PlutoGridColumnSizeConfig(
                autoSizeMode: PlutoAutoSizeMode.scale,
                resizeMode: PlutoResizeMode.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: '#',
        field: 'numero',
        type: PlutoColumnType.text(),
        width: 60,
        enableSorting: false,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Promoción',
        field: 'titulo',
        type: PlutoColumnType.text(),
        width: 200,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Canjes',
        field: 'canjes',
        type: PlutoColumnType.number(),
        width: 80,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final valor = rendererContext.cell.value as int;
          return Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0066CC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                valor.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0066CC),
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Clientes',
        field: 'clientes',
        type: PlutoColumnType.number(),
        width: 80,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Descuento Total',
        field: 'descuento',
        type: PlutoColumnType.currency(),
        width: 120,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final valor = rendererContext.cell.value as double;
          return Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.centerRight,
            child: Text(
              '\$${valor.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade600,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Ingreso Bruto',
        field: 'ingreso_bruto',
        type: PlutoColumnType.currency(),
        width: 120,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final valor = rendererContext.cell.value as double;
          return Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.centerRight,
            child: Text(
              '\$${valor.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Ingreso Neto',
        field: 'ingreso_neto',
        type: PlutoColumnType.currency(),
        width: 120,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final valor = rendererContext.cell.value as double;
          return Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.centerRight,
            child: Text(
              '\$${valor.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2ECC71),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'ROI',
        field: 'roi',
        type: PlutoColumnType.number(),
        width: 100,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final valor = rendererContext.cell.value as double;
          final porcentaje = (valor * 100).toStringAsFixed(1);
          final color =
              valor >= 0 ? const Color(0xFF2ECC71) : Colors.red.shade600;

          return Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    valor >= 0 ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$porcentaje%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Ticket Prom.',
        field: 'ticket_promedio',
        type: PlutoColumnType.currency(),
        width: 100,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final valor = rendererContext.cell.value as double;
          return Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.centerRight,
            child: Text(
              '\$${valor.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Acciones',
        field: 'acciones',
        type: PlutoColumnType.text(),
        width: 80,
        enableSorting: false,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final promocionId = rendererContext.cell.value.toString();
          return Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: IconButton(
              onPressed: () => widget.onVerDetalle?.call(promocionId),
              icon: const Icon(
                Icons.visibility,
                size: 18,
                color: Color(0xFFFF2D95),
              ),
              tooltip: 'Ver detalle',
            ),
          );
        },
      ),
    ];
  }
}

// ============================================================================
// TABLA CUPONES
// ============================================================================

class CuponesTable extends StatefulWidget {
  final Function(String cuponId)? onGenerarQR;
  final Function(String cuponId)? onDescargarQR;
  final Function(String cuponId)? onProbarCanje;

  const CuponesTable({
    Key? key,
    this.onGenerarQR,
    this.onDescargarQR,
    this.onProbarCanje,
  }) : super(key: key);

  @override
  State<CuponesTable> createState() => _CuponesTableState();
}

class _CuponesTableState extends State<CuponesTable> {
  PlutoGridStateManager? stateManager;

  @override
  Widget build(BuildContext context) {
    return Consumer<PromocionesGlobalesProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: PlutoGrid(
            columns: _buildColumns(),
            rows: provider.cuponesRows,
            onLoaded: (PlutoGridOnLoadedEvent event) {
              stateManager = event.stateManager;
              stateManager!.setShowColumnFilter(true);
            },
            configuration: PlutoGridConfiguration(
              localeText: const PlutoGridLocaleText.spanish(),
              style: PlutoGridStyleConfig(
                gridBackgroundColor: Colors.white,
                rowHeight: 70,
                columnHeight: 50,
                borderColor: Colors.grey.shade200,
                activatedBorderColor: const Color(0xFFFF6B00),
                gridBorderRadius: BorderRadius.circular(8),
                cellTextStyle: GoogleFonts.poppins(fontSize: 13),
                columnTextStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: '#',
        field: 'numero',
        type: PlutoColumnType.text(),
        width: 60,
        enableSorting: false,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Código',
        field: 'codigo',
        type: PlutoColumnType.text(),
        width: 150,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final codigo = rendererContext.cell.value.toString();
          return Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFF6B00).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    codigo,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF6B00),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'QR disponible',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade500,
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
        title: 'Usos',
        field: 'usos',
        type: PlutoColumnType.text(),
        width: 100,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final cupon = _getCuponFromRow(rendererContext.row);
          if (cupon == null) return Container();

          final progreso = cupon.limiteUsoGlobal > 0
              ? cupon.usosRealizados / cupon.limiteUsoGlobal
              : 0.0;

          return Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  cupon.usoTexto,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progreso,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progreso >= 1.0
                        ? Colors.red.shade600
                        : const Color(0xFF2ECC71),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Límite Cliente',
        field: 'limite_cliente',
        type: PlutoColumnType.number(),
        width: 100,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Vigencia',
        field: 'vigencia',
        type: PlutoColumnType.text(),
        width: 180,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final cupon = _getCuponFromRow(rendererContext.row);
          if (cupon == null) return Container();

          return Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Inicio: ${cupon.fechaInicio.toIso8601String().split('T')[0]}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fin: ${cupon.fechaFin.toIso8601String().split('T')[0]}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
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
        type: PlutoColumnType.text(),
        width: 100,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final cupon = _getCuponFromRow(rendererContext.row);
          if (cupon == null) return Container();

          Color estadoColor;
          IconData estadoIcon;

          if (!cupon.estaDisponible) {
            estadoColor = Colors.red.shade600;
            estadoIcon = Icons.block;
          } else if (DateTime.now().isAfter(cupon.fechaFin)) {
            estadoColor = Colors.grey.shade600;
            estadoIcon = Icons.schedule_outlined;
          } else {
            estadoColor = const Color(0xFF2ECC71);
            estadoIcon = Icons.check_circle;
          }

          return Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  estadoIcon,
                  color: estadoColor,
                  size: 18,
                ),
                const SizedBox(height: 4),
                Text(
                  cupon.estadoTexto,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: estadoColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Creado',
        field: 'creado',
        type: PlutoColumnType.date(),
        width: 100,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Acciones',
        field: 'acciones',
        type: PlutoColumnType.text(),
        width: 120,
        enableSorting: false,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final cuponId = rendererContext.cell.value.toString();
          return Container(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCuponActionButton(
                  icon: Icons.qr_code,
                  color: const Color(0xFFFF6B00),
                  onPressed: () => widget.onGenerarQR?.call(cuponId),
                  tooltip: 'Ver QR',
                ),
                _buildCuponActionButton(
                  icon: Icons.download,
                  color: const Color(0xFF0066CC),
                  onPressed: () => widget.onDescargarQR?.call(cuponId),
                  tooltip: 'Descargar',
                ),
                _buildCuponActionButton(
                  icon: Icons.play_arrow,
                  color: const Color(0xFF2ECC71),
                  onPressed: () => widget.onProbarCanje?.call(cuponId),
                  tooltip: 'Probar',
                ),
              ],
            ),
          );
        },
      ),
    ];
  }

  Widget _buildCuponActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: onPressed,
            child: Icon(
              icon,
              size: 14,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  CuponItem? _getCuponFromRow(PlutoRow row) {
    final cuponId = row.cells['acciones']?.value as String?;
    if (cuponId == null) return null;

    final provider =
        Provider.of<PromocionesGlobalesProvider>(context, listen: false);
    try {
      return provider.cuponesFiltrados.firstWhere(
        (c) => c.id == cuponId,
      );
    } catch (e) {
      return null;
    }
  }
}
