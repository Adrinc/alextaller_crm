import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/pages/talleralex/widgets/configuracion_widgets/color_config_tab.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/theme_config_provider.dart';
import 'package:nethive_neo/pages/talleralex/widgets/configuracion_widgets/advanced_schemes_tab.dart';
import 'package:nethive_neo/pages/talleralex/widgets/configuracion_widgets/logo_config_tab.dart';
import 'package:nethive_neo/pages/talleralex/widgets/configuracion_widgets/saved_themes_tab.dart';
import 'package:nethive_neo/pages/talleralex/widgets/configuracion_widgets/typography_config_tab.dart';
import 'package:nethive_neo/pages/talleralex/widgets/configuracion_widgets/theme_preview_panel.dart';
import 'package:nethive_neo/pages/talleralex/widgets/global_sidebar.dart';
import 'package:nethive_neo/pages/talleralex/widgets/responsive_drawer.dart';

// Data class para tabs de configuración
class ConfigTab {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final Widget widget;

  ConfigTab({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.widget,
  });
}

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _floatingAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatingAnimation;

  List<ConfigTab> _tabs = [];

  @override
  void initState() {
    super.initState();

    // Inicializar controladores de animación
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Configurar animaciones
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _slideAnimationController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );
    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _floatingAnimationController, curve: Curves.easeInOut),
    );

    // Inicializar tabs
    _initializeTabs();

    // Iniciar animaciones
    _slideAnimationController.forward();
    _fadeAnimationController.forward();
    _floatingAnimationController.repeat(reverse: true);
  }

  void _initializeTabs() {
    _tabs = [
      ConfigTab(
        id: 'colors',
        title: 'Paleta de Colores',
        subtitle: 'Crea armonías visuales únicas',
        icon: Icons.palette_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        widget: const ColorConfigTab(),
      ),
      ConfigTab(
        id: 'advanced_schemes',
        title: 'Esquemas Avanzados',
        subtitle: 'Más de 40 paletas profesionales',
        icon: Icons.auto_awesome_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
        ),
        widget: const AdvancedSchemesTab(),
      ),
      ConfigTab(
        id: 'typography',
        title: 'Tipografía Elegante',
        subtitle: 'Selecciona fuentes profesionales',
        icon: Icons.text_fields_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        ),
        widget: const TypographyConfigTab(),
      ),
      ConfigTab(
        id: 'logos',
        title: 'Identidad Visual',
        subtitle: 'Sube y gestiona tus logos',
        icon: Icons.image_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
        ),
        widget: const LogoConfigTab(),
      ),
      ConfigTab(
        id: 'themes',
        title: 'Biblioteca de Temas',
        subtitle: 'Guarda y organiza diseños',
        icon: Icons.collections_bookmark_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
        ),
        widget: const SavedThemesTab(),
      ),
    ];
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _floatingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final isSmallScreen = screenWidth < 1200;

    // Obtener la ruta actual desde GoRouter
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final currentRoute = currentLocation;

    return Consumer<ThemeConfigProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F0F3), // Fondo neumórfico blanco
          drawer: isSmallScreen
              ? Drawer(
                  child: ResponsiveDrawer(
                    currentRoute: currentRoute,
                  ),
                )
              : null,
          body: Row(
            children: [
              // Sidebar
              if (!isSmallScreen) GlobalSidebar(currentRoute: currentRoute),

              // Contenido principal
              Expanded(
                child: _buildMainConfigContent(provider, isMobile, isTablet),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainConfigContent(ThemeConfigProvider provider, bool isMobile, bool isTablet) {
    if (isMobile) {
      return _buildMobileLayout(provider);
    } else if (isTablet) {
      return _buildTabletLayout(provider);
    } else {
      return _buildDesktopLayout(provider);
    }
  }

  // Layout para móvil - Diseño vertical con tabs superiores
  Widget _buildMobileLayout(ThemeConfigProvider provider) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F3), // Fondo neumórfico blanco
      ),
      child: Column(
        children: [
          // Header compacto para móvil
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            decoration: BoxDecoration(
              gradient: AppTheme.of(context).primaryGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Design Studio',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Personaliza tu experiencia visual',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Progress indicator móvil
                    _buildMobileProgress(provider),
                  ],
                ),

                const SizedBox(height: 16),

                // Navigation tabs horizontal para móvil
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      final tab = _tabs[index];
                      final isSelected = _selectedTabIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected ? tab.gradient : null,
                            color: isSelected
                                ? null
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                tab.icon,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tab.title.split(' ').first, // Primera palabra
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Error overlay móvil
          if (provider.error != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    onPressed: provider.clearError,
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

          // Contenido principal móvil
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Container(
                key: ValueKey(_selectedTabIndex),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _tabs[_selectedTabIndex].widget,
                ),
              ),
            ),
          ),

          // Action button integrado para móvil
          Container(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.of(context).primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.of(context).primaryColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: provider.isSaving
                      ? null
                      : () async {
                          await provider.applyTheme();
                          if (mounted) {
                            _showSnackBar(
                                '¡Tema aplicado exitosamente! 🎉', Colors.green);
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (provider.isSaving)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          const Icon(Icons.rocket_launch,
                              color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          provider.isSaving ? 'Aplicando...' : 'Aplicar',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Layout para tablet - Híbrido
  Widget _buildTabletLayout(ThemeConfigProvider provider) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F3), // Fondo neumórfico blanco
      ),
      child: Column(
        children: [
          // Header para tablet
          Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
            decoration: BoxDecoration(
              gradient: AppTheme.of(context).primaryGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Design Studio Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Experiencia de diseño avanzada',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildProgressIndicator(provider),
                  ],
                ),

                const SizedBox(height: 24),

                // Tabs horizontales para tablet
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      final tab = _tabs[index];
                      final isSelected = _selectedTabIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = index),
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: isSelected ? tab.gradient : null,
                            color: isSelected
                                ? null
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                tab.icon,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tab.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Error overlay para tablet
          if (provider.error != null)
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  IconButton(
                    onPressed: provider.clearError,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

          // Contenido principal para tablet
          Expanded(
            child: Row(
              children: [
                // Contenido principal
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          key: ValueKey(_selectedTabIndex),
                          child: _tabs[_selectedTabIndex].widget,
                        ),
                      ),
                    ),
                  ),
                ),

                // Preview panel para tablet
                Container(
                  width: 300,
                  margin: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                  child: const ThemePreviewPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Layout para desktop - El diseño espectacular completo
  Widget _buildDesktopLayout(ThemeConfigProvider provider) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F3), // Fondo neumórfico blanco
      ),
      child: Stack(
        children: [
          // Fondo con formas flotantes
          _buildFloatingShapes(),

          // Contenido principal horizontal
          Row(
            children: [
              // Sidebar navegación espectacular
              _buildSidebar(provider),

              // Contenido principal
              Expanded(
                child: _buildMainContent(provider),
              ),
            ],
          ),

          // Error overlay
          if (provider.error != null) _buildErrorOverlay(provider),

          // Floating action bar
          _buildFloatingActionBar(provider),
        ],
      ),
    );
  }

  Widget _buildMobileProgress(ThemeConfigProvider provider) {
    int completedSections = 0;
    if (provider.currentConfig['light']?['colors'] != null) completedSections++;
    if (provider.currentConfig['light']?['typography'] != null)
      completedSections++;
    if (provider.lightLogoUrl != null || provider.lightLogoBytes != null)
      completedSections++;
    if (provider.savedThemes.isNotEmpty) completedSections++;

    double progress = completedSections / 4.0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 30,
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingShapes() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating circle 1
            Positioned(
              top: 100 + (_floatingAnimation.value * 20),
              right: 100,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.of(context).primaryColor.withOpacity(0.1),
                      AppTheme.of(context).tertiaryColor.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
            // Floating circle 2
            Positioned(
              bottom: 150 + (_floatingAnimation.value * -15),
              left: 50,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.of(context).secondaryColor.withOpacity(0.08),
                      AppTheme.of(context).primaryColor.withOpacity(0.08),
                    ],
                  ),
                ),
              ),
            ),
            // Floating triangle
            Positioned(
              top: 300 + (_floatingAnimation.value * 25),
              right: 200,
              child: CustomPaint(
                size: const Size(60, 60),
                painter: TrianglePainter(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.05),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidebar(ThemeConfigProvider provider) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.of(context).secondaryBackground,
            AppTheme.of(context).primaryBackground.withOpacity(0.95),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header espectacular con branding
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Logo con efecto glow
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.of(context).primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.5),
                        blurRadius: 25,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.of(context).primaryGradient.createShader(bounds),
                  child: const Text(
                    'DESIGN STUDIO',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crea experiencias visuales extraordinarias',
                  style: TextStyle(
                    color: AppTheme.of(context).secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Navigation tabs con efectos avanzados
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = _selectedTabIndex == index;

                return AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_slideAnimation.value * 150, 0),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildNavItem(tab, isSelected, index),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Progress indicator espectacular
          _buildProgressIndicator(provider),

          // Quick actions footer
          _buildQuickActions(provider),
        ],
      ),
    );
  }

  Widget _buildNavItem(ConfigTab tab, bool isSelected, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isSelected ? tab.gradient : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? null
                  : Border.all(
                      color:
                          AppTheme.of(context).primaryColor.withOpacity(0.15),
                      width: 1.5,
                    ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: tab.gradient.colors.first.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Icono con efecto hero
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : AppTheme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    tab.icon,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tab.title,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.of(context).primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tab.subtitle,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white70
                              : AppTheme.of(context).secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeConfigProvider provider) {
    // Calcular progreso basado en configuraciones completadas
    int completedSections = 0;
    if (provider.currentConfig['light']?['colors'] != null) completedSections++;
    if (provider.currentConfig['light']?['typography'] != null)
      completedSections++;
    if (provider.lightLogoUrl != null || provider.lightLogoBytes != null)
      completedSections++;
    if (provider.savedThemes.isNotEmpty) completedSections++;

    double progress = completedSections / 4.0;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.of(context).primaryColor.withOpacity(0.1),
            AppTheme.of(context).secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso del Diseño',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppTheme.of(context).primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  AppTheme.of(context).secondaryText.withOpacity(0.2),
              valueColor:
                  AlwaysStoppedAnimation(AppTheme.of(context).primaryColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeConfigProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.refresh,
              label: 'Reset',
              color: Colors.orange,
              onTap: () {
                provider.resetToDefault();
                _showSnackBar('Configuración reiniciada', Colors.orange);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.file_download,
              label: 'Export',
              color: Colors.blue,
              onTap: () => _showExportDialog(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeConfigProvider provider) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          children: [
            // Header dinámico del contenido
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: _tabs[_selectedTabIndex].gradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _tabs[_selectedTabIndex].icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tabs[_selectedTabIndex].title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          _tabs[_selectedTabIndex].subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Live preview toggle
                  if (MediaQuery.of(context).size.width > 1200)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: provider.togglePreview,
                        icon: Icon(
                          provider.isPreviewActive
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        tooltip: provider.isPreviewActive
                            ? 'Ocultar preview'
                            : 'Mostrar preview',
                      ),
                    ),
                ],
              ),
            ),

            // Contenido del tab con transiciones
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  key: ValueKey(_selectedTabIndex),
                  child: Row(
                    children: [
                      // Contenido principal del tab
                      Expanded(
                        flex: MediaQuery.of(context).size.width > 1400 ? 3 : 1,
                        child: _tabs[_selectedTabIndex].widget,
                      ),

                      // Preview panel flotante (solo en pantallas muy grandes)
                      if (MediaQuery.of(context).size.width > 1400 &&
                          provider.isPreviewActive)
                        const ThemePreviewPanel(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionBar(ThemeConfigProvider provider) {
    // Para desktop: Positioned widget
    return Positioned(
      bottom: 32,
      right: 32,
      child: _buildActionButton(provider),
    );
  }

  Widget _buildActionButton(ThemeConfigProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.of(context).primaryGradient,
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).primaryColor.withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reset button
          IconButton(
            onPressed: () {
              provider.resetToDefault();
              _showSnackBar(
                  'Tema reiniciado a valores por defecto', Colors.orange);
            },
            icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
            tooltip: 'Reiniciar configuración',
          ),

          Container(
            width: 1,
            height: 28,
            color: Colors.white.withOpacity(0.3),
          ),

          // Apply button con animación
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.isSaving)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                else
                  const Icon(Icons.rocket_launch,
                      color: Colors.white, size: 22),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: provider.isSaving
                      ? null
                      : () async {
                          await provider.applyTheme();
                          if (mounted) {
                            _showSnackBar('¡Tema aplicado exitosamente! 🎉',
                                Colors.green);
                          }
                        },
                  child: Text(
                    provider.isSaving ? 'Aplicando...' : 'Aplicar Diseño',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorOverlay(ThemeConfigProvider provider) {
    return Positioned(
      top: 100,
      left: 340,
      right: 32,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                provider.error!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            IconButton(
              onPressed: provider.clearError,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.info,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _showExportDialog(ThemeConfigProvider provider) {
    final json = provider.exportTheme();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.file_download, color: AppTheme.of(context).primaryColor),
            const SizedBox(width: 12),
            Text(
              'Exportar Configuración',
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          width: 400,
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
              child: SelectableText(
                json,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar',
                style: TextStyle(color: AppTheme.of(context).secondaryText)),
          ),
        ],
      ),
    );
  }
}

// Custom painter para las formas flotantes
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
