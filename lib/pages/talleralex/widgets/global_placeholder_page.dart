import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/providers/talleralex/navigation_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/pages/talleralex/widgets/global_sidebar.dart';
import 'package:nethive_neo/pages/talleralex/widgets/responsive_drawer.dart';

class GlobalPlaceholderPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final String description;
  final List<String> features;

  const GlobalPlaceholderPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.description,
    this.features = const [],
  });

  @override
  State<GlobalPlaceholderPage> createState() => _GlobalPlaceholderPageState();
}

class _GlobalPlaceholderPageState extends State<GlobalPlaceholderPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TallerAlexNavigationProvider>().irADashboardGlobal();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 1200;
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      drawer: isSmallScreen
          ? Drawer(
              child: ResponsiveDrawer(
                currentRoute: currentLocation,
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar
          if (!isSmallScreen) GlobalSidebar(currentRoute: currentLocation),

          // Contenido principal
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(context, theme, isSmallScreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, AppTheme theme, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
      ),
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _buildHeader(context, theme, isSmallScreen),
          ),

          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 32,
                vertical: 24,
              ),
              child: _buildMainContent(theme, isSmallScreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AppTheme theme, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 32,
        24,
        isSmallScreen ? 16 : 32,
        16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isSmallScreen)
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.alternate.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: theme.neumorphicShadows,
                        ),
                        child: IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          icon: Icon(
                            Icons.menu_rounded,
                            color: theme.primaryText,
                            size: 22,
                          ),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.title.toUpperCase(),
                            style: theme.bodyText1.override(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subtitle,
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: theme.secondaryText,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
          if (!isSmallScreen) ...[
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('/dashboard-global'),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Volver al Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.secondaryBackground,
                foregroundColor: theme.primaryText,
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: theme.alternate.withOpacity(0.3)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainContent(AppTheme theme, bool isSmallScreen) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            // Icono principal
            Container(
              width: isSmallScreen ? 120 : 160,
              height: isSmallScreen ? 120 : 160,
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(30),
                boxShadow: theme.neumorphicShadows,
              ),
              child: Icon(
                widget.icon,
                size: isSmallScreen ? 60 : 80,
                color: theme.primaryColor,
              ),
            ),

            const SizedBox(height: 32),

            // Título y descripción
            Text(
              widget.title,
              style: theme.title3.override(
                fontFamily: 'Poppins',
                color: theme.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 28 : 32,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              widget.description,
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                color: theme.secondaryText,
                fontSize: isSmallScreen ? 16 : 18,
                lineHeight: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Estado "En desarrollo"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF6B00),
                    const Color(0xFFFF2D95),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B00).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.construction,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'En desarrollo',
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if (widget.features.isNotEmpty) ...[
              const SizedBox(height: 48),

              // Características próximas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: theme.neumorphicShadows,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Características que incluirá:',
                      style: theme.title3.override(
                        fontFamily: 'Poppins',
                        color: theme.primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.features.map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: theme.bodyText1.override(
                                    fontFamily: 'Poppins',
                                    color: theme.secondaryText,
                                    lineHeight: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
