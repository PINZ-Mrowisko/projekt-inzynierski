import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../utils/common_widgets/text_area.dart';
import '../../employees/controllers/user_controller.dart';
import '../controllers/leave_controller.dart';
import '../models/holiday_model.dart';

void showAddEmployeeLeaveDialog(BuildContext context) {
  final selectedRange = Rx<PickerDateRange?>(null);
  final userController = Get.find<UserController>();
  final employee = userController.employee.value;
  final leaveController = Get.find<LeaveController>();
  final comment = RxString('');

  final errorMessage = RxString('');
  final holidayMessage = RxString('');
  final overlapMessage = RxString('');
  final numOfHolidays = RxInt(0);

  final errorText = Obx(() {
    if (errorMessage.value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        errorMessage.value,
        style: const TextStyle(color: Colors.red, fontSize: 14),
      ),
    );
  });

  final holidayText = Obx(() {
    if (holidayMessage.value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        holidayMessage.value,
        style: const TextStyle(color: Colors.blue, fontSize: 14),
      ),
    );
  });

  final overlapText = Obx(() {
    if (overlapMessage.value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        overlapMessage.value,
        style: const TextStyle(color: Colors.pink, fontSize: 14),
      ),
    );
  });

  bool validateDates(PickerDateRange? range) {
    errorMessage.value = '';
    holidayMessage.value = '';
    overlapMessage.value = '';

    if (range == null || range.startDate == null) return false;

    final startDate = range.startDate!;
    final endDate = range.endDate ?? startDate;
    final today = DateTime.now();
    final normalizeDate = (DateTime date) => DateTime(date.year, date.month, date.day);
    final startOnly = normalizeDate(startDate);
    final endOnly = normalizeDate(endDate);

    //final isOnDemand = leaveType.value == 'Urlop na żądanie';
    var requestedDays = endDate.difference(startDate).inDays + 1;

    // Check for holidays
    final List<Holiday> holidays = leaveController.holidays;

    final holidaysInRange = holidays.where((holiday) {
      final holidayDate = normalizeDate(holiday.date);
      return (holidayDate.isAtSameMomentAs(startOnly) ||
          holidayDate.isAtSameMomentAs(endOnly)) ||
          (holidayDate.isAfter(startOnly) && holidayDate.isBefore(endOnly));
    }).toList();

    numOfHolidays.value = holidaysInRange.length;
    requestedDays = requestedDays - holidaysInRange.length;

    if (holidaysInRange.isNotEmpty) {
      final formatted = holidaysInRange
          .map((h) => '${h.date.day.toString().padLeft(2, '0')}.${h.date.month.toString().padLeft(2, '0')}.${h.date.year} (${h.name})')
          .join(', ');
      holidayMessage.value = 'Uwaga! W wybranym okresie przypadają święta: $formatted. Zostaną one odjęte od długości wolnego.';
    }
    else {holidayMessage.value = '';}

    // Check for overlapping approved leaves
    final overlappingLeave = leaveController.getOverlappingLeave(startDate, endDate, employee.id);
    if (overlappingLeave != null) {
      final formatDate = (date) => '${date.day}.${date.month}.${date.year}';
      overlapMessage.value = 'Masz już złożoną nieobecność na ten termin'
          '${formatDate(overlappingLeave.startDate)}-${formatDate(overlappingLeave.endDate)}';
      return false;
    }



    if (startDate.isBefore(today)) {
          errorMessage.value = 'Nieobecność nie może być w przeszłości';
          return false;
        }

  return true;
  }

  final fields = [
    holidayText,
    overlapText,
    DatePickerDialogField(
      label: 'Wybierz zakres dat nieobecności',
      selectedRange: selectedRange,
      onRangeChanged: (range) {
        selectedRange.value = range;
        validateDates(range);
      },
    ),
    TextAreaDialogField( // Add comment field here
      label: 'Komentarz (opcjonalnie)',
      hintText: 'Wpisz komentarz do swojego wniosku urlopowego...',
      onChanged: (value) {
        comment.value = value;
      },
      maxLines: 5,
    ),
    errorText,
  ];

  final actions = [
    DialogActionButton(
      label: 'Zatwierdź',
      onPressed: () async {
        if (!validateDates(selectedRange.value)) {
          // Validation failed - show appropriate message
          if (selectedRange.value == null) {
            showCustomSnackbar(context, 'Wybierz zakres dat');
          } else if (errorMessage.value.isNotEmpty) {
            showCustomSnackbar(context, errorMessage.value);
          } else if (overlapMessage.value.isNotEmpty) {
            showCustomSnackbar(context, overlapMessage.value);
          }
          return;
        }

        final startDate = selectedRange.value!.startDate!;
        final endDate = selectedRange.value!.endDate ?? startDate;
        final requestedDays = endDate.difference(startDate).inDays + 1 - numOfHolidays.value;
        print(requestedDays);
        final commentText = comment.value.isEmpty ? "Brak komentarza" : comment.value; // Use actual comment

        try {
          await leaveController.saveEmpLeave(
              startDate,
              endDate,
              "Oczekujący",
              requestedDays,
              commentText,
          );
          //Get.back();
          await userController.fetchCurrentUserRecord();
          Get.back();
          showCustomSnackbar(context, 'Wniosek urlopowy został złożony');
        } catch (e) {
          showCustomSnackbar(context, 'Błąd podczas składania wniosku: ${e.toString()}');
        }
      },
    )
  ];

  Get.dialog(
    CustomFormDialog(
      title: 'Aplikuj o urlop',
      fields: fields,
      actions: actions,
      onClose: Get.back,
      width: 500,
      height: 700,
    ),
    barrierDismissible: false,
  );
}