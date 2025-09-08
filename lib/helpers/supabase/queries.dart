import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/models.dart';

class SupabaseQueries {
  static Future<User?> getCurrentUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final PostgrestFilterBuilder query =
          supabase.from('user_profile').select('''
            *,
            role:role_fk(*)
          ''').eq('user_profile_id', user.id);

      final res = await query.maybeSingle();

      if (res == null) {
        log('No se encontró user_profile para el usuario: ${user.id}');
        return null;
      }

      // Agregar datos del auth user
      res['id'] = user.id;
      res['email'] = user.email!;

      final usuario = User.fromMap(res);

      log('Usuario cargado exitosamente: ${usuario.email}');
      return usuario;
    } catch (e) {
      log('Error en getCurrentUserData() - $e');
      return null;
    }
  }

  static Future<Configuration?> getDefaultTheme() async {
    try {
      print('🔍 [getDefaultTheme] Cargando tema por defecto...');

      final res = await supabase
          .from('theme')
          .select('config')
          .eq('id', 1)
          .eq('organization_fk', 11) // Filtrar por organización
          .maybeSingle();

      print('🔍 [getDefaultTheme] Respuesta de la base de datos: $res');

      if (res == null) {
        log('No se encontró tema por defecto con id: 1 en organización 10');
        print(
            '🔴 [getDefaultTheme] No se encontró tema por defecto en organización 10');
        return null;
      }

      print('🔍 [getDefaultTheme] Config encontrada: ${res['config']}');

      // Convertir el formato si es necesario
      final convertedConfig = _convertThemeFormat(res['config']);
      print('🔍 [getDefaultTheme] Config convertida: $convertedConfig');

      final configuration = Configuration.fromMap({'config': convertedConfig});
      print(
          '🔍 [getDefaultTheme] Configuration parseada: ${configuration.toJson()}');

      return configuration;
    } catch (e) {
      log('Error en getDefaultTheme() - $e');
      print('🔴 [getDefaultTheme] Error: $e');
      return null;
    }
  }

  static Future<Configuration?> getUserTheme() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print('🔍 [getUserTheme] No hay usuario autenticado');
        return null;
      }

      print('🔍 [getUserTheme] Buscando tema para usuario: ${user.id}');

      // Buscar en user_profile usando el user_profile_id y verificar organization_fk
      final userProfileRes = await supabase
          .from('user_profile')
          .select('theme_fk, organization_fk')
          .eq('user_profile_id', user.id)
          .eq('organization_fk', 11) // Filtrar por organización
          .maybeSingle();

      print('🔍 [getUserTheme] Respuesta user_profile: $userProfileRes');

      if (userProfileRes == null) {
        log('No se encontró user_profile para el usuario: ${user.id} en organización 10');
        print(
            '🔍 [getUserTheme] No se encontró user_profile en organización 10, cargando tema por defecto');
        return await getDefaultTheme();
      }

      final themeFk = userProfileRes['theme_fk'];
      print('🔍 [getUserTheme] theme_fk encontrado: $themeFk');

      // Si theme_fk es null, cargar tema por defecto
      if (themeFk == null) {
        log('Usuario no tiene tema personalizado, cargando tema por defecto');
        print('🔍 [getUserTheme] theme_fk es null, cargando tema por defecto');
        return await getDefaultTheme();
      }

      // Buscar configuración del tema usando theme_fk y verificar organization_fk
      final themeRes = await supabase
          .from('theme')
          .select('config')
          .eq('id', themeFk)
          .eq('organization_fk', 11) // Filtrar por organización
          .maybeSingle();

      print('🔍 [getUserTheme] Respuesta theme: $themeRes');

      if (themeRes == null) {
        log('No se encontró tema con id: $themeFk en organización 10, cargando tema por defecto');
        print(
            '🔍 [getUserTheme] No se encontró tema con id: $themeFk en organización 10, cargando tema por defecto');
        return await getDefaultTheme();
      }

      print(
          '🔍 [getUserTheme] Configuración del tema encontrada: ${themeRes['config']}');
      log('Cargando tema personalizado del usuario con id: $themeFk');

      // Convertir el formato si es necesario
      final convertedConfig = _convertThemeFormat(themeRes['config']);
      print('🔍 [getUserTheme] Config convertida: $convertedConfig');

      final configuration = Configuration.fromMap({'config': convertedConfig});
      print(
          '🔍 [getUserTheme] Configuration parseada exitosamente: ${configuration.toJson()}');

      return configuration;
    } catch (e) {
      log('Error en getUserTheme() - $e, cargando tema por defecto');
      print('🔴 [getUserTheme] Error: $e');
      return await getDefaultTheme();
    }
  }

  static Future<bool> tokenChangePassword(String id, String newPassword) async {
    try {
      final res = await supabase.rpc('token_change_password', params: {
        'user_id': id,
        'new_password': newPassword,
      });

      if (res['data'] == true) {
        return true;
      }
    } catch (e) {
      log('Error en tokenChangePassword() - $e');
    }
    return false;
  }

  static Future<bool> saveToken(
    String userId,
    String tokenType,
    String token,
  ) async {
    try {
      await supabase
          .from('token')
          .upsert({'user_id': userId, tokenType: token});
      return true;
    } catch (e) {
      log('Error en saveToken() - $e');
    }
    return false;
  }

  /// Convierte formatos de tema entre estructura nueva y antigua
  /// Detecta automáticamente el formato y convierte al formato esperado por Configuration
  static Map<String, dynamic> _convertThemeFormat(Map<String, dynamic> config) {
    print('🔄 [_convertThemeFormat] Convirtiendo formato de tema...');
    print('🔄 [_convertThemeFormat] Input: $config');

    // Detectar si es formato nuevo (tiene "colors" anidados)
    final hasNestedColors = config['dark'] != null &&
        config['dark'] is Map &&
        (config['dark'] as Map).containsKey('colors');

    if (hasNestedColors) {
      print(
          '🔄 [_convertThemeFormat] Formato nuevo detectado, convirtiendo...');
      return _convertNewToOldFormat(config);
    } else {
      print(
          '🔄 [_convertThemeFormat] Formato antiguo detectado, usando tal como está');
      return config;
    }
  }

  /// Convierte del formato nuevo al formato antiguo
  static Map<String, dynamic> _convertNewToOldFormat(
      Map<String, dynamic> newFormat) {
    final converted = <String, dynamic>{};

    // Convertir dark mode
    if (newFormat['dark'] != null) {
      final darkSection = newFormat['dark'] as Map<String, dynamic>;
      final darkColors = darkSection['colors'] as Map<String, dynamic>?;

      converted['dark'] = <String, dynamic>{};

      if (darkColors != null) {
        // Mapear colores del formato nuevo al antiguo
        converted['dark']['primaryColor'] = darkColors['primary'];
        converted['dark']['secondaryColor'] = darkColors['secondary'];
        converted['dark']['tertiaryColor'] = darkColors['tertiary'];
        converted['dark']['primaryText'] = darkColors['primaryText'];
        converted['dark']['secondaryText'] = darkColors['secondaryText'];
        converted['dark']['primaryBackground'] =
            darkColors['primaryBackground'];
        converted['dark']['secondaryBackground'] =
            darkColors['secondaryBackground'];
        converted['dark']['alternate'] = darkColors['accent'];
        converted['dark']['hintText'] = darkColors['secondaryText']; // fallback
        converted['dark']['tertiaryText'] =
            darkColors['secondaryText']; // fallback
        converted['dark']['tertiaryBackground'] =
            darkColors['secondaryBackground']; // fallback
      }
    }

    // Convertir light mode
    if (newFormat['light'] != null) {
      final lightSection = newFormat['light'] as Map<String, dynamic>;
      final lightColors = lightSection['colors'] as Map<String, dynamic>?;

      converted['light'] = <String, dynamic>{};

      if (lightColors != null) {
        // Mapear colores del formato nuevo al antiguo
        converted['light']['primaryColor'] = lightColors['primary'];
        converted['light']['secondaryColor'] = lightColors['secondary'];
        converted['light']['tertiaryColor'] = lightColors['tertiary'];
        converted['light']['primaryText'] = lightColors['primaryText'];
        converted['light']['secondaryText'] = lightColors['secondaryText'];
        converted['light']['primaryBackground'] =
            lightColors['primaryBackground'];
        converted['light']['secondaryBackground'] =
            lightColors['secondaryBackground'];
        converted['light']['alternate'] = lightColors['accent'];
        converted['light']['hintText'] =
            lightColors['secondaryText']; // fallback
        converted['light']['tertiaryText'] =
            lightColors['secondaryText']; // fallback
        converted['light']['tertiaryBackground'] =
            lightColors['secondaryBackground']; // fallback
      }
    }

    // Convertir logos
    converted['logos'] = <String, dynamic>{};
    if (newFormat['dark'] != null &&
        (newFormat['dark'] as Map).containsKey('logo')) {
      converted['logos']['logoBlanco'] = newFormat['dark']['logo'];
    }
    if (newFormat['light'] != null &&
        (newFormat['light'] as Map).containsKey('logo')) {
      converted['logos']['logoColor'] = newFormat['light']['logo'];
    }

    print('🔄 [_convertThemeFormat] Resultado convertido: $converted');
    return converted;
  }
}
