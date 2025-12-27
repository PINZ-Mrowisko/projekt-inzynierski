//////////////////////////////////////////////////////////////////////

// In this file: our specific ScheduleModels are being converted into appointments - they are used in the custom Calendar Zosia put in
// as decided: fake end time is passed in order to provide correct tile width
// real shift end is passed in ID, and then parsed to be displayed in appointment builder
// no szczerze nie wiem co mam powiedziec jest to troche glupie i przekomplikowane ale inaczej wygladalo zle

/////////////////////////////////////////////////////////////////////

import 'dart:ui';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/schedules/controllers/schedule_controller.dart';
import 'package:the_basics/features/schedules/models/schedule_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';

class AppointmentConverter {
  List<Appointment> getAppointments(List<UserModel> filteredEmployees) {
    final scheduleController = Get.find<SchedulesController>();

    return scheduleController.individualShifts.map((shift) {
      final startDateTime = DateTime(
        shift.shiftDate.year,
        shift.shiftDate.month,
        shift.shiftDate.day,
        shift.start.hour,
        shift.start.minute,
      );

      // FAKE 8-hour duration for visual width !!!!!!!!!
      final visualEndDateTime = startDateTime.add(Duration(hours: 8));

      return Appointment(
        startTime: startDateTime,
        endTime: visualEndDateTime,
        subject: 'Zmiana',
        color: _getAppointmentColor(shift),
        resourceIds: <Object>[shift.employeeID],
        notes: shift.tags.join(', '),
        id: '${shift.employeeID}_${shift.shiftDate.day}_${shift.start.hour}:${shift.start.minute}_${shift.end.hour}:${shift.end.minute}',
      );
    }).toList();
  }

  Color _getAppointmentColor(ScheduleModel shift) {
    return AppColors.logo; // just single color for simplicity, can be changed here
  }
}

