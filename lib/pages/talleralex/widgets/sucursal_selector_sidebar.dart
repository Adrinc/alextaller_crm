import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/providers/talleralex/sucursales_provider.dart';
import 'package:nethive_neo/providers/talleralex/navigation_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class SucursalSelectorSidebar extends StatefulWidget {
  final SucursalesProvider provider;
  final Function(String) onSucursalSelected;

  const SucursalSelectorSidebar({
    Key? key,
    required this.provider,
    required this.onSucursalSelected,
  }) : super(key: key);

  @override
  State<SucursalSelectorSidebar> createState() =>
      _SucursalSelectorSidebarState();
}

class _SucursalSelectorSidebarState extends State<SucursalSelectorSidebar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _listController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.of(context).secondaryBackground,
            AppTheme.of(context).primaryBackground,
          ],
        ),
        border: Border(
          right: BorderSide(
            color: AppTheme.of(context).primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con gradiente personalizado de Taller Alex
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.of(context).primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Logo animado para Taller Alex
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.car_repair,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.8)
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'TALLER ALEX',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Text(
                            'Sucursales',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Contador de sucursales con efecto
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.store,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      TweenAnimationBuilder<int>(
                        duration: const Duration(milliseconds: 800),
                        tween: IntTween(
                            begin: 0, end: widget.provider.sucursales.length),
                        builder: (context, value, child) {
                          return Text(
                            '$value sucursales',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.of(context).tertiaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                style: AppTheme.of(context).bodyText1.override(
                      fontFamily: 'Poppins',
                      color: AppTheme.of(context).primaryText,
                    ),
                decoration: InputDecoration(
                  hintText: 'Buscar sucursal...',
                  hintStyle: AppTheme.of(context).bodyText2.override(
                        fontFamily: 'Poppins',
                        color: AppTheme.of(context).secondaryText,
                      ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.of(context).primaryColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Lista de sucursales
          Expanded(
            child: _buildSucursalesList(),
          ),

          // Botón para agregar nueva sucursal
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddSucursalDialog(context),
                icon: Icon(
                  Icons.add,
                  color: AppTheme.of(context).primaryText,
                ),
                label: Text(
                  'Nueva Sucursal',
                  style: AppTheme.of(context).bodyText1.override(
                        fontFamily: 'Poppins',
                        color: AppTheme.of(context).primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.of(context).primaryColor,
                  foregroundColor: AppTheme.of(context).primaryText,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSucursalesList() {
    final sucursalesFiltradas = widget.provider.sucursales.where((sucursal) {
      return sucursal.nombre.toLowerCase().contains(_searchQuery) ||
          sucursal.direccion?.toLowerCase().contains(_searchQuery) == true;
    }).toList();

    if (sucursalesFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.store_outlined,
              size: 48,
              color: AppTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron sucursales'
                  : 'No hay sucursales registradas',
              style: AppTheme.of(context).bodyText1.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Crea tu primera sucursal',
                style: AppTheme.of(context).bodyText2.override(
                      fontFamily: 'Poppins',
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
            ],
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _listController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: sucursalesFiltradas.length,
          itemBuilder: (context, index) {
            final sucursal = sucursalesFiltradas[index];
            final animationDelay = index * 0.1;

            return AnimatedBuilder(
              animation: _listController,
              builder: (context, child) {
                final animationValue = Curves.easeOutCubic.transform(
                    (_listController.value - animationDelay).clamp(0.0, 1.0));

                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: _buildSucursalCard(sucursal),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSucursalCard(sucursal) {
    final navigationProvider = context.watch<TallerAlexNavigationProvider>();
    final isSelected = navigationProvider.sucursalSeleccionadaId == sucursal.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context
                .read<TallerAlexNavigationProvider>()
                .setSucursalSeleccionada(sucursal.id);
            widget.onSucursalSelected(sucursal.id);
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.of(context).primaryColor.withOpacity(0.1)
                  : AppTheme.of(context).tertiaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.of(context).primaryColor
                    : AppTheme.of(context).alternate.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.of(context).primaryColor
                            : AppTheme.of(context)
                                .primaryColor
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.store,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        sucursal.nombre,
                        style: AppTheme.of(context).bodyText1.override(
                              fontFamily: 'Poppins',
                              color: AppTheme.of(context).primaryText,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (sucursal.direccion != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          sucursal.direccion!,
                          style: AppTheme.of(context).bodyText2.override(
                                fontFamily: 'Poppins',
                                color: AppTheme.of(context).secondaryText,
                                fontSize: 12,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (sucursal.telefono != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 14,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sucursal.telefono!,
                        style: AppTheme.of(context).bodyText2.override(
                              fontFamily: 'Poppins',
                              color: AppTheme.of(context).secondaryText,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddSucursalDialog(BuildContext context) {
    // TODO: Implementar diálogo para agregar sucursal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Diálogo para agregar sucursal en desarrollo',
          style: AppTheme.of(context).bodyText1.override(
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
        ),
        backgroundColor: AppTheme.of(context).primaryColor,
      ),
    );
  }
}
