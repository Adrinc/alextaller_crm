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
          width: 60,
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
          width: 250,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final sucursal = provider.sucursales[rendererContext.rowIdx];
            return Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // Imagen o icono de la sucursal
                  Container(
                    width: 40,
                    height: 40,
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
                      child: _buildSucursalImage(context, sucursal),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          sucursal.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.of(context).primaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (sucursal.emailContacto != null)
                          Text(
                            sucursal.emailContacto!,
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
          width: 200,
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
          title: 'Dirección',
          field: 'direccion',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.start,
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
          width: 80,
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
          width: 130,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          renderer: (rendererContext) {
            final sucursal = provider.sucursales[rendererContext.rowIdx];
            final hasCoords = sucursal.lat != null && sucursal.lng != null;

            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasCoords
                      ? AppTheme.of(context).success.withOpacity(0.1)
                      : AppTheme.of(context).warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasCoords ? Icons.gps_fixed : Icons.gps_off,
                      size: 14,
                      color: hasCoords
                          ? AppTheme.of(context).success
                          : AppTheme.of(context).warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasCoords ? 'Ubicado' : 'Sin ubicar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: hasCoords
                            ? AppTheme.of(context).success
                            : AppTheme.of(context).warning,
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
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 120,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          enableSorting: false,
          enableColumnDrag: false,
          enableContextMenu: false,
          renderer: (rendererContext) {
            final sucursal = provider.sucursales[rendererContext.rowIdx];
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botón ver/editar
                  Tooltip(
                    message: 'Ver sucursal',
                    child: InkWell(
                      onTap: () => context.go('/sucursal/${sucursal.id}'),
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
                      onTap: () => _showEditDialog(
                          context, sucursal.id, sucursal.nombre),
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
                      onTap: () => _showDeleteDialog(
                          context, sucursal.id, sucursal.nombre),
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
      rows: _buildRows(),
      onLoaded: (event) {
        // Si necesitas acceso al stateManager, puedes guardarlo aquí
      },
      createFooter: (stateManager) {
        stateManager.setPageSize(15, notify: false);
        return PlutoPagination(stateManager);
      },
    );
  }

  List<PlutoRow> _buildRows() {
    return provider.sucursales.asMap().entries.map((entry) {
      final index = entry.key;
      final sucursal = entry.value;

      return PlutoRow(
        cells: {
          'numero': PlutoCell(value: (index + 1).toString()),
          'nombre': PlutoCell(value: sucursal.nombre),
          'telefono': PlutoCell(value: sucursal.telefono ?? ''),
          'direccion': PlutoCell(value: sucursal.direccion ?? ''),
          'capacidad_bahias': PlutoCell(value: sucursal.capacidadBahias ?? 0),
          'coordenadas': PlutoCell(
              value: sucursal.lat != null && sucursal.lng != null
                  ? 'Ubicado'
                  : 'Sin ubicar'),
          'acciones': PlutoCell(value: 'acciones'),
        },
      );
    }).toList();
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
                            ? 'Sucursal eliminada correctamente'
                            : 'Error al eliminar la sucursal',
                      ),
                      backgroundColor: success
                          ? AppTheme.of(context).success
                          : AppTheme.of(context).error,
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
