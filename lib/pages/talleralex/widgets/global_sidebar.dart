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

class _GlobalSidebarState extends State<GlobalSidebar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      width: widget.isDrawer ? MediaQuery.of(context).size.width * 0.8 : 280,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: widget.isDrawer
            ? null
            : Border(
                right: BorderSide(
                  color: theme.primaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: widget.isDrawer ? const Offset(-2, 0) : const Offset(2, 0),
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
      padding: EdgeInsets.symmetric(vertical: widget.isDrawer ? 12 : 16),
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
        const SizedBox(height: 8),
        _buildSectionDivider(theme, 'Administración'),
        _buildNavItem(
          theme,
          icon: Icons.business_center_rounded,
          title: 'Administración Corporativa',
          route: '/administracion-corporativa',
          isActive: widget.currentRoute == '/administracion-corporativa',
          onTap: () {
            // TODO: Implementar navegación
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Función en desarrollo'),
                backgroundColor: theme.warning,
              ),
            );
            if (widget.isDrawer) {
              Navigator.of(context).pop();
              widget.onNavigate?.call();
            }
          },
        ),
        _buildNavItem(
          theme,
          icon: Icons.analytics_rounded,
          title: 'Reportes Ejecutivos',
          route: '/reportes-ejecutivos',
          isActive: widget.currentRoute == '/reportes-ejecutivos',
          onTap: () {
            // TODO: Implementar navegación
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Función en desarrollo'),
                backgroundColor: theme.warning,
              ),
            );
            if (widget.isDrawer) {
              Navigator.of(context).pop();
              widget.onNavigate?.call();
            }
          },
        ),
        const SizedBox(height: 8),
        _buildSectionDivider(theme, 'Sistema'),
        _buildNavItem(
          theme,
          icon: Icons.settings_rounded,
          title: 'Configuración Global',
          route: '/configuracion-global',
          isActive: widget.currentRoute == '/configuracion-global',
          onTap: () {
            // TODO: Implementar navegación
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Función en desarrollo'),
                backgroundColor: theme.warning,
              ),
            );
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive ? theme.primaryColor.withOpacity(0.1) : null,
        border: isActive
            ? Border.all(color: theme.primaryColor.withOpacity(0.3))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.primaryColor
                        : theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isActive ? Colors.white : theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      color: isActive ? theme.primaryColor : theme.primaryText,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isActive)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
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
      padding: EdgeInsets.all(widget.isDrawer ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        border: Border(
          top: BorderSide(
            color: theme.alternate.withOpacity(0.3),
            width: 1,
          ),
        ),
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
    );
  }
}
