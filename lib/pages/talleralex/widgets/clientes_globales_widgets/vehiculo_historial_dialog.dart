import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/models/talleralex/clientes_globales_models.dart';
import 'package:nethive_neo/providers/talleralex/clientes_globales_provider.dart';

class VehiculoHistorialDialog extends StatefulWidget {
  final VehiculoCliente vehiculo;
  final ClientesGlobalesProvider provider;

  const VehiculoHistorialDialog({
    super.key,
    required this.vehiculo,
    required this.provider,
  });

  @override
  State<VehiculoHistorialDialog> createState() =>
      _VehiculoHistorialDialogState();
}

class _VehiculoHistorialDialogState extends State<VehiculoHistorialDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isAnimationInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Cargar historial del vehículo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.provider.cargarHistorialVehiculo(widget.vehiculo.vehiculoId);
    });
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

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
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
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
    final maxWidth = isDesktop ? 1000.0 : screenSize.width * 0.95;
    final maxHeight = isDesktop ? 700.0 : screenSize.height * 0.9;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: maxWidth,
                height: maxHeight,
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
                child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    final theme = AppTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header con información del vehículo
          _buildVehiculoHeader(),

          // Lista de órdenes
          Expanded(
            child: _buildHistorialList(),
          ),

          // Resumen estadístico
          _buildResumenFooter(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    final theme = AppTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildVehiculoHeader(),
          Expanded(child: _buildHistorialList()),
          _buildResumenFooter(),
        ],
      ),
    );
  }

  Widget _buildVehiculoHeader() {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.secondaryColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Imagen/Icono del vehículo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: widget.vehiculo.fotoPath != null
                  ? Image.network(
                      widget.vehiculo.fotoPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildVehiculoIcon(),
                    )
                  : _buildVehiculoIcon(),
            ),
          ),

          const SizedBox(width: 20),

          // Información del vehículo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vehiculo.nombreCompleto,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Placa: ${widget.vehiculo.placa}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                if (widget.vehiculo.color != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Color: ${widget.vehiculo.color}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Botón cerrar
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculoIcon() {
    return const Icon(
      Icons.directions_car,
      color: Colors.white,
      size: 30,
    );
  }

  Widget _buildHistorialList() {
    final theme = AppTheme.of(context);

    if (widget.provider.historialVehiculo.isEmpty) {
      return _buildEmptyHistorial();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: widget.provider.historialVehiculo.length,
      itemBuilder: (context, index) {
        final orden = widget.provider.historialVehiculo[index];
        return _buildOrdenCard(orden, theme);
      },
    );
  }

  Widget _buildOrdenCard(HistorialVehiculo orden, AppTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.alternate.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la orden
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orden #${orden.numeroOrden}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: theme.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${orden.fechaInicioTexto} → ${orden.fechaFinTexto}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildEstadoBadge(orden.estado, theme),
            ],
          ),

          const SizedBox(height: 16),

          // Desglose de costos
          Row(
            children: [
              Expanded(
                child: _buildCostoItem(
                  'Servicios',
                  orden.totalServiciosTexto,
                  Icons.build_rounded,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCostoItem(
                  'Refacciones',
                  orden.totalRefaccionesTexto,
                  Icons.settings_rounded,
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Total y duración
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_money_rounded,
                        size: 16,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Total: ',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: theme.secondaryText,
                        ),
                      ),
                      Text(
                        orden.totalTexto,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  orden.duracionTexto,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          // Técnico asignado y observaciones
          if (orden.tecnicoAsignado != null || orden.observaciones != null) ...[
            const SizedBox(height: 12),
            if (orden.tecnicoAsignado != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: 14,
                    color: theme.secondaryText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Técnico: ${orden.tecnicoAsignado}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
            if (orden.observaciones != null) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note_rounded,
                    size: 14,
                    color: theme.secondaryText,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      orden.observaciones!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCostoItem(
      String titulo, String monto, IconData icono, Color color) {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icono,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                titulo,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: theme.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            monto,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoBadge(String estado, AppTheme theme) {
    Color color;
    IconData icono;

    switch (estado.toLowerCase()) {
      case 'completado':
      case 'finalizado':
        color = Colors.green;
        icono = Icons.check_circle;
        break;
      case 'en proceso':
      case 'en progreso':
        color = Colors.blue;
        icono = Icons.autorenew;
        break;
      case 'pendiente':
        color = Colors.orange;
        icono = Icons.schedule;
        break;
      case 'cancelado':
        color = Colors.red;
        icono = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icono = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            estado,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistorial() {
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
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.history_rounded,
                size: 40,
                color: theme.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin historial de servicios',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Este vehículo aún no tiene órdenes de servicio registradas.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenFooter() {
    final theme = AppTheme.of(context);
    final historial = widget.provider.historialVehiculo;

    if (historial.isEmpty) return const SizedBox.shrink();

    // Calcular estadísticas
    final totalOrdenes = historial.length;
    final totalGastado =
        historial.fold(0.0, (sum, orden) => sum + orden.totalGeneral);
    final ordenesCompletadas = historial
        .where((o) =>
            o.estado.toLowerCase() == 'completado' ||
            o.estado.toLowerCase() == 'finalizado')
        .length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.alternate.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: theme.alternate.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildEstadistica(
              'Total Órdenes',
              totalOrdenes.toString(),
              Icons.receipt_long_rounded,
              theme.primaryColor,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.alternate.withOpacity(0.3),
          ),
          Expanded(
            child: _buildEstadistica(
              'Completadas',
              ordenesCompletadas.toString(),
              Icons.check_circle_rounded,
              Colors.green,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.alternate.withOpacity(0.3),
          ),
          Expanded(
            child: _buildEstadistica(
              'Total Invertido',
              '\$${totalGastado.toStringAsFixed(2)}',
              Icons.attach_money_rounded,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadistica(
      String titulo, String valor, IconData icono, Color color) {
    final theme = AppTheme.of(context);

    return Column(
      children: [
        Icon(
          icono,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          titulo,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: theme.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
