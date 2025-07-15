import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'package:nethive_neo/helpers/supabase/queries.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

const storage = FlutterSecureStorage();

final supabase = Supabase.instance.client;
late SupabaseClient supabaseLU;

late final SharedPreferences prefs;
late Configuration? theme;

User? currentUser;

Future<void> initGlobals() async {
  prefs = await SharedPreferences.getInstance();
  currentUser = await SupabaseQueries.getCurrentUserData();
  /* //Temas de la aplicacion
  if (currentUser == null) {
    Configuration? conf = await SupabaseQueries.getDefaultTheme();
    AppTheme.initConfiguration(conf);
  } else {
    theme = await SupabaseQueries.getUserTheme();
    AppTheme.initConfiguration(theme);
  }
 */
  if (currentUser == null) return;
}

PlutoGridScrollbarConfig plutoGridScrollbarConfig(BuildContext context) {
  return PlutoGridScrollbarConfig(
    isAlwaysShown: true,
    scrollbarThickness: 5,
    hoverWidth: 20,
    scrollBarColor: AppTheme.of(context).primaryColor,
  );
}

PlutoGridStyleConfig plutoGridStyleConfig(BuildContext context,
    {double rowHeight = 50}) {
  return AppTheme.themeMode == ThemeMode.light
      ? PlutoGridStyleConfig(
          menuBackgroundColor: AppTheme.of(context).secondaryColor,
          gridPopupBorderRadius: BorderRadius.circular(16),
          enableColumnBorderVertical: false,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: true,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: AppTheme.of(context).bodyText3Family,
                color: AppTheme.of(context).primaryColor,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          rowColor: Colors.transparent,
          borderColor: const Color(0xFFF1F4FA),
          rowHeight: rowHeight,
          checkedColor: AppTheme.themeMode == ThemeMode.light
              ? AppTheme.of(context).secondaryColor
              : const Color(0XFF4B4B4B),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
        )
      : PlutoGridStyleConfig.dark(
          menuBackgroundColor: AppTheme.of(context).secondaryColor,
          gridPopupBorderRadius: BorderRadius.circular(16),
          enableColumnBorderVertical: false,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: true,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Quicksand',
                color: AppTheme.of(context).alternate,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          rowColor: Colors.transparent,
          borderColor: const Color(0xFFF1F4FA),
          rowHeight: rowHeight,
          checkedColor: AppTheme.themeMode == ThemeMode.light
              ? AppTheme.of(context).secondaryColor
              : const Color(0XFF4B4B4B),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
        );
}

PlutoGridStyleConfig plutoGridBigStyleConfig(BuildContext context) {
  return AppTheme.themeMode == ThemeMode.light
      ? PlutoGridStyleConfig(
          menuBackgroundColor: AppTheme.of(context).secondaryColor,
          gridPopupBorderRadius: BorderRadius.circular(16),
          enableColumnBorderVertical: false,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: true,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Quicksand',
                color: AppTheme.of(context).hintText,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          rowColor: Colors.transparent,
          borderColor: Colors.transparent,
          rowHeight: 50,
          checkedColor: AppTheme.themeMode == ThemeMode.light
              ? AppTheme.of(context).secondaryColor
              : const Color(0XFF4B4B4B),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
          columnHeight: 100,
          gridBorderRadius: BorderRadius.circular(16),
        )
      : PlutoGridStyleConfig.dark(
          menuBackgroundColor: AppTheme.of(context).secondaryColor,
          gridPopupBorderRadius: BorderRadius.circular(16),
          enableColumnBorderVertical: false,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: true,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Quicksand',
                color: AppTheme.of(context).alternate,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          rowColor: Colors.transparent,
          borderColor: const Color(0xFFF1F4FA),
          rowHeight: 50,
          checkedColor: AppTheme.themeMode == ThemeMode.light
              ? AppTheme.of(context).secondaryColor
              : const Color(0XFF4B4B4B),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
          columnHeight: 100,
          gridBorderRadius: BorderRadius.circular(16),
        );
}

