import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/providers/theme_config_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class LogoConfigTab extends StatelessWidget {
  const LogoConfigTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeConfigProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDDD6FE), Color(0xFFE879F9)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuración de Logos',
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Configure los logos para cada modo del tema',
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Row(
                  children: [
                    // Logo modo claro
                    Expanded(
                      child: _buildLogoCard(
                        context,
                        provider,
                        'light',
                        'Logo Modo Claro',
                        'Logo que se mostrará en el tema claro',
                        Icons.light_mode,
                        Colors.orange,
                        const Color(0xFFFEF3C7),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Logo modo oscuro
                    Expanded(
                      child: _buildLogoCard(
                        context,
                        provider,
                        'dark',
                        'Logo Modo Oscuro',
                        'Logo que se mostrará en el tema oscuro',
                        Icons.dark_mode,
                        Colors.indigo,
                        const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),

              // Recomendaciones
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recomendaciones',
                          style: TextStyle(
                            color: AppTheme.of(context).primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Tamaño recomendado: 512x512 píxeles o mayor\n'
                      '• Formato: PNG con fondo transparente\n'
                      '• Peso máximo: 2MB por logo\n'
                      '• Use colores que contrasten bien con cada modo\n'
                      '• Para modo claro: logos con colores oscuros\n'
                      '• Para modo oscuro: logos con colores claros',
                      style: TextStyle(
                        color: AppTheme.of(context).secondaryText,
                        fontSize: 14,
                        height: 1.5,
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

  Widget _buildLogoCard(
    BuildContext context,
    ThemeConfigProvider provider,
    String mode,
    String title,
    String description,
    IconData icon,
    Color accentColor,
    Color backgroundColor,
  ) {
    final hasLogo = (mode == 'light' && provider.lightLogoUrl != null) ||
        (mode == 'dark' && provider.darkLogoUrl != null);
    final hasNewLogo = (mode == 'light' && provider.lightLogoBytes != null) ||
        (mode == 'dark' && provider.darkLogoBytes != null);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        color: AppTheme.of(context).secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Preview del logo
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accentColor.withOpacity(0.3),
                ),
              ),
              child: Stack(
                children: [
                  // Fondo con patrón de transparencia
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: TransparencyPatternPainter(),
                    ),
                  ),

                  // Contenido del preview
                  Center(
                    child:
                        _buildLogoPreview(context, provider, mode, accentColor),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => provider.selectLogo(mode),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.upload, size: 18),
                  label: Text(
                    hasLogo || hasNewLogo ? 'Cambiar' : 'Subir',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (hasLogo || hasNewLogo) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showDeleteDialog(context, provider, mode),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                  ),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  tooltip: 'Eliminar logo',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPreview(
    BuildContext context,
    ThemeConfigProvider provider,
    String mode,
    Color accentColor,
  ) {
    final hasNewLogo = (mode == 'light' && provider.lightLogoBytes != null) ||
        (mode == 'dark' && provider.darkLogoBytes != null);
    final hasExistingLogo =
        (mode == 'light' && provider.lightLogoUrl != null) ||
            (mode == 'dark' && provider.darkLogoUrl != null);

    if (hasNewLogo) {
      // Mostrar logo nuevo seleccionado
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Image.memory(
                mode == 'light'
                    ? provider.lightLogoBytes!
                    : provider.darkLogoBytes!,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Nuevo logo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else if (hasExistingLogo) {
      // Mostrar logo existente
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Image.network(
                mode == 'light'
                    ? provider.lightLogoUrl!
                    : provider.darkLogoUrl!,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.broken_image,
                    size: 48,
                    color: AppTheme.of(context).secondaryText,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Logo actual',
              style: TextStyle(
                color: accentColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else {
      // Sin logo
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: AppTheme.of(context).secondaryText,
          ),
          const SizedBox(height: 8),
          Text(
            'Sin logo',
            style: TextStyle(
              color: AppTheme.of(context).secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      );
    }
  }

  void _showDeleteDialog(
      BuildContext context, ThemeConfigProvider provider, String mode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        title: Text(
          'Eliminar Logo',
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Está seguro que desea eliminar el logo del modo ${mode == 'light' ? 'claro' : 'oscuro'}?',
          style: TextStyle(
            color: AppTheme.of(context).secondaryText,
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
              // Implementar eliminación del logo
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class TransparencyPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tileSize = 8.0;
    final paint = Paint()..color = Colors.grey[300]!;

    for (double x = 0; x < size.width; x += tileSize * 2) {
      for (double y = 0; y < size.height; y += tileSize * 2) {
        // Patrón de cuadrícula alternante
        canvas.drawRect(Rect.fromLTWH(x, y, tileSize, tileSize), paint);
        canvas.drawRect(
            Rect.fromLTWH(x + tileSize, y + tileSize, tileSize, tileSize),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
