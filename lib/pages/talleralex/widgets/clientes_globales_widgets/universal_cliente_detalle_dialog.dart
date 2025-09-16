import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nethive_neo/providers/talleralex/clientes_globales_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

/// Interface unificada para datos de cliente que funciona con ambos modelos
abstract class ClienteData {
  String get clienteId;
  String get clienteNombre;
  String? get correo;
  String? get telefono;
  String? get direccion;
  String? get rfc;
  String? get notas;
  int get totalVehiculos;
  int get citasProximas;
  DateTime? get ultimaVisita;
  double get totalGastado;
  String? get imagenId;
  String? get imagenPath;
  String get sucursalNombre;
  String get clasificacionCliente;
  String get estadoCliente;
  String get ultimaVisitaTexto;
}

/// Adapter para ClienteGlobalGrid (vista global)
class ClienteGlobalAdapter implements ClienteData {
  final dynamic _cliente; // ClienteGlobalGrid

  ClienteGlobalAdapter(this._cliente);

  @override
  String get clienteId => _cliente.clienteId;

  @override
  String get clienteNombre => _cliente.clienteNombre;

  @override
  String? get correo => _cliente.correo;

  @override
  String? get telefono => _cliente.telefono;

  @override
  String? get direccion => _cliente.direccion;

  @override
  String? get rfc => _cliente.rfc;

  @override
  String? get notas => _cliente.notas;

  @override
  int get totalVehiculos => _cliente.totalVehiculos;

  @override
  int get citasProximas => _cliente.citasProximas;

  @override
  DateTime? get ultimaVisita => _cliente.ultimaVisita;

  @override
  double get totalGastado => _cliente.totalGastado;

  @override
  String? get imagenId => _cliente.imagenId;

  @override
  String? get imagenPath => _cliente.imagenPath;

  @override
  String get sucursalNombre => _cliente.sucursalNombre;

  @override
  String get clasificacionCliente => _cliente.clasificacionCliente;

  @override
  String get estadoCliente => _cliente.estadoCliente;

  @override
  String get ultimaVisitaTexto => _cliente.ultimaVisitaTexto;
}

/// Adapter para ClienteGrid (vista local de sucursal)
class ClienteLocalAdapter implements ClienteData {
  final dynamic _cliente; // ClienteGrid
  final String _sucursalNombre;

  ClienteLocalAdapter(this._cliente, this._sucursalNombre);

  @override
  String get clienteId => _cliente.clienteId;

  @override
  String get clienteNombre => _cliente.clienteNombre;

  @override
  String? get correo => _cliente.correo;

  @override
  String? get telefono => _cliente.telefono;

  @override
  String? get direccion => _cliente.direccion;

  @override
  String? get rfc => _cliente.rfc;

  @override
  String? get notas => _cliente.notas;

  @override
  int get totalVehiculos => _cliente.totalVehiculos;

  @override
  int get citasProximas => _cliente.citasProximas;

  @override
  DateTime? get ultimaVisita => _cliente.ultimaVisita;

  @override
  double get totalGastado => _cliente.totalGastado;

  @override
  String? get imagenId => _cliente.imagenId;

  @override
  String? get imagenPath => _cliente.imagenPath;

  @override
  String get sucursalNombre => _sucursalNombre;

  @override
  String get clasificacionCliente => 'Regular'; // Default para clientes locales

  @override
  String get estadoCliente => 'Activo'; // Default para clientes locales

  @override
  String get ultimaVisitaTexto => _cliente.ultimaVisitaTexto;
}

/// Provider interface unificada
abstract class ClienteHistorialProvider {
  Future<void> cargarHistorialCompleto(String clienteId);
  List<dynamic> get historialTecnico;
  List<dynamic> get historialFinanciero;
  List<dynamic> get sucursalesFrecuentes;
  List<dynamic> get vehiculosActivos;
  List<dynamic> get vehiculosInactivos;
}

/// Adapter para ClientesGlobalesProvider
class ClientesGlobalesProviderAdapter implements ClienteHistorialProvider {
  final ClientesGlobalesProvider _provider;

  ClientesGlobalesProviderAdapter(this._provider);

  @override
  Future<void> cargarHistorialCompleto(String clienteId) {
    return _provider.cargarHistorialCompleto(clienteId);
  }

  @override
  List<dynamic> get historialTecnico => _provider.historialTecnico;

  @override
  List<dynamic> get historialFinanciero => _provider.historialFinanciero;

  @override
  List<dynamic> get sucursalesFrecuentes => _provider.sucursalesFrecuentes;

  @override
  List<dynamic> get vehiculosActivos => _provider.vehiculosActivos;

  @override
  List<dynamic> get vehiculosInactivos => _provider.vehiculosInactivos;
}

/// Adapter para ClientesProvider (local de sucursal)
class ClientesProviderAdapter implements ClienteHistorialProvider {
  final dynamic _provider; // ClientesProvider

  ClientesProviderAdapter(this._provider);

