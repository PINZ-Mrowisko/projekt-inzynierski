// template_dialog_constants.dart
import 'package:flutter/material.dart';
import 'package:the_basics/utils/app_colors.dart';

class TemplateDialogConstants {
  // polish day names and abbreviations
  static final List<Map<String, String>> polishDays = [
    {'full': 'Poniedziałek', 'short': 'Pn'},
    {'full': 'Wtorek', 'short': 'Wt'},
    {'full': 'Środa', 'short': 'Śr'},
    {'full': 'Czwartek', 'short': 'Cz'},
    {'full': 'Piątek', 'short': 'Pt'},
    {'full': 'Sobota', 'short': 'Sb'},
    {'full': 'Niedziela', 'short': 'Nd'},
  ];

  static final List<String> timeOptions = List.generate(48, (index) {
    final hour = (index ~/ 2).toString().padLeft(2, '0');
    final minute = (index % 2 == 0) ? '00' : '30';
    return '$hour:$minute';
  });

  static final commonWorkHours = [
    '06:00', '06:30', '07:00', '07:30', '08:00', '08:30',
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
    '18:00', '18:30', '19:00', '19:30', '20:00', '20:30',
    '21:00', '21:30', '22:00', '22:30', '23:00', '23:30'
  ];

  // Helper functions
  static TimeOfDay? parseTime(String timeText) {
    try {
      final parts = timeText.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null && hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static List<String> filterTimeOptions(String input) {
    if (input.isEmpty) {
      return commonWorkHours.take(12).toList();
    }

    return timeOptions.where((time) {
      return time.toLowerCase().contains(input.toLowerCase());
    }).toList();
  }

  static String getDayCountText(int count) {
    if (count == 1) return 'dzień';
    if (count >= 2 && count <= 4) return 'dni';
    return 'dni';
  }

  static TextStyle get titleStyle => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppColors.textColor2,
  );

  static TextStyle get labelStyle => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textColor2,
  );

  static TextStyle get hintStyle => TextStyle(
    fontSize: 12,
    color: AppColors.textColor2.withOpacity(0.6),
  );

  static TextStyle get buttonTextStyle => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textColor2,
  );
}