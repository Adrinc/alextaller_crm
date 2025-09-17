import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/promociones_globales_provider.dart';
import 'package:nethive_neo/models/talleralex/promociones_models.dart';

class CrearPromocionModal extends StatefulWidget {
  const CrearPromocionModal({super.key});

  @override
  State<CrearPromocionModal> createState() => _CrearPromocionModalState();
}

class _CrearPromocionModalState extends State<CrearPromocionModal> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _descuentoController = TextEditingController();
  
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  TipoDescuento _tipoDescuento = TipoDescuento.porcentaje;
  bool _aplicaATodos = true;
  bool _isCreating = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _descuentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isSmallScreen ? screenWidth * 0.95 : 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 20),
              blurRadius: 40,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            _buildContent(theme, isSmallScreen),
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.campaign_rounded,
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
                  'Nueva Promoción',
                  style: theme.title3.override(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Crea una promoción para todas las sucursales',
                  style: theme.bodyText2.override(
                    fontFamily: 'Poppins',
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppTheme theme, bool isSmallScreen) {
    return Flexible(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre de la promoción
              _buildFormField(
                theme: theme,
                label: 'Nombre de la Promoción',
                controller: _nombreController,
                hint: 'Ej: Descuento de Verano 2024',
                icon: Icons.title_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  if (value.length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Descripción
              _buildFormField(
                theme: theme,
                label: 'Descripción',
                controller: _descripcionController,
                hint: 'Describe los beneficios de esta promoción',
                icon: Icons.description_rounded,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción es requerida';
                  }
                  if (value.length < 10) {
                    return 'La descripción debe ser más descriptiva';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Tipo y valor de descuento
              Row(
                children: [
                  // Tipo de descuento
                  Expanded(
                    child: _buildDropdownField(
                      theme: theme,
                      label: 'Tipo de Descuento',
                      value: _tipoDescuento,
                      items: TipoDescuento.values.map((tipo) {
                        return DropdownMenuItem<TipoDescuento>(
                          value: tipo,
                          child: Text(tipo.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _tipoDescuento = value!;
                        });
                      },
                      icon: Icons.percent_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Valor del descuento
                  Expanded(
                    child: _buildFormField(
                      theme: theme,
                      label: _tipoDescuento == TipoDescuento.porcentaje ? 'Porcentaje (%)' : 'Monto (\$)',
                      controller: _descuentoController,
                      hint: _tipoDescuento == TipoDescuento.porcentaje ? 'Ej: 15' : 'Ej: 100',
                      icon: _tipoDescuento == TipoDescuento.porcentaje ? Icons.percent_rounded : Icons.attach_money_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El descuento es requerido';
                        }
                        final numValue = double.tryParse(value);
                        if (numValue == null || numValue <= 0) {
                          return 'Ingresa un valor válido';
                        }
                        if (_tipoDescuento == TipoDescuento.porcentaje && numValue > 100) {
                          return 'El porcentaje no puede ser mayor a 100%';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Fechas
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      theme: theme,
                      label: 'Fecha de Inicio',
                      selectedDate: _fechaInicio,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _fechaInicio = date;
                            // Si no hay fecha fin o es anterior a la nueva fecha inicio
                            if (_fechaFin == null || _fechaFin!.isBefore(date)) {
                              _fechaFin = date.add(const Duration(days: 30));
                            }
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      theme: theme,
                      label: 'Fecha de Fin',
                      selectedDate: _fechaFin,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _fechaInicio?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1)),
                          firstDate: _fechaInicio ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _fechaFin = date;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Switch para aplicar a todos
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.store_rounded,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aplicar a todas las sucursales',
                            style: theme.bodyText1.override(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'La promoción estará disponible automáticamente',
                            style: theme.bodyText2.override(
                              fontFamily: 'Poppins',
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _aplicaATodos,
                      onChanged: (value) {
                        setState(() {
                          _aplicaATodos = value;
                        });
                      },
                      activeColor: theme.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.primaryBackground.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: theme.alternate.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isCreating ? null : () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.alternate.withOpacity(0.2),
                foregroundColor: theme.secondaryText,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isCreating ? null : _crearPromocion,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isCreating 
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                _isCreating ? 'Creando...' : 'Crear Promoción',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required AppTheme theme,
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int? maxLines,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.bodyText1.override(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines ?? 1,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: theme.primaryColor),
            filled: true,
            fillColor: theme.primaryBackground.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.alternate.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.alternate.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required AppTheme theme,
    required String label,
    required TipoDescuento value,
    required List<DropdownMenuItem<TipoDescuento>> items,
    required void Function(TipoDescuento?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.bodyText1.override(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TipoDescuento>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: theme.primaryColor),
            filled: true,
            fillColor: theme.primaryBackground.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.alternate.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.alternate.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required AppTheme theme,
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.bodyText1.override(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.primaryBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.alternate.withOpacity(0.3),
              ),
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
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}'
                        : 'Seleccionar fecha',
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      color: selectedDate != null ? theme.primaryText : theme.secondaryText,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: theme.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _crearPromocion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaInicio == null || _fechaFin == null) {
      _showMessage('Por favor selecciona las fechas de inicio y fin', isError: true);
      return;
    }

    if (_fechaFin!.isBefore(_fechaInicio!)) {
      _showMessage('La fecha de fin debe ser posterior a la fecha de inicio', isError: true);
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final provider = Provider.of<PromocionesGlobalesProvider>(context, listen: false);
      
      final promocionId = await provider.upsertPromocion(
        titulo: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        tipoDescuento: _tipoDescuento,
        valorDescuento: double.parse(_descuentoController.text.trim()),
        fechaInicio: _fechaInicio!,
        fechaFin: _fechaFin!,
        activo: true,
      );

      if (promocionId != null) {
        // Si aplicaATodos está activado, publicar en todas las sucursales
        if (_aplicaATodos) {
          await provider.publicarPromocionEnSucursales(
            promocionId: promocionId,
            todasLasSucursales: true,
          );
        }

        if (mounted) {
          Navigator.pop(context);
          _showMessage('Promoción creada exitosamente', isError: false);
        }
      } else {
        _showMessage(provider.error ?? 'Error al crear la promoción', isError: true);
      }
    } catch (e) {
      _showMessage('Error inesperado: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;
    
    final theme = AppTheme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? theme.error : theme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}