import 'package:flutter/material.dart';

class MyAppBar {
  MyAppBar._();

  static const lightAppBar = AppBarTheme(
      elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)
  );

  // do zmiany
  static const darkAppBar = AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)
  );

}
