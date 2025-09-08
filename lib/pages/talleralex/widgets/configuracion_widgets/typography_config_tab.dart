import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nethive_neo/providers/theme_config_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class TypographyConfigTab extends StatelessWidget {
  const TypographyConfigTab({super.key});

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
                    _buildTypographyConfig(context, provider, 'light'),
                    _buildTypographyConfig(context, provider, 'dark'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypographyConfig(
      BuildContext context, ThemeConfigProvider provider, String mode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header del modo
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: mode == 'light'
                  ? const LinearGradient(
                      colors: [Color(0xFFE0E7FF), Color(0xFFC7D2FE)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
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
                    color: mode == 'light' ? Colors.indigo : Colors.purple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.text_fields,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipografía ${mode == 'light' ? 'Clara' : 'Oscura'}',
                      style: TextStyle(
                        color:
                            mode == 'light' ? Colors.indigo[800] : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Configure las fuentes para el modo ${mode == 'light' ? 'claro' : 'oscuro'}',
                      style: TextStyle(
                        color: mode == 'light'
                            ? Colors.indigo[600]
                            : Colors.grey[300],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Selector de fuentes
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de familia de fuente
                  Text(
                    'Familia de Fuente',
                    style: TextStyle(
                      color: AppTheme.of(context).primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid de fuentes disponibles
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      childAspectRatio: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: provider.availableFonts.length,
                    itemBuilder: (context, index) {
                      final fontFamily = provider.availableFonts[index];
                      final isSelected = provider.getFont(mode) == fontFamily;

                      return GestureDetector(
                        onTap: () => provider.updateFont(mode, fontFamily),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1)
                                : AppTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.of(context).primaryColor
                                  : AppTheme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                fontFamily,
                                style: _getSafeTextStyle(
                                  fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppTheme.of(context).primaryColor
                                      : AppTheme.of(context).primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Aa Bb Cc 123',
                                style: _getSafeTextStyle(
                                  fontFamily,
                                  fontSize: 14,
                                  color: AppTheme.of(context).secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Preview de la tipografía
                  Text(
                    'Vista Previa',
                    style: TextStyle(
                      color: AppTheme.of(context).primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: mode == 'light'
                          ? provider.getColor(mode, 'primaryBackground')
                          : provider.getColor(mode, 'primaryBackground'),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Títulos
                        Text(
                          'Título Principal (32px)',
                          style: _getSafeTextStyle(
                            provider.getFont(mode),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: provider.getColor(mode, 'primaryText'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Subtítulo Secundario (24px)',
                          style: _getSafeTextStyle(
                            provider.getFont(mode),
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: provider.getColor(mode, 'secondaryText'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Párrafo de texto normal (16px)',
                          style: _getSafeTextStyle(
                            provider.getFont(mode),
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: provider.getColor(mode, 'primaryText'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Este es un ejemplo de cómo se verá el texto con la fuente seleccionada. Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                          style: _getSafeTextStyle(
                            provider.getFont(mode),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: provider.getColor(mode, 'secondaryText'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Botones de ejemplo
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    provider.getColor(mode, 'primary'),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                'Botón Primario',
                                style: _getSafeTextStyle(
                                  provider.getFont(mode),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: provider.getColor(mode, 'primary'),
                                ),
                              ),
                              child: Text(
                                'Botón Secundario',
                                style: _getSafeTextStyle(
                                  provider.getFont(mode),
                                  color: provider.getColor(mode, 'primary'),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 4;
    if (width > 1000) return 3;
    if (width > 600) return 2;
    return 1;
  }

  String _getFontVariantName(String fontFamily) {
    // Convertir nombres de fuentes a nombres válidos para GoogleFonts
    switch (fontFamily) {
      case 'Poppins':
        return 'Poppins';
      case 'Roboto':
        return 'Roboto';
      case 'Inter':
        return 'Inter';
      case 'Montserrat':
        return 'Montserrat';
      case 'Open Sans':
        return 'Open Sans';
      case 'Lato':
        return 'Lato';
      case 'Source Sans Pro':
        return 'Source Sans Pro';
      case 'Nunito':
        return 'Nunito';
      case 'Raleway':
        return 'Raleway';
      case 'Ubuntu':
        return 'Ubuntu';
      default:
        return 'Roboto'; // Fuente por defecto segura
    }
  }

  TextStyle _getSafeTextStyle(
    String fontFamily, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    try {
      return GoogleFonts.getFont(
        _getFontVariantName(fontFamily),
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    } catch (e) {
      // Si falla Google Fonts, usar fuente del sistema
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }
  }
}
