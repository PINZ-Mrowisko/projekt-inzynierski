import 'package:flutter/material.dart';

class MyTextTheme {
  MyTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: TextStyle().copyWith(fontSize: 32.0, fontWeight: FontWeight.bold, color: Color(0xff494646)),
    headlineMedium: TextStyle().copyWith(fontSize: 24.0, fontWeight: FontWeight.w700, color: Color(0xff494646)),
    headlineSmall: TextStyle().copyWith(fontSize: 18.0, fontWeight: FontWeight.w300, color: Color(0xff494646)),

    labelLarge: TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: Color(0xff494646)),
    labelMedium: TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: Color(0xff494646).withValues(alpha: 0.5))

    // etc zalezy czego bedziemy uzywac, czy jeszcze jakis title, body text czy innych
    // warto tutaj to konfigurowac i od razu tak uzywac zeby bylo uniformowo w calej aplikacji
  );

  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: TextStyle().copyWith(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
    headlineMedium: TextStyle().copyWith(fontSize: 24.0, fontWeight: FontWeight.w700, color: Colors.white),
    headlineSmall: TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w300, color: Colors.white),

    labelLarge: TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.white),
    labelMedium: TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.white.withValues(alpha: 0.5))
  );
}
