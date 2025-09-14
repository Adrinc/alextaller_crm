import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nethive_neo/providers/talleralex/clientes_globales_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class FiltrosAvanzadosDialog extends StatefulWidget {
  final ClientesGlobalesProvider provider;

  const FiltrosAvanzadosDialog({
    super.key,
    required this.provider,
  });

  @override
  State<FiltrosAvanzadosDialog> createState() => _FiltrosAvanzadosDialogState();
}

class _FiltrosAvanzadosDialogState extends State<FiltrosAvanzadosDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los filtros
  final _busquedaController = TextEditingController();
  final _gastoMinimoController = TextEditingController();
  final _gastoMaximoController = TextEditingController();

  // Valores de filtros
  String? _clasificacionSeleccionada;
  String? _estadoSeleccionado;
  String? _sucursalSeleccionada;
  DateTime? _fechaInicioVisita;
  DateTime? _fechaFinVisita;
  int? _diasInactivoMinimo;

  // Animaciones
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isAnimationInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCurrentFilters();
  }

  void _loadCurrentFilters() {
    final filtros = widget.provider.filtros;
    _busquedaController.text = filtros.searchTerm;
    _clasificacionSeleccionada = filtros.clasificacion;
    _estadoSeleccionado = filtros.estado;
    _sucursalSeleccionada = filtros.sucursalId;
    _fechaInicioVisita = filtros.ultimaVisitaDesde;
    _fechaFinVisita = filtros.ultimaVisitaHasta;

    if (filtros.gastoMinimo != null) {
      _gastoMinimoController.text = filtros.gastoMinimo.toString();
    }
    if (filtros.gastoMaximo != null) {
      _gastoMaximoController.text = filtros.gastoMaximo.toString();
    }
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isAnimationInitialized = true;
        });
        _startAnimations();
      }
    });
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _busquedaController.dispose();
    _gastoMinimoController.dispose();
    _gastoMaximoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAnimationInitialized) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final maxWidth = isDesktop ? 1000.0 : 800.0;
    final maxHeight = isDesktop ? 700.0 : 750.0;

    return AnimatedBuilder(
      animation:
          Listenable.merge([_scaleAnimation, _slideAnimation, _fadeAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: maxWidth,
                  height: maxHeight,
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                  ),
                  child:
                      isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    final theme = AppTheme.of(context);

    return Row(
      children: [
        // Panel lateral con header
        Container(
          width: 320,
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
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            offset: const Offset(-4, -4),
                            blurRadius: 12,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(4, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Filtros Avanzados',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Personaliza tu búsqueda de clientes',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Resumen de filtros activos
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: _buildFiltrosResumen(),
                ),
              ),
            ],
          ),
        ),

        // Contenido principal del formulario
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: theme.neumorphicShadows,
            ),
            child: Column(
              children: [
                // Header del contenido
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.primaryBackground.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Configurar Filtros',
                        style: theme.title3.override(
                          fontFamily: 'Poppins',
                          color: theme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme.secondaryText,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.alternate.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Formulario
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildFormularioFiltros(),
                    ),
                  ),
                ),

                // Botones de acción
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.primaryBackground.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: _buildBotonesAccion(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final theme = AppTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: theme.neumorphicShadows,
      ),
      child: Column(
        children: [
          // Header móvil
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.secondaryColor],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
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
                        'Filtros Avanzados',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Personaliza tu búsqueda',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Formulario móvil
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildFormularioFiltros(),
              ),
            ),
          ),

          // Botones móviles
          Container(
            padding: const EdgeInsets.all(20),
            child: _buildBotonesAccion(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosResumen() {
    final theme = AppTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtros Activos',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        if (widget.provider.tieneFiltrosActivos) ...[
          if (_busquedaController.text.isNotEmpty)
            _buildFiltroChip('Búsqueda', _busquedaController.text),
          if (_clasificacionSeleccionada != null)
            _buildFiltroChip('Clasificación', _clasificacionSeleccionada!),
          if (_estadoSeleccionado != null)
            _buildFiltroChip('Estado', _estadoSeleccionado!),
          if (_sucursalSeleccionada != null)
            _buildFiltroChip('Sucursal', 'Seleccionada'),
          if (_gastoMinimoController.text.isNotEmpty ||
              _gastoMaximoController.text.isNotEmpty)
            _buildFiltroChip('Rango de Gasto', 'Definido'),
          if (_fechaInicioVisita != null || _fechaFinVisita != null)
            _buildFiltroChip('Período', 'Definido'),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No hay filtros activos',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFiltroChip(String titulo, String valor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$titulo: ',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              valor,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioFiltros() {
    final theme = AppTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Búsqueda general
        _buildSeccionTitulo('Búsqueda General'),
        _buildCampoTexto(
          controller: _busquedaController,
          label: 'Buscar cliente',
          hint: 'Nombre, teléfono, email...',
          icon: Icons.search_rounded,
        ),

        const SizedBox(height: 24),

        // Clasificación y Estado
        _buildSeccionTitulo('Segmentación'),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                label: 'Clasificación',
                value: _clasificacionSeleccionada,
                items: ['VIP', 'Premium', 'Frecuente', 'Ocasional', 'Nuevo'],
                onChanged: (value) =>
                    setState(() => _clasificacionSeleccionada = value),
                icon: Icons.star_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown(
                label: 'Estado',
                value: _estadoSeleccionado,
                items: ['Activo', 'Regular', 'En riesgo', 'Inactivo'],
                onChanged: (value) =>
                    setState(() => _estadoSeleccionado = value),
                icon: Icons.trending_up_rounded,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Sucursal
        _buildSeccionTitulo('Ubicación'),
        _buildDropdown(
          label: 'Sucursal',
          value: _sucursalSeleccionada,
          items: widget.provider.sucursalesDisponibles,
          onChanged: (value) => setState(() => _sucursalSeleccionada = value),
          icon: Icons.location_on_rounded,
        ),

        const SizedBox(height: 24),

        // Rango de gasto
        _buildSeccionTitulo('Filtros Financieros'),
        Row(
          children: [
            Expanded(
              child: _buildCampoTexto(
                controller: _gastoMinimoController,
                label: 'Gasto mínimo',
                hint: '0.00',
                icon: Icons.monetization_on_rounded,
                inputType: TextInputType.number,
                prefijo: '\$',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCampoTexto(
                controller: _gastoMaximoController,
                label: 'Gasto máximo',
                hint: '999999.99',
                icon: Icons.monetization_on_outlined,
                inputType: TextInputType.number,
                prefijo: '\$',
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Período de visitas
        _buildSeccionTitulo('Período de Actividad'),
        Row(
          children: [
            Expanded(
              child: _buildCampoFecha(
                label: 'Desde',
                fecha: _fechaInicioVisita,
                onChanged: (fecha) =>
                    setState(() => _fechaInicioVisita = fecha),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCampoFecha(
                label: 'Hasta',
                fecha: _fechaFinVisita,
                onChanged: (fecha) => setState(() => _fechaFinVisita = fecha),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Filtros rápidos
        _buildSeccionTitulo('Filtros Rápidos'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFiltroRapido(
              'Solo VIP',
              Icons.star,
              Colors.amber,
              () => _aplicarFiltroVIP(),
            ),
            _buildFiltroRapido(
              'Alto Valor (>50k)',
              Icons.monetization_on,
              Colors.green,
              () => _aplicarFiltroAltoValor(),
            ),
            _buildFiltroRapido(
              'Inactivos (90+ días)',
              Icons.schedule,
              Colors.orange,
              () => _aplicarFiltroInactivos(),
            ),
            _buildFiltroRapido(
              'Nuevos (30 días)',
              Icons.new_releases,
              Colors.blue,
              () => _aplicarFiltroNuevos(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    final theme = AppTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            titulo,
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    String? prefijo,
  }) {
    final theme = AppTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        style: theme.bodyText1.override(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: theme.primaryText,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: prefijo,
          prefixIcon: Icon(
            icon,
            color: theme.primaryColor,
            size: 20,
          ),
          labelStyle: theme.bodyText2.override(
            fontFamily: 'Poppins',
            color: theme.secondaryText,
            fontSize: 12,
          ),
          hintStyle: theme.bodyText2.override(
            fontFamily: 'Poppins',
            color: theme.secondaryText.withOpacity(0.7),
            fontSize: 12,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.alternate),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.alternate),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: theme.formBackground,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    final theme = AppTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              'Todos',
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                color: theme.secondaryText,
              ),
            ),
          ),
          ...items.map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: theme.primaryText,
                  ),
                ),
              )),
        ],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: theme.primaryColor,
            size: 20,
          ),
          labelStyle: theme.bodyText2.override(
            fontFamily: 'Poppins',
            color: theme.secondaryText,
            fontSize: 12,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.alternate),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.alternate),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: theme.formBackground,
        ),
      ),
    );
  }

  Widget _buildCampoFecha({
    required String label,
    required DateTime? fecha,
    required void Function(DateTime?) onChanged,
  }) {
    final theme = AppTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _seleccionarFecha(onChanged),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: theme.formBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.alternate),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: theme.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fecha != null
                          ? '${fecha.day}/${fecha.month}/${fecha.year}'
                          : 'Seleccionar fecha',
                      style: theme.bodyText1.override(
                        fontFamily: 'Poppins',
                        color: fecha != null
                            ? theme.primaryText
                            : theme.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (fecha != null)
                IconButton(
                  onPressed: () => onChanged(null),
                  icon: Icon(
                    Icons.clear,
                    color: theme.secondaryText,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltroRapido(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = AppTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesAccion() {
    final theme = AppTheme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;

    return Row(
      children: [
        // Botón limpiar
        Expanded(
          child: OutlinedButton(
            onPressed: _limpiarFiltros,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isDesktop ? 16 : 14,
                horizontal: 24,
              ),
              side: BorderSide(color: theme.alternate),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.clear_all_rounded,
                  size: 18,
                  color: theme.secondaryText,
                ),
                const SizedBox(width: 8),
                Text(
                  'Limpiar',
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: theme.secondaryText,
                    fontSize: isDesktop ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Botón aplicar
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _aplicarFiltros,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isDesktop ? 16 : 14,
                horizontal: 24,
              ),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_rounded,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Aplicar Filtros',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 14 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _aplicarFiltroVIP() {
    setState(() {
      _clasificacionSeleccionada = 'VIP';
    });
  }

  void _aplicarFiltroAltoValor() {
    setState(() {
      _gastoMinimoController.text = '50000';
    });
  }

  void _aplicarFiltroInactivos() {
    final fechaLimite = DateTime.now().subtract(const Duration(days: 90));
    setState(() {
      _fechaFinVisita = fechaLimite;
    });
  }

  void _aplicarFiltroNuevos() {
    final fechaLimite = DateTime.now().subtract(const Duration(days: 30));
    setState(() {
      _fechaInicioVisita = fechaLimite;
    });
  }

  Future<void> _seleccionarFecha(void Function(DateTime?) onChanged) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      onChanged(fecha);
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _busquedaController.clear();
      _gastoMinimoController.clear();
      _gastoMaximoController.clear();
      _clasificacionSeleccionada = null;
      _estadoSeleccionado = null;
      _sucursalSeleccionada = null;
      _fechaInicioVisita = null;
      _fechaFinVisita = null;
      _diasInactivoMinimo = null;
    });

    widget.provider.limpiarFiltros();
  }

  void _aplicarFiltros() {
    // Aplicar filtros al provider
    widget.provider.filtrarPorTexto(_busquedaController.text);
    widget.provider.filtrarPorClasificacion(_clasificacionSeleccionada);
    widget.provider.filtrarPorEstado(_estadoSeleccionado);
    widget.provider.filtrarPorSucursal(_sucursalSeleccionada);

    // Aplicar filtros de rango de gasto
    double? gastoMin;
    double? gastoMax;

    if (_gastoMinimoController.text.isNotEmpty) {
      gastoMin = double.tryParse(_gastoMinimoController.text);
    }
    if (_gastoMaximoController.text.isNotEmpty) {
      gastoMax = double.tryParse(_gastoMaximoController.text);
    }

    widget.provider.filtrarPorRangoGasto(gastoMin, gastoMax);

    // Aplicar filtros de fecha
    widget.provider.filtrarPorFechaVisita(_fechaInicioVisita, _fechaFinVisita);

    Navigator.of(context).pop();

    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              'Filtros aplicados exitosamente',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
