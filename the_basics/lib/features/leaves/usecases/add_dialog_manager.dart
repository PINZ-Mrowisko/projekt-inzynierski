import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../controllers/leave_controller.dart';
import '../models/holiday_model.dart';

//to implement actual logic prferably with dynamic dropdown items
void showAddManagerLeaveDialog(BuildContext context, LeaveController controller) {
  final leaveType = RxnString();
  final selectedRange = Rx<PickerDateRange?>(null);
  final userController = Get.find<UserController>();
  final employee = userController.employee.value;

  final errorMessage = RxString('');
  final holidayMessage = RxString('');
  final overlapMessage = RxString('');

  final numOfHolidays = RxInt(0);

  // final leaveStatusText = Obx(() {
  //   final type = leaveType.value;
  //   if (type == null) return const SizedBox.shrink();
  //   final statusMap = {
  //     'Urlop wypoczynkowy': 'Pozostało dni urlopu wypoczynkowego: ${employee.vacationDays}/20',
  //     'Urlop na żądanie': 'pozostało : ${employee.onDemandDays}/4',
  //   };
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 22.0),
  //     child: Text(
  //       statusMap[type] ?? '',
  //       style: const TextStyle(color: AppColors.logo, fontSize: 14),
  //     ),
  //   );
  // });

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

  // funkcja walidująca wybrane daty - tutaj do zmiany jesli logika biznesowa wyglada inaczej
  void validateDates(PickerDateRange? range, LeaveController controller) {
    errorMessage.value = '';
    holidayMessage.value ='';
    overlapMessage.value = '';

    if (range == null || range.startDate == null || leaveType.value == null) return;

    final startDate = range.startDate!;
    final endDate = range.endDate ?? startDate;
    final today = DateTime.now();
    final normalizeDate = (DateTime date) => DateTime(date.year, date.month, date.day);
    final startOnly = normalizeDate(startDate);
    final endOnly = normalizeDate(endDate);


    final isOnDemand = leaveType.value == 'Urlop na żądanie';
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
      //print("IVe got some!~~~~~~~~~~");
      final formatDate = (date) => '${date.day}.${date.month}.${date.year}';
      overlapMessage.value = 'Masz już zaakceptowany urlop w terminie '
          '${formatDate(overlappingLeave.startDate)}-${formatDate(overlappingLeave.endDate)}';
      return;
    }


    if (startDate.isBefore(today)) {
      errorMessage.value = 'Nieobecność nie może być w przeszłości';
      return;
    }

    // Walidacja urlopu wypoczynkowego
    // if (!isOnDemand) {
    //   if (startDate.isBefore(today)) {
    //     errorMessage.value = 'Urlop wypoczynkowy nie może być w przeszłości';
    //     return;
    //   }
    // }
    // final dateMinusOne = today.subtract(const Duration(days: 1));
    // if (isOnDemand) {
    //   if (startDate.isBefore(dateMinusOne)) {
    //     errorMessage.value = "Urlop na żądanie nie może być w przeszłości (ale dziś może).";
    //     return;
    //   }
    //
    // }
    //print(requestedDays);

    // Walidacja dostępnych dni
    // if (isOnDemand) {
    //   if (requestedDays > employee.onDemandDays) {
    //     errorMessage.value = 'Nie masz wystarczającej liczby dni urlopu na żądanie';
    //     return;
    //   }
    //   if (requestedDays > 1) {
    //     errorMessage.value = 'Urlop na żądanie może trwać maksymalnie 1 dzień';
    //     return;
    //   }
    // } else {
    //   if (requestedDays > employee.vacationDays) {
    //     errorMessage.value = 'Nie masz wystarczającej liczby dni urlopu wypoczynkowego';
    //     return;
    //   }
    // }
  }


  final fields = [
    holidayText,
    overlapText,
    // DropdownDialogField(
    //   label: 'Typ urlopu',
    //   hintText: 'Wybierz typ urlopu',
    //   items: [
    //     DropdownItem(value: 'Urlop wypoczynkowy', label: 'Urlop wypoczynkowy'),
    //     DropdownItem(value: 'Urlop na żądanie', label: 'Urlop na żądanie'),
    //   ],
    //   onChanged: (value) {
    //     leaveType.value = value;
    //     validateDates(selectedRange.value, controller);
    //   }
    // ),
    DatePickerDialogField(
      label: 'Wybierz zakres dat urlopu',
      selectedRange: selectedRange,
      onRangeChanged: (range) {
        selectedRange.value = range;
        validateDates(range, controller);
      },
    ),
    errorText,

  ];

  final actions = [
    DialogActionButton(
      label: 'Zatwierdź',
      onPressed: () async {
        if (selectedRange.value == null) {
          showCustomSnackbar(context, 'Wybierz zakres dat');
          return;
        }

        if (errorMessage.value.isNotEmpty) {
          showCustomSnackbar(context, 'Popraw błędy przed zatwierdzeniem');
          return;
        }

        if (overlapMessage.value.isNotEmpty) {
          showCustomSnackbar(context, 'Masz już urlop w tym terminie.');
          return;
        }

        /// HANDLE LEAVE REQUEST LOGIC HERE
        final leaveController = Get.find<LeaveController>();
        final startDate = selectedRange.value!.startDate;
        final endDate = selectedRange.value!.endDate ?? selectedRange.value!.startDate;
        final comment = "PH";
        final requestedDays = endDate!.difference(startDate!).inDays + 1 - numOfHolidays.value;
        try {
          await leaveController.saveLeave(
              startDate,
              endDate,
              "Mój urlop",
              requestedDays,
            comment
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
    CustomFormDialog(
      title: 'Dodaj urlop',
      fields: fields,
      actions: actions,
      onClose: Get.back,
      width: 500,
      height: 700,
    ),
    barrierDismissible: false,
  );
}