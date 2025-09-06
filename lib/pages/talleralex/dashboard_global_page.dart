import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/providers/talleralex/navigation_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class DashboardGlobalPage extends StatefulWidget {
  const DashboardGlobalPage({super.key});

  @override
  State<DashboardGlobalPage> createState() => _DashboardGlobalPageState();
}

class _DashboardGlobalPageState extends State<DashboardGlobalPage> {
  @override
  void initState() {
    super.initState();
    // Configurar navegación inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TallerAlexNavigationProvider>().irADashboardGlobal();
    });
  }

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
                child: _buildContent(context, theme),
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
      child: Row(
        children: [
          // Logo y título
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: theme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.build_circle,
                  color: theme.primaryText,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'TALLER ALEX',
                  style: theme.title2.override(
                    fontFamily: 'Poppins',
                    color: theme.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Botón de sucursales
          InkWell(
            onTap: () {
              context.go('/sucursales');
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.store,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ver Sucursales',
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del dashboard
          Text(
            'Dashboard Global',
            style: theme.title1.override(
              fontFamily: 'Poppins',
              color: theme.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Resumen general de todas las sucursales',
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
            ),
          ),

          const SizedBox(height: 32),

          // Cards de métricas principales
          Expanded(
            child: _buildMetricsGrid(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, AppTheme theme) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard(
          context,
          theme,
          'Citas Hoy',
          '24',
          Icons.calendar_today,
          theme.primaryColor,
        ),
        _buildMetricCard(
          context,
          theme,
          'Ingresos del Día',
          '\$12,450',
          Icons.attach_money,
          theme.success,
        ),
        _buildMetricCard(
          context,
          theme,
          'Órdenes Activas',
          '18',
          Icons.build,
          theme.tertiaryColor,
        ),
        _buildMetricCard(
          context,
          theme,
          'Alertas Inventario',
          '3',
          Icons.warning,
          theme.warning,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    AppTheme theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
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
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.title2.override(
              fontFamily: 'Poppins',
              color: theme.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
