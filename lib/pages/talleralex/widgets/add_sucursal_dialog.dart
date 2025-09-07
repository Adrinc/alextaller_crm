import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nethive_neo/providers/talleralex/sucursales_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class AddSucursalDialog extends StatefulWidget {
  final SucursalesProvider provider;

  const AddSucursalDialog({
    super.key,
    required this.provider,
  });

  @override
  State<AddSucursalDialog> createState() => _AddSucursalDialogState();
}

class _AddSucursalDialogState extends State<AddSucursalDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _capacidadBahiasController = TextEditingController(text: '1');

  bool _isLoading = false;
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
    // Escuchar cambios del provider
    widget.provider.addListener(_onProviderChanged);
  }

  void _onProviderChanged() {
    if (mounted) {
      setState(() {
        // Forzar rebuild cuando cambie el provider
      });
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
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Pequeño delay para asegurar que el widget esté completamente montado
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
    widget.provider.removeListener(_onProviderChanged);
    _scaleController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _capacidadBahiasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAnimationInitialized) {
      return const SizedBox.shrink();
    }

    // Detectar el tamaño de pantalla
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 768 && screenSize.width <= 1024;

    // Ajustar dimensiones según el tipo de pantalla
    final maxWidth = isDesktop ? 900.0 : (isTablet ? 750.0 : 650.0);
    final maxHeight = isDesktop ? 700.0 : 750.0;

    // Ajustar el padding del header según la pantalla
    final headerPadding = isDesktop
        ? const EdgeInsets.symmetric(vertical: 20, horizontal: 30)
        : const EdgeInsets.all(25);

    // Ajustar el tamaño del icono
    final iconSize = isDesktop ? 35.0 : 40.0;
    final titleSize = isDesktop ? 24.0 : 28.0;
    final subtitleSize = isDesktop ? 14.0 : 16.0;

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
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
                child: Card(
                  color: AppTheme.of(context).primaryBackground,
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: isDesktop
                      ? _buildDesktopLayout(
                          headerPadding, iconSize, titleSize, subtitleSize)
                      : _buildMobileLayout(
                          headerPadding, iconSize, titleSize, subtitleSize),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(EdgeInsets headerPadding, double iconSize,
      double titleSize, double subtitleSize) {
    return Row(
      children: [
        // Header lateral compacto para desktop
        Container(
          width: 280,
          decoration: BoxDecoration(
            gradient: AppTheme.of(context).primaryGradient,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_business,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Nueva Sucursal',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Agrega una nueva sucursal al sistema',
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Contenido principal del formulario
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCompactFormField(
                            controller: _nombreController,
                            label: 'Nombre de la Sucursal',
                            hint: 'Ej: Sucursal Centro',
                            icon: Icons.business,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es requerido';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactFormField(
                                  controller: _telefonoController,
                                  label: 'Teléfono',
                                  hint: 'Ej: +52 123 456 7890',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildCompactFormField(
                                  controller: _capacidadBahiasController,
                                  label: 'Capacidad Bahías',
                                  hint: 'Número de bahías',
                                  icon: Icons.garage,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'La capacidad es requerida';
                                    }
                                    final capacidad = int.tryParse(value);
                                    if (capacidad == null || capacidad <= 0) {
                                      return 'Debe ser un número válido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          _buildCompactFormField(
                            controller: _emailController,
                            label: 'Email de Contacto',
                            hint: 'contacto@sucursal.com',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Email inválido';
                                }
                              }
                              return null;
                            },
                          ),
                          _buildCompactFormField(
                            controller: _direccionController,
                            label: 'Dirección',
                            hint: 'Dirección completa de la sucursal',
                            icon: Icons.location_on,
                            maxLines: 2,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La dirección es requerida';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactFormField(
                                  controller: _latitudController,
                                  label: 'Latitud',
                                  hint: 'Ej: 19.432608',
                                  icon: Icons.gps_fixed,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final lat = double.tryParse(value);
                                      if (lat == null ||
                                          lat < -90 ||
                                          lat > 90) {
                                        return 'Latitud inválida (-90 a 90)';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildCompactFormField(
                                  controller: _longitudController,
                                  label: 'Longitud',
                                  hint: 'Ej: -99.133208',
                                  icon: Icons.gps_fixed,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final lng = double.tryParse(value);
                                      if (lng == null ||
                                          lng < -180 ||
                                          lng > 180) {
                                        return 'Longitud inválida (-180 a 180)';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildEnhancedFileButton(
                            label: 'Imagen de la Sucursal',
                            subtitle: 'Selecciona una imagen (opcional)',
                            icon: Icons.image,
                            fileName: widget.provider.imagenFileName,
                            file: widget.provider.imagenToUpload,
                            onPressed: () => widget.provider.selectImagen(),
                            gradient: AppTheme.of(context).primaryGradient,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                              color: AppTheme.of(context).primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: AppTheme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _crearSucursal,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppTheme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Crear Sucursal',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(EdgeInsets headerPadding, double iconSize,
      double titleSize, double subtitleSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header para móvil
        SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppTheme.of(context).primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: headerPadding,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_business,
                    size: iconSize,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nueva Sucursal',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Agrega una nueva sucursal',
                        style: TextStyle(
                          fontSize: subtitleSize,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Contenido del formulario para móvil
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildCompactFormField(
                            controller: _nombreController,
                            label: 'Nombre de la Sucursal',
                            hint: 'Ej: Sucursal Centro',
                            icon: Icons.business,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es requerido';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactFormField(
                                  controller: _telefonoController,
                                  label: 'Teléfono',
                                  hint: '+52 123 456 7890',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCompactFormField(
                                  controller: _capacidadBahiasController,
                                  label: 'Bahías',
                                  hint: 'Núm.',
                                  icon: Icons.garage,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Requerido';
                                    }
                                    final capacidad = int.tryParse(value);
                                    if (capacidad == null || capacidad <= 0) {
                                      return 'Número válido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          _buildCompactFormField(
                            controller: _emailController,
                            label: 'Email de Contacto',
                            hint: 'contacto@sucursal.com',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Email inválido';
                                }
                              }
                              return null;
                            },
                          ),
                          _buildCompactFormField(
                            controller: _direccionController,
                            label: 'Dirección',
                            hint: 'Dirección completa',
                            icon: Icons.location_on,
                            maxLines: 2,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La dirección es requerida';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactFormField(
                                  controller: _latitudController,
                                  label: 'Latitud',
                                  hint: '19.432608',
                                  icon: Icons.gps_fixed,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final lat = double.tryParse(value);
                                      if (lat == null ||
                                          lat < -90 ||
                                          lat > 90) {
                                        return 'Latitud inválida';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCompactFormField(
                                  controller: _longitudController,
                                  label: 'Longitud',
                                  hint: '-99.133208',
                                  icon: Icons.gps_fixed,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final lng = double.tryParse(value);
                                      if (lng == null ||
                                          lng < -180 ||
                                          lng > 180) {
                                        return 'Longitud inválida';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildEnhancedFileButton(
                            label: 'Imagen Sucursal',
                            subtitle: 'Selecciona imagen (opcional)',
                            icon: Icons.image,
                            fileName: widget.provider.imagenFileName,
                            file: widget.provider.imagenToUpload,
                            onPressed: () => widget.provider.selectImagen(),
                            gradient: AppTheme.of(context).primaryGradient,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                              color: AppTheme.of(context).primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: AppTheme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _crearSucursal,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppTheme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Crear',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.of(context).primaryText,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: AppTheme.of(context).primaryColor,
            size: 20,
          ),
          labelStyle: TextStyle(
            color: AppTheme.of(context).secondaryText,
            fontSize: 13,
          ),
          hintStyle: TextStyle(
            color: AppTheme.of(context).secondaryText.withOpacity(0.7),
            fontSize: 13,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: AppTheme.of(context).primaryColor.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: AppTheme.of(context).primaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: AppTheme.of(context).primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.of(context).error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.of(context).error, width: 2),
          ),
          filled: true,
          fillColor: AppTheme.of(context).secondaryBackground,
        ),
      ),
    );
  }

  Widget _buildEnhancedFileButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required String? fileName,
    required dynamic file,
    required VoidCallback onPressed,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppTheme.of(context).secondaryBackground,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
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
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.of(context).primaryText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fileName ?? subtitle,
                        style: TextStyle(
                          color: fileName != null
                              ? AppTheme.of(context).primaryColor
                              : AppTheme.of(context).secondaryText,
                          fontSize: 12,
                          fontWeight: fileName != null
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  fileName != null ? Icons.check_circle : Icons.upload,
                  color: fileName != null
                      ? AppTheme.of(context).success
                      : AppTheme.of(context).secondaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _crearSucursal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final datos = <String, dynamic>{
        'nombre': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim().isEmpty
            ? null
            : _telefonoController.text.trim(),
        'email_contacto': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'capacidad_bahias': int.parse(_capacidadBahiasController.text.trim()),
      };

      // Agregar coordenadas si están disponibles
      if (_latitudController.text.trim().isNotEmpty) {
        datos['lat'] = double.parse(_latitudController.text.trim());
      }
      if (_longitudController.text.trim().isNotEmpty) {
        datos['lng'] = double.parse(_longitudController.text.trim());
      }

      // Subir imagen si está disponible
      if (widget.provider.imagenToUpload != null) {
        final imagenUrl = await widget.provider.uploadImagen();
        if (imagenUrl != null) {
          datos['imagen_url'] = imagenUrl;
        }
      }

      final success = await widget.provider.crearSucursal(datos);

      if (mounted) {
        if (success) {
          // Limpiar datos del formulario
          widget.provider.resetFormData();

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Sucursal "${_nombreController.text}" creada exitosamente',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppTheme.of(context).success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.provider.error ?? 'Error al crear la sucursal',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppTheme.of(context).error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error inesperado: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.of(context).error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
