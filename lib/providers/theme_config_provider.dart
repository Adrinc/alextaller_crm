import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/helpers/supabase/queries.dart';
import 'package:nethive_neo/models/configuration.dart';
import 'package:nethive_neo/theme/theme.dart';

class ThemeConfigProvider extends ChangeNotifier {
  static const int organizationId = 11;

  // Estado del configurador
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  // Configuración actual
  Map<String, dynamic> _currentConfig = {};
  List<Map<String, dynamic>> _savedThemes = [];

  // Tracking del tema activo
  int? _currentThemeId; // ID del tema activo (null si es temporal)

  // Modo preview
  ThemeMode _previewMode = ThemeMode.light;
  bool _isPreviewActive = false;

  // Logos
  String? _lightLogoUrl;
  String? _darkLogoUrl;
  Uint8List? _lightLogoBytes;
  Uint8List? _darkLogoBytes;
  String? _lightLogoName;
  String? _darkLogoName;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  Map<String, dynamic> get currentConfig => _currentConfig;
  List<Map<String, dynamic>> get savedThemes => _savedThemes;
  ThemeMode get previewMode => _previewMode;
  bool get isPreviewActive => _isPreviewActive;
  String? get lightLogoUrl => _lightLogoUrl;
  String? get darkLogoUrl => _darkLogoUrl;
  Uint8List? get lightLogoBytes => _lightLogoBytes;
  Uint8List? get darkLogoBytes => _darkLogoBytes;
  int? get currentThemeId => _currentThemeId; // ID del tema activo

  // Configuración por defecto
  Map<String, dynamic> get defaultConfig => {
        'name': 'Tema Por Defecto',
        'light': {
          'colors': {
            'primary': '#10B981', // Verde esmeralda principal
            'secondary': '#059669', // Verde más oscuro
            'tertiary': '#0D9488', // Verde azulado
            'accent': '#3B82F6', // Azul de acento
            'primaryBackground': '#0F172A', // Fondo muy oscuro
            'secondaryBackground': '#1E293B', // Fondo secundario oscuro
            'primaryText': '#FFFFFF', // Texto blanco
            'secondaryText': '#94A3B8', // Texto gris claro
            'success': '#10B981', // Verde para éxito
            'warning': '#F59E0B', // Amarillo para advertencias
            'error': '#EF4444', // Rojo para errores
            'info': '#3B82F6', // Azul para información
          },
          'typography': {
            'fontFamily': 'Poppins',
            'fontSize': {
              'xs': 12,
              'sm': 14,
              'base': 16,
              'lg': 18,
              'xl': 20,
              '2xl': 24,
              '3xl': 30,
              '4xl': 36,
            }
          },
          'logo': null,
          'iconStyle': 'material',
        },
        'dark': {
          'colors': {
            'primary': '#10B981', // Verde esmeralda principal
            'secondary': '#059669', // Verde más oscuro
            'tertiary': '#0D9488', // Verde azulado
            'accent': '#3B82F6', // Azul de acento
            'primaryBackground': '#0F172A', // Fondo muy oscuro
            'secondaryBackground': '#1E293B', // Fondo secundario oscuro
            'primaryText': '#FFFFFF', // Texto blanco
            'secondaryText': '#94A3B8', // Texto gris claro
            'success': '#10B981', // Verde para éxito
            'warning': '#F59E0B', // Amarillo para advertencias
            'error': '#EF4444', // Rojo para errores
            'info': '#3B82F6', // Azul para información
          },
          'typography': {
            'fontFamily': 'Poppins',
            'fontSize': {
              'xs': 12,
              'sm': 14,
              'base': 16,
              'lg': 18,
              'xl': 20,
              '2xl': 24,
              '3xl': 30,
              '4xl': 36,
            }
          },
          'logo': null,
          'iconStyle': 'material',
        }
      };

  // Fuentes disponibles
  List<String> get availableFonts => [
        'Poppins',
        'Roboto',
        'Inter',
        'Montserrat',
        'Open Sans',
        'Lato',
        'Source Sans Pro',
        'Nunito',
        'Raleway',
        'Ubuntu',
      ];

