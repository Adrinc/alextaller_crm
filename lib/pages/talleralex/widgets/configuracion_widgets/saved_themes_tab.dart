import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/providers/theme_config_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class SavedThemesTab extends StatelessWidget {
  const SavedThemesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeConfigProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con acciones
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBFDBFE), Color(0xFF93C5FD)],
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
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bookmark,
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
                            'Temas Guardados',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Gestiona y aplica tus configuraciones guardadas',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón para guardar tema actual
                    ElevatedButton.icon(
                      onPressed: () => _showSaveThemeDialog(context, provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Guardar Actual'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Acciones adicionales
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showImportDialog(context, provider),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppTheme.of(context).primaryColor),
                      ),
                      icon: Icon(
                        Icons.upload_file,
                        color: AppTheme.of(context).primaryColor,
                        size: 18,
                      ),
                      label: Text(
                        'Importar Tema',
                        style: TextStyle(
                          color: AppTheme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showExportDialog(context, provider),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppTheme.of(context).primaryColor),
                      ),
                      icon: Icon(
                        Icons.download,
                        color: AppTheme.of(context).primaryColor,
                        size: 18,
                      ),
                      label: Text(
                        'Exportar Actual',
                        style: TextStyle(
                          color: AppTheme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showResetDialog(context, provider),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                      ),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.orange,
                        size: 18,
                      ),
                      label: const Text(
                        'Resetear',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Lista de temas guardados
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.savedThemes.isEmpty
                        ? _buildEmptyState(context)
                        : _buildThemesList(context, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: AppTheme.of(context).secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay temas guardados',
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Guarda tu primer tema personalizado',
            style: TextStyle(
              color: AppTheme.of(context).secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesList(BuildContext context, ThemeConfigProvider provider) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: provider.savedThemes.length,
      itemBuilder: (context, index) {
        final theme = provider.savedThemes[index];
        return _buildThemeCard(context, provider, theme);
      },
    );
  }

  Widget _buildThemeCard(BuildContext context, ThemeConfigProvider provider,
      Map<String, dynamic> theme) {
    final config = theme['config'] as Map<String, dynamic>;

    // Extraer colores de manera compatible con ambas estructuras
    final lightColors = _extractColors(config['light']);
    final darkColors = _extractColors(config['dark']);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Preview de colores
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  // Preview modo claro
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            _getColorFromHex(lightColors['primaryBackground']),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getColorFromHex(lightColors['primary']),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 8, bottom: 8),
                                    decoration: BoxDecoration(
                                      color: _getColorFromHex(
                                          lightColors['secondary']),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 8, bottom: 8),
                                    decoration: BoxDecoration(
                                      color: _getColorFromHex(
                                          lightColors['accent']),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Preview modo oscuro
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            _getColorFromHex(darkColors['primaryBackground']),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getColorFromHex(darkColors['primary']),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 8, bottom: 8),
                                    decoration: BoxDecoration(
                                      color: _getColorFromHex(
                                          darkColors['secondary']),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 8, bottom: 8),
                                    decoration: BoxDecoration(
                                      color: _getColorFromHex(
                                          darkColors['accent']),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Información del tema
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme['name'] ?? 'Sin nombre',
                    style: TextStyle(
                      color: AppTheme.of(context).primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(theme['created_at']),
                    style: TextStyle(
                      color: AppTheme.of(context).secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => provider.loadTheme(theme['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text(
                            'Cargar',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () =>
                            _showDeleteThemeDialog(context, provider, theme),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          padding: const EdgeInsets.all(8),
                        ),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        tooltip: 'Eliminar tema',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 4;
    if (width > 1000) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Color _getColorFromHex(dynamic colorValue) {
    if (colorValue == null) return Colors.grey;
    if (colorValue is String) {
      try {
        return Color(int.parse(colorValue.replaceFirst('#', '0xFF')));
      } catch (e) {
        return Colors.grey;
      }
    }
    return Colors.grey;
  }

  /// Extrae colores de manera compatible con ambas estructuras (nueva y antigua)
  Map<String, dynamic> _extractColors(Map<String, dynamic>? modeConfig) {
    if (modeConfig == null) return {};

    // Verificar si tiene la estructura nueva (con 'colors' anidado)
    if (modeConfig.containsKey('colors')) {
      // Estructura nueva: config['light']['colors']['primary']
      return modeConfig['colors'] as Map<String, dynamic>? ?? {};
    } else {
      // Estructura antigua: config['light']['primary'] directo
      // Mapear los nombres de la estructura antigua a la nueva
      return {
        'primary': modeConfig['primary'] ?? modeConfig['primaryColor'],
        'secondary': modeConfig['secondary'] ?? modeConfig['secondaryColor'],
        'tertiary': modeConfig['tertiary'] ?? modeConfig['tertiaryColor'],
        'accent': modeConfig['primaryContainer'] ?? modeConfig['alternate'],
        'primaryBackground':
            modeConfig['surface'] ?? modeConfig['primaryBackground'],
        'secondaryBackground':
            modeConfig['surfaceContainer'] ?? modeConfig['secondaryBackground'],
        'primaryText': modeConfig['onSurface'] ?? modeConfig['primaryText'],
        'secondaryText':
            modeConfig['onSurfaceVariant'] ?? modeConfig['secondaryText'],
        'error': modeConfig['error'],
      };
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Fecha desconocida';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  void _showSaveThemeDialog(
      BuildContext context, ThemeConfigProvider provider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        title: Text(
          'Guardar Tema',
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              style: TextStyle(color: AppTheme.of(context).primaryText),
              decoration: InputDecoration(
                labelText: 'Nombre del tema',
                labelStyle:
                    TextStyle(color: AppTheme.of(context).secondaryText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppTheme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.of(context).secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final success = await provider.saveTheme(controller.text);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tema guardado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteThemeDialog(BuildContext context,
      ThemeConfigProvider provider, Map<String, dynamic> theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        title: Text(
          'Eliminar Tema',
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Está seguro que desea eliminar el tema "${theme['name']}"?',
          style: TextStyle(color: AppTheme.of(context).secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.of(context).secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await provider.deleteTheme(theme['id']);
              if (context.mounted) {
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tema eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
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

  void _showImportDialog(BuildContext context, ThemeConfigProvider provider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        title: Text(
          'Importar Tema',
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pegue el JSON del tema a importar:',
              style: TextStyle(color: AppTheme.of(context).secondaryText),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 10,
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                hintText:
                    '{\n  "name": "Mi Tema",\n  "light": {...},\n  "dark": {...}\n}',
                hintStyle: TextStyle(color: AppTheme.of(context).secondaryText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.of(context).secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              provider.importTheme(controller.text);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, ThemeConfigProvider provider) {
    final json = provider.exportTheme();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        title: Text(
          'Exportar Tema',
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Copie el siguiente JSON:',
              style: TextStyle(color: AppTheme.of(context).secondaryText),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.maxFinite,
              height: 300,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  json,
                  style: TextStyle(
                    color: AppTheme.of(context).primaryText,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, ThemeConfigProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        title: Text(
          'Resetear Configuración',
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Está seguro que desea resetear la configuración a los valores por defecto?',
          style: TextStyle(color: AppTheme.of(context).secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.of(context).secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetToDefault();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración reseteada'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );
  }
}
