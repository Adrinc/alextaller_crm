import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/promociones_globales_provider.dart';

class PromocionesHeader extends StatefulWidget {
  final VoidCallback? onCrearPromocion;
  final VoidCallback? onRefresh;

  const PromocionesHeader({
    Key? key,
    this.onCrearPromocion,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<PromocionesHeader> createState() => _PromocionesHeaderState();
}

class _PromocionesHeaderState extends State<PromocionesHeader>
    with TickerProviderStateMixin {
  final TextEditingController _filtroTextoController = TextEditingController();
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;
  bool _filtrosExpandidos = false;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    ));

    // Inicializar el controlador de texto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<PromocionesGlobalesProvider>(context, listen: false);
      _filtroTextoController.text = provider.filtroTexto;
    });
  }

  @override
  void dispose() {
    _filtroTextoController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    _refreshController.forward().then((_) {
      _refreshController.reset();
    });
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    return Consumer<PromocionesGlobalesProvider>(
      builder: (context, provider, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              // Sombra superior izquierda (luz)
              BoxShadow(
                color: Colors.white,
                offset: Offset(-4, -4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
              // Sombra inferior derecha (sombra)
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.4),
                offset: Offset(4, 4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === TÍTULO Y ACCIONES PRINCIPALES ===
                _buildTituloYAcciones(theme, isSmallScreen),

                const SizedBox(height: 24),

                // === KPIs ===
                _buildKPIs(theme, isSmallScreen, provider),

                const SizedBox(height: 24),

                // === FILTROS ===
                _buildSeccionFiltros(theme, isSmallScreen, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTituloYAcciones(AppTheme theme, bool isSmallScreen) {
    return Row(
      children: [
        // Título
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Promociones Globales',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gestiona promociones, cupones y analiza su rendimiento',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // Acciones principales
        if (!isSmallScreen) ...[
          const SizedBox(width: 16),
          _buildAccionesPrincipales(),
        ],
      ],
    );
  }

  Widget _buildAccionesPrincipales() {
    return Consumer<PromocionesGlobalesProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            // Botón Refrescar
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: provider.isLoading ? null : _onRefresh,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RotationTransition(
                          turns: _refreshAnimation,
                          child: Icon(
                            Icons.refresh,
                            size: 18,
                            color: provider.isLoading
                                ? Colors.grey.shade400
                                : const Color(0xFF0066CC),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Refrescar',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: provider.isLoading
                                ? Colors.grey.shade400
                                : const Color(0xFF0A0A0A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Botón Crear Promoción
            Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF0066CC), Color(0xFF2ECC71)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0066CC).withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.onCrearPromocion,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nueva Promoción',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
      },
    );
  }

  Widget _buildKPIs(AppTheme theme, bool isSmallScreen,
      PromocionesGlobalesProvider provider) {
    final kpisActivas = provider.kpisPromocionesActivas;
    final kpisROI = provider.kpisROI;
    final kpisCupones = provider.kpisCupones;

    final kpis = [
      {
        'titulo': 'Promociones Vigentes',
        'valor': '${kpisActivas['vigentes']}/${kpisActivas['total']}',
        'icono': Icons.campaign,
        'color': const Color(0xFF0066CC),
        'subtitulo': '${kpisActivas['programadas']} programadas',
      },
      {
        'titulo': 'ROI Promedio',
        'valor': '${(kpisROI['roi_promedio'] * 100).toStringAsFixed(1)}%',
        'icono': Icons.trending_up,
        'color': const Color(0xFF2ECC71),
        'subtitulo': '${kpisROI['total_canjes']} canjes',
      },
      {
        'titulo': 'Cupones Disponibles',
        'valor': '${kpisCupones['disponibles']}',
        'icono': Icons.qr_code,
        'color': const Color(0xFFFF6B00),
        'subtitulo': '${kpisCupones['usos_total']} usos',
      },
      {
        'titulo': 'Ingresos Netos',
        'valor': '\$${(kpisROI['ingreso_neto']).toStringAsFixed(0)}',
        'icono': Icons.attach_money,
        'color': const Color(0xFFFF2D95),
        'subtitulo': '${kpisROI['clientes_unicos']} clientes únicos',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isSmallScreen ? 1.4 : 1.8,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        final kpi = kpis[index];
        return _buildKPICard(
          titulo: kpi['titulo'] as String,
          valor: kpi['valor'] as String,
          subtitulo: kpi['subtitulo'] as String,
          icono: kpi['icono'] as IconData,
          color: kpi['color'] as Color,
        );
      },
    );
  }

  Widget _buildKPICard({
    required String titulo,
    required String valor,
    required String subtitulo,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icono,
                    size: 20,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              valor,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitulo,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionFiltros(AppTheme theme, bool isSmallScreen,
      PromocionesGlobalesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de filtros
        Row(
          children: [
            Text(
              'Filtros',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A0A0A),
              ),
            ),

            const Spacer(),

            if (isSmallScreen) ...[
              // Botón toggle en móvil
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        _filtrosExpandidos = !_filtrosExpandidos;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _filtrosExpandidos
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 20,
                        color: const Color(0xFF0A0A0A),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // Botón limpiar filtros (siempre visible)
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    _filtroTextoController.clear();
                    provider.limpiarFiltros();
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.clear_all,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        if (!isSmallScreen) ...[
                          const SizedBox(width: 6),
                          Text(
                            'Limpiar',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Controles de filtros
        if (!isSmallScreen || _filtrosExpandidos) ...[
          _buildControlesFiltros(provider, isSmallScreen),
        ],
      ],
    );
  }

  Widget _buildControlesFiltros(
      PromocionesGlobalesProvider provider, bool isSmallScreen) {
    return isSmallScreen
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFiltroTexto(provider),
              const SizedBox(height: 12),
              _buildFiltroSucursal(provider),
              const SizedBox(height: 12),
              _buildFiltroFechas(provider),
            ],
          )
        : Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildFiltroTexto(provider),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildFiltroSucursal(provider),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: _buildFiltroFechas(provider),
              ),
            ],
          );
  }

  Widget _buildFiltroTexto(PromocionesGlobalesProvider provider) {
    return TextField(
      controller: _filtroTextoController,
      onChanged: (value) {
        provider.setFiltroTexto(value);
      },
      decoration: InputDecoration(
        hintText: 'Buscar promoción...',
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey.shade500,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.grey.shade500,
          size: 20,
        ),
        suffixIcon: _filtroTextoController.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                onPressed: () {
                  _filtroTextoController.clear();
                  provider.setFiltroTexto('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0066CC)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFF0A0A0A),
      ),
    );
  }

  Widget _buildFiltroSucursal(PromocionesGlobalesProvider provider) {
    return DropdownButtonFormField<String>(
      value: provider.sucursalIdFiltro,
      onChanged: (value) {
        provider.setSucursalFiltro(value);
      },
      decoration: InputDecoration(
        hintText: 'Todas las sucursales',
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey.shade500,
        ),
        prefixIcon: Icon(
          Icons.business,
          color: Colors.grey.shade500,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0066CC)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFF0A0A0A),
      ),
      dropdownColor: Colors.white,
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(
            'Todas las sucursales',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        ...provider.sucursales
            .map((sucursal) => DropdownMenuItem<String>(
                  value: sucursal.id,
                  child: Text(
                    sucursal.nombre,
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildFiltroFechas(PromocionesGlobalesProvider provider) {
    return GestureDetector(
      onTap: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialDateRange: provider.rangoFechas,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF0066CC),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          provider.setRangoFechas(picked);
        }
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.date_range,
                color: Colors.grey.shade500,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${provider.rangoFechas.start.toIso8601String().split('T')[0]} - ${provider.rangoFechas.end.toIso8601String().split('T')[0]}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF0A0A0A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
