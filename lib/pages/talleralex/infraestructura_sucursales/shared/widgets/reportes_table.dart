// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/reportes_provider.dart';

class ReportesTable extends StatelessWidget {
  final ReportesProvider provider;
  final String sucursalId;
  final String tipo; // 'clientes', 'tecnicos', 'alertas'

  const ReportesTable({
    super.key,
    required this.provider,
    required this.sucursalId,
    required this.tipo,
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
      rows: _getRows(),
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
    switch (tipo) {
      case 'clientes':
        return _buildClientesColumns(theme);
      case 'tecnicos':
        return _buildTecnicosColumns(theme);
      case 'alertas':
        return _buildAlertasColumns(theme);
      default:
        return [];
    }
  }

  List<PlutoRow> _getRows() {
    switch (tipo) {
      case 'clientes':
        return provider.clientesFrecuentesRows;
      case 'tecnicos':
        return provider.tecnicosProductivosRows;
      case 'alertas':
        return provider.alertasRows;
      default:
        return [];
    }
  }

  List<PlutoColumn> _buildClientesColumns(AppTheme theme) {
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
          final cliente = provider.clientesFrecuentes.firstWhere(
            (e) => e.clienteNombre == rendererContext.cell.value,
            orElse: () => provider.clientesFrecuentes.first,
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
                      colors: [theme.primaryColor, theme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      cliente.iniciales,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
                          color: theme.primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (cliente.correo?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          cliente.correo!,
                          style: TextStyle(
                            color: theme.secondaryText,
                            fontSize: 11,
                            fontFamily: 'Poppins',
                          ),
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
        width: 140,
        minWidth: 120,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final telefono = rendererContext.cell.value?.toString() ?? '';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: telefono.isNotEmpty
                ? Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 14,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          telefono,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.primaryText,
                            fontFamily: 'Poppins',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Sin teléfono',
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
        title: 'Total Citas',
        field: 'total_citas',
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
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
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green.shade700,
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
        title: 'Promedio/Cita',
        field: 'promedio_gasto',
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
    ];
  }

  List<PlutoColumn> _buildTecnicosColumns(AppTheme theme) {
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
        title: 'Técnico',
        field: 'nombre',
        type: PlutoColumnType.text(),
        width: 200,
        minWidth: 180,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final tecnico = provider.tecnicosProductivos.firstWhere(
            (e) => e.empleadoNombre == rendererContext.cell.value,
            orElse: () => provider.tecnicosProductivos.first,
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
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      tecnico.iniciales,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Información del técnico
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tecnico.empleadoNombre,
                        style: TextStyle(
                          color: theme.primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tecnico.especialidad?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          tecnico.especialidad!,
                          style: TextStyle(
                            color: theme.secondaryText,
                            fontSize: 11,
                            fontFamily: 'Poppins',
                          ),
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
        title: 'Órdenes',
        field: 'ordenes_atendidas',
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Horas',
        field: 'horas_trabajadas',
        type: PlutoColumnType.text(),
        width: 100,
        minWidth: 80,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Ingresos',
        field: 'ingresos_generados',
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
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green.shade700,
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
        title: 'Promedio/Orden',
        field: 'promedio_ingreso',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Tiempo/Orden',
        field: 'promedio_tiempo',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
    ];
  }

  List<PlutoColumn> _buildAlertasColumns(AppTheme theme) {
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
      ),
      PlutoColumn(
        title: 'Tipo',
        field: 'tipo',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Título',
        field: 'titulo',
        type: PlutoColumnType.text(),
        width: 200,
        minWidth: 180,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Descripción',
        field: 'descripcion',
        type: PlutoColumnType.text(),
        width: 300,
        minWidth: 250,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Severidad',
        field: 'severidad',
        type: PlutoColumnType.text(),
        width: 100,
        minWidth: 80,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Fecha',
        field: 'fecha',
        type: PlutoColumnType.text(),
        width: 120,
        minWidth: 100,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
    ];
  }

  Widget _buildCustomHeader(
    BuildContext context,
    AppTheme theme,
    PlutoGridStateManager stateManager,
  ) {
    String titulo = '';
    IconData icono = Icons.table_chart;

    switch (tipo) {
      case 'clientes':
        titulo = 'Clientes Frecuentes';
        icono = Icons.people;
        break;
      case 'tecnicos':
        titulo = 'Técnicos Productivos';
        icono = Icons.build;
        break;
      case 'alertas':
        titulo = 'Alertas Operativas';
        icono = Icons.warning;
        break;
    }

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
                    icono,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    titulo,
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
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
    int totalRegistros = 0;
    String textoAdicional = '';

    switch (tipo) {
      case 'clientes':
        totalRegistros = provider.clientesFrecuentes.length;
        final totalGastado = provider.clientesFrecuentes
            .fold<double>(0, (sum, c) => sum + c.totalGastado);
        textoAdicional = 'Total gastado: \$${totalGastado.toStringAsFixed(2)}';
        break;
      case 'tecnicos':
        totalRegistros = provider.tecnicosProductivos.length;
        final totalIngresos = provider.tecnicosProductivos
            .fold<double>(0, (sum, t) => sum + t.ingresosGenerados);
        textoAdicional =
            'Ingresos generados: \$${totalIngresos.toStringAsFixed(2)}';
        break;
      case 'alertas':
        totalRegistros = provider.alertas.length;
        final alertasAltas =
            provider.alertas.where((a) => a.severidad == 'alta').length;
        textoAdicional = 'Alertas críticas: $alertasAltas';
        break;
    }

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
              'Total de registros: $totalRegistros',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            if (textoAdicional.isNotEmpty)
              Text(
                textoAdicional,
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
}
