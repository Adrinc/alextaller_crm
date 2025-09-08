import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/talleralex/dashboard_global_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:intl/intl.dart';

class DashboardStatsCards extends StatefulWidget {
  final DashboardGlobalProvider provider;
  final bool isLargeScreen;
  final bool isMediumScreen;
  final bool isSmallScreen;

  const DashboardStatsCards({
    Key? key,
    required this.provider,
    required this.isLargeScreen,
    required this.isMediumScreen,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  State<DashboardStatsCards> createState() => _DashboardStatsCardsState();
}

class _DashboardStatsCardsState extends State<DashboardStatsCards>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      6,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 50)),
        vsync: this,
      ),
    );

    _animations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
      );
    }).toList();

    // Iniciar animaciones secuencialmente
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _animationControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount:
          widget.isLargeScreen ? 6 : (widget.isMediumScreen ? 3 : 2),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: widget.isSmallScreen ? 1.2 : 1.4,
      children: [
        _buildAnimatedCard(
          0,
          theme,
          'Citas Hoy',
          widget.provider.citasHoyGlobal.toString(),
          Icons.calendar_today_rounded,
          theme.primaryColor,
          '+${(widget.provider.citasHoyGlobal * 0.15).round()}',
          'vs ayer',
        ),
        _buildAnimatedCard(
          1,
          theme,
          'Ingresos',
          '${(widget.provider.ingresosTotalesGlobal / 1000).toStringAsFixed(0)}K',
          Icons.attach_money_rounded,
          theme.success,
          '+12.5%',
          'este mes',
        ),
        _buildAnimatedCard(
          2,
          theme,
          'Órdenes',
          widget.provider.ordenesAbiertasGlobal.toString(),
          Icons.build_circle_rounded,
          theme.tertiaryColor,
          '${widget.provider.tasaOrdenesCerradas.toStringAsFixed(0)}%',
          'cierre',
        ),
        _buildAnimatedCard(
          3,
          theme,
          'Sucursales',
          widget.provider.totalSucursalesActivas.toString(),
          Icons.store_rounded,
          const Color(0xFF3F51B5),
          '+2',
          'activas',
        ),
        _buildAnimatedCard(
          4,
          theme,
          'Empleados',
          widget.provider.empleadosActivosGlobal.toString(),
          Icons.people_rounded,
          const Color(0xFF9C27B0),
          '${widget.provider.promedioEmpleadosXSucursal.toStringAsFixed(0)}',
          'promedio',
        ),
        _buildAnimatedCard(
          5,
          theme,
          'Alertas',
          widget.provider.refaccionesAlertaGlobal.toString(),
          Icons.warning_amber_rounded,
          widget.provider.refaccionesAlertaGlobal > 5
              ? theme.error
              : theme.warning,
          widget.provider.refaccionesAlertaGlobal > 5 ? 'Alto' : 'Normal',
          'nivel',
        ),
      ],
    );
  }

  Widget _buildAnimatedCard(
    int index,
    AppTheme theme,
    String title,
    String value,
    IconData icon,
    Color color,
    String trend,
    String trendLabel,
  ) {
    return AnimatedBuilder(
      animation: _animations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _animations[index].value),
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _animations[index].value)),
            child: Opacity(
              opacity: _animations[index].value.clamp(0.0, 1.0),
              child: _buildStatsCard(
                theme,
                title,
                value,
                icon,
                color,
                trend,
                trendLabel,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(
    AppTheme theme,
    String title,
    String value,
    IconData icon,
    Color color,
    String trend,
    String trendLabel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: theme.neumorphicShadows,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header con icono
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: widget.isSmallScreen ? 24 : 28,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: theme.neumorphicInsetShadows,
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: color,
                      fontSize: widget.isSmallScreen ? 11 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Valor principal - más compacto
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: theme.primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.isSmallScreen ? 28 : 32,
                ),
                maxLines: 1,
              ),
            ),

            const SizedBox(height: 4),

            // Título compacto
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: theme.secondaryText,
                fontSize: widget.isSmallScreen ? 13 : 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
            ),

            const SizedBox(height: 4),

            // Etiqueta de tendencia
            Text(
              trendLabel,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: theme.tertiaryText,
                fontSize: widget.isSmallScreen ? 11 : 12,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
