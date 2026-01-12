import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/utils/app_colors.dart';

Widget buildAppointmentWidget(
    BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails,
    ) {

  final appointment = calendarAppointmentDetails.appointments.first;

  // --- ROZPAKOWYWANIE DANYCH Z LOCATION ---
  // Format: "COUNTER;;TIME_TEXT;;IS_CLAMPED"

  String extraCount = '';
  String timeTextToShow = '';
  bool isClamped = false;

  if (appointment.location != null && appointment.location!.contains(';;')) {
    final parts = appointment.location!.split(';;');
    if (parts.length >= 2) {
      extraCount = parts[0];
      timeTextToShow = parts[1];
    }
    if (parts.length >= 3) {
      isClamped = parts[2] == "1";
    }
  } else {
    extraCount = appointment.location ?? '';
    final st = appointment.startTime;
    final et = appointment.endTime;
    timeTextToShow = '${st.hour.toString().padLeft(2, '0')}:${st.minute.toString().padLeft(2, '0')} - '
        '${et.hour.toString().padLeft(2, '0')}:${et.minute.toString().padLeft(2, '0')}';
  }

  final bool hasWarning = appointment.notes?.contains('⚠️') ?? false;
  final bool isLeave = appointment.subject.toLowerCase().contains('urlop');

  if (isLeave) {
    final st = appointment.startTime;
    final et = appointment.endTime;
    timeTextToShow = '${st.hour.toString().padLeft(2, '0')}:${st.minute.toString().padLeft(2, '0')} - '
        '${et.hour.toString().padLeft(2, '0')}:${et.minute.toString().padLeft(2, '0')}';
  }

  String displayBottomText = appointment.notes ?? '';

  if (!isLeave) {
    displayBottomText = appointment.subject;
    if (hasWarning && !displayBottomText.contains('⚠️')) {
      displayBottomText = '⚠️ $displayBottomText';
    }
  }

  final Widget tileContent = Container(
    decoration: BoxDecoration(
      color: isLeave ? Colors.orangeAccent : appointment.color,
      borderRadius: BorderRadius.circular(3),
      border: hasWarning
          ? Border.all(color: AppColors.warning, width: 2,)
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
                TextSpan(text: timeTextToShow),
                if (extraCount.isNotEmpty)
                  TextSpan(
                    text: ' $extraCount',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
          ),

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

  if (isLeave) {
    return tileContent;
  }

  final String tooltipMessage = '$timeTextToShow\n$displayBottomText ${extraCount.isNotEmpty ? extraCount : ''}';

  return Tooltip(
    message: tooltipMessage,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(4),
    ),
    textStyle: const TextStyle(color: Colors.white, fontSize: 12),
    child: tileContent,
  );
}