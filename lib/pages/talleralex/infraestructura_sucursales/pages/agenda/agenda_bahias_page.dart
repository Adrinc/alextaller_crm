import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/agenda_bahias_provider.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/bahias_widgets.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/bahias_table.dart';
import 'package:nethive_neo/pages/talleralex/infraestructura_sucursales/shared/widgets/reserva_bahia_dialog.dart';
import 'package:nethive_neo/models/talleralex/bahias_models.dart';

class AgendaBahiasPage extends StatefulWidget {
  final String sucursalId;

  const AgendaBahiasPage({
    super.key,
    required this.sucursalId,
  });

  @override
  State<AgendaBahiasPage> createState() => _AgendaBahiasPageState();
}

class _AgendaBahiasPageState extends State<AgendaBahiasPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _vistaActual = 'lista'; // 'lista', 'timeline', 'metricas'

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

    // Cargar datos de bahías
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgendaBahiasProvider>().cargarReservas(widget.sucursalId);
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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<AgendaBahiasProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState(theme);
          }

          if (provider.error != null) {
            return _buildErrorState(theme, provider.error!);
          }

          return Column(
            children: [
              // Header con controles
              _buildHeader(theme, provider),

              const SizedBox(height: 24),

              // Métricas rápidas
              _buildMetricasRapidas(theme, provider),

              const SizedBox(height: 24),

              // Filtros y vista selector
              _buildFiltrosYVistas(theme, provider),

              const SizedBox(height: 24),

              // Contenido principal
              Expanded(
                child: _buildContenidoPrincipal(theme, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppTheme theme, AgendaBahiasProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.garage,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agenda de Bahías',
                  style: theme.title2.override(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gestión y control de bahías de trabajo',
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          // Controles de fecha
          _buildDateControls(theme, provider),
        ],
      ),
    );
  }

  Widget _buildDateControls(AppTheme theme, AgendaBahiasProvider provider) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              provider.irDiaAnterior();
              provider.cargarReservas(widget.sucursalId,
                  fecha: provider.fechaSeleccionada);
            },
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatearFecha(provider.fechaSeleccionada),
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              provider.irDiaSiguiente();
              provider.cargarReservas(widget.sucursalId,
                  fecha: provider.fechaSeleccionada);
            },
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              provider.irHoy();
              provider.cargarReservas(widget.sucursalId,
                  fecha: provider.fechaSeleccionada);
            },
            icon: const Icon(Icons.today, color: Colors.white),
            tooltip: 'Ir a hoy',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricasRapidas(AppTheme theme, AgendaBahiasProvider provider) {
    final metricas = provider.metricas;
    if (metricas == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: BahiaMetricaCard(
            titulo: 'Bahías Totales',
            valor: '${metricas.bahiasTotales}',
            subtitulo: '${metricas.bahiasLibres} libres',
            icono: Icons.garage,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BahiaMetricaCard(
            titulo: 'Ocupación Promedio',
            valor:
                '${metricas.porcentajeOcupacionPromedio.toStringAsFixed(1)}%',
            subtitulo: '${metricas.bahiasOcupadas} ocupadas',
            icono: Icons.pie_chart,
            color: theme.secondaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BahiaMetricaCard(
            titulo: 'Reservas Hoy',
            valor: '${metricas.reservasHoy}',
            subtitulo: 'Total del día',
            icono: Icons.event,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BahiaMetricaCard(
            titulo: 'Alertas',
            valor: '${metricas.alertasSolapadas + metricas.citasSinBahia}',
            subtitulo: 'Revisar conflictos',
            icono: Icons.warning,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildFiltrosYVistas(AppTheme theme, AgendaBahiasProvider provider) {
    return Row(
      children: [
        // Filtros
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F3),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                offset: const Offset(-6, -6),
                blurRadius: 12,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.4),
                offset: const Offset(6, 6),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.filter_list, size: 20),
              const SizedBox(width: 8),
              Text(
                'Filtros:',
                style: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              _buildFiltroDropdown(
                'Estado',
                provider.filtroEstado,
                ['todos', 'libre', 'ocupada', 'completa'],
                (value) => provider.aplicarFiltroEstado(value),
                theme,
              ),
              const SizedBox(width: 12),
              _buildFiltroDropdown(
                'Técnico',
                provider.filtroTecnico,
                [
                  'todos',
                  'técnico1',
                  'técnico2'
                ], // Esto vendría de los datos reales
                (value) => provider.aplicarFiltroTecnico(value),
                theme,
              ),
            ],
          ),
        ),

        const Spacer(),

        // Selector de vista
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F3),
            borderRadius: BorderRadius.circular(12),
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
            children: [
              _buildVistaButton('Lista', Icons.list, 'lista', theme),
              _buildVistaButton('Timeline', Icons.timeline, 'timeline', theme),
              _buildVistaButton('Métricas', Icons.analytics, 'metricas', theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFiltroDropdown(
    String label,
    String valor,
    List<String> opciones,
    Function(String) onChanged,
    AppTheme theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: valor,
        underline: const SizedBox.shrink(),
        isDense: true,
        items: opciones.map((opcion) {
          return DropdownMenuItem(
            value: opcion,
            child: Text(
              opcion.toUpperCase(),
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) => onChanged(value ?? 'todos'),
      ),
    );
  }

  Widget _buildVistaButton(
      String texto, IconData icono, String vista, AppTheme theme) {
    final isSelected = _vistaActual == vista;

    return GestureDetector(
      onTap: () => setState(() => _vistaActual = vista),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [theme.primaryColor, theme.secondaryColor],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icono,
              color: isSelected ? Colors.white : theme.primaryColor,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              texto,
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                color: isSelected ? Colors.white : theme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenidoPrincipal(
      AppTheme theme, AgendaBahiasProvider provider) {
    switch (_vistaActual) {
      case 'timeline':
        return _buildVistaTimeline(theme, provider);
      case 'metricas':
        return _buildVistaMetricas(theme, provider);
      default:
        return _buildVistaLista(theme, provider);
    }
  }

  Widget _buildVistaLista(AppTheme theme, AgendaBahiasProvider provider) {
    final ocupaciones = provider.ocupacionesFiltradas;

    if (ocupaciones.isEmpty) {
      return _buildEmptyState(theme, 'No hay bahías disponibles');
    }

    return BahiasTable(
      provider: provider,
      sucursalId: widget.sucursalId,
    );
  }

  Widget _buildVistaTimeline(AppTheme theme, AgendaBahiasProvider provider) {
    final ocupaciones = provider.ocupacionesFiltradas;

    if (ocupaciones.isEmpty) {
      return _buildEmptyState(theme, 'No hay datos para mostrar en timeline');
    }

    return ListView.builder(
      itemCount: ocupaciones.length,
      itemBuilder: (context, index) {
        final ocupacion = ocupaciones[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F3),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                offset: const Offset(-6, -6),
                blurRadius: 12,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.4),
                offset: const Offset(6, 6),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.garage, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    ocupacion.bahiaNombre,
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${ocupacion.porcentajeOcupacion.toStringAsFixed(0)}% ocupada',
                    style: theme.bodyText2.override(
                      fontFamily: 'Poppins',
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BahiaTimelineView(
                reservas: provider.reservas,
                bahiaId: ocupacion.bahiaId,
                fecha: provider.fechaSeleccionada,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVistaMetricas(AppTheme theme, AgendaBahiasProvider provider) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                child: OcupacionChart(ocupaciones: provider.ocupaciones),
              ),
              const SizedBox(height: 16),
              _buildResumenMetricas(theme, provider),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: _buildListaMetricasDetallada(theme, provider),
        ),
      ],
    );
  }

  Widget _buildResumenMetricas(AppTheme theme, AgendaBahiasProvider provider) {
    final metricas = provider.metricas;
    if (metricas == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-6, -6),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(6, 6),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Resumen del Día',
            style: theme.title3.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricaItem('Total', '${metricas.bahiasTotales}',
                  theme.primaryColor, theme),
              _buildMetricaItem('Ocupadas', '${metricas.bahiasOcupadas}',
                  Colors.orange, theme),
              _buildMetricaItem(
                  'Libres', '${metricas.bahiasLibres}', Colors.green, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricaItem(
      String label, String valor, Color color, AppTheme theme) {
    return Column(
      children: [
        Text(
          valor,
          style: theme.title2.override(
            fontFamily: 'Poppins',
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.bodyText2.override(
            fontFamily: 'Poppins',
            color: theme.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildListaMetricasDetallada(
      AppTheme theme, AgendaBahiasProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-6, -6),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(6, 6),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalle por Bahía',
            style: theme.title3.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: provider.ocupaciones.length,
              itemBuilder: (context, index) {
                final ocupacion = provider.ocupaciones[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          ocupacion.bahiaNombre,
                          style: theme.bodyText1.override(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        ocupacion.tiempoOcupado,
                        style: theme.bodyText2.override(
                          fontFamily: 'Poppins',
                          color: theme.secondaryText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getColorEstado(ocupacion.estado)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${ocupacion.porcentajeOcupacion.toStringAsFixed(0)}%',
                          style: theme.bodyText2.override(
                            fontFamily: 'Poppins',
                            color: _getColorEstado(ocupacion.estado),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(AppTheme theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: const Offset(-12, -12),
              blurRadius: 24,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.grey.shade400.withOpacity(0.4),
              offset: const Offset(12, 12),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Cargando agenda de bahías...',
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                color: theme.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AppTheme theme, String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: const Offset(-12, -12),
              blurRadius: 24,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.grey.shade400.withOpacity(0.4),
              offset: const Offset(12, 12),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar bahías',
              style: theme.title3.override(
                fontFamily: 'Poppins',
                color: theme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
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

  Widget _buildEmptyState(AppTheme theme, String mensaje) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: const Offset(-12, -12),
              blurRadius: 24,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.grey.shade400.withOpacity(0.4),
              offset: const Offset(12, 12),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.garage_outlined,
              color: theme.secondaryText,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: theme.bodyText1.override(
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

  // Métodos de utilidad
  String _formatearFecha(DateTime fecha) {
    final dias = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];

    return '${dias[fecha.weekday % 7]} ${fecha.day} ${meses[fecha.month - 1]}';
  }

  Color _getColorEstado(EstadoBahia estado) {
    switch (estado) {
      case EstadoBahia.libre:
        return Colors.green;
      case EstadoBahia.parcial:
        return Colors.blue;
      case EstadoBahia.ocupada:
        return Colors.orange;
      case EstadoBahia.casiCompleta:
        return Colors.deepOrange;
      case EstadoBahia.completa:
        return Colors.red;
    }
  }

  // Diálogos y acciones
  void _mostrarDetallesBahia(OcupacionBahia ocupacion) {
    // TODO: Implementar diálogo de detalles
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalles de ${ocupacion.bahiaNombre}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _mostrarDialogoReserva(OcupacionBahia ocupacion) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ReservaBahiaDialog(
        ocupacion: ocupacion,
        sucursalId: widget.sucursalId,
      ),
    );

    // Si la reserva fue exitosa, recargar los datos
    if (result == true && mounted) {
      context.read<AgendaBahiasProvider>().cargarReservas(widget.sucursalId);
    }
  }
}