  // Estilos de iconos disponibles
  List<Map<String, dynamic>> get iconStyles => [
        {'id': 'material', 'name': 'Material Design', 'icon': Icons.android},
        {'id': 'cupertino', 'name': 'Cupertino (iOS)', 'icon': Icons.apple},
        {'id': 'rounded', 'name': 'Redondeados', 'icon': Icons.circle_outlined},
        {'id': 'sharp', 'name': 'Afilados', 'icon': Icons.crop_square},
      ];

  ThemeConfigProvider() {
    _initializeConfig();
  }

  void _initializeConfig() {
    _currentConfig = Map<String, dynamic>.from(defaultConfig);
    notifyListeners(); // Notificar que la configuración por defecto está lista
    loadSavedThemes();
    // No cargar tema del usuario automáticamente en la inicialización
    // Se cargará cuando el usuario inicie sesión
  }

  // Método público para recargar el tema después del login
  Future<void> reloadUserTheme() async {
    await loadCurrentTheme();
  }

  // Cargar configuración actual desde Supabase
  Future<void> loadCurrentTheme() async {
    _setLoading(true);
    try {
      // Obtener el tema del usuario usando el nuevo flujo
      final userTheme = await SupabaseQueries.getUserTheme();

      if (userTheme?.config != null) {
        // Convertir Configuration a Map<String, dynamic> para el provider
        final config = userTheme!.config!;

        _currentConfig = {
          'name': 'Tema del Usuario',
          'light': {
            'colors': _extractColors(config.light),
            'typography': _extractTypography(config.light),
            'logo': config.logos?.logoColor,
            'iconStyle': 'material',
          },
          'dark': {
            'colors': _extractColors(config.dark),
            'typography': _extractTypography(config.dark),
            'logo': config.logos?.logoBlanco,
            'iconStyle': 'material',
          },
        };

        await _loadLogos();
        log('Tema del usuario cargado exitosamente en ThemeConfigProvider');

        // ¡IMPORTANTE! Aplicar la configuración al AppTheme
        AppTheme.initConfiguration(userTheme);
      } else {
        log('No se pudo cargar el tema del usuario, usando configuración por defecto');
        _currentConfig = Map<String, dynamic>.from(defaultConfig);
      }
    } catch (e) {
      log('Error loading current theme: $e');
      // Si no existe configuración, mantener la por defecto
      _currentConfig = Map<String, dynamic>.from(defaultConfig);
    } finally {
      _setLoading(false);
    }
  } // Cargar logos desde storage

  Future<void> _loadLogos() async {
    try {
      final lightLogo = _currentConfig['light']?['logo'];
      final darkLogo = _currentConfig['dark']?['logo'];

      if (lightLogo != null) {
        _lightLogoUrl = supabase.storage
            .from('nethive')
            .getPublicUrl('configurador/logos/$lightLogo');
      }

      if (darkLogo != null) {
        _darkLogoUrl = supabase.storage
            .from('nethive')
            .getPublicUrl('configurador/logos/$darkLogo');
      }
    } catch (e) {
      log('Error loading logos: $e');
    }
  }

  // Cargar temas guardados
  Future<void> loadSavedThemes() async {
    try {
      final response = await supabase
          .from('theme')
          .select('id, name, config, created_at')
          .eq('organization_fk', organizationId)
          .order('created_at', ascending: false);

      _savedThemes = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error loading saved themes: $e');
      _setError('Error al cargar temas guardados');
    }
    notifyListeners();
  }

  // Actualizar color
  void updateColor(String mode, String colorKey, Color color) {
    if (_currentConfig[mode] == null) _currentConfig[mode] = {};
    if (_currentConfig[mode]['colors'] == null)
      _currentConfig[mode]['colors'] = {};

    _currentConfig[mode]['colors'][colorKey] =
        '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

    // Al modificar, se convierte en tema temporal
    _currentThemeId = null;

    notifyListeners();
  } // Actualizar fuente