PlutoGridStyleConfig plutoGridDashboardStyleConfig(BuildContext context) {
  return AppTheme.themeMode == ThemeMode.light
      ? PlutoGridStyleConfig(
          menuBackgroundColor: AppTheme.of(context).secondaryColor,
          gridPopupBorderRadius: BorderRadius.circular(16),
          enableColumnBorderVertical: false,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: true,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Quicksand',
                color: AppTheme.of(context).hintText,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          rowColor: Colors.transparent,
          borderColor: const Color(0xFFF1F4FA),
          rowHeight: 50,
          checkedColor: AppTheme.themeMode == ThemeMode.light
              ? AppTheme.of(context).secondaryColor
              : const Color(0XFF4B4B4B),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
        )
      : PlutoGridStyleConfig.dark(
          menuBackgroundColor: AppTheme.of(context).secondaryColor,
          gridPopupBorderRadius: BorderRadius.circular(16),
          enableColumnBorderVertical: false,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: true,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Quicksand',
                color: AppTheme.of(context).alternate,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          rowColor: Colors.transparent,
          borderColor: const Color(0xFFF1F4FA),
          rowHeight: 50,
          checkedColor: AppTheme.themeMode == ThemeMode.light
              ? AppTheme.of(context).secondaryColor
              : const Color(0XFF4B4B4B),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
        );
}

double rowHeight = 60;

PlutoGridStyleConfig plutoGridPopUpStyleConfig(BuildContext context) {
  return AppTheme.themeMode == ThemeMode.light
      ? PlutoGridStyleConfig(
          menuBackgroundColor: AppTheme.of(context).secondaryBackground,
          gridPopupBorderRadius: BorderRadius.circular(16),
          //
          enableColumnBorderVertical: false,
          columnTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          borderColor: Colors.transparent,
          //
          rowHeight: 40,
          rowColor: Colors.transparent,
          cellTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: AppTheme.of(context).bodyText3Family,
                color: AppTheme.of(context).primaryText,
              ),
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: false,
          checkedColor: Colors.transparent,
          enableRowColorAnimation: false,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          //
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
        )
      : PlutoGridStyleConfig.dark(
          menuBackgroundColor: Colors.transparent,
          //
          enableColumnBorderVertical: false,
          columnTextStyle: AppTheme.of(context).copyRightText,
          iconColor: AppTheme.of(context).tertiaryColor,
          borderColor: Colors.transparent,
          //
          rowHeight: 40,
          rowColor: Colors.transparent,
          cellTextStyle: AppTheme.of(context).copyRightText,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: false,
          checkedColor: Colors.transparent,
          enableRowColorAnimation: false,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          //
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
        );
}

PlutoGridStyleConfig plutoGridStyleConfigContentManager(BuildContext context,
    {double rowHeight = 50}) {
  return AppTheme.themeMode == ThemeMode.light
      ? PlutoGridStyleConfig(
          menuBackgroundColor: AppTheme.of(context).secondaryColor,
          gridPopupBorderRadius: BorderRadius.circular(16),
          enableColumnBorderVertical: true,
          enableColumnBorderHorizontal: true,
          enableCellBorderVertical: true,
          enableCellBorderHorizontal: true,
          columnHeight: 100,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: AppTheme.of(context).bodyText3Family,
                color: AppTheme.of(context).primaryColor,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          rowColor: Colors.transparent,
          borderColor: const Color(0xFFF1F4FA),
          rowHeight: rowHeight,
          checkedColor: AppTheme.themeMode == ThemeMode.light
              ? AppTheme.of(context).secondaryColor
              : const Color(0XFF4B4B4B),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
          gridBorderRadius: BorderRadius.circular(16),
        )
      : PlutoGridStyleConfig.dark(
          menuBackgroundColor: AppTheme.of(context).secondaryColor,
          gridPopupBorderRadius: BorderRadius.circular(16),
          enableColumnBorderVertical: true,
          enableColumnBorderHorizontal: true,
          enableCellBorderVertical: true,
          enableCellBorderHorizontal: true,
          columnHeight: 100,
          columnTextStyle: AppTheme.of(context).bodyText3.override(
                fontFamily: 'Quicksand',
                color: AppTheme.of(context).alternate,
              ),
          cellTextStyle: AppTheme.of(context).bodyText3,
          iconColor: AppTheme.of(context).tertiaryColor,
          rowColor: Colors.transparent,
          borderColor: const Color(0xFFF1F4FA),
          rowHeight: rowHeight,
          checkedColor: AppTheme.themeMode == ThemeMode.light
              ? AppTheme.of(context).secondaryColor
              : const Color(0XFF4B4B4B),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: AppTheme.of(context).primaryBackground,
          activatedBorderColor: AppTheme.of(context).tertiaryColor,
        );
}
