import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/inventario_global_provider.dart';

class RedistribucionDialog extends StatefulWidget {
  final String refaccionId;
  final String nombreRefaccion;
  final String sucursalOrigenId;
  final String sucursalOrigenNombre;
  final int stockDisponible;

  const RedistribucionDialog({
    Key? key,
    required this.refaccionId,
    required this.nombreRefaccion,
    required this.sucursalOrigenId,
    required this.sucursalOrigenNombre,
    required this.stockDisponible,
  }) : super(key: key);

  @override
  State<RedistribucionDialog> createState() => _RedistribucionDialogState();
}

class _RedistribucionDialogState extends State<RedistribucionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController();
  final _motivoController = TextEditingController();

  String? _sucursalDestinoId;
  bool _isProcessing = false;

  @override
  void dispose() {
    _cantidadController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isSmallScreen ? screenWidth * 0.95 : 500,
        constraints: BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),
            _buildForm(theme),
            const SizedBox(height: 24),
            _buildActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.swap_horiz,
            color: theme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Redistribuir Refacción',
                style: theme.title3.override(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.nombreRefaccion,
                style: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  color: theme.secondaryText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildForm(AppTheme theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de origen
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Origen',
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.store, size: 16, color: theme.secondaryText),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.sucursalOrigenNombre,
                        style: theme.bodyText1.override(fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.inventory, size: 16, color: theme.secondaryText),
                    const SizedBox(width: 8),
                    Text(
                      'Stock disponible: ${widget.stockDisponible}',
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Selector de sucursal destino
          Consumer<InventarioGlobalProvider>(
            builder: (context, provider, child) {
              final sucursalesDisponibles = provider
                  .getSucursalesParaRedistribucion(widget.refaccionId)
                  .where((s) => s['sucursal_id'] != widget.sucursalOrigenId)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sucursal Destino',
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _sucursalDestinoId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.primaryColor),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintText: 'Seleccionar sucursal destino',
                    ),
                    items: sucursalesDisponibles.map((sucursal) {
                      return DropdownMenuItem<String>(
                        value: sucursal['sucursal_id']?.toString(),
                        child: Text(
                          sucursal['sucursal_nombre']?.toString() ?? '',
                          style:
                              theme.bodyText1.override(fontFamily: 'Poppins'),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _sucursalDestinoId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona una sucursal destino';
                      }
                      return null;
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Campo de cantidad
          Text(
            'Cantidad a Redistribuir',
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _cantidadController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: 'Ingresa la cantidad',
              suffixText: 'unidades',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa una cantidad';
              }
              final cantidad = int.tryParse(value);
              if (cantidad == null || cantidad <= 0) {
                return 'La cantidad debe ser mayor a 0';
              }
              if (cantidad > widget.stockDisponible) {
                return 'La cantidad no puede ser mayor al stock disponible';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Campo de motivo
          Text(
            'Motivo de Redistribución',
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _motivoController,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: 'Describe el motivo de la redistribución...',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa un motivo';
              }
              if (value.trim().length < 10) {
                return 'El motivo debe tener al menos 10 caracteres';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActions(AppTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isProcessing ? null : _procesarRedistribucion,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isProcessing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Redistribuir',
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _procesarRedistribucion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final provider =
          Provider.of<InventarioGlobalProvider>(context, listen: false);

      final result = await provider.redistribuirRefaccion(
        refaccionOrigenId: widget.refaccionId,
        sucursalDestinoId: _sucursalDestinoId!,
        cantidad: int.parse(_cantidadController.text),
        usuarioId: 'current-user-id', // TODO: Obtener del contexto de sesión
        motivo: _motivoController.text.trim(),
      );

      if (result != null) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Redistribución realizada exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Error en la redistribución'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
