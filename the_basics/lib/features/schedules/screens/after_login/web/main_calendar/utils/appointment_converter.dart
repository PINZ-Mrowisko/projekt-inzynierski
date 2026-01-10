//////////////////////////////////////////////////////////////////////

// In this file: our specific ScheduleModels are being converted into appointments - they are used in the custom Calendar Zosia put in
// CHANGED: real times provided for tile width
// real shift end is passed in ID, and then parsed to be displayed in appointment builder
// no szczerze nie wiem co mam powiedziec jest to troche glupie i przekomplikowane ale inaczej wygladalo zle

/////////////////////////////////////////////////////////////////////

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

        // tags conversion
        final tagNames = _convertTagIdsToNames(shift.tags, tagsController);
        final displayTags = tagNames.isNotEmpty 
            ? tagNames.join(', ')
            : 'Brak tagów';


      appointments.add(
        Appointment(
          startTime: startDateTime,
          endTime: endDateTime,
          subject: displayTags,
          color: _getAppointmentColor(shift),
          resourceIds: <Object>[shift.employeeID],
          notes: displayTags,
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