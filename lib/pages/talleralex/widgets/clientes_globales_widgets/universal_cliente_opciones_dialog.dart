import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nethive_neo/theme/theme.dart';

class UniversalClienteOpcionesDialog extends StatefulWidget {
  final dynamic
      cliente; // Puede ser ClienteData o cualquier objeto con las propiedades necesarias
  final VoidCallback? onVerDetalle;
  final VoidCallback? onEditarCliente;
  final VoidCallback? onCrearCita;

  const UniversalClienteOpcionesDialog({
    super.key,
    required this.cliente,
    this.onVerDetalle,
    this.onEditarCliente,
    this.onCrearCita,
  });

  @override
  State<UniversalClienteOpcionesDialog> createState() =>
      _UniversalClienteOpcionesDialogState();
}

class _UniversalClienteOpcionesDialogState
    extends State<UniversalClienteOpcionesDialog>
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

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
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
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _scaleController.forward();
    });
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

    final theme = AppTheme.of(context);

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
                width: 320,
                constraints: const BoxConstraints(
                  maxWidth: 350,
                ),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(theme),
                    _buildOptions(theme),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppTheme theme) {
    // Acceso seguro a las propiedades del cliente
    String clienteNombre = '';
    String? telefono;
    String? correo;

    try {
      clienteNombre = widget.cliente.clienteNombre ?? '';
      telefono = widget.cliente.telefono;
      correo = widget.cliente.correo;
    } catch (e) {
      // Fallback si el objeto no tiene las propiedades esperadas
      clienteNombre = 'Cliente';
    }

    return Container(
      width: double.infinity,
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
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Avatar del cliente
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                clienteNombre.isNotEmpty ? clienteNombre[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Nombre del cliente
          Text(
            clienteNombre,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Info de contacto
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (telefono != null) ...[
                Icon(
                  Icons.phone,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  telefono,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
              if (telefono != null && correo != null) ...[
                const SizedBox(width: 12),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (correo != null) ...[
                Icon(
                  Icons.email,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    correo,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(AppTheme theme) {
    // Acceso seguro a las propiedades del cliente
    String? telefono;
    String? correo;

    try {
      telefono = widget.cliente.telefono;
      correo = widget.cliente.correo;
    } catch (e) {
      // No hay problema si no tiene estas propiedades
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Ver detalle completo
          _buildOptionButton(
            icon: Icons.visibility_rounded,
            label: 'Ver Detalle Completo',
            subtitle: 'Historial, vehículos y más',
            color: Colors.blue,
            onTap: widget.onVerDetalle,
          ),

          const SizedBox(height: 8),

          // Opciones de contacto
          Row(
            children: [
              if (telefono != null) ...[
                // Llamar
                Expanded(
                  child: _buildCompactOption(
                    icon: Icons.phone,
                    label: 'Llamar',
                    color: Colors.green,
                    onTap: () => _launchPhone(telefono ?? ''),
                  ),
                ),
                const SizedBox(width: 8),
                // WhatsApp
                Expanded(
                  child: _buildCompactOption(
                    icon: Icons.message,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () => _launchWhatsApp(telefono ?? ''),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: _buildCompactOption(
                    icon: Icons.phone_disabled,
                    label: 'Sin teléfono',
                    color: Colors.grey,
                    onTap: null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactOption(
                    icon: Icons.message_outlined,
                    label: 'Sin WhatsApp',
                    color: Colors.grey,
                    onTap: null,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Email
          if (correo != null)
            _buildOptionButton(
              icon: Icons.email_rounded,
              label: 'Enviar Email',
              subtitle: correo,
              color: Colors.orange,
              onTap: () => _launchEmail(correo ?? ''),
            ),

          const SizedBox(height: 8),

          // Nueva cita
          _buildOptionButton(
            icon: Icons.event_rounded,
            label: 'Nueva Cita',
            subtitle: 'Agendar servicio',
            color: Colors.purple,
            onTap: widget.onCrearCita,
          ),

          const SizedBox(height: 8),

          // Editar cliente
          _buildOptionButton(
            icon: Icons.edit_rounded,
            label: 'Editar Cliente',
            subtitle: 'Modificar información',
            color: Colors.amber,
            onTap: widget.onEditarCliente,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    String? subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = AppTheme.of(context);
    final isDisabled = onTap == null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isDisabled
            ? theme.alternate.withOpacity(0.3)
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDisabled
              ? Colors.grey.withOpacity(0.3)
              : color.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? Colors.grey.withOpacity(0.3)
                        : color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    color: isDisabled ? Colors.grey : color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDisabled ? Colors.grey : theme.primaryText,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color:
                                isDisabled ? Colors.grey : theme.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isDisabled)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: theme.secondaryText,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactOption({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = AppTheme.of(context);
    final isDisabled = onTap == null;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDisabled
            ? theme.alternate.withOpacity(0.3)
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDisabled
              ? Colors.grey.withOpacity(0.3)
              : color.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isDisabled ? Colors.grey : color,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDisabled ? Colors.grey : theme.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchWhatsApp(String phone) async {
    // Limpiar el número de teléfono
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanPhone.startsWith('+')) {
      cleanPhone =
          '+52$cleanPhone'; // Agregar código de país México por defecto
    }

    final message =
        Uri.encodeComponent('Hola, me comunico desde el Taller Alex CRM');
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$message');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchEmail(String email) async {
    final uri = Uri.parse(
        'mailto:$email?subject=${Uri.encodeComponent('Contacto desde Taller Alex CRM')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
