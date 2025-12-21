import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/utils/app_colors.dart';

class SpecialRegionsBuilder {
  List<TimeRegion> getSpecialRegions() {
    final DateTime now = DateTime.now();
    final DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(365, (index) {
      final day = monday.subtract(const Duration(days: 180)).add(Duration(days: index));
      return TimeRegion(
        startTime: DateTime(day.year, day.month, day.day, 8, 0),
        endTime: DateTime(day.year, day.month, day.day, 20, 59),
        enablePointerInteraction: false,
        color: day.weekday.isEven ? AppColors.lightBlue : Colors.transparent,
        text: '',
      );
    });
  }
}