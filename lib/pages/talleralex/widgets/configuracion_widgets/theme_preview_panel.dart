import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nethive_neo/providers/theme_config_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class ThemePreviewPanel extends StatelessWidget {
  const ThemePreviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeConfigProvider>(
      builder: (context, provider, child) {
        return Container(
          width: 400,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.of(context).primaryColor.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header del preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.of(context).primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.preview,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Vista Previa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Toggle para preview activo
                    Switch(
                      value: provider.isPreviewActive,
                      onChanged: (value) => provider.togglePreview(),
                      activeColor: Colors.white,
                      activeTrackColor: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),

              // Selector de modo
              if (provider.isPreviewActive) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => provider.setPreviewMode(ThemeMode.light),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: provider.previewMode == ThemeMode.light
                                  ? AppTheme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: provider.previewMode == ThemeMode.light
                                    ? AppTheme.of(context).primaryColor
                                    : AppTheme.of(context)
                                        .primaryColor
                                        .withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.light_mode,
                                  color: provider.previewMode == ThemeMode.light
                                      ? AppTheme.of(context).primaryColor
                                      : AppTheme.of(context).secondaryText,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Claro',
                                  style: TextStyle(
                                    color: provider.previewMode ==
                                            ThemeMode.light
                                        ? AppTheme.of(context).primaryColor
                                        : AppTheme.of(context).secondaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => provider.setPreviewMode(ThemeMode.dark),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: provider.previewMode == ThemeMode.dark
                                  ? AppTheme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: provider.previewMode == ThemeMode.dark
                                    ? AppTheme.of(context).primaryColor
                                    : AppTheme.of(context)
                                        .primaryColor
                                        .withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.dark_mode,
                                  color: provider.previewMode == ThemeMode.dark
                                      ? AppTheme.of(context).primaryColor
                                      : AppTheme.of(context).secondaryText,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Oscuro',
                                  style: TextStyle(
                                    color: provider.previewMode ==
                                            ThemeMode.dark
                                        ? AppTheme.of(context).primaryColor
                                        : AppTheme.of(context).secondaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Preview del tema
                Expanded(
                  child: _buildPreviewContent(context, provider),
                ),
              ] else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.visibility_off,
                          size: 48,
                          color: AppTheme.of(context).secondaryText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Preview Desactivado',
                          style: TextStyle(
                            color: AppTheme.of(context).primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Active el switch para ver\nla vista previa en tiempo real',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.of(context).secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewContent(
      BuildContext context, ThemeConfigProvider provider) {
    final mode = provider.previewMode == ThemeMode.light ? 'light' : 'dark';
    final backgroundColor = provider.getColor(mode, 'primaryBackground');
    final cardColor = provider.getColor(mode, 'secondaryBackground');
    final primaryColor = provider.getColor(mode, 'primary');
    final secondaryColor = provider.getColor(mode, 'secondary');
    final textColor = provider.getColor(mode, 'primaryText');
    final secondaryTextColor = provider.getColor(mode, 'secondaryText');
    final successColor = provider.getColor(mode, 'success');
    final errorColor = provider.getColor(mode, 'error');
    final fontFamily = provider.getFont(mode);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Header simulado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Logo preview
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'NETHIVE',
                  style: _getSafeTextStyle(
                    fontFamily,
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    'Dashboard Principal',
                    style: _getSafeTextStyle(
                      fontFamily,
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bienvenido al sistema de gestión',
                    style: _getSafeTextStyle(
                      fontFamily,
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tarjetas de ejemplo
                  Expanded(
                    child: Row(
                      children: [
                        // Tarjeta 1
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: successColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.trending_up,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '24.5K',
                                      style: _getSafeTextStyle(
                                        fontFamily,
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ventas',
                                  style: _getSafeTextStyle(
                                    fontFamily,
                                    color: secondaryTextColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tarjeta 2
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: errorColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.warning,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '3',
                                      style: _getSafeTextStyle(
                                        fontFamily,
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Alertas',
                                  style: _getSafeTextStyle(
                                    fontFamily,
                                    color: secondaryTextColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botones de ejemplo
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              'Primario',
                              style: _getSafeTextStyle(
                                fontFamily,
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              'Secundario',
                              style: _getSafeTextStyle(
                                fontFamily,
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
      ),
    );
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
