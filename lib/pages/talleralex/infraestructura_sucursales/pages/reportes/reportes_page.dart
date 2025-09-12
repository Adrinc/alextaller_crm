import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/reportes_provider.dart';
import '../../shared/widgets/reportes_table.dart';

class ReportesPage extends StatefulWidget {
  final String sucursalId;

  const ReportesPage({
    super.key,
    required this.sucursalId,
  });

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _vistaActual = 'general';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportesProvider>().inicializar(widget.sucursalId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 900;

    return Consumer<ReportesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState(theme);
        }

        if (provider.error != null) {
          return _buildErrorState(theme, provider.error!);
        }

        return Container(
          color: const Color(0xFFF0F0F3),
          child: Column(
            children: [
              // Header con título y filtros
              _buildHeader(theme, provider, isSmallScreen),

              // Contenido principal
              Expanded(
                child: isSmallScreen
                    ? _buildMobileLayout(theme, provider)
                    : _buildDesktopLayout(theme, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      AppTheme theme, ReportesProvider provider, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y botones de acción
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor,
                                theme.secondaryColor
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.analytics,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reportes Locales',
                                style: theme.title2.override(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Análisis y métricas operativas',
                                style: theme.bodyText2.override(
                                  fontFamily: 'Poppins',
                                  color: theme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isSmallScreen) ...[
                const SizedBox(width: 16),
                _buildActionButtons(theme, provider),
              ],
            ],
          ),

          if (isSmallScreen) ...[
            const SizedBox(height: 16),
            _buildActionButtons(theme, provider),
          ],

          const SizedBox(height: 24),

          // Selector de vista
          _buildViewSelector(theme, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppTheme theme, ReportesProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón refrescar
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                offset: const Offset(-4, -4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.4),
                offset: const Offset(4, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => provider.refrescar(),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.refresh,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Botón exportar
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _exportarDatos(provider),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.download,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Exportar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewSelector(AppTheme theme, bool isSmallScreen) {
    final opciones = [
      {'id': 'general', 'title': 'General', 'icon': Icons.dashboard},
      {'id': 'graficas', 'title': 'Gráficas', 'icon': Icons.bar_chart},
      {'id': 'clientes', 'title': 'Clientes', 'icon': Icons.people},
      {'id': 'tecnicos', 'title': 'Técnicos', 'icon': Icons.build},
    ];

    if (isSmallScreen) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400.withOpacity(0.3),
              offset: const Offset(2, 2),
              blurRadius: 6,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-2, -2),
              blurRadius: 6,
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: theme.primaryColor,
          labelColor: theme.primaryColor,
          unselectedLabelColor: theme.secondaryText,
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          tabs: opciones
              .map((opcion) => Tab(
                    icon: Icon(opcion['icon'] as IconData, size: 18),
                    text: opcion['title'] as String,
                  ))
              .toList(),
        ),
      );
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.3),
            offset: const Offset(2, 2),
            blurRadius: 6,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: opciones.map((opcion) {
          final isSelected = _vistaActual == opcion['id'];
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _vistaActual = opcion['id'] as String;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        opcion['icon'] as IconData,
                        color: isSelected
                            ? theme.primaryColor
                            : theme.secondaryText,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        opcion['title'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? theme.primaryColor
                              : theme.secondaryText,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileLayout(AppTheme theme, ReportesProvider provider) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildGeneralView(theme, provider, true),
        _buildGraficasView(theme, provider, true),
        _buildClientesView(theme, provider, true),
        _buildTecnicosView(theme, provider, true),
      ],
    );
  }

  Widget _buildDesktopLayout(AppTheme theme, ReportesProvider provider) {
    switch (_vistaActual) {
      case 'graficas':
        return _buildGraficasView(theme, provider, false);
      case 'clientes':
        return _buildClientesView(theme, provider, false);
      case 'tecnicos':
        return _buildTecnicosView(theme, provider, false);
      default:
        return _buildGeneralView(theme, provider, false);
    }
  }

  Widget _buildGeneralView(
      AppTheme theme, ReportesProvider provider, bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPIs Cards
          _buildKPIsSection(theme, provider, isMobile),

          const SizedBox(height: 32),

          // Gráficas resumidas
          if (!isMobile) ...[
            _buildResumenGraficas(theme, provider),
            const SizedBox(height: 32),
          ],

          // Alertas
          _buildAlertasSection(theme, provider, isMobile),
        ],
      ),
    );
  }

