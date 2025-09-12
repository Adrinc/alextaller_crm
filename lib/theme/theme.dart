import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/main.dart';
import 'package:nethive_neo/models/configuration.dart';

const kThemeModeKey = '__theme_mode__';

void setDarkModeSetting(BuildContext context, ThemeMode themeMode) =>
    MyApp.of(context).setThemeMode(themeMode);

abstract class AppTheme {
  static ThemeMode get themeMode {
    final darkMode = prefs.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.light
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static LightModeTheme lightTheme = LightModeTheme();
  static DarkModeTheme darkTheme = DarkModeTheme();

  static void initConfiguration(Configuration? conf) {
    if (conf?.config != null) {
      lightTheme = LightModeTheme(mode: conf!.config!.light);
      darkTheme = DarkModeTheme(mode: conf.config!.dark);
    } else {
      lightTheme = LightModeTheme();
      darkTheme = DarkModeTheme();
    }
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? prefs.remove(kThemeModeKey)
      : prefs.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static AppTheme of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTheme : lightTheme;
  Color hexToColor(String hexString) {
    // Quita el signo de almohadilla si está presente
    hexString = hexString.toUpperCase().replaceAll("#",
        ""); // Si la cadena tiene 6 caracteres, añade el valor de opacidad completa "FF"
    if (hexString.length == 6) {
      hexString = "FF$hexString";
    } // Si la cadena tiene 8 caracteres, ya incluye la transparencia, así que se deja como está
    else if (hexString.length == 8) {
      hexString = hexString.substring(6, 8) + hexString.substring(0, 6);
    } // Añade el prefijo 0x y convierte la cadena hexadecimal a un entero
    return Color(int.parse("0x$hexString"));
  }

  abstract Color primaryColor;
  abstract Color secondaryColor;
  abstract Color tertiaryColor;
  abstract Color alternate;
  abstract Color primaryBackground;
  abstract Color secondaryBackground;
  abstract Color tertiaryBackground;
  abstract Color transparentBackground;
  abstract Color primaryText;
  abstract Color secondaryText;
  abstract Color tertiaryText;
  abstract Color hintText;
  abstract Color error;
  abstract Color warning;
  abstract Color success;
  abstract Color formBackground;

  // Sombras neumórficas abstractas
  List<BoxShadow> get neumorphicShadows;
  List<BoxShadow> get neumorphicInsetShadows;
  List<BoxShadow> get softShadows;

  Gradient blueGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFFF007F), // Rosa fucsia principal
      Color(0xFFFF2D95), // Rosa brillante
      Color(0xFFFF4081), // Rosa alternativo
      Color(0xFF1A1A1A), // Fondo oscuro
    ],
  );

  Gradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFFF007F), // Rosa fucsia principal
      Color(0xFFFF2D95), // Rosa brillante
      Color.fromARGB(255, 157, 0, 255), // Naranja de acento
      Color(0xFF0A0A0A), // Negro de fondo
    ],
  );

  // Nuevo gradiente para elementos modernos
  Gradient modernGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFFF007F), // Rosa fucsia principal
      Color.fromARGB(255, 157, 0, 255), // Naranja de acento
      Color(0xFFFF2D95), // Rosa brillante
      Color(0xFFFF4081), // Rosa alternativo
    ],
  );

  // Gradiente para backgrounds oscuros
  Gradient darkBackgroundGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0xFF0A0A0A), // Negro de fondo
      Color(0xFF1A1A1A), // Fondo secundario oscuro
      Color(0xFF2A2A2A), // Fondo terciario
    ],
  );

  String get title1Family => typography.title1Family;
  TextStyle get title1 => typography.title1;
  String get title2Family => typography.title2Family;
  TextStyle get title2 => typography.title2;
  String get title3Family => typography.title3Family;
  TextStyle get title3 => typography.title3;
  String get subtitle1Family => typography.subtitle1Family;
  TextStyle get subtitle1 => typography.subtitle1;
  String get subtitle2Family => typography.subtitle2Family;
  TextStyle get subtitle2 => typography.subtitle2;
  String get bodyText1Family => typography.bodyText1Family;
  TextStyle get bodyText1 => typography.bodyText1;
  String get bodyText2Family => typography.bodyText2Family;
  TextStyle get bodyText2 => typography.bodyText2;
  String get bodyText3Family => typography.bodyText3Family;
  TextStyle get bodyText3 => typography.bodyText3;
  String get plutoDataTextFamily => typography.plutoDataTextFamily;
  TextStyle get plutoDataText => typography.plutoDataText;
  String get copyRightTextFamily => typography.copyRightTextFamily;
  TextStyle get copyRightText => typography.copyRightText;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends AppTheme {
  @override
  Color primaryColor = const Color(0xFFE91E63); // Rosa fucsia principal
  @override
  Color secondaryColor = const Color(0xFF9C27B0); // Púrpura elegante
  @override
  Color tertiaryColor = const Color(0xFF2196F3); // Azul de acento
  @override
  Color alternate = const Color(0xFFE0E0E0); // Gris claro alternativo
  @override
  Color primaryBackground = const Color(0xFFF0F0F3); // Fondo neumórfico blanco
  @override
  Color secondaryBackground =
      const Color(0xFFFFFFFF); // Blanco puro para contenedores
  @override
  Color tertiaryBackground = const Color(0xFFF8F9FA); // Blanco ligeramente gris
  @override
  Color transparentBackground =
      const Color(0xFFFFFFFF).withOpacity(.8); // Fondo transparente blanco
  @override
  Color primaryText = const Color(0xFF2D3748); // Texto oscuro principal
  @override
  Color secondaryText = const Color(0xFF718096); // Texto gris medio
  @override
  Color tertiaryText = const Color(0xFFA0AEC0); // Texto gris claro
  @override
  Color hintText = const Color(0xFFCBD5E0); // Texto de sugerencia
  @override
  Color error = const Color(0xFFF56565); // Rojo suave para errores
  @override
  Color warning = const Color(0xFFED8936); // Naranja suave para advertencias
  @override
  Color success = const Color(0xFF48BB78); // Verde suave para éxito
  @override
  Color formBackground = const Color(0xFFFFFFFF); // Blanco para formularios

  // Sombras neumórficas predefinidas
  List<BoxShadow> get neumorphicShadows => [
        BoxShadow(
          color: Colors.white,
          offset: const Offset(-8, -8),
          blurRadius: 15,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: const Color(0xFFBEBEBE).withOpacity(0.4),
          offset: const Offset(8, 8),
          blurRadius: 15,
          spreadRadius: 1,
        ),
      ];

  List<BoxShadow> get neumorphicInsetShadows => [
        BoxShadow(
          color: const Color(0xFFBEBEBE).withOpacity(0.4),
          offset: const Offset(-4, -4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.white,
          offset: const Offset(4, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  List<BoxShadow> get softShadows => [
        BoxShadow(
          color: primaryColor.withOpacity(0.1),
          offset: const Offset(0, 4),
          blurRadius: 20,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          offset: const Offset(0, 2),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ];

  LightModeTheme({Mode? mode}) {
    if (mode != null) {
      primaryColor = hexToColor(mode.primaryColor!);
      secondaryColor = hexToColor(mode.secondaryColor!);
      tertiaryColor = hexToColor(mode.tertiaryColor!);
      primaryText = hexToColor(mode.primaryText!);
      primaryBackground = hexToColor(mode.primaryBackground!);
    }
  }
}

class DarkModeTheme extends AppTheme {
  @override
  Color primaryColor = const Color(0xFFFF007F); // Rosa fucsia principal
  @override
  Color secondaryColor = const Color(0xFFFF2D95); // Rosa brillante
  @override
  Color tertiaryColor = const Color(0xFFFF6B00); // Naranja de acento
  @override
  Color alternate = const Color(0xFFFF4081); // Rosa alternativo
  @override
  Color primaryBackground = const Color(0xFF0A0A0A); // Negro de fondo
  @override
  Color secondaryBackground =
      const Color(0xFF1A1A1A); // Fondo secundario oscuro
  @override
  Color tertiaryBackground = const Color(0xFF2A2A2A); // Fondo terciario
  @override
  Color transparentBackground =
      const Color(0xFF1A1A1A).withOpacity(.3); // Fondo transparente
  @override
  Color primaryText = const Color(0xFFFFFFFF); // Texto blanco
  @override
  Color secondaryText = const Color(0xFFB0B0B0); // Texto gris claro
  @override
  Color tertiaryText = const Color(0xFF808080); // Texto gris medio
  @override
  Color hintText = const Color(0xFF606060); // Texto de sugerencia
  @override
  Color error = const Color(0xFFFF4444); // Rojo para errores
  @override
  Color warning = const Color(0xFFFF6B00); // Naranja para advertencias
  @override
  Color success = const Color(0xFF00FF88); // Verde para éxito
  @override
  Color formBackground = const Color(0xFF1A1A1A); // Fondo de formularios oscuro

  // Sombras neumórficas para tema oscuro
  @override
  List<BoxShadow> get neumorphicShadows => [
        BoxShadow(
          color: const Color(0xFF2A2A2A),
          offset: const Offset(-8, -8),
          blurRadius: 15,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.8),
          offset: const Offset(8, 8),
          blurRadius: 15,
          spreadRadius: 1,
        ),
      ];

  @override
  List<BoxShadow> get neumorphicInsetShadows => [
        BoxShadow(
          color: Colors.black.withOpacity(0.8),
          offset: const Offset(-4, -4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: const Color(0xFF2A2A2A),
          offset: const Offset(4, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  @override
  List<BoxShadow> get softShadows => [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          offset: const Offset(0, 4),
          blurRadius: 20,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(0, 2),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ];

  // Nuevos gradientes modernos
  @override
  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor,
          secondaryColor,
        ],
      );

  @override
  LinearGradient get modernGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          tertiaryColor,
          primaryColor,
        ],
      );

  @override
  LinearGradient get darkBackgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryBackground,
          secondaryBackground,
        ],
      );

  DarkModeTheme({Mode? mode}) {
    if (mode != null) {
      primaryColor = hexToColor(mode.primaryColor!);
      secondaryColor = hexToColor(mode.secondaryColor!);
      tertiaryColor = hexToColor(mode.tertiaryColor!);
      primaryText = hexToColor(mode.primaryText!);
      primaryBackground = hexToColor(mode.primaryBackground!);
    }
  }
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    required String fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    TextDecorationStyle? decorationStyle,
    double? lineHeight,
  }) =>
      useGoogleFonts
          ? GoogleFonts.getFont(
              fontFamily,
              color: color ?? this.color,
              fontSize: fontSize ?? this.fontSize,
              fontWeight: fontWeight ?? this.fontWeight,
              fontStyle: fontStyle ?? this.fontStyle,
              letterSpacing: letterSpacing ?? this.letterSpacing,
              decoration: decoration,
              decorationStyle: decorationStyle,
              height: lineHeight,
            )
          : copyWith(
              fontFamily: fontFamily,
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              fontStyle: fontStyle,
              decoration: decoration,
              decorationStyle: decorationStyle,
              height: lineHeight,
            );
}

