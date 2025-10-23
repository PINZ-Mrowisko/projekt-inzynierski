import 'package:flutter/material.dart';

class MyTextTheme {
  MyTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    // Headlines
    headlineLarge: TextStyle().copyWith(fontSize: 32.0, fontWeight: FontWeight.bold, color: Color(0xff494646)),
    headlineMedium: TextStyle().copyWith(fontSize: 24.0, fontWeight: FontWeight.w700, color: Color(0xff494646)),
    headlineSmall: TextStyle().copyWith(fontSize: 18.0, fontWeight: FontWeight.w600, color: Color(0xff494646)),

    // Titles
    titleLarge: TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w600, color: Color(0xff494646)),
    titleMedium: TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w500, color: Color(0xff494646)),
    titleSmall: TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: Color(0xff494646)),

    // Body
    bodyLarge: TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.w500, color: Color(0xff494646)),
    bodyMedium: TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.normal, color: Color(0xff494646)),
    bodySmall: TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.normal, color: Color(0xff494646).withOpacity(0.5)),

    // Labels
    labelLarge: TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: Color(0xff494646)),
    labelMedium: TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: Color(0xff494646).withOpacity(0.5)),
  );

  static TextTheme darkTextTheme = TextTheme(
    // Headlines
    headlineLarge: TextStyle().copyWith(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
    headlineMedium: TextStyle().copyWith(fontSize: 24.0, fontWeight: FontWeight.w700, color: Colors.white),
    headlineSmall: TextStyle().copyWith(fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.white),

    // Titles
    titleLarge: TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w600, color: Colors.white),
    titleMedium: TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.white),
    titleSmall: TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: Colors.white),

    // Body
    bodyLarge: TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.w500, color: Colors.white),
    bodyMedium: TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.white),
    bodySmall: TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.white.withOpacity(0.7)),

    // Labels
    labelLarge: TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.white),
    labelMedium: TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.white.withOpacity(0.5)),
  );
}