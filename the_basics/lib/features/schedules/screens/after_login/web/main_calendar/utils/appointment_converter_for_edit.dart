import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/leaves/models/leave_model.dart';
import 'package:the_basics/features/schedules/controllers/schedule_controller.dart';
import 'package:the_basics/features/schedules/models/schedule_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/app_colors.dart';

class AppointmentConverterForEdit {

  // Zakres widoczności (musi być zgodny z MainCalendarEdit)
  static const int viewStartHour = 7;
  static const int viewEndHour = 21;
  // Minimalna wizualna szerokość kafelka w minutach
  static const int minVisualDurationMinutes = 315;

  List<Appointment> getAppointments(
      List<UserModel> filteredEmployees,
      {List<LeaveModel>? leaves}
      ) {
    final scheduleController = Get.find<SchedulesController>();
    final tagsController = Get.find<TagsController>();
    final userController = Get.find<UserController>();

    final appointments = <Appointment>[];

    // Zliczanie Unknown na dany dzień
    final Map<String, int> unknownCounts = {};
    for (final shift in scheduleController.individualShifts) {
      if (shift.employeeID == 'Unknown') {
        final key = '${shift.shiftDate.year}-${shift.shiftDate.month}-${shift.shiftDate.day}';
        unknownCounts[key] = (unknownCounts[key] ?? 0) + 1;
      }
    }

    final Set<String> processedUnknownDates = {};

    final sortedShifts = List<ScheduleModel>.from(scheduleController.individualShifts);
    sortedShifts.sort((a, b) {
      int dateComp = a.shiftDate.compareTo(b.shiftDate);
      if (dateComp != 0) return dateComp;
      return a.start.hour.compareTo(b.start.hour);
    });

    // --- PRZETWARZANIE ZMIAN (SHIFTS) ---
    for (final shift in sortedShifts) {
      final isUnknown = shift.employeeID == 'Unknown';
      final employeeExists = filteredEmployees.any((emp) => emp.id == shift.employeeID);

      if (isUnknown) {
        final dateKey = '${shift.shiftDate.year}-${shift.shiftDate.month}-${shift.shiftDate.day}';
        if (processedUnknownDates.contains(dateKey)) {
          continue;
        }
        processedUnknownDates.add(dateKey);
      }

      if (isUnknown || employeeExists) {
        // PRAWDZIWE DANE
        final realStart = DateTime(
          shift.shiftDate.year, shift.shiftDate.month, shift.shiftDate.day,
          shift.start.hour, shift.start.minute,
        );
        final realEnd = DateTime(
          shift.shiftDate.year, shift.shiftDate.month, shift.shiftDate.day,
          shift.end.hour, shift.end.minute,
        );

        DateTime visualStart = realStart;
        DateTime visualEnd = realEnd;
        bool isClamped = false;

        final viewStartDateTime = DateTime(realStart.year, realStart.month, realStart.day, viewStartHour, 0);
        final viewEndDateTime = DateTime(realStart.year, realStart.month, realStart.day, viewEndHour, 0);

        // A. Całkowicie przed widokiem (np. 05:00-06:00) -> Przyklej do 7:00
        if (realEnd.isBefore(viewStartDateTime) || realEnd.isAtSameMomentAs(viewStartDateTime)) {
          visualStart = viewStartDateTime;
          visualEnd = viewStartDateTime.add(Duration(minutes: minVisualDurationMinutes));
          isClamped = true;
        }
        // B. Całkowicie po widoku (np. 22:00-23:00) -> Przyklej przed 21:00
        else if (realStart.isAfter(viewEndDateTime) || realStart.isAtSameMomentAs(viewEndDateTime)) {
          visualEnd = viewEndDateTime;
          visualStart = viewEndDateTime.subtract(Duration(minutes: minVisualDurationMinutes));
          isClamped = true;
        }
        // C. W środku lub wystaje
        else {
          // C. W środku lub wystaje na krawędziach

          // Utnij start do 7:00
          if (visualStart.isBefore(viewStartDateTime)) {
            visualStart = viewStartDateTime;
            isClamped = true;
          }

          // Utnij koniec do 21:00 (rozwiązuje problem wystawania na kolejny dzień)
          if (visualEnd.isAfter(viewEndDateTime)) {
            visualEnd = viewEndDateTime;
            // Nie ustawiam isClamped = true, żeby nie było strzałki, ale można
          }

          // D. Sprawdzenie minimalnej długości
          final currentDuration = visualEnd.difference(visualStart).inMinutes;

          if (currentDuration < minVisualDurationMinutes) {
            // Oblicz ile brakuje
            final int missing = minVisualDurationMinutes - currentDuration;

            // Spróbuj wydłużyć w prawo
            DateTime proposedEnd = visualEnd.add(Duration(minutes: missing));

            if (proposedEnd.isAfter(viewEndDateTime)) {
              // ŚCIANA 21:00! Nie możemy wydłużyć w prawo.
              visualEnd = viewEndDateTime;

              // WYDŁUŻAMY W LEWO (wstecz)
              visualStart = visualEnd.subtract(Duration(minutes: minVisualDurationMinutes));

              // Zabezpieczenie: nie wyjdź przed 7:00
              if (visualStart.isBefore(viewStartDateTime)) {
                visualStart = viewStartDateTime;
              }
            } else {
              // Mamy miejsce z prawej, wydłużamy normalnie
              visualEnd = proposedEnd;
            }
          }
        }

        // TAGI
        final tagNames = _convertTagIdsToNames(shift.tags, tagsController);
        final String displayTags = tagNames.isNotEmpty
            ? tagNames.join(', ')
            : 'Brak tagów';

        // PAKOWANIE DANYCH DO LOCATION
        // Format: Counter ;; PrawdziwyCzas ;; isClamped
        String counterPart = '';
        if (isUnknown) {
          final dateKey = '${shift.shiftDate.year}-${shift.shiftDate.month}-${shift.shiftDate.day}';
          final count = unknownCounts[dateKey] ?? 0;
          if (count > 1) {
            counterPart = '(+${count - 1})';
          }
        }

        final timePart = '${shift.start.hour.toString().padLeft(2, '0')}:${shift.start.minute.toString().padLeft(2, '0')} - '
            '${shift.end.hour.toString().padLeft(2, '0')}:${shift.end.minute.toString().padLeft(2, '0')}';

        // Result: "(+2);;05:00 - 06:00;;1"
        final String packedLocation = '$counterPart;;$timePart;;${isClamped ? "1" : "0"}';

        // OSTRZEŻENIA O BRAKUJĄCYCH TAGACH
        bool hasMissingTags = false;
        if (!isUnknown && shift.tags.isNotEmpty) {
          final employee = userController.allEmployees.firstWhereOrNull(
                  (emp) => emp.id == shift.employeeID
          );
          if (employee != null) {
            final employeeTagNames = employee.tags.toSet();
            hasMissingTags = tagNames.any(
                    (tagName) => !employeeTagNames.contains(tagName)
            );
          }
        }

        String displayNotes = displayTags;
        if (hasMissingTags) {
          displayNotes = '⚠️ $displayTags';
        }

        appointments.add(
          Appointment(
            startTime: visualStart,
            endTime: visualEnd,
            subject: displayTags,
            color: _getAppointmentColor(shift),
            resourceIds: <Object>[shift.employeeID],
            notes: displayNotes,
            location: packedLocation, // <--- Przekazujemy paczkę danych
            id: '${shift.employeeID}_${shift.shiftDate.day}_'
                '${shift.start.hour}:${shift.start.minute}_'
                '${shift.end.hour}:${shift.end.minute}',
          ),
        );
      }
    }

    // --- PRZETWARZANIE URLOPÓW (ZACHOWANA ORYGINALNA LOGIKA) ---
    if (leaves != null) {
      for (final leave in leaves) {
        if (leave.status.toLowerCase() == 'zaakceptowany' ||
            leave.status.toLowerCase() == 'mój urlop') {

          final employee = filteredEmployees.firstWhere(
                (emp) => emp.id == leave.userId,
            orElse: () => UserModel.empty(),
          );

          if (employee.id != null) {
            final startDateTime = DateTime(
              leave.startDate.year,
              leave.startDate.month,
              leave.startDate.day,
              8, // standard time for leave start 8:00 AM
              0,
            );

            final endDateTime = DateTime(
              leave.endDate.year,
              leave.endDate.month,
              leave.endDate.day,
              16, // standard time for leave end 4:00 PM
              0,
            );

            // full coverage if multi-day leave
            final visualEndDateTime = leave.startDate.isAtSameMomentAs(leave.endDate)
                ? startDateTime.add(Duration(hours: 8))
                : endDateTime;

            appointments.add(
              Appointment(
                startTime: startDateTime,
                endTime: visualEndDateTime,
                subject: 'Urlop',
                color: Colors.orangeAccent,
                resourceIds: <Object>[leave.userId],
                notes: leave.comment?.isNotEmpty == true
                    ? '${leave.comment}'
                    : 'Urlop (${leave.status})',
                id: 'leave_${leave.id}_${leave.userId}',
              ),
            );
          }
        }
      }
    }

    return appointments;
  }

  List<String> _convertTagIdsToNames(
      List<String> tagIds,
      TagsController tagsController,
      ) {
    final tagMap = {
      for (final tag in tagsController.allTags) tag.id: tag.tagName
    };

    return tagIds.map((id) {
      final name = tagMap[id];
      return (name != null && name.isNotEmpty) ? name : "Tag usunięty";
    }).toList();
  }

  Color _getAppointmentColor(ScheduleModel shift) {
    if (shift.employeeID == 'Unknown') {
      return AppColors.warning;
    }

    if (shift.start.hour >= 12) {
      return AppColors.logolighter;
    } else {
      return AppColors.logo;
    }
  }
}