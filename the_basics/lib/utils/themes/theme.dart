import 'package:flutter/material.dart';
import 'package:the_basics/utils/themes/custom/app_bar_theme.dart';
import 'package:the_basics/utils/themes/custom/checkbox_theme.dart';
import 'package:the_basics/utils/themes/custom/elevated_button_theme.dart';
import 'package:the_basics/utils/themes/custom/text_field_theme.dart';
import 'package:the_basics/utils/themes/custom/text_theme.dart';

class MyAppTheme {
  MyAppTheme._(); //create private constructor

  static ThemeData lightTheme  = ThemeData(
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
  );


  static ThemeData darkTheme  = ThemeData(
      useMaterial3: true,
      //fontFamily: 'Inter',
      brightness: Brightness.dark,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.grey.shade600,
      textTheme: MyTextTheme.darkTextTheme,
      elevatedButtonTheme: MyElevatedButtonTheme.darkElevatedButtonTheme
  );
}