import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/leaves/models/leave_model.dart';
import 'package:the_basics/features/schedules/controllers/schedule_controller.dart';
import 'package:the_basics/features/schedules/models/schedule_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/app_colors.dart';

class AppointmentConverter {

  static const int viewStartHour = 7;
  static const int viewEndHour = 21;
  static const int minVisualDurationMinutes = 315;

  List<Appointment> getAppointments(List<UserModel> filteredEmployees, {List<LeaveModel>? leaves}) {
    final scheduleController = Get.find<SchedulesController>();
    final tagsController = Get.find<TagsController>();

    final appointments = <Appointment>[];

    // shifts with real times
    for (final shift in scheduleController.individualShifts) {
      final employee = filteredEmployees.firstWhere(
            (emp) => emp.id == shift.employeeID,
        orElse: () => UserModel.empty(),
      );

      if (employee.id != null) {
        final realStart = DateTime(
          shift.shiftDate.year,
          shift.shiftDate.month,
          shift.shiftDate.day,
          shift.start.hour,
          shift.start.minute,
        );

        final realEnd = DateTime(
          shift.shiftDate.year,
          shift.shiftDate.month,
          shift.shiftDate.day,
          shift.end.hour,
          shift.end.minute,
        );

        DateTime visualStart = realStart;
        DateTime visualEnd = realEnd;
        bool isClamped = false;

        final viewStartDateTime = DateTime(realStart.year, realStart.month, realStart.day, viewStartHour, 0);
        final viewEndDateTime = DateTime(realStart.year, realStart.month, realStart.day, viewEndHour, 0);

        // A. Całkowicie przed widokiem -> Przyklej do startu
        if (realEnd.isBefore(viewStartDateTime) || realEnd.isAtSameMomentAs(viewStartDateTime)) {
          visualStart = viewStartDateTime;
          visualEnd = viewStartDateTime.add(const Duration(minutes: minVisualDurationMinutes));
          isClamped = true;
        }
        // B. Całkowicie po widoku -> Przyklej do końca
        else if (realStart.isAfter(viewEndDateTime) || realStart.isAtSameMomentAs(viewEndDateTime)) {
          visualEnd = viewEndDateTime;
          visualStart = viewEndDateTime.subtract(const Duration(minutes: minVisualDurationMinutes));
          isClamped = true;
        }
        else {
          // C. W środku lub wystaje

          // Utnij start do 7:00
          if (visualStart.isBefore(viewStartDateTime)) {
            visualStart = viewStartDateTime;
            isClamped = true;
          }

          // Utnij koniec do 21:00
          if (visualEnd.isAfter(viewEndDateTime)) {
            visualEnd = viewEndDateTime;
          }

          // D. Minimalna długość
          final currentDuration = visualEnd.difference(visualStart).inMinutes;

          if (currentDuration < minVisualDurationMinutes) {
            final int missing = minVisualDurationMinutes - currentDuration;

            DateTime proposedEnd = visualEnd.add(Duration(minutes: missing));

            if (proposedEnd.isAfter(viewEndDateTime)) {
              visualEnd = viewEndDateTime;
              visualStart = visualEnd.subtract(const Duration(minutes: minVisualDurationMinutes));

              if (visualStart.isBefore(viewStartDateTime)) {
                visualStart = viewStartDateTime;
              }
            } else {
              visualEnd = proposedEnd;
            }
          }
        }

        // tags conversion
        final tagNames = _convertTagIdsToNames(shift.tags, tagsController);
        final displayTags = tagNames.isNotEmpty
            ? tagNames.join(', ')
            : 'Brak tagów';

        final timePart = '${shift.start.hour.toString().padLeft(2, '0')}:${shift.start.minute.toString().padLeft(2, '0')} - '
            '${shift.end.hour.toString().padLeft(2, '0')}:${shift.end.minute.toString().padLeft(2, '0')}';

        final String packedLocation = ';;$timePart;;${isClamped ? "1" : "0"}';

        appointments.add(
          Appointment(
            startTime: visualStart,
            endTime: visualEnd,
            subject: displayTags,
            color: _getAppointmentColor(shift),
            resourceIds: <Object>[shift.employeeID],
            notes: displayTags,
            location: packedLocation,
            id: '${shift.employeeID}_${shift.shiftDate.day}_${shift.start.hour}:${shift.start.minute}_${shift.end.hour}:${shift.end.minute}',
          ),
        );
      }
    }

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
              8,
              0,
            );

            final endDateTime = DateTime(
              leave.endDate.year,
              leave.endDate.month,
              leave.endDate.day,
              16,
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

  // help function to convert tag IDs to names
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
    if (shift.start.hour >= 12) {
    return AppColors.logolighter;
  } else {
    return AppColors.logo;
  }
  }
}