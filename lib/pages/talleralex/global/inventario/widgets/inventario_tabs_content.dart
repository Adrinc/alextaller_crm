import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/inventario_global_provider.dart';

enum InventarioTabType {
  alertas,
  caducidad,
  rotacion,
  sugerencias,
}

class InventarioTabsContent extends StatelessWidget {
  final InventarioTabType tabType;
  final bool isSmallScreen;

  const InventarioTabsContent({
    Key? key,
    required this.tabType,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<InventarioGlobalProvider>(
      builder: (context, provider, child) {
        switch (tabType) {
          case InventarioTabType.alertas:
            return _buildAlertasTab(context, provider);
          case InventarioTabType.caducidad:
            return _buildCaducidadTab(context, provider);
          case InventarioTabType.rotacion:
            return _buildRotacionTab(context, provider);
          case InventarioTabType.sugerencias:
            return _buildSugerenciasTab(context, provider);
        }
      },
    );
  }

  Widget _buildAlertasTab(
      BuildContext context, InventarioGlobalProvider provider) {
    final theme = AppTheme.of(context);

    if (provider.isLoading) {
      return _buildLoadingState(theme);
    }

    if (provider.alertasStock.isEmpty) {
      return _buildEmptyState(
        theme,
        Icons.check_circle_outline,
        '¡Excelente!',
        'No hay alertas de stock críticas',
        Colors.green,
      );
    }

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con resumen
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.red.shade600, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alertas de Stock Crítico',
                        style: theme.title3.override(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      Text(
                        '${provider.alertasStock.length} refacciones necesitan atención',
                        style: theme.bodyText2.override(
                          fontFamily: 'Poppins',
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lista de alertas
          Expanded(
            child: ListView.separated(
              itemCount: provider.alertasStock.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final alerta = provider.alertasStock[index];
                return _buildAlertaCard(alerta, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertaCard(dynamic alerta, AppTheme theme) {
    final tipoAlerta = alerta['tipo_alerta']?.toString() ?? '';
    final stockActual =
        int.tryParse(alerta['stock_actual']?.toString() ?? '0') ?? 0;
    final stockMinimo =
        int.tryParse(alerta['stock_minimo']?.toString() ?? '0') ?? 0;

    Color alertaColor = Colors.orange;
    IconData alertaIcon = Icons.warning;
    String alertaTexto = 'Stock Bajo';

    if (tipoAlerta == 'SIN_STOCK') {
      alertaColor = Colors.red;
      alertaIcon = Icons.error;
      alertaTexto = 'Sin Stock';
    } else if (tipoAlerta == 'SOBRESTOCK') {
      alertaColor = Colors.blue;
      alertaIcon = Icons.inventory_2;
      alertaTexto = 'Sobrestock';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alertaColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: alertaColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(alertaIcon, color: alertaColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alerta['nombre_refaccion']?.toString() ?? '',
                      style: theme.bodyText1.override(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      alerta['sucursal_nombre']?.toString() ?? '',
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: alertaColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alertaTexto,
                  style: theme.bodyText2.override(
                    fontFamily: 'Poppins',
                    color: alertaColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStockInfo(
                  'Actual', stockActual.toString(), alertaColor, theme),
              const SizedBox(width: 16),
              _buildStockInfo(
                  'Mínimo', stockMinimo.toString(), Colors.grey, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfo(
      String label, String value, Color color, AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.bodyText2.override(
            fontFamily: 'Poppins',
            color: theme.secondaryText,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: theme.bodyText1.override(
            fontFamily: 'Poppins',
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCaducidadTab(
      BuildContext context, InventarioGlobalProvider provider) {
    final theme = AppTheme.of(context);

    if (provider.isLoading) {
      return _buildLoadingState(theme);
    }

    if (provider.refaccionesPorCaducar.isEmpty) {
      return _buildEmptyState(
        theme,
        Icons.schedule_outlined,
        'Control de Caducidad',
        'No hay refacciones próximas a caducar',
        Colors.purple,
      );
    }

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        children: [
          // Header informativo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Colors.purple.shade600, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${provider.refaccionesPorCaducar.length} refacciones próximas a caducar',
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              itemCount: provider.refaccionesPorCaducar.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = provider.refaccionesPorCaducar[index];
                return _buildCaducidadCard(item, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaducidadCard(dynamic item, AppTheme theme) {
    final diasParaCaducar =
        int.tryParse(item['dias_para_caducar']?.toString() ?? '0') ?? 0;
    final stockActual =
        int.tryParse(item['stock_actual']?.toString() ?? '0') ?? 0;
    final valorAfectado =
        double.tryParse(item['valor_afectado']?.toString() ?? '0') ?? 0.0;

    Color urgenciaColor = Colors.green;
    String urgenciaTexto = 'Normal';

    if (diasParaCaducar < 0) {
      urgenciaColor = Colors.red.shade700;
      urgenciaTexto = 'Caducado';
    } else if (diasParaCaducar == 0) {
      urgenciaColor = Colors.red;
      urgenciaTexto = 'Caduca Hoy';
    } else if (diasParaCaducar <= 7) {
      urgenciaColor = Colors.orange;
      urgenciaTexto = 'Esta Semana';
    } else if (diasParaCaducar <= 30) {
      urgenciaColor = Colors.yellow.shade700;
      urgenciaTexto = 'Este Mes';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: urgenciaColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nombre_refaccion']?.toString() ?? '',
                      style: theme.bodyText1.override(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${item['sucursal_nombre']} • Lote: ${item['lote'] ?? 'N/A'}',
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: urgenciaColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  urgenciaTexto,
                  style: theme.bodyText2.override(
                    fontFamily: 'Poppins',
                    color: urgenciaColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetrica('Stock', stockActual.toString(), Icons.inventory),
              const SizedBox(width: 16),
              _buildMetrica('Días', diasParaCaducar.toString(), Icons.schedule),
              const SizedBox(width: 16),
              _buildMetrica('Valor', '\$${valorAfectado.toStringAsFixed(0)}',
                  Icons.attach_money),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRotacionTab(
      BuildContext context, InventarioGlobalProvider provider) {
    final theme = AppTheme.of(context);

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: _buildPlaceholderContent(
        theme,
        Icons.trending_up,
        'Análisis de Rotación',
        'Análisis de rotación de inventario próximamente',
        Colors.blue,
      ),
    );
  }

  Widget _buildSugerenciasTab(
      BuildContext context, InventarioGlobalProvider provider) {
    final theme = AppTheme.of(context);

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: _buildPlaceholderContent(
        theme,
        Icons.lightbulb_outline,
        'Sugerencias de Compra',
        'Sugerencias inteligentes de compra próximamente',
        Colors.green,
      ),
    );
  }

  Widget _buildMetrica(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando datos...',
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    AppTheme theme,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 64, color: color.withOpacity(0.6)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.title3.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent(
    AppTheme theme,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 80, color: color.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.title2.override(
              fontFamily: 'Poppins',
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              'Próximamente',
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
