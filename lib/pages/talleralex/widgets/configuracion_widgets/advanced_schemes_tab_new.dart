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
  late AnimationController _pulseController;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
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
                Colors.black.withOpacity(0.03),
                Colors.transparent,
                Colors.black.withOpacity(0.01),
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSpectacularHeader(context, themeProvider),
                const SizedBox(height: 28),
                _buildAdvancedSearchSection(),
                const SizedBox(height: 28),
                _buildRandomGeneratorHero(themeProvider),
                const SizedBox(height: 28),
                _buildQuickAccessSection(themeProvider),
                const SizedBox(height: 28),
                _buildProfessionalSchemesGrid(context, themeProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpectacularHeader(
      BuildContext context, ThemeConfigProvider provider) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.06),
                  Theme.of(context).colorScheme.tertiary.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        MdiIcons.paletteAdvanced,
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
                            'Esquemas Profesionales',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Paletas curadas por diseñadores expertos • Material Design 3 • +40 esquemas únicos',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildStatsRow(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(context, '40+', 'Esquemas', MdiIcons.palette),
        const SizedBox(width: 12),
        _buildStatCard(context, 'M3', 'Material', MdiIcons.materialDesign),
        const SizedBox(width: 12),
        _buildStatCard(context, '∞', 'Aleatorios', MdiIcons.dice6),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context, String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.magnify,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Búsqueda Inteligente',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) =>
                  setState(() => searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, estilo o color...',
                hintStyle: GoogleFonts.poppins(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 13,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    MdiIcons.magnify,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildAdvancedFilterChip(
                'Material Design 3',
                showMaterialDesign3,
                MdiIcons.materialDesign,
                () =>
                    setState(() => showMaterialDesign3 = !showMaterialDesign3),
              ),
              _buildAdvancedFilterChip(
                'Esquemas Clásicos',
                showClassicSchemes,
                MdiIcons.palette,
                () => setState(() => showClassicSchemes = !showClassicSchemes),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilterChip(
      String label, bool selected, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                )
              : null,
          color: selected ? null : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRandomGeneratorHero(ThemeConfigProvider provider) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.85),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                  Theme.of(context).colorScheme.tertiary.withOpacity(0.75),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        MdiIcons.autorenew,
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
                            'Generador Mágico ✨',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Crea temas únicos con IA avanzada',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildMagicButton(
                        'Aleatorio',
                        MdiIcons.dice6,
                        () => _generateRandomTheme(provider),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMagicButton(
                        'Inspiración',
                        MdiIcons.brain,
                        () => _generateInspiredTheme(provider),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMagicButton(String text, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(ThemeConfigProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              MdiIcons.flash,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Acceso Rápido',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickAccessCard(
                  'Material\nBaseline', FlexScheme.materialBaseline, provider),
              _buildQuickAccessCard(
                  'Flutter\nDash', FlexScheme.flutterDash, provider),
              _buildQuickAccessCard(
                  'Deep\nBlue', FlexScheme.deepBlue, provider),
              _buildQuickAccessCard(
                  'Sakura\nPink', FlexScheme.sakura, provider),
              _buildQuickAccessCard('Green\nMoney', FlexScheme.money, provider),
              _buildQuickAccessCard('Gold\nSunset', FlexScheme.gold, provider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
      String name, FlexScheme scheme, ThemeConfigProvider provider) {
    final colors = FlexColorSchemeHelper.getSchemeColors(
        scheme, provider.previewMode == ThemeMode.dark);
    final isSelected = selectedScheme == scheme;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _applyScheme(scheme, provider),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 90,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors['primary']!,
                          colors['secondary']!,
                        ],
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: colors['surface'],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _getContrastColor(colors['surface']!),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMiniColorDot(colors['primary']!),
                            const SizedBox(width: 2),
                            _buildMiniColorDot(colors['secondary']!),
                            const SizedBox(width: 2),
                            _buildMiniColorDot(colors['tertiary']!),
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
      ),
    );
  }

  Widget _buildProfessionalSchemesGrid(
      BuildContext context, ThemeConfigProvider provider) {
    final filteredSchemes = _getFilteredSchemes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              MdiIcons.viewGrid,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Esquemas Profesionales',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${filteredSchemes.length} esquemas',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: filteredSchemes.length,
          itemBuilder: (context, index) {
            final scheme = filteredSchemes[index];
            return _buildProfessionalSchemeCard(context, scheme, provider);
          },
        ),
      ],
    );
  }

  Widget _buildProfessionalSchemeCard(
      BuildContext context, FlexScheme scheme, ThemeConfigProvider provider) {
    final colors = FlexColorSchemeHelper.getSchemeColors(
        scheme, provider.previewMode == ThemeMode.dark);
    final displayName = FlexColorSchemeHelper.getSchemeDisplayName(scheme);
    final isSelected = selectedScheme == scheme;

    return InkWell(
      onTap: () => _applyScheme(scheme, provider),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.15),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 6 : 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors['primary']!,
                        colors['secondary']!,
                        colors['tertiary']!,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: colors['tertiary']!,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors['surface']!,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  color: colors['surface'],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getContrastColor(colors['surface']!),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildColorDot(colors['primary']!),
                          const SizedBox(width: 4),
                          _buildColorDot(colors['secondary']!),
                          const SizedBox(width: 4),
                          _buildColorDot(colors['tertiary']!),
                          const Spacer(),
                          Icon(
                            MdiIcons.palette,
                            size: 12,
                            color: _getContrastColor(colors['surface']!)
                                .withOpacity(0.5),
                          ),
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

  Widget _buildColorDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniColorDot(Color color) {
    return Container(
      width: 6,
      height: 6,
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

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
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

    _showSuccessSnackBar('¡Tema aleatorio generado! 🎨');
  }

  void _generateInspiredTheme(ThemeConfigProvider provider) {
    final inspirationThemes = [
      {
        'name': 'Sunset Vibes',
        'colors': [
          const Color(0xFFFF6B6B),
          const Color(0xFFFFE66D),
          const Color(0xFF4ECDC4)
        ]
      },
      {
        'name': 'Ocean Breeze',
        'colors': [
          const Color(0xFF1A535C),
          const Color(0xFF4ECDC4),
          const Color(0xFFFFE66D)
        ]
      },
      {
        'name': 'Forest Magic',
        'colors': [
          const Color(0xFF2D5016),
          const Color(0xFF4F772D),
          const Color(0xFF90A955)
        ]
      },
      {
        'name': 'Cosmic Dreams',
        'colors': [
          const Color(0xFF2E1065),
          const Color(0xFF7C3AED),
          const Color(0xFFA855F7)
        ]
      },
      {
        'name': 'Autumn Leaves',
        'colors': [
          const Color(0xFFD2691E),
          const Color(0xFFFF8C00),
          const Color(0xFFFFB347)
        ]
      },
    ];

    final random = math.Random();
    final selectedTheme =
        inspirationThemes[random.nextInt(inspirationThemes.length)];
    final colors = selectedTheme['colors'] as List<Color>;

    final mode = provider.previewMode == ThemeMode.dark ? 'dark' : 'light';

    provider.updateColor(mode, 'primary', colors[0]);
    provider.updateColor(mode, 'secondary', colors[1]);
    provider.updateColor(mode, 'tertiary', colors[2]);
    provider.updateColor(mode, 'accent', colors[2]);

    _showSuccessSnackBar('Tema "${selectedTheme['name']}" aplicado! ✨');
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

    _showSuccessSnackBar(
        'Esquema "${FlexColorSchemeHelper.getSchemeDisplayName(scheme)}" aplicado! 🎯');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(MdiIcons.checkCircle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
