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
  List<Appointment> getAppointments(
      List<UserModel> filteredEmployees,
      {List<LeaveModel>? leaves}
      ) {
    final scheduleController = Get.find<SchedulesController>();
    final tagsController = Get.find<TagsController>();
    final userController = Get.find<UserController>();

    final appointments = <Appointment>[];

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

    // Shifts
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
        final startDateTime = DateTime(
          shift.shiftDate.year,
          shift.shiftDate.month,
          shift.shiftDate.day,
          shift.start.hour,
          shift.start.minute,
        );

        final endDateTime = DateTime(
          shift.shiftDate.year,
          shift.shiftDate.month,
          shift.shiftDate.day,
          shift.end.hour,
          shift.end.minute,
        );

        final tagNames = _convertTagIdsToNames(shift.tags, tagsController);
        final String displayTags = tagNames.isNotEmpty
            ? tagNames.join(', ')
            : 'Brak tagów';

        String counterForLocation = '';
        String displayTagsForNotes = displayTags;

        if (isUnknown) {
          final dateKey = '${shift.shiftDate.year}-${shift.shiftDate.month}-${shift.shiftDate.day}';
          final count = unknownCounts[dateKey] ?? 0;

          if (count > 1) {
            counterForLocation = '(+${count - 1})';
            displayTagsForNotes = '$displayTags $counterForLocation';
          }
        }

        // Logika brakujących tagów
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

        String displayNotes = displayTagsForNotes;
        if (hasMissingTags) {
          displayNotes = '⚠️ $displayTagsForNotes';
        }

        appointments.add(
          Appointment(
            startTime: startDateTime,
            endTime: endDateTime,
            subject: displayTags,
            color: _getAppointmentColor(shift),
            resourceIds: <Object>[shift.employeeID],
            notes: displayNotes,
            location: counterForLocation, // tu mamy nasz licznik
            id: '${shift.employeeID}_${shift.shiftDate.day}_'
                '${shift.start.hour}:${shift.start.minute}_'
                '${shift.end.hour}:${shift.end.minute}',
          ),
        );
      }
    }

    // Leaves
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

  List<String> _convertTagIdsToNames(List<String> tagIds, TagsController tagsController) {
    final List<String> tagNames = [];

    for (final tagId in tagIds) {
      final tag = tagsController.allTags.firstWhere(
            (t) => t.id == tagId,
      );

      if (tag != null && tag.tagName != null && tag.tagName!.isNotEmpty) {
        tagNames.add(tag.tagName!);
      } else {
        tagNames.add(tagId);
      }
    }

    return tagNames;
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