  Widget _buildKPIsSection(
      AppTheme theme, ReportesProvider provider, bool isMobile) {
    final kpis = provider.kpis;
    if (kpis == null) return const SizedBox.shrink();

    final kpiItems = [
      {
        'title': 'Citas del Mes',
        'value': '${kpis.totalCitas}',
        'subtitle': '${kpis.citasCompletadas} completadas',
        'icon': Icons.calendar_today,
        'color': Colors.blue,
        'progress': kpis.porcentajeCitasCompletadas / 100,
      },
      {
        'title': 'Órdenes Activas',
        'value': '${kpis.totalOrdenes}',
        'subtitle': '${kpis.ordenesAbiertas} abiertas',
        'icon': Icons.build,
        'color': Colors.orange,
        'progress': kpis.porcentajeOrdenesCerradas / 100,
      },
      {
        'title': 'Ingresos del Mes',
        'value': kpis.ingresosMesTexto,
        'subtitle': 'Pagos confirmados',
        'icon': Icons.attach_money,
        'color': Colors.green,
        'progress': 0.85,
      },
      {
        'title': 'Ocupación Bahías',
        'value': kpis.porcentajeOcupacionTexto,
        'subtitle': 'Promedio mensual',
        'icon': Icons.garage,
        'color': Colors.purple,
        'progress': kpis.porcentajeOcupacionBahias / 100,
      },
      {
        'title': 'Top Servicio',
        'value': kpis.topServicio,
        'subtitle': '${kpis.topServicioVeces} veces',
        'icon': Icons.star,
        'color': Colors.amber,
        'progress': 1.0,
      },
    ];

    if (isMobile) {
      return Column(
        children: kpiItems
            .map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildKPICard(theme, item),
                ))
            .toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: kpiItems.length,
      itemBuilder: (context, index) => _buildKPICard(theme, kpiItems[index]),
    );
  }

  Widget _buildKPICard(AppTheme theme, Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-8, -8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(8, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: 24,
                ),
              ),
              const Spacer(),
              if (item['progress'] != null)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: item['progress'] as double,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(item['color'] as Color),
                    strokeWidth: 3,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item['title'] as String,
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item['value'] as String,
            style: theme.title3.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 4),
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
    );
  }

  Widget _buildGraficasView(
      AppTheme theme, ReportesProvider provider, bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis Gráfico',
            style: theme.title2.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Gráfica de ingresos
          _buildIngresosChart(theme, provider, isMobile),

          const SizedBox(height: 32),

          // Gráficas de servicios y refacciones
          if (isMobile)
            Column(
              children: [
                _buildServiciosChart(theme, provider),
                const SizedBox(height: 32),
                _buildRefaccionesChart(theme, provider),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildServiciosChart(theme, provider)),
                const SizedBox(width: 24),
                Expanded(child: _buildRefaccionesChart(theme, provider)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildClientesView(
      AppTheme theme, ReportesProvider provider, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clientes Frecuentes',
            style: theme.title2.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ReportesTable(
              provider: provider,
              sucursalId: widget.sucursalId,
              tipo: 'clientes',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTecnicosView(
      AppTheme theme, ReportesProvider provider, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Técnicos Productivos',
            style: theme.title2.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ReportesTable(
              provider: provider,
              sucursalId: widget.sucursalId,
              tipo: 'tecnicos',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenGraficas(AppTheme theme, ReportesProvider provider) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildIngresosChart(theme, provider, false, altura: 300),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildEstadosOrdenesChart(theme, provider),
        ),
      ],
    );
  }

  Widget _buildIngresosChart(
      AppTheme theme, ReportesProvider provider, bool isMobile,
      {double? altura}) {
    final datos = provider.datosIngresosPorDia.length > 15
        ? provider.datosIngresosPorDia
            .sublist(provider.datosIngresosPorDia.length - 15)
        : provider.datosIngresosPorDia;

    return Container(
      height: altura ?? (isMobile ? 300 : 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingresos Últimos 15 Días',
            style: theme.title3.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 3,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < datos.length) {
                          return Text(
                            datos[value.toInt()].etiqueta,
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'Poppins',
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1000,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${(value / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'Poppins',
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                minX: 0,
                maxX: datos.isEmpty ? 1 : (datos.length - 1).toDouble(),
                minY: 0,
                maxY: datos.isEmpty
                    ? 100
                    : datos
                            .map((e) => e.valor)
                            .reduce((a, b) => a > b ? a : b) *
                        1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: datos.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.valor);
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.secondaryColor],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor.withOpacity(0.3),
                          theme.secondaryColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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

  Widget _buildServiciosChart(AppTheme theme, ReportesProvider provider) {
    final datos = provider.datosServiciosTop;

    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Servicios',
            style: theme.title3.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: datos.isEmpty
                    ? 100
                    : datos
                            .map((e) => e.valor)
                            .reduce((a, b) => a > b ? a : b) *
                        1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < datos.length) {
                          final nombre = datos[value.toInt()].etiqueta;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              nombre.length > 10
                                  ? '${nombre.substring(0, 10)}...'
                                  : nombre,
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'Poppins',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'Poppins',
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: datos.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.valor,
                        gradient: LinearGradient(
                          colors: [theme.primaryColor, theme.secondaryColor],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefaccionesChart(AppTheme theme, ReportesProvider provider) {
    final datos = provider.datosRefaccionesTop;

    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Refacciones',
            style: theme.title3.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: datos.isEmpty
                    ? 100
                    : datos
                            .map((e) => e.valor)
                            .reduce((a, b) => a > b ? a : b) *
                        1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < datos.length) {
                          final nombre = datos[value.toInt()].etiqueta;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              nombre.length > 10
                                  ? '${nombre.substring(0, 10)}...'
                                  : nombre,
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'Poppins',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'Poppins',
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: datos.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.valor,
                        gradient: LinearGradient(
                          colors: [Colors.orange, Colors.amber],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadosOrdenesChart(AppTheme theme, ReportesProvider provider) {
    final datos = provider.datosEstadosOrdenes;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estados de Órdenes',
            style: theme.title3.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: datos.asMap().entries.map((entry) {
                  final colors = [Colors.orange, Colors.green];
                  return PieChartSectionData(
                    color: colors[entry.key % colors.length],
                    value: entry.value.valor,
                    title: '${entry.value.valor.toInt()}',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: datos.asMap().entries.map((entry) {
              final colors = [Colors.orange, Colors.green];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[entry.key % colors.length],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.value.etiqueta,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertasSection(
      AppTheme theme, ReportesProvider provider, bool isMobile) {
    final alertas = provider.alertas.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Alertas Operativas',
              style: theme.title2.override(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Ver todas las alertas
              },
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...alertas
            .map((alerta) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        width: 4,
                        color: alerta.severidad == 'alta'
                            ? Colors.red
                            : alerta.severidad == 'media'
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        alerta.tipo == 'inventario'
                            ? Icons.inventory
                            : alerta.tipo == 'citas'
                                ? Icons.event_busy
                                : Icons.warning,
                        color: alerta.severidad == 'alta'
                            ? Colors.red
                            : alerta.severidad == 'media'
                                ? Colors.orange
                                : Colors.green,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alerta.titulo,
                              style: theme.bodyText1.override(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alerta.descripcion,
                              style: theme.bodyText2.override(
                                fontFamily: 'Poppins',
                                color: theme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        alerta.fechaTexto,
                        style: theme.bodyText2.override(
                          fontFamily: 'Poppins',
                          color: theme.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildLoadingState(AppTheme theme) {
    return Container(
      color: const Color(0xFFF0F0F3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F3),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                offset: const Offset(-8, -8),
                blurRadius: 16,
              ),
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.4),
                offset: const Offset(8, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Generando reportes...',
                style: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(AppTheme theme, String error) {
    return Container(
      color: const Color(0xFFF0F0F3),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F3),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                offset: const Offset(-8, -8),
                blurRadius: 16,
              ),
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.4),
                offset: const Offset(8, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: theme.error,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Error al cargar reportes',
                style: theme.title3.override(
                  fontFamily: 'Poppins',
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
              const SizedBox(height: 24),
              InkWell(
                onTap: () {
                  context.read<ReportesProvider>().refrescar();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Reintentar',
                    style: theme.bodyText1.override(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportarDatos(ReportesProvider provider) {
    // Implementar exportación a CSV/Excel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exportando datos...'),
        backgroundColor: AppTheme.of(context).primaryColor,
      ),
    );
  }
}
