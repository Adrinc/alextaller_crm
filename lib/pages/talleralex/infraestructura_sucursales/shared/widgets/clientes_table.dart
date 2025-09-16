// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/clientes_provider.dart';
import 'package:nethive_neo/models/talleralex/clientes_models.dart';
import 'package:nethive_neo/pages/talleralex/widgets/clientes_globales_widgets/universal_cliente_detalle_dialog.dart';
import 'package:nethive_neo/pages/talleralex/widgets/clientes_globales_widgets/universal_cliente_opciones_dialog.dart';

class ClientesTable extends StatefulWidget {
  final ClientesProvider provider;
  final String sucursalId;
  final String sucursalNombre;

  const ClientesTable({
    super.key,
    required this.provider,
    required this.sucursalId,
    required this.sucursalNombre,
  });

  @override
  State<ClientesTable> createState() => _ClientesTableState();
}

class _ClientesTableState extends State<ClientesTable> {
  ClientesProvider get provider => widget.provider;
  String get sucursalId => widget.sucursalId;
  String get sucursalNombre => widget.sucursalNombre;

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
      rows: provider.clientesRows,
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
        title: 'Cliente',
        field: 'nombre',
        type: PlutoColumnType.text(),
        width: 220,
        minWidth: 180,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final cliente = provider.clientesFiltrados.firstWhere(
            (e) => e.clienteNombre == rendererContext.cell.value,
            orElse: () => provider.clientesFiltrados.first,
          );

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Avatar con iniciales
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
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
                      _getInitials(cliente.clienteNombre),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Información del cliente
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cliente.clienteNombre,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: theme.primaryText,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (cliente.rfc?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          'RFC: ${cliente.rfc}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Contacto',
        field: 'telefono',
        type: PlutoColumnType.text(),
        width: 180,
        minWidth: 150,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final cliente = provider.clientesFiltrados.firstWhere(
            (e) => e.telefono == rendererContext.cell.value,
            orElse: () => provider.clientesFiltrados.first,
          );

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (cliente.telefono?.isNotEmpty == true)
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 14,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cliente.telefono!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.primaryText,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                if (cliente.correo?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        size: 14,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          cliente.correo!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Dirección',
        field: 'direccion',
        type: PlutoColumnType.text(),
        width: 200,
        minWidth: 160,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final direccion = rendererContext.cell.value?.toString() ?? '';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: direccion.isNotEmpty
                ? Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.orange.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          direccion,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.primaryText,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Sin dirección',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Poppins',
                    ),
                  ),
          );
        },
      ),
      PlutoColumn(
        title: 'Vehículos',
        field: 'vehiculos',
        type: PlutoColumnType.number(),
        width: 100,
        minWidth: 80,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final count = rendererContext.cell.value as int;

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: count > 0 ? Colors.blue.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      count > 0 ? Colors.blue.shade300 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 16,
                    color:
                        count > 0 ? Colors.blue.shade600 : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: count > 0
                          ? Colors.blue.shade600
                          : Colors.grey.shade500,
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
        title: 'Citas Próximas',
        field: 'citas_proximas',
        type: PlutoColumnType.number(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final count = rendererContext.cell.value as int;

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: count > 0 ? Colors.green.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      count > 0 ? Colors.green.shade300 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event,
                    size: 16,
                    color: count > 0
                        ? Colors.green.shade600
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: count > 0
                          ? Colors.green.shade600
                          : Colors.grey.shade500,
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
        title: 'Última Visita',
        field: 'ultima_visita',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final texto = rendererContext.cell.value?.toString() ?? 'Sin visitas';

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: texto != 'Sin visitas'
                    ? Colors.purple.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: texto != 'Sin visitas'
                      ? Colors.purple.shade300
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 11,
                  color: texto != 'Sin visitas'
                      ? Colors.purple.shade600
                      : Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Total Gastado',
        field: 'total_gastado',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          final texto = rendererContext.cell.value?.toString() ?? '\$0.00';

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Acciones',
        field: 'acciones',
        type: PlutoColumnType.text(),
        width: 180,
        minWidth: 180,
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
                // Botón ver detalles completo
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        final clienteId = rendererContext.cell.value.toString();
                        final cliente = provider.clientesFiltrados.firstWhere(
                          (c) => c.clienteId == clienteId,
                        );
                        _mostrarDetalleCompleto(context, cliente);
                      },
                      child: Icon(
                        Icons.visibility,
                        size: 16,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
                ),
                // Botón opciones/contactar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.shade200,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        final clienteId = rendererContext.cell.value.toString();
                        final cliente = provider.clientesFiltrados.firstWhere(
                          (c) => c.clienteId == clienteId,
                        );
                        _mostrarOpcionesCliente(context, cliente);
                      },
                      child: Icon(
                        Icons.phone,
                        size: 16,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ),
                ),
                // Botón más opciones
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        final clienteId = rendererContext.cell.value.toString();
                        final cliente = provider.clientesFiltrados.firstWhere(
                          (c) => c.clienteId == clienteId,
                        );
                        _mostrarOpcionesCompletas(context, cliente);
                      },
                      child: Icon(
                        Icons.more_horiz,
                        size: 16,
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
                    Icons.people_outline,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Clientes (${provider.clientesFiltrados.length})',
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
              'Total de clientes: ${provider.clientesFiltrados.length}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              'Vehículos totales: ${provider.clientesFiltrados.fold<int>(0, (sum, c) => sum + c.totalVehiculos)}',
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

  // Métodos para manejar los popups universales
  void _mostrarDetalleCompleto(BuildContext context, ClienteGrid cliente) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => UniversalClienteDetalleDialog(
        cliente: ClienteLocalAdapter(cliente, sucursalNombre),
        provider: ClientesProviderAdapter(provider),
      ),
    );
  }

  void _mostrarOpcionesCliente(BuildContext context, ClienteGrid cliente) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => UniversalClienteOpcionesDialog(
        cliente: ClienteLocalAdapter(cliente, sucursalNombre),
      ),
    );
  }

  void _mostrarOpcionesCompletas(BuildContext context, ClienteGrid cliente) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => UniversalClienteOpcionesDialog(
        cliente: ClienteLocalAdapter(cliente, sucursalNombre),
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
}
