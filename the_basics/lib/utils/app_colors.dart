import 'package:flutter/material.dart';

class AppColors {
  static Color get pageBackground => _isDarkMode ? Color(0xFF121212) : Color(0xFFF5F5F5);
  static Color get logo => _isDarkMode ? Color(0xFF64B5F6) : Color(0xFF00529F);
  static Color get logolighter => _isDarkMode ? Color(0xFF90CAF9) : Color.fromARGB(255, 41, 114, 182);
  static Color get lightBlue => _isDarkMode ? Color(0xFF1E2A38) : Color(0xFFD2DEEB);
  static Color get blue => _isDarkMode ? Color(0xFF455A64) : Color(0xFFA8B9CE);
  static Color get textColor1 => _isDarkMode ? Colors.white : Color(0xFF1D1B20);
  static Color get textColor2 => _isDarkMode ? const Color.fromARGB(226, 255, 255, 255) : Color(0xFF49454F);
  static Color get divider => _isDarkMode ? Color(0xFF2C2C2C) : Color(0xFFD9D9D9);
  static Color get warning => _isDarkMode ? Color(0xFFEF5350) : Color(0xFFEC221F);
  
  static Color get white => _isDarkMode ? Color.fromARGB(255, 36, 36, 36) : Colors.white;
  static Color get black => _isDarkMode ? Colors.white : Colors.black;
  static const Color transparent = Colors.transparent;

  static bool get _isDarkMode {
    final context = _getContext();
    if (context != null) {
      return Theme.of(context).brightness == Brightness.dark;
    }
    return false; // domyślnie light theme
  }

  static BuildContext? _getContext() {
    try {
      return navigatorKey.currentContext;
    } catch (e) {
      return null;
    }
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();