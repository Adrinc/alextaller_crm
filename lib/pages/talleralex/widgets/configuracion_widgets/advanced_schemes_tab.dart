import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:math' as math;

import '../../../../../helpers/flex_color_scheme_helper.dart';
import '../../../../../providers/theme_config_provider.dart';

class AdvancedSchemesTab extends StatefulWidget {
  const AdvancedSchemesTab({super.key});

  @override
  State<AdvancedSchemesTab> createState() => _AdvancedSchemesTabState();
}

class _AdvancedSchemesTabState extends State<AdvancedSchemesTab>
    with TickerProviderStateMixin {
  FlexScheme? selectedScheme;
  bool showMaterialDesign3 = true;
  bool showClassicSchemes = true;
  String searchQuery = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeConfigProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.8),
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildSearchSection(),
                const SizedBox(height: 24),
                _buildGeneratorSection(themeProvider),
                const SizedBox(height: 24),
                _buildSchemesGrid(context, themeProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                MdiIcons.paletteAdvanced,
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
                    'Esquemas Avanzados',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Más de 40 paletas profesionales + IA',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Column(
      children: [
        TextField(
          onChanged: (value) =>
              setState(() => searchQuery = value.toLowerCase()),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Buscar esquemas...',
            hintStyle: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            prefixIcon: Icon(Icons.search,
                color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilterChip(
                label: Text(
                  'Material Design 3',
                  style: TextStyle(
                    color: showMaterialDesign3
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                selected: showMaterialDesign3,
                onSelected: (value) =>
                    setState(() => showMaterialDesign3 = value),
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surface,
                avatar: Icon(
                  MdiIcons.materialDesign,
                  size: 18,
                  color: showMaterialDesign3
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilterChip(
                label: Text(
                  'Esquemas Clásicos',
                  style: TextStyle(
                    color: showClassicSchemes
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                selected: showClassicSchemes,
                onSelected: (value) =>
                    setState(() => showClassicSchemes = value),
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surface,
                avatar: Icon(
                  MdiIcons.palette,
                  size: 18,
                  color: showClassicSchemes
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGeneratorSection(ThemeConfigProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.9),
            Theme.of(context).colorScheme.secondary.withOpacity(0.8),
            Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  MdiIcons.autorenew,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generador Mágico ✨',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Genera temas únicos al instante',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGeneratorButton(
                  'Aleatorio 🎲',
                  'Tema completamente random',
                  () => _generateRandomTheme(provider),
                  Colors.white.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGeneratorButton(
                  'Inspiración 🧠',
                  'Basado en tendencias',
                  () => _generateInspiredTheme(provider),
                  Colors.white.withOpacity(0.15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratorButton(String title, String subtitle,
      VoidCallback onPressed, Color backgroundColor) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchemesGrid(BuildContext context, ThemeConfigProvider provider) {
    final filteredSchemes = _getFilteredSchemes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Esquemas Profesionales',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: filteredSchemes.length,
          itemBuilder: (context, index) {
            final scheme = filteredSchemes[index];
            return _buildCompactSchemeCard(context, scheme, provider);
          },
        ),
      ],
    );
  }

  Widget _buildCompactSchemeCard(
      BuildContext context, FlexScheme scheme, ThemeConfigProvider provider) {
    final colors = FlexColorSchemeHelper.getSchemeColors(
        scheme, provider.previewMode == ThemeMode.dark);
    final displayName = FlexColorSchemeHelper.getSchemeDisplayName(scheme);
    final isSelected = selectedScheme == scheme;

    return GestureDetector(
      onTap: () => _applyScheme(scheme, provider),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              // Preview de colores (más compacto)
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors['primary']!,
                        colors['secondary']!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Círculo decorativo pequeño
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors['tertiary']!,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Icono de selección
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.2),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Información del esquema (más compacta)
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(6),
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _buildColorDot(colors['primary']!, 8),
                          const SizedBox(width: 2),
                          _buildColorDot(colors['secondary']!, 8),
                          const SizedBox(width: 2),
                          _buildColorDot(colors['tertiary']!, 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 0.5,
        ),
      ),
    );
  }

  List<FlexScheme> _getFilteredSchemes() {
    var schemes = FlexColorSchemeHelper.availableSchemes;

    if (searchQuery.isNotEmpty) {
      schemes = schemes.where((scheme) {
        final displayName =
            FlexColorSchemeHelper.getSchemeDisplayName(scheme).toLowerCase();
        return displayName.contains(searchQuery);
      }).toList();
    }

    return schemes;
  }

  void _generateRandomTheme(ThemeConfigProvider provider) {
    final randomTheme = FlexColorSchemeHelper.generateRandomTheme(
      isDark: provider.previewMode == ThemeMode.dark,
    );

    final mode = provider.previewMode == ThemeMode.dark ? 'dark' : 'light';

    provider.updateColor(mode, 'primary', randomTheme.colorScheme.primary);
    provider.updateColor(mode, 'secondary', randomTheme.colorScheme.secondary);
    provider.updateColor(mode, 'tertiary', randomTheme.colorScheme.tertiary);
    provider.updateColor(mode, 'accent', randomTheme.colorScheme.tertiary);
    provider.updateColor(
        mode, 'primaryBackground', randomTheme.colorScheme.surface);
    provider.updateColor(
        mode, 'secondaryBackground', randomTheme.colorScheme.surface);
    provider.updateColor(mode, 'error', randomTheme.colorScheme.error);

    _showFeedback('🎲 Tema aleatorio generado! Vista previa actualizada');
  }

  void _generateInspiredTheme(ThemeConfigProvider provider) {
    // Seleccionar un esquema "trending" (los primeros 10 son más modernos)
    final trendingSchemes =
        FlexColorSchemeHelper.availableSchemes.take(10).toList();
    final selectedScheme =
        trendingSchemes[math.Random().nextInt(trendingSchemes.length)];

    final newTheme = FlexColorSchemeHelper.createThemeFromScheme(
      scheme: selectedScheme,
      isDark: provider.previewMode == ThemeMode.dark,
    );

    final mode = provider.previewMode == ThemeMode.dark ? 'dark' : 'light';

    provider.updateColor(mode, 'primary', newTheme.colorScheme.primary);
    provider.updateColor(mode, 'secondary', newTheme.colorScheme.secondary);
    provider.updateColor(mode, 'tertiary', newTheme.colorScheme.tertiary);
    provider.updateColor(mode, 'accent', newTheme.colorScheme.tertiary);
    provider.updateColor(
        mode, 'primaryBackground', newTheme.colorScheme.surface);
    provider.updateColor(
        mode, 'secondaryBackground', newTheme.colorScheme.surface);
    provider.updateColor(mode, 'error', newTheme.colorScheme.error);

    _showFeedback(
        '🧠 Tema inspirado en "${FlexColorSchemeHelper.getSchemeDisplayName(selectedScheme)}" aplicado!');
  }

  void _applyScheme(FlexScheme scheme, ThemeConfigProvider provider) {
    setState(() => selectedScheme = scheme);

    final newTheme = FlexColorSchemeHelper.createThemeFromScheme(
      scheme: scheme,
      isDark: provider.previewMode == ThemeMode.dark,
    );

    final mode = provider.previewMode == ThemeMode.dark ? 'dark' : 'light';

    provider.updateColor(mode, 'primary', newTheme.colorScheme.primary);
    provider.updateColor(mode, 'secondary', newTheme.colorScheme.secondary);
    provider.updateColor(mode, 'tertiary', newTheme.colorScheme.tertiary);
    provider.updateColor(mode, 'accent', newTheme.colorScheme.tertiary);
    provider.updateColor(
        mode, 'primaryBackground', newTheme.colorScheme.surface);
    provider.updateColor(
        mode, 'secondaryBackground', newTheme.colorScheme.surface);
    provider.updateColor(mode, 'error', newTheme.colorScheme.error);

    _showFeedback(
        '✨ "${FlexColorSchemeHelper.getSchemeDisplayName(scheme)}" aplicado! Revisa la vista previa');
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(MdiIcons.checkCircle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Ver Preview',
          textColor: Colors.white,
          onPressed: () {
            // Aquí podrías agregar lógica para mostrar/enfocar la vista previa
          },
        ),
      ),
    );
  }
}
