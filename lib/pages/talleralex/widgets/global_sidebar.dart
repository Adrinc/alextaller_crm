import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/theme/theme.dart';

class GlobalSidebar extends StatefulWidget {
  final String currentRoute;
  final bool isDrawer;
  final VoidCallback? onNavigate;

  const GlobalSidebar({
    Key? key,
    required this.currentRoute,
    this.isDrawer = false,
    this.onNavigate,
  }) : super(key: key);

  @override
  State<GlobalSidebar> createState() => _GlobalSidebarState();
}

class _GlobalSidebarState extends State<GlobalSidebar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      width: widget.isDrawer ? MediaQuery.of(context).size.width * 0.8 : 300,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3), // Mismo color neumórfico
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.3),
            blurRadius: 20,
            offset: widget.isDrawer ? const Offset(-5, 0) : const Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header con logo y título
          _buildHeader(theme),

          // Navigation items
          Expanded(
            child: _buildNavigationItems(theme),
          ),

          // Footer con información adicional
          _buildFooter(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return Container(
      padding: EdgeInsets.all(widget.isDrawer ? 16 : 24),
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
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Botón de cerrar en modo drawer (posicionado arriba a la derecha)
          if (widget.isDrawer)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),

          // Logo centrado
          Center(
            child: Container(
              width: widget.isDrawer ? 60 : 80,
              height: widget.isDrawer ? 60 : 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.isDrawer ? 15 : 20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    offset: const Offset(-4, -4),
                    blurRadius: 12,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(4, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.isDrawer ? 15 : 20),
                child: Image.asset(
                  'assets/images/favicon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          SizedBox(height: widget.isDrawer ? 12 : 16),

          // Subtítulo elegante centrado
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white.withOpacity(0.2),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'CRM Corporativo',
                style: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: widget.isDrawer ? 11 : 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems(AppTheme theme) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        _buildNavItem(
          theme,
          icon: Icons.dashboard_rounded,
          title: 'Dashboard Global',
          route: '/dashboard-global',
          isActive: widget.currentRoute == '/dashboard-global' ||
              widget.currentRoute == '/',
          onTap: () {
            // Solo navegar si no estamos ya en esa ruta
            if (widget.currentRoute != '/dashboard-global' &&
                widget.currentRoute != '/') {
              context.go('/dashboard-global');
            }
            if (widget.isDrawer) {
              Navigator.of(context).pop();
              widget.onNavigate?.call();
            }
          },
        ),
        _buildNavItem(
          theme,
          icon: Icons.store_rounded,
          title: 'Sucursales Activas',
          route: '/sucursales',
          isActive: widget.currentRoute == '/sucursales',
          onTap: () {
            // Solo navegar si no estamos ya en esa ruta
            if (widget.currentRoute != '/sucursales') {
              context.go('/sucursales');
            }
            if (widget.isDrawer) {
              Navigator.of(context).pop();
              widget.onNavigate?.call();
            }
          },
        ),
        const SizedBox(height: 16),
        _buildSectionDivider(theme, 'Gestión de Usuarios'),
        _buildNavItem(
          theme,
          icon: Icons.pending_actions_rounded,
          title: 'Usuarios Pendientes',
          route: '/usuarios-pendientes',
          isActive: widget.currentRoute == '/usuarios-pendientes',
          onTap: () {
            if (widget.currentRoute != '/usuarios-pendientes') {
              context.go('/usuarios-pendientes');
            }
            if (widget.isDrawer) {
              Navigator.of(context).pop();
              widget.onNavigate?.call();
            }
          },
        ),
        _buildNavItem(
          theme,
          icon: Icons.groups_rounded,
          title: 'Empleados Globales',
          route: '/empleados-globales',
          isActive: widget.currentRoute == '/empleados-globales',
          onTap: () {
            if (widget.currentRoute != '/empleados-globales') {
              context.go('/empleados-globales');
            }
            if (widget.isDrawer) {
              Navigator.of(context).pop();
              widget.onNavigate?.call();
            }
          },
        ),
        _buildNavItem(
          theme,
          icon: Icons.people_alt_rounded,
          title: 'Clientes Globales',
          route: '/clientes-globales',
          isActive: widget.currentRoute == '/clientes-globales',
          onTap: () {
            if (widget.currentRoute != '/clientes-globales') {
              context.go('/clientes-globales');
            }
            if (widget.isDrawer) {
              Navigator.of(context).pop();
              widget.onNavigate?.call();
            }
          },
        ),
        const SizedBox(height: 16),
        _buildSectionDivider(theme, 'Operaciones'),
        _buildNavItem(
          theme,
          icon: Icons.inventory_2_rounded,
          title: 'Inventario Global',
          route: '/inventario-global',
          isActive: widget.currentRoute == '/inventario-global',
          onTap: () {
            if (widget.currentRoute != '/inventario-global') {
              context.go('/inventario-global');
            }
            if (widget.isDrawer) {
              Navigator.of(context).pop();
              widget.onNavigate?.call();
            }
          },
        ),
        _buildNavItem(
          theme,
          icon: Icons.local_offer_rounded,
          title: 'Promociones Globales',
          route: '/promociones-globales',
          isActive: widget.currentRoute == '/promociones-globales',
          onTap: () {
            if (widget.currentRoute != '/promociones-globales') {
              context.go('/promociones-globales');
            }
            if (widget.isDrawer) {
              Navigator.of(context).pop();
              widget.onNavigate?.call();
            }
          },
        ),
        const SizedBox(height: 16),
        _buildSectionDivider(theme, 'Reportes'),
        _buildNavItem(
          theme,
          icon: Icons.analytics_rounded,
          title: 'Reportes Ejecutivos',
          route: '/reportes-ejecutivos',
          isActive: widget.currentRoute == '/reportes-ejecutivos',
          onTap: () {
            if (widget.currentRoute != '/reportes-ejecutivos') {
              context.go('/reportes-ejecutivos');
            }
            if (widget.isDrawer) {
              Navigator.of(context).pop();
              widget.onNavigate?.call();
            }
          },
        ),
        const SizedBox(height: 16),
        _buildSectionDivider(theme, 'Administración'),
        _buildNavItem(
          theme,
          icon: Icons.business_center_rounded,
          title: 'Catálogos Corporativos',
          route: '/catalogos-corporativos',
          isActive: widget.currentRoute == '/catalogos-corporativos',
          onTap: () {
            if (widget.currentRoute != '/catalogos-corporativos') {
              context.go('/catalogos-corporativos');
            }
            if (widget.isDrawer) {
              Navigator.of(context).pop();
              widget.onNavigate?.call();
            }
          },
        ),
        const SizedBox(height: 16),
        _buildSectionDivider(theme, 'Sistema'),
        _buildNavItem(
          theme,
          icon: Icons.palette_rounded,
          title: 'Configuración Visual',
          route: '/configuracion-visual',
          isActive: widget.currentRoute == '/configuracion-visual',
          onTap: () {
            if (widget.currentRoute != '/configuracion-visual') {
              context.go('/configuracion-visual');
            }
            if (widget.isDrawer) {
              Navigator.of(context).pop();
              widget.onNavigate?.call();
            }
          },
        ),
        _buildNavItem(
          theme,
          icon: Icons.settings_applications_rounded,
          title: 'Configuración del Sistema',
          route: '/configuracion-sistema',
          isActive: widget.currentRoute == '/configuracion-sistema',
          onTap: () {
            if (widget.currentRoute != '/configuracion-sistema') {
              context.go('/configuracion-sistema');
            }
            if (widget.isDrawer) {
              Navigator.of(context).pop();
              widget.onNavigate?.call();
            }
          },
        ),
      ],
    );
  }

  Widget _buildNavItem(
    AppTheme theme, {
    required IconData icon,
    required String title,
    required String route,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isActive
                  ? [
                      // Sombras internas para elemento seleccionado
                      BoxShadow(
                        color: Colors.grey.shade400.withOpacity(0.4),
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: const Offset(-4, -4),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                  : [
                      // Sombras externas para elementos no seleccionados
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? LinearGradient(
                            colors: [
                              theme.primaryColor,
                              theme.secondaryColor,
                            ],
                          )
                        : null,
                    color:
                        isActive ? null : theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : theme.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      color: isActive ? theme.primaryColor : theme.primaryText,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionDivider(AppTheme theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: theme.alternate.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                color: theme.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: theme.alternate.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Información de versión con estilo neumórfico
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F3),
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
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      size: 16,
                      color: theme.secondaryText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ayuda y Soporte',
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: theme.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: theme.secondaryText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Versión 1.0.0',
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: theme.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
