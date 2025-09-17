import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nethive_neo/providers/talleralex/promociones_globales_provider.dart';

class PromocionesTabBar extends StatefulWidget {
  final TabController tabController;
  final Function(int)? onTabChanged;

  const PromocionesTabBar({
    Key? key,
    required this.tabController,
    this.onTabChanged,
  }) : super(key: key);

  @override
  State<PromocionesTabBar> createState() => _PromocionesTabBarState();
}

class _PromocionesTabBarState extends State<PromocionesTabBar> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (!widget.tabController.indexIsChanging) {
      widget.onTabChanged?.call(widget.tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    return Consumer<PromocionesGlobalesProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              // TabBar personalizada
              Container(
                padding: const EdgeInsets.all(8),
                child: _buildCustomTabBar(isSmallScreen, provider),
              ),

              // Línea separadora
              Container(
                height: 1,
                color: Colors.grey.shade200,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomTabBar(
      bool isSmallScreen, PromocionesGlobalesProvider provider) {
    final tabs = [
      {
        'title': 'Promociones',
        'subtitle': 'Activas',
        'icon': Icons.campaign,
        'count': provider.kpisPromocionesActivas['total'],
        'color': const Color(0xFF0066CC),
      },
      {
        'title': 'Gestión',
        'subtitle': 'Crear/Editar',
        'icon': Icons.edit,
        'count': null,
        'color': const Color(0xFF2ECC71),
      },
      {
        'title': 'Cupones',
        'subtitle': 'QR/Códigos',
        'icon': Icons.qr_code,
        'count': provider.kpisCupones['total'],
        'color': const Color(0xFFFF6B00),
      },
      {
        'title': 'ROI',
        'subtitle': 'Análisis',
        'icon': Icons.trending_up,
        'count': provider.promocionesROI.length,
        'color': const Color(0xFFFF2D95),
      },
    ];

    return isSmallScreen
        ? _buildMobileTabBar(tabs, provider)
        : _buildDesktopTabBar(tabs, provider);
  }

  Widget _buildDesktopTabBar(
      List<Map<String, dynamic>> tabs, PromocionesGlobalesProvider provider) {
    return Row(
      children: tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final tab = entry.value;
        final isSelected = widget.tabController.index == index;

        return Expanded(
          child: _buildTabItem(
            title: tab['title'],
            subtitle: tab['subtitle'],
            icon: tab['icon'],
            count: tab['count'],
            color: tab['color'],
            isSelected: isSelected,
            onTap: () => widget.tabController.animateTo(index),
            isSmallScreen: false,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileTabBar(
      List<Map<String, dynamic>> tabs, PromocionesGlobalesProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = widget.tabController.index == index;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
              right: index == tabs.length - 1 ? 0 : 8,
            ),
            child: _buildTabItem(
              title: tab['title'],
              subtitle: tab['subtitle'],
              icon: tab['icon'],
              count: tab['count'],
              color: tab['color'],
              isSelected: isSelected,
              onTap: () => widget.tabController.animateTo(index),
              isSmallScreen: true,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required String subtitle,
    required IconData icon,
    int? count,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isSmallScreen ? 140 : null,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono y badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.2)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: isSmallScreen ? 20 : 24,
                        color: isSelected ? color : Colors.grey.shade600,
                      ),
                    ),

                    // Badge con contador
                    if (count != null && count > 0)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            count > 99 ? '99+' : count.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Título
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : const Color(0xFF0A0A0A),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 2),

                // Subtítulo
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isSelected
                        ? color.withOpacity(0.8)
                        : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget para el contenido de cada pestaña
class PromocionesTabContent extends StatefulWidget {
  final int selectedTab;
  final VoidCallback? onCrearPromocion;
  final VoidCallback? onEditarPromocion;

  const PromocionesTabContent({
    Key? key,
    required this.selectedTab,
    this.onCrearPromocion,
    this.onEditarPromocion,
  }) : super(key: key);

  @override
  State<PromocionesTabContent> createState() => _PromocionesTabContentState();
}

class _PromocionesTabContentState extends State<PromocionesTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<PromocionesGlobalesProvider>(
      builder: (context, provider, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildTabContent(widget.selectedTab, provider),
        );
      },
    );
  }

  Widget _buildTabContent(
      int selectedTab, PromocionesGlobalesProvider provider) {
    switch (selectedTab) {
      case 0: // Promociones Activas
        return _buildPromocionesActivasTab(provider);
      case 1: // Gestión
        return _buildGestionTab(provider);
      case 2: // Cupones
        return _buildCuponesTab(provider);
      case 3: // ROI
        return _buildROITab(provider);
      default:
        return _buildPromocionesActivasTab(provider);
    }
  }

  Widget _buildPromocionesActivasTab(PromocionesGlobalesProvider provider) {
    return Container(
      key: const ValueKey('promociones_activas'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0066CC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.campaign,
                  color: Color(0xFF0066CC),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Promociones Activas',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A0A0A),
                      ),
                    ),
                    Text(
                      'Gestiona las promociones publicadas en tus sucursales',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (provider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (provider.error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar las promociones',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.red.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else if (provider.promocionesActivasFiltradas.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay promociones activas',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tu primera promoción para comenzar',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: widget.onCrearPromocion,
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Promoción'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066CC),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Aquí iría el PlutoGrid de promociones activas
            Text(
              'TODO: PlutoGrid de Promociones Activas (${provider.promocionesActivasFiltradas.length} registros)',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildGestionTab(PromocionesGlobalesProvider provider) {
    return Container(
      key: const ValueKey('gestion'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Color(0xFF2ECC71),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de Promociones',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A0A0A),
                      ),
                    ),
                    Text(
                      'Crea, edita y administra tus promociones',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: widget.onCrearPromocion,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nueva'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Acciones rápidas
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildGestionCard(
                title: 'Crear Promoción',
                subtitle: 'Nueva promoción desde cero',
                icon: Icons.add_box,
                color: const Color(0xFF2ECC71),
                onTap: widget.onCrearPromocion,
              ),
              _buildGestionCard(
                title: 'Editar Existente',
                subtitle: 'Modificar promociones activas',
                icon: Icons.edit,
                color: const Color(0xFF0066CC),
                onTap: widget.onEditarPromocion,
              ),
              _buildGestionCard(
                title: 'Publicar Masivo',
                subtitle: 'Distribuir a sucursales',
                icon: Icons.publish,
                color: const Color(0xFFFF6B00),
                onTap: () {
                  // TODO: Implementar publicación masiva
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGestionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCuponesTab(PromocionesGlobalesProvider provider) {
    return Container(
      key: const ValueKey('cupones'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B00).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code,
                  color: Color(0xFFFF6B00),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cupones y Códigos QR',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A0A0A),
                      ),
                    ),
                    Text(
                      'Gestiona cupones individuales y códigos QR',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'TODO: PlutoGrid de Cupones (${provider.cupones.length} registros)',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildROITab(PromocionesGlobalesProvider provider) {
    return Container(
      key: const ValueKey('roi'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2D95).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFFFF2D95),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Análisis de ROI',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A0A0A),
                      ),
                    ),
                    Text(
                      'Rendimiento y métricas de tus promociones',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'TODO: PlutoGrid de ROI (${provider.promocionesROI.length} registros)',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
