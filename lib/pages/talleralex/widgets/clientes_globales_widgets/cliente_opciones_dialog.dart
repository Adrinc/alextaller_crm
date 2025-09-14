import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nethive_neo/theme/theme.dart';

class ClienteOpcionesDialog extends StatefulWidget {
  final dynamic cliente;
  final VoidCallback? onVerDetalle;
  final VoidCallback? onEditarCliente;
  final VoidCallback? onCrearCita;

  const ClienteOpcionesDialog({
    super.key,
    required this.cliente,
    this.onVerDetalle,
    this.onEditarCliente,
    this.onCrearCita,
  });

  @override
  State<ClienteOpcionesDialog> createState() => _ClienteOpcionesDialogState();
}

class _ClienteOpcionesDialogState extends State<ClienteOpcionesDialog>
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
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
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

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: isDesktop ? 450 : 350,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildClienteInfo(),
                    const SizedBox(height: 24),
                    _buildAcciones(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final theme = AppTheme.of(context);

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
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
                'Opciones del Cliente',
                style: theme.title3.override(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryText,
                ),
              ),
              Text(
                'Acciones disponibles',
                style: theme.bodyText2.override(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: theme.secondaryText,
                ),
              ),
            ],
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
    );
  }

  Widget _buildClienteInfo() {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.alternate.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            child: Text(
              widget.cliente.clienteNombre.isNotEmpty
                  ? widget.cliente.clienteNombre[0].toUpperCase()
                  : '?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cliente.clienteNombre,
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.cliente.sucursalNombre,
                  style: theme.bodyText2.override(
                    fontFamily: 'Poppins',
                    color: theme.secondaryText,
                    fontSize: 12,
                  ),
                ),
                if (widget.cliente.telefono != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.cliente.telefono!,
                    style: theme.bodyText2.override(
                      fontFamily: 'Poppins',
                      color: theme.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Badge de clasificación
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getClasificacionColor(widget.cliente.clasificacionCliente)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _getClasificacionColor(widget.cliente.clasificacionCliente)
                        .withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getClasificacionIcon(widget.cliente.clasificacionCliente),
                  size: 12,
                  color: _getClasificacionColor(
                      widget.cliente.clasificacionCliente),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.cliente.clasificacionCliente,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getClasificacionColor(
                        widget.cliente.clasificacionCliente),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcciones() {
    return Column(
      children: [
        // Fila 1: Ver detalle y Contactar
        Row(
          children: [
            Expanded(
              child: _buildOpcionBoton(
                icono: Icons.visibility_rounded,
                titulo: 'Ver Detalle',
                subtitulo: 'Historial completo',
                color: Colors.blue,
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onVerDetalle?.call();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOpcionBoton(
                icono: Icons.phone_rounded,
                titulo: 'Contactar',
                subtitulo: 'Llamar o mensaje',
                color: Colors.green,
                onTap: _mostrarOpcionesContacto,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Fila 2: Crear cita y Editar
        Row(
          children: [
            Expanded(
              child: _buildOpcionBoton(
                icono: Icons.event_available_rounded,
                titulo: 'Nueva Cita',
                subtitulo: 'Agendar servicio',
                color: Colors.purple,
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onCrearCita?.call();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOpcionBoton(
                icono: Icons.edit_rounded,
                titulo: 'Editar',
                subtitulo: 'Modificar datos',
                color: Colors.orange,
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onEditarCliente?.call();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOpcionBoton({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = AppTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icono,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitulo,
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: theme.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarOpcionesContacto() {
    final theme = AppTheme.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.phone_rounded,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contactar Cliente',
                          style: theme.bodyText1.override(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: theme.primaryText,
                          ),
                        ),
                        Text(
                          widget.cliente.clienteNombre,
                          style: theme.bodyText2.override(
                            fontFamily: 'Poppins',
                            color: theme.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: theme.secondaryText,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (widget.cliente.telefono != null) ...[
                _buildContactoOpcion(
                  icono: Icons.phone,
                  titulo: 'Llamar',
                  valor: widget.cliente.telefono!,
                  onTap: () => _llamarCliente(widget.cliente.telefono!),
                ),
                const SizedBox(height: 12),
                _buildContactoOpcion(
                  icono: Icons.message,
                  titulo: 'WhatsApp',
                  valor: widget.cliente.telefono!,
                  onTap: () => _enviarWhatsApp(widget.cliente.telefono!),
                ),
              ],
              if (widget.cliente.correo != null) ...[
                const SizedBox(height: 12),
                _buildContactoOpcion(
                  icono: Icons.email,
                  titulo: 'Email',
                  valor: widget.cliente.correo!,
                  onTap: () => _enviarEmail(widget.cliente.correo!),
                ),
              ],
              if (widget.cliente.telefono == null &&
                  widget.cliente.correo == null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.alternate.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.secondaryText,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No hay información de contacto disponible',
                          style: theme.bodyText2.override(
                            fontFamily: 'Poppins',
                            color: theme.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactoOpcion({
    required IconData icono,
    required String titulo,
    required String valor,
    required VoidCallback onTap,
  }) {
    final theme = AppTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.alternate.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icono,
                color: theme.primaryColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: theme.primaryText,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    valor,
                    style: theme.bodyText2.override(
                      fontFamily: 'Poppins',
                      color: theme.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.secondaryText,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Color _getClasificacionColor(String clasificacion) {
    switch (clasificacion) {
      case 'VIP':
        return Colors.amber.shade700;
      case 'Premium':
        return Colors.purple;
      case 'Frecuente':
        return Colors.green;
      case 'Ocasional':
        return Colors.blue;
      case 'Nuevo':
        return Colors.grey;
      default:
        return Colors.grey.shade600;
    }
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

  Future<void> _llamarCliente(String telefono) async {
    final uri = Uri.parse('tel:$telefono');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _mostrarError('No se puede abrir la aplicación de teléfono');
    }
    Navigator.of(context).pop();
  }

  Future<void> _enviarWhatsApp(String telefono) async {
    // Limpiar el número de teléfono
    final numeroLimpio = telefono.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse('https://wa.me/52$numeroLimpio');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _mostrarError('No se puede abrir WhatsApp');
    }
    Navigator.of(context).pop();
  }

  Future<void> _enviarEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _mostrarError('No se puede abrir la aplicación de email');
    }
    Navigator.of(context).pop();
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mensaje,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
