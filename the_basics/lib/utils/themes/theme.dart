import 'package:flutter/material.dart';
import 'package:the_basics/utils/themes/custom/app_bar_theme.dart';
import 'package:the_basics/utils/themes/custom/checkbox_theme.dart';
import 'package:the_basics/utils/themes/custom/elevated_button_theme.dart';
import 'package:the_basics/utils/themes/custom/text_field_theme.dart';
import 'package:the_basics/utils/themes/custom/text_theme.dart';

class MyAppTheme {
  MyAppTheme._(); //create private constructor

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    //fontFamily: 'Inter', //TODO: import text family
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    textTheme: MyTextTheme.lightTextTheme,
    elevatedButtonTheme: MyElevatedButtonTheme.lightElevatedButtonTheme,
    checkboxTheme: MyCheckboxTheme.lightCheckboxTheme,
    inputDecorationTheme: MyTextFieldTheme.lightInputDecorationTheme,
    appBarTheme: MyAppBar.lightAppBar,
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      iconColor: Colors.grey.shade700,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    //fontFamily: 'Inter',
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Color(0xFF121212),
    textTheme: MyTextTheme.darkTextTheme,
    elevatedButtonTheme: MyElevatedButtonTheme.darkElevatedButtonTheme,
    checkboxTheme: MyCheckboxTheme.darkCheckboxTheme,
    inputDecorationTheme: MyTextFieldTheme.darkInputDecorationTheme,
    appBarTheme: MyAppBar.darkAppBar,
    cardTheme: CardThemeData(
      color: Color(0xFF1E1E1E),
      surfaceTintColor: Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      surfaceTintColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade700,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      iconColor: Colors.grey.shade400,
    ),
    colorScheme: ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.blue.shade300,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      onSurface: Colors.white,
    ),
  );
}