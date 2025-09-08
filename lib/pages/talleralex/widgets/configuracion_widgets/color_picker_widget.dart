import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:nethive_neo/theme/theme.dart';

class ColorPickerWidget extends StatelessWidget {
  final String label;
  final Color currentColor;
  final Function(Color) onColorChanged;
  final String? description;

  const ColorPickerWidget({
    super.key,
    required this.label,
    required this.currentColor,
    required this.onColorChanged,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Muestra de color actual
              GestureDetector(
                onTap: () => _showColorPicker(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: currentColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: currentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Información del color
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${currentColor.value.toRadixString(16).substring(2).toUpperCase()}',
                      style: TextStyle(
                        color: AppTheme.of(context).secondaryText,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: TextStyle(
                          color: AppTheme.of(context).secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Botón de editar
              IconButton(
                onPressed: () => _showColorPicker(context),
                icon: Icon(
                  Icons.edit,
                  color: AppTheme.of(context).primaryColor,
                ),
                tooltip: 'Cambiar color',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    Color tempColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        title: Text(
          'Seleccionar $label',
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color Picker
              BlockPicker(
                pickerColor: currentColor,
                onColorChanged: (color) => tempColor = color,
                availableColors: _getRecommendedColors(),
              ),

              const SizedBox(height: 20),

              // Color Wheel para selección avanzada
              ColorPicker(
                pickerColor: currentColor,
                onColorChanged: (color) => tempColor = color,
                colorPickerWidth: 250,
                pickerAreaHeightPercent: 0.6,
                enableAlpha: false,
                displayThumbColor: true,
                paletteType: PaletteType.hueWheel,
                labelTypes: const [],
                pickerAreaBorderRadius: BorderRadius.circular(8),
              ),

              const SizedBox(height: 20),

              // Preview del color seleccionado
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: tempColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '#${tempColor.value.toRadixString(16).substring(2).toUpperCase()}',
                    style: TextStyle(
                      color: _getContrastColor(tempColor),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: AppTheme.of(context).secondaryText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onColorChanged(tempColor);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  List<Color> _getRecommendedColors() {
    return [
      // Azules
      const Color(0xFF3B82F6), const Color(0xFF1E40AF), const Color(0xFF60A5FA),
      // Púrpuras
      const Color(0xFF8B5CF6), const Color(0xFF7C3AED), const Color(0xFFA78BFA),
      // Verdes
      const Color(0xFF10B981), const Color(0xFF059669), const Color(0xFF34D399),
      // Rojos
      const Color(0xFFEF4444), const Color(0xFFDC2626), const Color(0xFFF87171),
      // Amarillos/Naranjas
      const Color(0xFFF59E0B), const Color(0xFFD97706), const Color(0xFFFBBF24),
      // Grises
      const Color(0xFF6B7280), const Color(0xFF4B5563), const Color(0xFF9CA3AF),
      // Cian/Teal
      const Color(0xFF06B6D4), const Color(0xFF0891B2), const Color(0xFF22D3EE),
      // Rosa
      const Color(0xFFEC4899), const Color(0xFFDB2777), const Color(0xFFF472B6),
      // Índigo
      const Color(0xFF6366F1), const Color(0xFF4F46E5), const Color(0xFF818CF8),
    ];
  }

  Color _getContrastColor(Color backgroundColor) {
    // Calcular luminancia
    final luminance = backgroundColor.computeLuminance();
    // Si la luminancia es mayor a 0.5, usar texto oscuro, sino claro
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
