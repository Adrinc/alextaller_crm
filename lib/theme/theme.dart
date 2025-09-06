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
      Color(0xFFFF6B00), // Naranja de acento
      Color(0xFF0A0A0A), // Negro de fondo
    ],
  );

  // Nuevo gradiente para elementos modernos
  Gradient modernGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFFF007F), // Rosa fucsia principal
      Color(0xFFFF6B00), // Naranja de acento
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
      const Color(0xFF1A1A1A).withOpacity(.1); // Fondo transparente
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
  Color formBackground = const Color(0xFFFF007F)
      .withOpacity(.05); // Fondo de formularios con rosa fucsia

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
  Color formBackground = const Color(0xFFFF007F)
      .withOpacity(.1); // Fondo de formularios con rosa fucsia

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
        fontSize: 70,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );
  @override
  String get title2Family => 'Poppins';
  @override
  TextStyle get title2 => GoogleFonts.poppins(
        fontSize: 65,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );
  @override
  String get title3Family => 'Poppins';
  @override
  TextStyle get title3 => GoogleFonts.poppins(
        fontSize: 48,
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
