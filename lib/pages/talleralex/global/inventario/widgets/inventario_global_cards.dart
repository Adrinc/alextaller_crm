import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/inventario_global_provider.dart';
import 'redistribucion_dialog.dart';

class InventarioGlobalCards extends StatelessWidget {
  const InventarioGlobalCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Consumer<InventarioGlobalProvider>(
      builder: (context, provider, child) {
        if (provider.inventarioFiltrado.isEmpty) {
          return _buildEmptyState(theme);
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: provider.inventarioFiltrado.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = provider.inventarioFiltrado[index];
            return _buildInventarioCard(context, item, theme, index + 1);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: theme.primaryColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay refacciones',
            style: theme.title3.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron refacciones con los filtros aplicados',
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

  Widget _buildInventarioCard(
      BuildContext context, dynamic item, AppTheme theme, int numero) {
    final stockActual =
        int.tryParse(item['stock_actual']?.toString() ?? '0') ?? 0;
    final stockMinimo =
        int.tryParse(item['stock_minimo']?.toString() ?? '0') ?? 0;
    final precioUnitario =
        double.tryParse(item['precio_unitario']?.toString() ?? '0') ?? 0.0;
    final valorTotal = stockActual * precioUnitario;

    // Determinar estado del stock
    String estadoStock = 'Normal';
    Color estadoColor = Colors.green;
    IconData estadoIcon = Icons.check_circle;

    if (stockActual == 0) {
      estadoStock = 'Sin Stock';
      estadoColor = Colors.red;
      estadoIcon = Icons.error;
    } else if (stockActual <= stockMinimo) {
      estadoStock = 'Stock Bajo';
      estadoColor = Colors.orange;
      estadoIcon = Icons.warning;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetallesDialog(context, item, theme),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con número y estado
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          numero.toString(),
                          style: theme.bodyText1.override(
                            fontFamily: 'Poppins',
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: estadoColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(estadoIcon, size: 14, color: estadoColor),
                          const SizedBox(width: 4),
                          Text(
                            estadoStock,
                            style: theme.bodyText2.override(
                              fontFamily: 'Poppins',
                              color: estadoColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Nombre de la refacción
                Text(
                  item['nombre_refaccion']?.toString() ?? 'Sin nombre',
                  style: theme.title3.override(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Información básica
                if (item['categoria']?.toString().isNotEmpty == true)
                  _buildInfoRow(
                    Icons.category_outlined,
                    'Categoría',
                    item['categoria']?.toString() ?? '',
                    theme,
                  ),

                _buildInfoRow(
                  Icons.store_outlined,
                  'Sucursal',
                  item['sucursal_nombre']?.toString() ?? '',
                  theme,
                ),

                const SizedBox(height: 12),

                // Stock y precios
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricaCard(
                        'Stock Actual',
                        stockActual.toString(),
                        Icons.inventory,
                        theme.primaryColor,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricaCard(
                        'Stock Mín.',
                        stockMinimo.toString(),
                        Icons.low_priority,
                        Colors.orange,
                        theme,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricaCard(
                        'Precio Unit.',
                        '\$${precioUnitario.toStringAsFixed(2)}',
                        Icons.attach_money,
                        Colors.green,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricaCard(
                        'Valor Total',
                        '\$${valorTotal.toStringAsFixed(2)}',
                        Icons.calculate,
                        Colors.purple,
                        theme,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showDetallesDialog(context, item, theme),
                        icon: Icon(Icons.info_outline, size: 16),
                        label: Text('Ver Detalles'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                          side: BorderSide(color: theme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    if (stockActual > 0) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showRedistribucionDialog(context, item),
                          icon: Icon(Icons.swap_horiz, size: 16),
                          label: Text('Redistribuir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.secondaryText),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricaCard(
    String label,
    String value,
    IconData icon,
    Color color,
    AppTheme theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.bodyText2.override(
                    fontFamily: 'Poppins',
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetallesDialog(BuildContext context, dynamic item, AppTheme theme) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(maxWidth: 400),
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
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalles de Refacción',
                          style: theme.title3.override(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item['nombre_refaccion']?.toString() ?? '',
                          style: theme.bodyText1.override(
                            fontFamily: 'Poppins',
                            color: theme.secondaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Información completa
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

              // Stock y precios
              _buildDetalleItem('Stock Actual',
                  item['stock_actual']?.toString() ?? '0', theme),
              _buildDetalleItem('Stock Mínimo',
                  item['stock_minimo']?.toString() ?? '0', theme),
              _buildDetalleItem(
                  'Precio Unitario',
                  '\$${(double.tryParse(item['precio_unitario']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)}',
                  theme),

              if (item['proveedor']?.toString().isNotEmpty == true) ...[
                const Divider(height: 32),
                _buildDetalleItem(
                    'Proveedor', item['proveedor']?.toString() ?? '', theme),
              ],

              const SizedBox(height: 24),

              // Botón cerrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cerrar',
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetalleItem(String label, String value, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
}
