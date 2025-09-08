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
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: widget.isSmallScreen ? 1.8 : 1.6,
      children: [
        _buildAnimatedCard(
          0,
          theme,
          'Citas de Hoy',
          widget.provider.citasHoyGlobal.toString(),
          Icons.calendar_today_rounded,
          theme.primaryColor,
          '+${(widget.provider.citasHoyGlobal * 0.15).round()}',
          'vs ayer',
        ),
        _buildAnimatedCard(
          1,
          theme,
          'Ingresos Totales',
          currencyFormat.format(widget.provider.ingresosTotalesGlobal),
          Icons.attach_money_rounded,
          theme.success,
          '+12.5%',
          'este mes',
        ),
        _buildAnimatedCard(
          2,
          theme,
          'Órdenes Abiertas',
          widget.provider.ordenesAbiertasGlobal.toString(),
          Icons.build_circle_rounded,
          theme.tertiaryColor,
          '${widget.provider.tasaOrdenesCerradas.toStringAsFixed(1)}%',
          'tasa cierre',
        ),
        _buildAnimatedCard(
          3,
          theme,
          'Sucursales Activas',
          widget.provider.totalSucursalesActivas.toString(),
          Icons.store_rounded,
          Colors.blue,
          '+2',
          'este año',
        ),
        _buildAnimatedCard(
          4,
          theme,
          'Empleados Activos',
          widget.provider.empleadosActivosGlobal.toString(),
          Icons.people_rounded,
          Colors.purple,
          '${widget.provider.promedioEmpleadosXSucursal.toStringAsFixed(1)}',
          'por sucursal',
        ),
        _buildAnimatedCard(
          5,
          theme,
          'Alertas Inventario',
          widget.provider.refaccionesAlertaGlobal.toString(),
          Icons.warning_amber_rounded,
          widget.provider.refaccionesAlertaGlobal > 5
              ? theme.error
              : theme.warning,
          widget.provider.refaccionesAlertaGlobal > 5 ? 'Alto' : 'Normal',
          'nivel riesgo',
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
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.secondaryBackground.withOpacity(0.8),
            theme.primaryBackground.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          // Neumorphism shadows
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            offset: const Offset(-6, -6),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(6, 6),
            blurRadius: 16,
          ),
          // Accent glow
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Animated background pattern
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.2),
                      color.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon and title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withOpacity(0.2),
                              color.withOpacity(0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Value
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: theme.title2.override(
                        fontFamily: 'Poppins',
                        color: theme.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      maxLines: 1,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Title
                  Text(
                    title,
                    style: theme.bodyText2.override(
                      fontFamily: 'Poppins',
                      color: theme.secondaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Trend indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          theme.success.withOpacity(0.2),
                          theme.success.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: theme.success,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            trend,
                            style: theme.bodyText2.override(
                              fontFamily: 'Poppins',
                              color: theme.success,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
