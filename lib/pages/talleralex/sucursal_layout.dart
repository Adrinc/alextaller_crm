import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/providers/talleralex/navigation_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class SucursalLayout extends StatelessWidget {
  final String sucursalId;

  const SucursalLayout({
    super.key,
    required this.sucursalId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.darkBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, theme),

              // Content
              Expanded(
                child: Row(
                  children: [
                    // Sidebar
                    _buildSidebar(context, theme),

                    // Main content
                    Expanded(
                      child: _buildMainContent(context, theme),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(
          bottom: BorderSide(
            color: theme.tertiaryBackground,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Botón de regresar
          InkWell(
            onTap: () => context.go('/sucursales'),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.tertiaryBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_back,
                color: theme.primaryText,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Breadcrumb
          Consumer<TallerAlexNavigationProvider>(
            builder: (context, navProvider, child) {
              return Text(
                navProvider.breadcrumbPath,
                style: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  color: theme.secondaryText,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AppTheme theme) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(
          right: BorderSide(
            color: theme.tertiaryBackground,
            width: 1,
          ),
        ),
      ),
      child: Consumer<TallerAlexNavigationProvider>(
        builder: (context, navProvider, child) {
          return Column(
            children: [
              // Header del sidebar
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sucursal ID: $sucursalId',
                      style: theme.title3.override(
                        fontFamily: 'Poppins',
                        color: theme.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestión de sucursal',
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                height: 1,
                color: theme.tertiaryBackground,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),

              const SizedBox(height: 16),

              // Menú de módulos
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: navProvider.modulosSucursal.map((modulo) {
                    final isSelected = navProvider.moduloActual == modulo;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: InkWell(
                        onTap: () => navProvider.cambiarModulo(modulo),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.primaryColor.withOpacity(0.1)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(
                                    color: theme.primaryColor.withOpacity(0.3),
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                navProvider.getIconoModulo(modulo),
                                color: isSelected
                                    ? theme.primaryColor
                                    : theme.secondaryText,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  navProvider.getNombreModulo(modulo),
                                  style: theme.bodyText2.override(
                                    fontFamily: 'Poppins',
                                    color: isSelected
                                        ? theme.primaryColor
                                        : theme.primaryText,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, AppTheme theme) {
    return Consumer<TallerAlexNavigationProvider>(
      builder: (context, navProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del módulo actual
              Text(
                navProvider.getNombreModulo(navProvider.moduloActual),
                style: theme.title2.override(
                  fontFamily: 'Poppins',
                  color: theme.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Módulo de ${navProvider.getNombreModulo(navProvider.moduloActual).toLowerCase()}',
                style: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  color: theme.secondaryText,
                ),
              ),

              const SizedBox(height: 32),

              // Contenido del módulo
              Expanded(
                child: _buildModuleContent(
                    context, theme, navProvider.moduloActual),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModuleContent(
      BuildContext context, AppTheme theme, TallerAlexModulo modulo) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                context
                    .read<TallerAlexNavigationProvider>()
                    .getIconoModulo(modulo),
                color: theme.primaryColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Módulo en desarrollo',
              style: theme.title3.override(
                fontFamily: 'Poppins',
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El contenido de este módulo se implementará próximamente',
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                color: theme.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
