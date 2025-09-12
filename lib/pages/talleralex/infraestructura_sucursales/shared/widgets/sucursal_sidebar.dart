import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/navigation_provider.dart';

class SucursalSidebar extends StatefulWidget {
  final String sucursalId;

  const SucursalSidebar({
    Key? key,
    required this.sucursalId,
  }) : super(key: key);

  @override
  State<SucursalSidebar> createState() => _SucursalSidebarState();
}

class _SucursalSidebarState extends State<SucursalSidebar>
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
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Establecer dashboard como módulo por defecto al entrar a la infraestructura
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navProvider = context.read<TallerAlexNavigationProvider>();
      if (navProvider.moduloActual != TallerAlexModulo.dashboard) {
        navProvider.cambiarModulo(TallerAlexModulo.dashboard);
      }
    });
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
      width: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: Consumer<TallerAlexNavigationProvider>(
        builder: (context, navProvider, child) {
          return Column(
            children: [
              // Header con logo animado
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      theme.secondaryColor,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'GESTIÓN DE SUCURSAL',
                      style: theme.title3.override(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Menú de módulos
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _buildMenuItems(context, theme, navProvider),
                ),
              ),

              // Footer con botón de regreso
              Container(
                padding: const EdgeInsets.all(24),
                child: _buildBackButton(context, theme),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildMenuItems(
    BuildContext context,
    AppTheme theme,
    TallerAlexNavigationProvider navProvider,
  ) {
    final modulos = [
      {
        'icon': Icons.dashboard,
        'title': 'Dashboard',
        'subtitle': 'Vista general',
        'modulo': TallerAlexModulo.dashboard
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Agenda / Bahías',
        'subtitle': 'Gestión de citas',
        'modulo': TallerAlexModulo.agenda
      },
      {
        'icon': Icons.people,
        'title': 'Empleados',
        'subtitle': 'Personal de sucursal',
        'modulo': TallerAlexModulo.empleados
      },
      {
        'icon': Icons.person,
        'title': 'Clientes',
        'subtitle': 'Base de clientes',
        'modulo': TallerAlexModulo.clientes
      },
      {
        'icon': Icons.build,
        'title': 'Citas y Órdenes',
        'subtitle': 'Servicios activos',
        'modulo': TallerAlexModulo.citas
      },
      {
        'icon': Icons.inventory,
        'title': 'Inventario',
        'subtitle': 'Refacciones',
        'modulo': TallerAlexModulo.inventario
      },
      {
        'icon': Icons.payment,
        'title': 'Pagos y Facturación',
        'subtitle': 'Gestión financiera',
        'modulo': TallerAlexModulo.pagos
      },
      {
        'icon': Icons.local_offer,
        'title': 'Promociones',
        'subtitle': 'Cupones y ofertas',
        'modulo': TallerAlexModulo.promociones
      },
      {
        'icon': Icons.analytics,
        'title': 'Reportes Locales',
        'subtitle': 'Análisis y métricas',
        'modulo': TallerAlexModulo.reportes
      },
/*       {
        'icon': Icons.settings,
        'title': 'Configuración',
        'subtitle': 'Ajustes de sucursal',
        'modulo': TallerAlexModulo.configuracion
      }, */
    ];

    return modulos.map((item) {
      final isSelected = navProvider.moduloActual == item['modulo'];

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                navProvider.cambiarModulo(item['modulo'] as TallerAlexModulo),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F3),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
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
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                theme.primaryColor,
                                theme.secondaryColor,
                              ],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: isSelected ? Colors.white : theme.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: theme.bodyText1.override(
                            fontFamily: 'Poppins',
                            color: isSelected
                                ? theme.primaryColor
                                : theme.primaryText,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['subtitle'] as String,
                          style: theme.bodyText2.override(
                            fontFamily: 'Poppins',
                            color: theme.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
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
    }).toList();
  }

  Widget _buildBackButton(BuildContext context, AppTheme theme) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back,
              color: theme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Volver a Sucursales',
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