abstract class Typography {
  String get title1Family;
  TextStyle get title1;
  String get title2Family;
  TextStyle get title2;
  String get title3Family;
  TextStyle get title3;
  String get subtitle1Family;
  TextStyle get subtitle1;
  String get subtitle2Family;
  TextStyle get subtitle2;
  String get bodyText1Family;
  TextStyle get bodyText1;
  String get bodyText2Family;
  TextStyle get bodyText2;
  String get bodyText3Family;
  TextStyle get bodyText3;
  String get plutoDataTextFamily;
  TextStyle get plutoDataText;
  String get copyRightTextFamily;
  TextStyle get copyRightText;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final AppTheme theme;

  @override
  String get title1Family => 'Poppins';
  @override
  TextStyle get title1 => GoogleFonts.poppins(
        fontSize: 42,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );
  @override
  String get title2Family => 'Poppins';
  @override
  TextStyle get title2 => GoogleFonts.poppins(
        fontSize: 38,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );
  @override
  String get title3Family => 'Poppins';
  @override
  TextStyle get title3 => GoogleFonts.poppins(
        fontSize: 34,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );

  @override
  String get subtitle1Family => 'Poppins';
  @override
  TextStyle get subtitle1 => GoogleFonts.poppins(
        fontSize: 28,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );
  @override
  String get subtitle2Family => 'Poppins';
  @override
  TextStyle get subtitle2 => GoogleFonts.poppins(
        fontSize: 24,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );

  @override
  String get bodyText1Family => 'Poppins';
  @override
  TextStyle get bodyText1 => GoogleFonts.poppins(
        fontSize: 20,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
      );
  @override
  String get bodyText2Family => 'Poppins';
  @override
  TextStyle get bodyText2 => GoogleFonts.poppins(
        fontSize: 18,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
      );
  @override
  String get bodyText3Family => 'Poppins';
  @override
  TextStyle get bodyText3 => GoogleFonts.poppins(
        fontSize: 14,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
      );
  @override
  String get plutoDataTextFamily => 'Poppins';
  @override
  TextStyle get plutoDataText => GoogleFonts.poppins(
        fontSize: 12,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
      );
  @override
  String get copyRightTextFamily => 'Poppins';
  @override
  TextStyle get copyRightText => GoogleFonts.poppins(
        fontSize: 12,
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
      );
}
