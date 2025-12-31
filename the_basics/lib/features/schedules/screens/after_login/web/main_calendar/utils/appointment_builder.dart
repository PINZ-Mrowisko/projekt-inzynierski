//////////////////////////////////////////////////////////////////////

// In this file: the  tile for each appointment in calendar is being created
// CHANGED: real times provided for tile width

/////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/utils/app_colors.dart';

Widget buildAppointmentWidget(
    BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails,
    ) {

  final appointment = calendarAppointmentDetails.appointments.first;

  // Pobieramy licznik ukrytych zmian (np. "(+2)") z pola location
  final String extraCount = appointment.location ?? '';

  final bool hasWarning = appointment.notes?.contains('⚠️') ?? false;
  final isLeave = appointment.subject.toLowerCase().contains('urlop');

  // get REAL start and end times
  final startTime = appointment.startTime;
  final endTime = appointment.endTime;

  String displayBottomText = appointment.notes ?? '';

  if (!isLeave) {
    displayBottomText = appointment.subject;
    if (hasWarning && !displayBottomText.contains('⚠️')) {
      displayBottomText = '⚠️ $displayBottomText';
    }
  }

  return Container(
    decoration: BoxDecoration(
      color: isLeave ? Colors.orangeAccent : appointment.color,
      borderRadius: BorderRadius.circular(3),
      border: hasWarning
          ? Border.all(color: Colors.red, width: 2,)
          : Border.all(color: AppColors.white, width: 0.5,),
    ),
    margin: const EdgeInsets.all(1),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        if (!isLeave)
          RichText(
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            text: TextSpan(
              style: TextStyle(
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
              ),
              children: [
                TextSpan(
                  text: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - '
                      '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                ),
                // Tutaj wyświetlamy licznik (+X) obok godziny
                if (extraCount.isNotEmpty)
                  TextSpan(
                    text: '   $extraCount',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.black,
                    ),
                  ),
              ],
            ),
          ),

        // tags or leave comment
        if (displayBottomText.isNotEmpty)
          Text(
            displayBottomText,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      ],
    ),
  );
}