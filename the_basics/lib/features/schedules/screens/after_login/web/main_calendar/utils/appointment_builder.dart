//////////////////////////////////////////////////////////////////////

// In this file: the  tile for each appointment in calendar is being created
// due to very ugly display (when a shift was very short) - i decided to standardize the length
// so now each tile will get shown as if it's at least 8 hours long.
// if you want shorter tile modify line 41 to just use the appointhment.endTime

/////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/utils/app_colors.dart';

Widget buildAppointmentWidget(
    BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails,
    ) {

  final appointment = calendarAppointmentDetails.appointments.first;

  // Parse REAL times from appointment ID or notes - we do this to achieve same tile length for all appointments
  // we keep real end time in id, meanwhile pass fake end time to builder

  final realTimes = _parseRealTimes(appointment);
  final realEndTime = realTimes['end'];

  return Container(
    decoration: BoxDecoration(
      color: appointment.color,
      borderRadius: BorderRadius.circular(3),
      border: Border.all(
        color: AppColors.white,
        width: 0.5,
      ),
    ),
    margin: const EdgeInsets.all(1),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')} - '
              '${realEndTime?.hour}:${realEndTime?.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (appointment.subject.isNotEmpty)
          Text(
            appointment.subject.replaceAll(' - ', ' '),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
          ),
      ],
    ),
  );
}

Map<String, TimeOfDay> _parseRealTimes(Appointment appointment) {

  // Check if ID exists and has the expected format
  if (appointment.id != null) {
    final idString = appointment.id.toString();
    if (idString.contains('_')) {
      final parts = idString.split('_');


      // format: employeeID_day_startTime_endTime
      // A5UneZimHkbKUC88GyuwovdAW6y1_5_6:00_15:00

      if (parts.length >= 4) {
        try {
          final startParts = parts[2].split(':');
          final endParts = parts[3].split(':');

          final startHour = int.parse(startParts[0]);
          final startMinute = int.parse(startParts[1]);
          final endHour = int.parse(endParts[0]);
          final endMinute = int.parse(endParts[1]);

          final result = {
            'start': TimeOfDay(hour: startHour, minute: startMinute),
            'end': TimeOfDay(hour: endHour, minute: endMinute),
          };

          return result;

        } catch (e) {
          print( 'Error parsing times from ID: $e');
        }
      } else {
        print('Not enough parts in ID. got ${parts.length}');
      }
    } else {
      print('ID does not contain underscore');
    }
  } else {
    print('Appointment ID is null');
  }

  // if doesnt work we fallback to fake times
  final fakeStart = TimeOfDay.fromDateTime(appointment.startTime);
  final fakeEnd = TimeOfDay.fromDateTime(appointment.startTime.add(Duration(hours: 8)));

  return {
    'start': fakeStart,
    'end': fakeEnd,
  };
}
