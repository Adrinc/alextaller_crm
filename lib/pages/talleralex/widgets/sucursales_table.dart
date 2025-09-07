// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/providers/talleralex/sucursales_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/helpers/globals.dart';

class SucursalesTable extends StatelessWidget {
  final SucursalesProvider provider;

  const SucursalesTable({
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
          title: 'Nu.',
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
          title: 'Nombre de Sucursal',
          field: 'nombre',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.start,
          minWidth: 200,
          width: 250,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final sucursalMapa =
                provider.sucursalesMapa[rendererContext.rowIdx];
            return Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // Imagen o icono de la sucursal
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: _buildSucursalImage(context, sucursalMapa),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          sucursalMapa.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.of(context).primaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (sucursalMapa.emailContacto != null)
                          Text(
                            sucursalMapa.emailContacto!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.of(context).secondaryText,
                            ),
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
          title: 'Teléfono',
          field: 'telefono',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          minWidth: 200,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final telefono = rendererContext.cell.value?.toString() ?? 'N/A';
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).tertiaryBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.phone,
                      size: 14,
                      color: AppTheme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      telefono,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.of(context).primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Empleados Activos',
          field: 'empleados_activos',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          minWidth: 140,
          type: PlutoColumnType.number(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final empleados = rendererContext.cell.value?.toString() ?? '0';
            final numEmpleados = int.tryParse(empleados) ?? 0;
            Color badgeColor;
            if (numEmpleados >= 10) {
              badgeColor = AppTheme.of(context).success;
            } else if (numEmpleados >= 5) {
              badgeColor = AppTheme.of(context).warning;
            } else {
              badgeColor = AppTheme.of(context).error;
            }

            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: badgeColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      size: 14,
                      color: badgeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      empleados,
                      style: TextStyle(
                        fontSize: 12,
                        color: badgeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Citas Hoy',
          field: 'citas_hoy',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          minWidth: 100,
          type: PlutoColumnType.number(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final citas = rendererContext.cell.value?.toString() ?? '0';
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event,
                      size: 14,
                      color: AppTheme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      citas,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Reportes',
          field: 'reportes_totales',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          /*  width: 100, */
          type: PlutoColumnType.number(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final reportes = rendererContext.cell.value?.toString() ?? '0';
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).tertiaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment,
                      size: 14,
                      color: AppTheme.of(context).tertiaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      reportes,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.of(context).tertiaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Dirección',
          field: 'direccion',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.start,
          minWidth: 300,
          width: 350,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final direccion =
                rendererContext.cell.value?.toString() ?? 'Sin dirección';
            return Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.of(context).secondaryText,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      direccion,
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Bahías',
          field: 'capacidad_bahias',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          minWidth: 80,
          width: 100,
          type: PlutoColumnType.number(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final capacidad = rendererContext.cell.value?.toString() ?? '0';
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  capacidad,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Coordenadas',
          field: 'coordenadas',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          minWidth: 180,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final sucursalMapa =
                provider.sucursalesMapa[rendererContext.rowIdx];
            final hasCoords =
                sucursalMapa.lat != null && sucursalMapa.lng != null;

            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Estado de coordenadas
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: hasCoords
                          ? AppTheme.of(context).success.withOpacity(0.1)
                          : AppTheme.of(context).warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasCoords ? Icons.gps_fixed : Icons.gps_off,
                          size: 12,
                          color: hasCoords
                              ? AppTheme.of(context).success
                              : AppTheme.of(context).warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasCoords ? 'Ubicado' : 'Sin ubicar',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: hasCoords
                                ? AppTheme.of(context).success
                                : AppTheme.of(context).warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Coordenadas detalladas
                  if (hasCoords) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${sucursalMapa.lat!.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.of(context).secondaryText,
                      ),
                    ),
                    Text(
                      'Lng: ${sucursalMapa.lng!.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.of(context).secondaryText,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Gestión',
          field: 'gestion',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          minWidth: 100,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          enableSorting: false,
          enableColumnDrag: false,
          enableContextMenu: false,
          renderer: (rendererContext) {
            final sucursalMapa =
                provider.sucursalesMapa[rendererContext.rowIdx];
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(4),
              child: Tooltip(
                message: 'Gestionar sucursal',
                child: InkWell(
                  onTap: () =>
                      context.go('/sucursal/${sucursalMapa.sucursalId}'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.of(context).primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.of(context)
                              .primaryColor
                              .withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.settings,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Gestión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Acciones',
          field: 'acciones',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          minWidth: 120,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          enableSorting: false,
          enableColumnDrag: false,
          enableContextMenu: false,
          renderer: (rendererContext) {
            final sucursalMapa =
                provider.sucursalesMapa[rendererContext.rowIdx];
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botón ver/editar
                  Tooltip(
                    message: 'Ver detalles',
                    child: InkWell(
                      onTap: () => _showEditDialog(context,
                          sucursalMapa.sucursalId, sucursalMapa.nombre),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context)
                              .primaryColor
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.visibility,
                          size: 16,
                          color: AppTheme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Botón editar
                  Tooltip(
                    message: 'Editar sucursal',
                    child: InkWell(
                      onTap: () => _showEditDialog(context,
                          sucursalMapa.sucursalId, sucursalMapa.nombre),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context)
                              .tertiaryColor
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: AppTheme.of(context).tertiaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Botón eliminar
                  Tooltip(
                    message: 'Eliminar sucursal',
                    child: InkWell(
                      onTap: () => _showDeleteDialog(context,
                          sucursalMapa.sucursalId, sucursalMapa.nombre),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.delete,
                          size: 16,
                          color: AppTheme.of(context).error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
      rows: provider.sucursalesRows,
      onLoaded: (event) {
        // Si necesitas acceso al stateManager, puedes guardarlo aquí
      },
      createFooter: (stateManager) {
        stateManager.setPageSize(15, notify: false);
        return PlutoPagination(stateManager);
      },
    );
  }

  void _showEditDialog(BuildContext context, String sucursalId, String nombre) {
    // TODO: Implementar diálogo de edición
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar sucursal: $nombre (En desarrollo)'),
        backgroundColor: AppTheme.of(context).primaryColor,
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, String sucursalId, String nombre) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.of(context).primaryBackground,
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: AppTheme.of(context).error,
              ),
              const SizedBox(width: 8),
              Text(
                'Confirmar eliminación',
                style: AppTheme.of(context).title3.override(
                      fontFamily: 'Poppins',
                      color: AppTheme.of(context).primaryText,
                    ),
              ),
            ],
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar la sucursal "$nombre"?\n\nEsta acción no se puede deshacer.',
            style: AppTheme.of(context).bodyText2.override(
                  fontFamily: 'Poppins',
                  color: AppTheme.of(context).primaryText,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.of(context).secondaryText),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await context
                    .read<SucursalesProvider>()
                    .eliminarSucursal(sucursalId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '✅ Sucursal "$nombre" eliminada exitosamente'
                            : '❌ Error al eliminar la sucursal',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: success
                          ? AppTheme.of(context).success
                          : AppTheme.of(context).error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.of(context).error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSucursalImage(BuildContext context, sucursal) {
    if (sucursal.imagenUrl != null && sucursal.imagenUrl!.isNotEmpty) {
      final imageUrl =
          "${supabaseLU.supabaseUrl}/storage/v1/object/public/taller_alex/imagenes/${sucursal.imagenUrl}";

      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon(context);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.of(context).primaryColor,
              ),
            ),
          );
        },
      );
    } else {
      return _buildDefaultIcon(context);
    }
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.of(context).primaryGradient,
      ),
      child: Icon(
        Icons.store,
        size: 20,
        color: Colors.white,
      ),
    );
  }
}
