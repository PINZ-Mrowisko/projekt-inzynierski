import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../utils/common_widgets/text_area.dart';
import '../controllers/leave_controller.dart';
import '../models/holiday_model.dart';

void showAddManagerLeaveMobileDialog(BuildContext context, LeaveController controller) {
  final selectedRange = Rx<PickerDateRange?>(null);
  final userController = Get.find<UserController>();
  final employee = userController.employee.value;

  final errorMessage = RxString('');
  final holidayMessage = RxString('');
  final overlapMessage = RxString('');
  final comment = RxString('');
  final numOfHolidays = RxInt(0);

  final errorText = Obx(() {
    if (errorMessage.value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        errorMessage.value,
        style: TextStyle(color: AppColors.warning, fontSize: 14),
      ),
    );
  });

  final holidayText = Obx(() {
    if (holidayMessage.value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        holidayMessage.value,
        style: TextStyle(color: AppColors.logo, fontSize: 14),
      ),
    );
  });

  final overlapText = Obx(() {
    if (overlapMessage.value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        overlapMessage.value,
        style: TextStyle(color: AppColors.warning, fontSize: 14),
      ),
    );
  });

  // funkcja walidująca wybrane daty - tutaj do zmiany jesli logika biznesowa wyglada inaczej
  bool validateDates(PickerDateRange? range, LeaveController controller) {
    errorMessage.value = '';
    holidayMessage.value ='';
    overlapMessage.value = '';

    if (range == null || range.startDate == null ) return false;

    final startDate = range.startDate!;
    final endDate = range.endDate ?? startDate;
    final today = DateTime.now();
    final normalizeDate = (DateTime date) => DateTime(date.year, date.month, date.day);
    final startOnly = normalizeDate(startDate);
    final endOnly = normalizeDate(endDate);


    //for now set it like that, we need to substract the holidays
    var requestedDays = endDate.difference(startDate).inDays + 1;

    final List<Holiday> holidays = controller.holidays;


    // finds holidays that happen in time of leave
    final holidaysInRange = holidays.where((holiday) {
      final holidayDate = normalizeDate(holiday.date);
      return (holidayDate.isAtSameMomentAs(startOnly) ||
          holidayDate.isAtSameMomentAs(endOnly)) ||
          (holidayDate.isAfter(startOnly) && holidayDate.isBefore(endOnly));
    }).toList();

    // assign number of overlapping holidays so we can substract them later
    numOfHolidays.value = holidaysInRange.length;
    requestedDays = requestedDays - holidaysInRange.length;

    if (holidaysInRange.isNotEmpty) {
      final formatted = holidaysInRange
          .map((h) => '${h.date.day.toString().padLeft(2, '0')}.${h.date.month.toString().padLeft(2, '0')}.${h.date.year} (${h.name})')
          .join(', ');
      holidayMessage.value = 'Uwaga! W wybranym okresie przypadają święta: $formatted. Zostaną one odjęte od dlugości wolnego';
    }
    else {holidayMessage.value = '';}


    /// Check for overlap with already accepted leave requests
    final overlappingLeave = controller.getOverlappingLeave(startDate, endDate, employee.id);
    if (overlappingLeave != null) {
      final formatDate = (date) => '${date.day}.${date.month}.${date.year}';
      overlapMessage.value = 'Masz już zaakceptowany urlop w terminie '
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
      label: 'Wybierz zakres dat urlopu',
      selectedRange: selectedRange,
      onRangeChanged: (range) {
        selectedRange.value = range;
        validateDates(range, controller);
      },
    ),
    // add field for comment
    TextAreaDialogField(
      label: 'Komentarz (opcjonalnie)',
      hintText: 'Wpisz komentarz do swojego urlopu...',
      onChanged: (value) {
        // Store the comment value
        comment.value = value;
      },
      maxLines: 5, // Allows multiline input
    ),
    errorText,

  ];

  final actions = [
    DialogActionButton(
      label: 'Zatwierdź',
      onPressed: () async {
        if (!validateDates(selectedRange.value, controller)) {
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

        /// HANDLE LEAVE REQUEST LOGIC HERE
        final leaveController = Get.find<LeaveController>();
        final startDate = selectedRange.value!.startDate;
        final endDate = selectedRange.value!.endDate ?? selectedRange.value!.startDate;
        final commentText = comment.value.isEmpty ? "Brak komentarza" : comment.value;
        final requestedDays = endDate!.difference(startDate!).inDays + 1 - numOfHolidays.value;

        try {
          await leaveController.saveLeave(
              startDate,
              endDate,
              "Mój urlop",
              requestedDays,
              commentText
          );
          //Get.back();
          await userController.fetchCurrentUserRecord();
          Get.back();
          showCustomSnackbar(context, 'Urlop został dodany do kalendarza');
        } catch (e) {
          showCustomSnackbar(context, 'Błąd podczas dodawania urlopu: ${e.toString()}');
        }
        }
    )
  ];

  Get.dialog(
    Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Transform.scale(
          scale: 0.85,
          child: CustomFormDialog(
            title: 'Dodaj urlop',
            fields: fields,
            actions: actions,
            onClose: Get.back,
            width: 500,
            height: 700,
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}