  @override
  Future<void> cargarHistorialCompleto(String clienteId) async {
    // Carga solo el historial disponible en el provider local
    await _provider.cargarHistorialCliente(clienteId);
    await _provider.cargarVehiculosCliente(clienteId);
  }

  @override
  List<dynamic> get historialTecnico => _provider.historialCliente;

  @override
  List<dynamic> get historialFinanciero =>
      _provider.historialCliente; // Usa el mismo historial

  @override
  List<dynamic> get sucursalesFrecuentes =>
      []; // No disponible en provider local

  @override
  List<dynamic> get vehiculosActivos => _provider.vehiculosCliente;

  @override
  List<dynamic> get vehiculosInactivos => []; // No disponible en provider local
}

/// Diálogo de detalle universal que funciona con ambos tipos de clientes
class UniversalClienteDetalleDialog extends StatefulWidget {
  final ClienteData cliente;
  final ClienteHistorialProvider provider;

  const UniversalClienteDetalleDialog({
    super.key,
    required this.cliente,
    required this.provider,
  });

  @override
  State<UniversalClienteDetalleDialog> createState() =>
      _UniversalClienteDetalleDialogState();
}

class _UniversalClienteDetalleDialogState
    extends State<UniversalClienteDetalleDialog> with TickerProviderStateMixin {
  late TabController _tabController;
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
    _tabController = TabController(length: 4, vsync: this);
    _initializeAnimations();

    // Cargar historial completo del cliente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.provider.cargarHistorialCompleto(widget.cliente.clienteId);
    });
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
      begin: const Offset(0, -0.3),
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
    _tabController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAnimationInitialized) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final maxWidth = isDesktop ? 1200.0 : screenSize.width * 0.95;
    final maxHeight = isDesktop ? 800.0 : screenSize.height * 0.9;

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
        // Panel lateral con información del cliente
        Container(
          width: 350,
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
          child: _buildClienteInfo(),
        ),

        // Contenido principal con tabs
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
                // Header con tabs
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.primaryBackground.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          controller: _tabController,
                          labelColor: theme.primaryColor,
                          unselectedLabelColor: theme.secondaryText,
                          indicatorColor: theme.primaryColor,
                          indicatorWeight: 3,
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.build_rounded, size: 20),
                              text: 'Historial Técnico',
                            ),
                            Tab(
                              icon: Icon(Icons.attach_money_rounded, size: 20),
                              text: 'Historial Financiero',
                            ),
                            Tab(
                              icon: Icon(Icons.location_on_rounded, size: 20),
                              text: 'Sucursales',
                            ),
                            Tab(
                              icon: Icon(Icons.directions_car, size: 20),
                              text: 'Vehículos',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
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

                // Contenido de las tabs
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHistorialTecnico(),
                      _buildHistorialFinanciero(),
                      _buildSucursalesFrecuentes(),
                      _buildVehiculos(),
                    ],
                  ),
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
          // Header móvil con información básica
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
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        widget.cliente.clienteNombre.isNotEmpty
                            ? widget.cliente.clienteNombre[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.cliente.clienteNombre,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.cliente.sucursalNombre,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
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
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  tabs: const [
                    Tab(text: 'Técnico'),
                    Tab(text: 'Financiero'),
                    Tab(text: 'Sucursales'),
                    Tab(text: 'Vehículos'),
                  ],
                ),
              ],
            ),
          ),

          // Contenido de las tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHistorialTecnico(),
                _buildHistorialFinanciero(),
                _buildSucursalesFrecuentes(),
                _buildVehiculos(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClienteInfo() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Avatar del cliente
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
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
            child: Center(
              child: Text(
                widget.cliente.clienteNombre.isNotEmpty
                    ? widget.cliente.clienteNombre[0].toUpperCase()
                    : '?',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Nombre del cliente
          Text(
            widget.cliente.clienteNombre,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Clasificación
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                Icon(
                  _getClasificacionIcon(widget.cliente.clasificacionCliente),
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.cliente.clasificacionCliente,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Información de contacto
          _buildInfoCard(
            'Contacto',
            [
              if (widget.cliente.telefono != null)
                _buildInfoItem(Icons.phone, widget.cliente.telefono!),
              if (widget.cliente.correo != null)
                _buildInfoItem(Icons.email, widget.cliente.correo!),
              _buildInfoItem(Icons.location_on, widget.cliente.sucursalNombre),
            ],
          ),

          const SizedBox(height: 16),

          // Información financiera
          _buildInfoCard(
            'Información Financiera',
            [
              _buildInfoItem(
                Icons.attach_money,
                '\$${widget.cliente.totalGastado.toStringAsFixed(2)}',
                'Total Gastado',
              ),
              _buildInfoItem(
                Icons.calendar_today,
                widget.cliente.ultimaVisitaTexto,
                'Última Visita',
              ),
              _buildInfoItem(
                Icons.trending_up,
                '${widget.cliente.totalVehiculos} vehículos',
                'Vehículos',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String titulo, List<Widget> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String valor, [String? label]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                Text(
                  valor,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialTecnico() {
    final theme = AppTheme.of(context);

    if (widget.provider.historialTecnico.isEmpty) {
      return _buildEmptyState(
        icon: Icons.build_rounded,
        titulo: 'Sin historial técnico',
        mensaje: 'No hay registros técnicos disponibles para este cliente.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: widget.provider.historialTecnico.length,
      itemBuilder: (context, index) {
        final registro = widget.provider.historialTecnico[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.formBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: theme.neumorphicShadows,
            border: const BorderDirectional(
              start: BorderSide(
                width: 4,
                color: Colors.blue,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.build_rounded,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Orden #${registro.numeroOrden}',
                          style: theme.bodyText1.override(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: theme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          registro.fechaInicioTexto,
                          style: theme.bodyText2.override(
                            fontFamily: 'Poppins',
                            color: theme.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(registro.estado).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      registro.estado,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getEstadoColor(registro.estado),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${registro.vehiculoTexto} - ${registro.estado}',
                style: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  color: theme.primaryText,
                  fontSize: 14,
                ),
              ),
              if (registro.serviciosIncluidos != null &&
                  registro.serviciosIncluidos!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.build_rounded,
                            size: 16,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Servicios incluidos:',
                            style: theme.bodyText2.override(
                              fontFamily: 'Poppins',
                              color: theme.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        registro.serviciosIncluidos!,
                        style: theme.bodyText2.override(
                          fontFamily: 'Poppins',
                          color: theme.primaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.alternate.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Total: ${registro.totalGeneralTexto}',
                  style: theme.bodyText2.override(
                    fontFamily: 'Poppins',
                    color: theme.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistorialFinanciero() {
    final theme = AppTheme.of(context);

    if (widget.provider.historialFinanciero.isEmpty) {
      return _buildEmptyState(
        icon: Icons.attach_money_rounded,
        titulo: 'Sin historial financiero',
        mensaje: 'No hay registros financieros disponibles para este cliente.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: widget.provider.historialFinanciero.length,
      itemBuilder: (context, index) {
        final registro = widget.provider.historialFinanciero[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.formBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: theme.neumorphicShadows,
            border: const BorderDirectional(
              start: BorderSide(
                width: 4,
                color: Colors.green,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.attach_money_rounded,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          registro.fechaInicioTexto,
                          style: theme.bodyText2.override(
                            fontFamily: 'Poppins',
                            color: theme.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          registro.totalPagadoTexto ??
                              '\$${registro.totalGeneral?.toStringAsFixed(2) ?? "0.00"}',
                          style: theme.bodyText1.override(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Orden #${registro.numeroOrden ?? registro.ordenId} - ${widget.cliente.sucursalNombre}',
                      style: theme.bodyText1.override(
                        fontFamily: 'Poppins',
                        color: theme.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.alternate.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        registro.ordenEstado ?? registro.estado,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: theme.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSucursalesFrecuentes() {
    final theme = AppTheme.of(context);

    if (widget.provider.sucursalesFrecuentes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.location_on_rounded,
        titulo: 'Sin información de sucursales',
        mensaje: 'No hay datos de sucursales frecuentes para este cliente.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: widget.provider.sucursalesFrecuentes.length,
      itemBuilder: (context, index) {
        final sucursal = widget.provider.sucursalesFrecuentes[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.formBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: theme.neumorphicShadows,
            border: const BorderDirectional(
              start: BorderSide(
                width: 4,
                color: Colors.blue,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sucursal.sucursalNombre,
                      style: theme.bodyText1.override(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sucursal.totalVisitas} visitas',
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // Barra de porcentaje
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${sucursal.porcentajeVisitas?.toStringAsFixed(1) ?? "0.0"}%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.alternate.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (sucursal.porcentajeVisitas ?? 0) / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVehiculos() {
    // Para simplificar, vamos a mostrar solo un mensaje por ahora
    // Más adelante podemos adaptar también el widget de vehículos
    return _buildEmptyState(
      icon: Icons.directions_car,
      titulo: 'Vehículos del cliente',
      mensaje: 'Total de vehículos: ${widget.cliente.totalVehiculos}',
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String titulo,
    required String mensaje,
  }) {
    final theme = AppTheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.alternate.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 40,
                color: theme.secondaryText.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              titulo,
              style: theme.title3.override(
                fontFamily: 'Poppins',
                color: theme.primaryText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
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

  IconData _getClasificacionIcon(String clasificacion) {
    switch (clasificacion) {
      case 'VIP':
        return Icons.star;
      case 'Premium':
        return Icons.diamond;
      case 'Frecuente':
        return Icons.favorite;
      case 'Ocasional':
        return Icons.person;
      case 'Nuevo':
        return Icons.new_releases;
      default:
        return Icons.person_outline;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Completado':
        return Colors.green;
      case 'En proceso':
        return Colors.blue;
      case 'Pendiente':
        return Colors.orange;
      case 'Cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