  void updateFont(String mode, String fontFamily) {
    if (_currentConfig[mode] == null) _currentConfig[mode] = {};
    if (_currentConfig[mode]['typography'] == null)
      _currentConfig[mode]['typography'] = {};

    _currentConfig[mode]['typography']['fontFamily'] = fontFamily;

    // Al modificar, se convierte en tema temporal
    _currentThemeId = null;

    notifyListeners();
  }

  // Actualizar estilo de iconos
  void updateIconStyle(String mode, String iconStyle) {
    if (_currentConfig[mode] == null) _currentConfig[mode] = {};
    _currentConfig[mode]['iconStyle'] = iconStyle;

    // Al modificar, se convierte en tema temporal
    _currentThemeId = null;

    notifyListeners();
  }

  // Seleccionar logo
  Future<void> selectLogo(String mode) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final fileName =
              'logo_${mode}_${DateTime.now().millisecondsSinceEpoch}.${file.extension}';

          if (mode == 'light') {
            _lightLogoBytes = file.bytes;
            _lightLogoName = fileName;
          } else {
            _darkLogoBytes = file.bytes;
            _darkLogoName = fileName;
          }

          notifyListeners();
        }
      }
    } catch (e) {
      log('Error selecting logo: $e');
      _setError('Error al seleccionar logo');
    }
  }

  // Subir logo a storage
  Future<String?> _uploadLogo(String mode) async {
    try {
      Uint8List? logoBytes;
      String? logoName;

      if (mode == 'light') {
        logoBytes = _lightLogoBytes;
        logoName = _lightLogoName;
      } else {
        logoBytes = _darkLogoBytes;
        logoName = _darkLogoName;
      }

      if (logoBytes != null && logoName != null) {
        await supabase.storage
            .from('nethive')
            .uploadBinary('configurador/logos/$logoName', logoBytes);

        return logoName;
      }
    } catch (e) {
      log('Error uploading logo: $e');
      _setError('Error al subir logo');
    }
    return null;
  }

  // Guardar tema
  Future<bool> saveTheme(String themeName) async {
    _setSaving(true);
    try {
      // Subir logos si hay nuevos
      if (_lightLogoBytes != null) {
        final lightLogoPath = await _uploadLogo('light');
        if (lightLogoPath != null) {
          _currentConfig['light']['logo'] = lightLogoPath;
        }
      }

      if (_darkLogoBytes != null) {
        final darkLogoPath = await _uploadLogo('dark');
        if (darkLogoPath != null) {
          _currentConfig['dark']['logo'] = darkLogoPath;
        }
      }

      // Actualizar nombre del tema
      _currentConfig['name'] = themeName;

      // Convertir al formato antiguo antes de guardar
      final configToSave = _convertToOldFormat(_currentConfig);
      print(
          '🎨 [saveTheme] Guardando configuración en formato antiguo: $configToSave');

      // Guardar en Supabase
      await supabase.from('theme').upsert({
        'organization_fk': organizationId,
        'name': themeName,
        'config': configToSave,
      });

      // Limpiar logos temporales
      _lightLogoBytes = null;
      _darkLogoBytes = null;
      _lightLogoName = null;
      _darkLogoName = null;

      await loadSavedThemes();
      await _loadLogos();

      return true;
    } catch (e) {
      log('Error saving theme: $e');
      _setError('Error al guardar tema');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  // Cargar tema guardado
  Future<void> loadTheme(int themeId) async {
    _setLoading(true);
    try {
      final theme = _savedThemes.firstWhere((theme) => theme['id'] == themeId);
      final savedConfig = theme['config'] as Map<String, dynamic>;

      // Convertir de la estructura guardada a la estructura del provider
      _currentConfig = _convertFromSavedFormat(savedConfig);
      _currentThemeId = themeId; // Trackear el tema activo
      await _loadLogos();

      // Aplicar automáticamente el tema cargado
      await _updateGlobalTheme();
    } catch (e) {
      log('Error loading theme: $e');
      _setError('Error al cargar tema');
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar tema
  Future<bool> deleteTheme(int themeId) async {
    try {
      // Primero obtener la información del tema para extraer los logos
      final theme = _savedThemes.firstWhere((theme) => theme['id'] == themeId);
      final config = theme['config'] as Map<String, dynamic>;

      // Obtener nombres de archivos de logos
      final lightLogo = config['light']?['logo'];
      final darkLogo = config['dark']?['logo'];

      // Eliminar logos del storage si existen
      if (lightLogo != null) {
        try {
          await supabase.storage
              .from('nethive')
              .remove(['configurador/logos/$lightLogo']);
          log('Light logo deleted: $lightLogo');
        } catch (e) {
          log('Error deleting light logo: $e');
          // Continuar aunque falle la eliminación del logo
        }
      }

      if (darkLogo != null) {
        try {
          await supabase.storage
              .from('nethive')
              .remove(['configurador/logos/$darkLogo']);
          log('Dark logo deleted: $darkLogo');
        } catch (e) {
          log('Error deleting dark logo: $e');
          // Continuar aunque falle la eliminación del logo
        }
      }

      // Eliminar el registro del tema de la base de datos
      await supabase.from('theme').delete().eq('id', themeId);

      // Recargar la lista de temas
      await loadSavedThemes();

      return true;
    } catch (e) {
      log('Error deleting theme: $e');
      _setError('Error al eliminar tema');
      return false;
    }
  }

  // Aplicar tema al sistema
  Future<void> applyTheme() async {
    try {
      if (_currentThemeId != null) {
        // Es un tema guardado - actualizar user_profile.theme_fk
        await _updateUserTheme(_currentThemeId!);
      } else {
        // Es un tema temporal - solo aplicar visualmente
        await _updateGlobalTheme();
      }

      // Forzar notificación para asegurar que todos los widgets se actualicen
      notifyListeners();
    } catch (e) {
      log('Error applying theme: $e');
      _setError('Error al aplicar tema');
      notifyListeners(); // También notificar en caso de error
    }
  }

  // Actualizar el theme_fk del usuario en user_profile
  Future<void> _updateUserTheme(int themeId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await supabase
          .from('user_profile')
          .update({'theme_fk': themeId})
          .eq('user_profile_id', user.id)
          .eq('organization_fk', organizationId);

      // También aplicar el tema visualmente
      await _updateGlobalTheme();

      log('Theme applied to user successfully - ID: $themeId');
    } catch (e) {
      log('Error updating user theme: $e');
      throw e;
    }
  }

  // Método para actualizar el tema global de la aplicación
  Future<void> _updateGlobalTheme() async {
    try {
      // Importar las clases necesarias
      final Configuration configuration = _convertToConfiguration();

      // Actualizar AppTheme
      AppTheme.initConfiguration(configuration);

      // Notificar a todos los widgets que el tema ha cambiado
      notifyListeners();

      log('Global theme updated successfully');
    } catch (e) {
      log('Error updating global theme: $e');
    }
  }

  // Convertir la configuración actual al formato Configuration
  Configuration _convertToConfiguration() {
    final lightColors = _currentConfig['light']?['colors'] ?? {};
    final darkColors = _currentConfig['dark']?['colors'] ?? {};

    return Configuration(
      config: Config(
        light: Mode(
          primaryColor: lightColors['primary'],
          secondaryColor: lightColors['secondary'],
          tertiaryColor: lightColors['tertiary'],
          alternate: lightColors['accent'],
          primaryBackground: lightColors['primaryBackground'],
          secondaryBackground: lightColors['secondaryBackground'],
          primaryText: lightColors['primaryText'],
          secondaryText: lightColors['secondaryText'],
          tertiaryText:
              lightColors['secondaryText'], // Usar secondaryText como fallback
          hintText:
              lightColors['secondaryText'], // Usar secondaryText como fallback
          tertiaryBackground: lightColors[
              'secondaryBackground'], // Usar secondaryBackground como fallback
        ),
        dark: Mode(
          primaryColor: darkColors['primary'],
          secondaryColor: darkColors['secondary'],
          tertiaryColor: darkColors['tertiary'],
          alternate: darkColors['accent'],
          primaryBackground: darkColors['primaryBackground'],
          secondaryBackground: darkColors['secondaryBackground'],
          primaryText: darkColors['primaryText'],
          secondaryText: darkColors['secondaryText'],
          tertiaryText:
              darkColors['secondaryText'], // Usar secondaryText como fallback
          hintText:
              darkColors['secondaryText'], // Usar secondaryText como fallback
          tertiaryBackground: darkColors[
              'secondaryBackground'], // Usar secondaryBackground como fallback
        ),
        logos: Logos(
          logoColor: _currentConfig['light']?['logo'],
          logoBlanco: _currentConfig['dark']?['logo'],
        ),
      ),
    );
  }

  // Preview
  void setPreviewMode(ThemeMode mode) {
    _previewMode = mode;
    notifyListeners();
  }

  void togglePreview() {
    _isPreviewActive = !_isPreviewActive;
    notifyListeners();
  }

  // Export/Import
  String exportTheme() {
    return jsonEncode(_currentConfig);
  }

  void importTheme(String jsonData) {
    try {
      final imported = jsonDecode(jsonData);
      _currentConfig = Map<String, dynamic>.from(imported);
      notifyListeners();
    } catch (e) {
      _setError('Error al importar tema: formato inválido');
    }
  }

  // Resetear a configuración por defecto
  void resetToDefault() {
    _currentConfig = Map<String, dynamic>.from(defaultConfig);
    _lightLogoBytes = null;
    _darkLogoBytes = null;
    _lightLogoName = null;
    _darkLogoName = null;
    _lightLogoUrl = null;
    _darkLogoUrl = null;
    notifyListeners();
  }

  // Obtener color como Color object
  Color getColor(String mode, String colorKey) {
    final colorHex = _currentConfig[mode]?['colors']?[colorKey];
    if (colorHex != null && colorHex is String) {
      log('getColor($mode, $colorKey): Found $colorHex');
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    }

    // Si no se encuentra el color, usar el color por defecto del defaultConfig
    final defaultColorHex = defaultConfig[mode]?['colors']?[colorKey];
    if (defaultColorHex != null && defaultColorHex is String) {
      log('getColor($mode, $colorKey): Using default $defaultColorHex');
      return Color(int.parse(defaultColorHex.replaceFirst('#', '0xFF')));
    }

    log('getColor($mode, $colorKey): Using fallback blue');
    return Colors.blue; // Último recurso
  }

  // Obtener fuente
  String getFont(String mode) {
    return _currentConfig[mode]?['typography']?['fontFamily'] ?? 'Poppins';
  }

  // Obtener estilo de iconos
  String getIconStyle(String mode) {
    return _currentConfig[mode]?['iconStyle'] ?? 'material';
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  void _setSaving(bool saving) {
    _isSaving = saving;
    if (saving) _error = null;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Métodos auxiliares para convertir Configuration a Map
  Map<String, String?> _extractColors(Mode? mode) {
    if (mode == null) {
      return {};
    }

    final colors = {
      'primary': mode.primaryColor,
      'secondary': mode.secondaryColor,
      'tertiary': mode.tertiaryColor,
      'primaryBackground': mode.primaryBackground,
      'secondaryBackground': mode.secondaryBackground,
      'tertiaryBackground': mode.tertiaryBackground,
      'primaryText': mode.primaryText,
      'secondaryText': mode.secondaryText,
      'tertiaryText': mode.tertiaryText,
      'alternate': mode.alternate,
      'hintText': mode.hintText,
    };

    return colors;
  }

  Map<String, String?> _extractTypography(Mode? mode) {
    // Para tipografía, usando colores de texto como base
    if (mode == null) {
      return {};
    }

    final typography = {
      'headingFamily': 'Poppins',
      'bodyFamily': 'Poppins',
      'headingColor': mode.primaryText,
      'bodyColor': mode.secondaryText,
    };

    return typography;
  }

  /// Convierte del formato del provider (nuevo) al formato antiguo para guardar en BD
  Map<String, dynamic> _convertToOldFormat(Map<String, dynamic> currentConfig) {
    final converted = <String, dynamic>{};

    // Convertir light mode
    if (currentConfig['light'] != null) {
      final lightSection = currentConfig['light'] as Map<String, dynamic>;
      final lightColors = lightSection['colors'] as Map<String, dynamic>?;

      if (lightColors != null) {
        // Usar colores base para crear colores derivados según Material Design
        final primary = lightColors['primary'] ?? '#10B981';
        final secondary = lightColors['secondary'] ?? '#059669';
        final tertiary = lightColors['tertiary'] ?? '#0D9488';
        final surface = lightColors['primaryBackground'] ?? '#FFFFFF';
        final error = lightColors['error'] ?? '#EF4444';

        converted['light'] = <String, dynamic>{
          // Colores principales
          'primary': primary,
          'onPrimary': '#FFFFFF',
          'primaryContainer': _lightenColor(primary, 0.8),
          'onPrimaryContainer': '#000000',
          'primaryFixed': _lightenColor(primary, 0.9),
          'onPrimaryFixed': '#000000',
          'primaryFixedDim': _lightenColor(primary, 0.7),
          'onPrimaryFixedVariant': '#000000',

          // Colores secundarios
          'secondary': secondary,
          'onSecondary': '#FFFFFF',
          'secondaryContainer': _lightenColor(secondary, 0.8),
          'onSecondaryContainer': '#000000',
          'secondaryFixed': _lightenColor(secondary, 0.9),
          'onSecondaryFixed': '#000000',
          'secondaryFixedDim': _lightenColor(secondary, 0.7),
          'onSecondaryFixedVariant': '#000000',

          // Colores terciarios
          'tertiary': tertiary,
          'onTertiary': '#FFFFFF',
          'tertiaryContainer': _lightenColor(tertiary, 0.8),
          'onTertiaryContainer': '#000000',
          'tertiaryFixed': _lightenColor(tertiary, 0.9),
          'onTertiaryFixed': '#000000',
          'tertiaryFixedDim': _lightenColor(tertiary, 0.7),
          'onTertiaryFixedVariant': '#000000',

          // Superficies
          'surface': surface,
          'onSurface': surface == '#FFFFFF' ? '#000000' : '#FFFFFF',
          'surfaceContainer': _darkenColor(surface, 0.05),
          'surfaceContainerHigh': _darkenColor(surface, 0.08),
          'surfaceContainerHighest': _darkenColor(surface, 0.12),
          'surfaceContainerLow': _lightenColor(surface, 0.05),
          'surfaceContainerLowest': _lightenColor(surface, 0.1),
          'surfaceDim': _darkenColor(surface, 0.06),
          'surfaceBright': _lightenColor(surface, 0.08),
          'surfaceTint': primary,
          'onSurfaceVariant': surface == '#FFFFFF' ? '#393939' : '#CACACA',

          // Error
          'error': error,
          'onError': '#FFFFFF',
          'errorContainer': _lightenColor(error, 0.8),
          'onErrorContainer': '#000000',

          // Inversed
          'inversePrimary': _lightenColor(primary, 0.3),
          'inverseSurface': surface == '#FFFFFF' ? '#2A2A2A' : '#E8E8E8',
          'onInverseSurface': surface == '#FFFFFF' ? '#F1F1F1' : '#2A2A2A',

          // Outline y otros
          'outline': '#919191',
          'outlineVariant': '#D1D1D1',
          'shadow': '#000000',
          'scrim': '#000000',
          'brightness': 'light',

          // AppBar
          'appBarColor': primary,
        };
      }
    }

    // Convertir dark mode
    if (currentConfig['dark'] != null) {
      final darkSection = currentConfig['dark'] as Map<String, dynamic>;
      final darkColors = darkSection['colors'] as Map<String, dynamic>?;

      if (darkColors != null) {
        // Usar colores base para crear colores derivados según Material Design
        final primary = darkColors['primary'] ?? '#10B981';
        final secondary = darkColors['secondary'] ?? '#059669';
        final tertiary = darkColors['tertiary'] ?? '#0D9488';
        final surface = darkColors['primaryBackground'] ?? '#080808';
        final error = darkColors['error'] ?? '#CF6679';

        converted['dark'] = <String, dynamic>{
          // Colores principales
          'primary': primary,
          'onPrimary': '#000000',
          'primaryContainer': _darkenColor(primary, 0.3),
          'onPrimaryContainer': '#FFFFFF',
          'primaryFixed': _lightenColor(primary, 0.8),
          'onPrimaryFixed': '#000000',
          'primaryFixedDim': _lightenColor(primary, 0.6),
          'onPrimaryFixedVariant': '#000000',

          // Colores secundarios
          'secondary': secondary,
          'onSecondary': '#000000',
          'secondaryContainer': _darkenColor(secondary, 0.3),
          'onSecondaryContainer': '#FFFFFF',
          'secondaryFixed': _lightenColor(secondary, 0.8),
          'onSecondaryFixed': '#000000',
          'secondaryFixedDim': _lightenColor(secondary, 0.6),
          'onSecondaryFixedVariant': '#000000',

          // Colores terciarios
          'tertiary': tertiary,
          'onTertiary': '#000000',
          'tertiaryContainer': _darkenColor(tertiary, 0.3),
          'onTertiaryContainer': '#FFFFFF',
          'tertiaryFixed': _lightenColor(tertiary, 0.8),
          'onTertiaryFixed': '#000000',
          'tertiaryFixedDim': _lightenColor(tertiary, 0.6),
          'onTertiaryFixedVariant': '#000000',

          // Superficies
          'surface': surface,
          'onSurface': '#F1F1F1',
          'surfaceContainer': _lightenColor(surface, 0.15),
          'surfaceContainerHigh': _lightenColor(surface, 0.25),
          'surfaceContainerHighest': _lightenColor(surface, 0.35),
          'surfaceContainerLow': _lightenColor(surface, 0.08),
          'surfaceContainerLowest': _darkenColor(surface, 0.02),
          'surfaceDim': _darkenColor(surface, 0.02),
          'surfaceBright': _lightenColor(surface, 0.4),
          'surfaceTint': primary,
          'onSurfaceVariant': '#CACACA',

          // Error
          'error': error,
          'onError': '#000000',
          'errorContainer': _darkenColor(error, 0.3),
          'onErrorContainer': '#FFFFFF',

          // Inversed
          'inversePrimary': _darkenColor(primary, 0.3),
          'inverseSurface': '#E8E8E8',
          'onInverseSurface': '#2A2A2A',

          // Outline y otros
          'outline': '#777777',
          'outlineVariant': '#414141',
          'shadow': '#000000',
          'scrim': '#000000',
          'brightness': 'dark',

          // AppBar
          'appBarColor': primary,
        };
      }
    }

    // Agregar logos (manteniendo la estructura correcta)
    converted['logos'] = <String, dynamic>{};
    if (currentConfig['light'] != null &&
        currentConfig['light']['logo'] != null) {
      converted['logos']['logoColor'] = currentConfig['light']['logo'];
    }
    if (currentConfig['dark'] != null &&
        currentConfig['dark']['logo'] != null) {
      converted['logos']['logoBlanco'] = currentConfig['dark']['logo'];
    }

    return converted;
  }

  /// Convierte del formato guardado en BD al formato del provider
  Map<String, dynamic> _convertFromSavedFormat(
      Map<String, dynamic> savedConfig) {
    final converted = <String, dynamic>{};

    // Detectar si es estructura nueva (simplificada) o estructura antigua (completa)
    final lightSection = savedConfig['light'] as Map<String, dynamic>?;
    final darkSection = savedConfig['dark'] as Map<String, dynamic>?;

    if (lightSection != null) {
      // Verificar si tiene la estructura nueva (con 'colors' anidado)
      if (lightSection.containsKey('colors')) {
        // Es estructura nueva, copiar directamente
        converted['light'] = Map<String, dynamic>.from(lightSection);
      } else {
        // Es estructura antigua (completa), extraer colores principales
        converted['light'] = {
          'colors': {
            'primary': lightSection['primary'] ??
                lightSection['primaryColor'] ??
                '#10B981',
            'secondary': lightSection['secondary'] ??
                lightSection['secondaryColor'] ??
                '#059669',
            'tertiary': lightSection['tertiary'] ??
                lightSection['tertiaryColor'] ??
                '#0D9488',
            'accent': lightSection['primaryContainer'] ?? '#3B82F6',
            'primaryBackground': lightSection['surface'] ?? '#FFFFFF',
            'secondaryBackground': lightSection['surfaceContainer'] ??
                lightSection['surface'] ??
                '#F5F5F5',
            'primaryText': lightSection['onSurface'] ?? '#000000',
            'secondaryText': lightSection['onSurfaceVariant'] ?? '#666666',
            'success': '#10B981',
            'warning': '#F59E0B',
            'error': lightSection['error'] ?? '#EF4444',
            'info': '#3B82F6',
          },
          'typography': {
            'fontFamily': 'Poppins',
            'fontSize': {
              'xs': 12,
              'sm': 14,
              'base': 16,
              'lg': 18,
              'xl': 20,
              '2xl': 24,
              '3xl': 30,
              '4xl': 36,
            }
          },
          'logo': savedConfig['logos']?['logoColor'],
          'iconStyle': 'material',
        };
      }
    }

    if (darkSection != null) {
      // Verificar si tiene la estructura nueva (con 'colors' anidado)
      if (darkSection.containsKey('colors')) {
        // Es estructura nueva, copiar directamente
        converted['dark'] = Map<String, dynamic>.from(darkSection);
      } else {
        // Es estructura antigua (completa), extraer colores principales
        converted['dark'] = {
          'colors': {
            'primary': darkSection['primary'] ??
                darkSection['primaryColor'] ??
                '#10B981',
            'secondary': darkSection['secondary'] ??
                darkSection['secondaryColor'] ??
                '#059669',
            'tertiary': darkSection['tertiary'] ??
                darkSection['tertiaryColor'] ??
                '#0D9488',
            'accent': darkSection['primaryContainer'] ?? '#3B82F6',
            'primaryBackground': darkSection['surface'] ?? '#080808',
            'secondaryBackground': darkSection['surfaceContainer'] ??
                darkSection['surface'] ??
                '#1A1A1A',
            'primaryText': darkSection['onSurface'] ?? '#FFFFFF',
            'secondaryText': darkSection['onSurfaceVariant'] ?? '#AAAAAA',
            'success': '#10B981',
            'warning': '#F59E0B',
            'error': darkSection['error'] ?? '#CF6679',
            'info': '#3B82F6',
          },
          'typography': {
            'fontFamily': 'Poppins',
            'fontSize': {
              'xs': 12,
              'sm': 14,
              'base': 16,
              'lg': 18,
              'xl': 20,
              '2xl': 24,
              '3xl': 30,
              '4xl': 36,
            }
          },
          'logo': savedConfig['logos']?['logoBlanco'],
          'iconStyle': 'material',
        };
      }
    }

    // Copiar nombre si existe
    if (savedConfig.containsKey('name')) {
      converted['name'] = savedConfig['name'];
    }

    log('🔄 [_convertFromSavedFormat] Convertido: light=${converted['light']?['colors']?['primary']}, dark=${converted['dark']?['colors']?['primary']}');

    return converted;
  }

  // Métodos auxiliares para generar colores derivados
  String _lightenColor(String hexColor, double amount) {
    try {
      final color = Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
      final hsl = HSLColor.fromColor(color);
      final lightened =
          hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
      final newColor = lightened.toColor();
      return '#${newColor.value.toRadixString(16).substring(2).toUpperCase()}';
    } catch (e) {
      return hexColor; // Retornar el color original si hay error
    }
  }

  String _darkenColor(String hexColor, double amount) {
    try {
      final color = Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
      final hsl = HSLColor.fromColor(color);
      final darkened =
          hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
      final newColor = darkened.toColor();
      return '#${newColor.value.toRadixString(16).substring(2).toUpperCase()}';
    } catch (e) {
      return hexColor; // Retornar el color original si hay error
    }
  }
}
