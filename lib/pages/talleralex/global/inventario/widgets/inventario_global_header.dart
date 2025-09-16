import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/inventario_global_provider.dart';

class InventarioGlobalHeader extends StatefulWidget {
  const InventarioGlobalHeader({Key? key}) : super(key: key);

  @override
  State<InventarioGlobalHeader> createState() => _InventarioGlobalHeaderState();
}

class _InventarioGlobalHeaderState extends State<InventarioGlobalHeader> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    return Consumer<InventarioGlobalProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor,
                theme.secondaryColor,
                theme.primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y acciones principales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inventario Global',
                          style: theme.title1.override(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 24 : 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Control centralizado de inventarios',
                          style: theme.bodyText1.override(
                            fontFamily: 'Poppins',
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Botón de refrescar
                      _buildActionButton(
                        icon: Icons.refresh,
                        onPressed: provider.isLoading
                            ? null
                            : () => provider.cargarInventarioGlobal(),
                        tooltip: 'Actualizar datos',
                        isLoading: provider.isLoading,
                      ),
                      const SizedBox(width: 12),
                      // Botón de filtros
                      _buildActionButton(
                        icon: _showFilters
                            ? Icons.filter_list_off
                            : Icons.filter_list,
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                        tooltip: 'Filtros avanzados',
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // KPIs Row
              if (!isSmallScreen)
                _buildKPIsRow(provider, theme)
              else
                _buildKPIsGrid(provider, theme),

              // Barra de búsqueda y filtros rápidos
              const SizedBox(height: 20),
              _buildSearchAndQuickFilters(provider, theme, isSmallScreen),

              // Filtros avanzados (expandible)
              if (_showFilters) ...[
                const SizedBox(height: 16),
                _buildAdvancedFilters(provider, theme, isSmallScreen),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon, color: Colors.white, size: 20),
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildKPIsRow(InventarioGlobalProvider provider, AppTheme theme) {
    return Row(
      children: [
        Expanded(
            child: _buildKPICard(
          'Total Refacciones',
          provider.kpis['total_refacciones']?.toString() ?? '0',
          Icons.inventory_2,
          Colors.blue.shade600,
        )),
        const SizedBox(width: 16),
        Expanded(
            child: _buildKPICard(
          'Valor Total',
          '\$${(provider.kpis['valor_total'] ?? 0.0).toStringAsFixed(0)}',
          Icons.attach_money,
          Colors.green.shade600,
        )),
        const SizedBox(width: 16),
        Expanded(
            child: _buildKPICard(
          'Sin Stock',
          provider.kpis['sin_stock']?.toString() ?? '0',
          Icons.warning,
          Colors.red.shade600,
        )),
        const SizedBox(width: 16),
        Expanded(
            child: _buildKPICard(
          'Stock Bajo',
          provider.kpis['stock_bajo']?.toString() ?? '0',
          Icons.priority_high,
          Colors.orange.shade600,
        )),
        const SizedBox(width: 16),
        Expanded(
            child: _buildKPICard(
          'Por Caducar',
          provider.kpis['alertas_caducidad']?.toString() ?? '0',
          Icons.schedule,
          Colors.purple.shade600,
        )),
      ],
    );
  }

  Widget _buildKPIsGrid(InventarioGlobalProvider provider, AppTheme theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildKPICard(
              'Total Refacciones',
              provider.kpis['total_refacciones']?.toString() ?? '0',
              Icons.inventory_2,
              Colors.blue.shade600,
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _buildKPICard(
              'Valor Total',
              '\$${(provider.kpis['valor_total'] ?? 0.0).toStringAsFixed(0)}',
              Icons.attach_money,
              Colors.green.shade600,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildKPICard(
              'Sin Stock',
              provider.kpis['sin_stock']?.toString() ?? '0',
              Icons.warning,
              Colors.red.shade600,
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _buildKPICard(
              'Stock Bajo',
              provider.kpis['stock_bajo']?.toString() ?? '0',
              Icons.priority_high,
              Colors.orange.shade600,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.of(context).title2.override(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.of(context).bodyText2.override(
                  fontFamily: 'Poppins',
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndQuickFilters(
    InventarioGlobalProvider provider,
    AppTheme theme,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        // Barra de búsqueda
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => provider.setFiltroRefaccion(value),
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre de refacción...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon:
                  Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear,
                          color: Colors.white.withOpacity(0.8)),
                      onPressed: () {
                        _searchController.clear();
                        provider.setFiltroRefaccion('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Filtros rápidos
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickFilterChip('Todos', provider.filtroNivelStock == 0, () {
              provider.setFiltroNivelStock(0);
            }),
            _buildQuickFilterChip('Sin Stock', provider.filtroNivelStock == 2,
                () {
              provider.setFiltroNivelStock(2);
            }),
            _buildQuickFilterChip('Stock Bajo', provider.filtroNivelStock == 1,
                () {
              provider.setFiltroNivelStock(1);
            }),
            _buildQuickFilterChip('Sobrestock', provider.filtroNivelStock == 3,
                () {
              provider.setFiltroNivelStock(3);
            }),
            if (provider.filtroCategoria.isNotEmpty ||
                provider.filtroSucursal.isNotEmpty ||
                provider.filtroRefaccion.isNotEmpty)
              _buildQuickFilterChip('Limpiar Filtros', false, () {
                _searchController.clear();
                provider.limpiarFiltros();
              }, isAction: true),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip(String label, bool isActive, VoidCallback onTap,
      {bool isAction = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.3)
              : isAction
                  ? Colors.red.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Colors.white.withOpacity(0.5)
                : isAction
                    ? Colors.red.withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.of(context).bodyText2.override(
                fontFamily: 'Poppins',
                color: Colors.white.withOpacity(isActive ? 1.0 : 0.8),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters(
    InventarioGlobalProvider provider,
    AppTheme theme,
    bool isSmallScreen,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros Avanzados',
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (isSmallScreen) ...[
            // Vista móvil: filtros apilados
            _buildFilterDropdown(
              'Categoría',
              provider.filtroCategoria,
              provider.categoriasDisponibles,
              (value) => provider.setFiltroCategoria(value ?? ''),
            ),
            const SizedBox(height: 12),
            _buildFilterDropdown(
              'Sucursal',
              provider.filtroSucursal,
              provider.sucursalesDisponibles,
              (value) => provider.setFiltroSucursal(value ?? ''),
            ),
          ] else ...[
            // Vista desktop: filtros en fila
            Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    'Categoría',
                    provider.filtroCategoria,
                    provider.categoriasDisponibles,
                    (value) => provider.setFiltroCategoria(value ?? ''),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFilterDropdown(
                    'Sucursal',
                    provider.filtroSucursal,
                    provider.sucursalesDisponibles,
                    (value) => provider.setFiltroSucursal(value ?? ''),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String currentValue,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.of(context).bodyText2.override(
                fontFamily: 'Poppins',
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: currentValue.isEmpty ? null : currentValue,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'Seleccionar $label',
              hintStyle:
                  TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
            style: TextStyle(color: Colors.white, fontSize: 12),
            dropdownColor: AppTheme.of(context).primaryColor,
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  'Todos',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ),
              ...options
                  .map((option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(
                          option,
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                  .toList(),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
