import 'package:flutter/material.dart';
import 'package:nethive_neo/pages/talleralex/widgets/configuracion_widgets/color_picker_widget.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/providers/theme_config_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class ColorConfigTab extends StatelessWidget {
  const ColorConfigTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeConfigProvider>(
      builder: (context, provider, child) {
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // Tab bar para Light/Dark
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                child: TabBar(
                  indicatorColor: AppTheme.of(context).primaryColor,
                  labelColor: AppTheme.of(context).primaryColor,
                  unselectedLabelColor: AppTheme.of(context).secondaryText,
                  indicator: BoxDecoration(
                    color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.light_mode),
                      text: 'Modo Claro',
                    ),
                    Tab(
                      icon: Icon(Icons.dark_mode),
                      text: 'Modo Oscuro',
                    ),
                  ],
                ),
              ),

              // Contenido de los tabs
              Expanded(
                child: TabBarView(
                  children: [
                    _buildColorGrid(context, provider, 'light'),
                    _buildColorGrid(context, provider, 'dark'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorGrid(
      BuildContext context, ThemeConfigProvider provider, String mode) {
    final colorCategories = _getColorCategories();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomScrollView(
        slivers: [
          // Header del modo
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: mode == 'light'
                    ? const LinearGradient(
                        colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF1F2937), Color(0xFF374151)],
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
                      color: mode == 'light' ? Colors.orange : Colors.indigo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      mode == 'light' ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mode == 'light' ? 'Tema Claro' : 'Tema Oscuro',
                        style: TextStyle(
                          color: mode == 'light'
                              ? Colors.orange[800]
                              : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Configure los colores para el modo ${mode == 'light' ? 'claro' : 'oscuro'}',
                        style: TextStyle(
                          color: mode == 'light'
                              ? Colors.orange[600]
                              : Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Grid de categorías de colores
          ...colorCategories
              .map((category) => [
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Icon(
                              category['icon'],
                              color: AppTheme.of(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category['title'],
                              style: TextStyle(
                                color: AppTheme.of(context).primaryText,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppTheme.of(context)
                                    .primaryColor
                                    .withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getCrossAxisCount(context),
                        childAspectRatio: 3.5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final colorInfo = category['colors'][index];
                          return ColorPickerWidget(
                            label: colorInfo['label'],
                            description: colorInfo['description'],
                            currentColor:
                                provider.getColor(mode, colorInfo['key']),
                            onColorChanged: (color) {
                              provider.updateColor(
                                  mode, colorInfo['key'], color);
                            },
                          );
                        },
                        childCount: category['colors'].length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ])
              .expand((x) => x)
              .toList(),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 3;
    if (width > 900) return 2;
    return 1;
  }

  List<Map<String, dynamic>> _getColorCategories() {
    return [
      {
        'title': 'Colores Principales',
        'icon': Icons.palette,
        'colors': [
          {
            'key': 'primary',
            'label': 'Primario',
            'description': 'Color principal de la marca',
          },
          {
            'key': 'secondary',
            'label': 'Secundario',
            'description': 'Color secundario para acentos',
          },
          {
            'key': 'tertiary',
            'label': 'Terciario',
            'description': 'Color terciario complementario',
          },
          {
            'key': 'accent',
            'label': 'Acento',
            'description': 'Color para destacar elementos',
          },
        ],
      },
      {
        'title': 'Fondos',
        'icon': Icons.format_color_fill,
        'colors': [
          {
            'key': 'primaryBackground',
            'label': 'Fondo Principal',
            'description': 'Fondo principal de la aplicación',
          },
          {
            'key': 'secondaryBackground',
            'label': 'Fondo Secundario',
            'description': 'Fondo de tarjetas y paneles',
          },
        ],
      },
      {
        'title': 'Textos',
        'icon': Icons.text_fields,
        'colors': [
          {
            'key': 'primaryText',
            'label': 'Texto Principal',
            'description': 'Color principal del texto',
          },
          {
            'key': 'secondaryText',
            'label': 'Texto Secundario',
            'description': 'Color para texto secundario',
          },
        ],
      },
      {
        'title': 'Estados',
        'icon': Icons.traffic,
        'colors': [
          {
            'key': 'success',
            'label': 'Éxito',
            'description': 'Color para estados exitosos',
          },
          {
            'key': 'warning',
            'label': 'Advertencia',
            'description': 'Color para advertencias',
          },
          {
            'key': 'error',
            'label': 'Error',
            'description': 'Color para errores',
          },
          {
            'key': 'info',
            'label': 'Información',
            'description': 'Color para información',
          },
        ],
      },
    ];
  }
}
