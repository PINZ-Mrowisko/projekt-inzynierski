import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../employees/controllers/user_controller.dart';
import '../controllers/leave_controller.dart';

//to implement actual logic prferably with dynamic dropdown items
void showAddEmployeeLeaveDialog(BuildContext context) {
  final leaveType = RxnString();
  final selectedRange = Rx<PickerDateRange?>(null);
  final userController = Get.find<UserController>();
  final employee = userController.employee.value;
  final errorMessage = RxString('');

  final leaveStatusText = Obx(() {
    final type = leaveType.value;
    if (type == null) return const SizedBox.shrink();
    final statusMap = {
      'Urlop wypoczynkowy': 'Wykorzystanie urlopu wypoczynkowego ${employee.vacationDays}/20',
      'Urlop na żądanie': 'Wykorzystanie urlopu na żądanie ${employee.onDemandDays}/4',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 22.0),
      child: Text(
        statusMap[type] ?? '',
        style: const TextStyle(color: AppColors.logo, fontSize: 14),
      ),
    );
  });

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

  void validateDates(PickerDateRange? range) {
    errorMessage.value = '';

    if (range == null || range.startDate == null || leaveType.value == null) return;

    final startDate = range.startDate!;
    final endDate = range.endDate ?? startDate;
    final today = DateTime.now();
    final isOnDemand = leaveType.value == 'Urlop na żądanie';
    final requestedDays = endDate.difference(startDate).inDays + 1;

    if (!isOnDemand) {
      if (startDate.isBefore(today)) {
        errorMessage.value = 'Urlop wypoczynkowy nie może być w przeszłości';
        return;
      }
    }

    if (isOnDemand) {
      if (requestedDays > employee.onDemandDays) {
        errorMessage.value = 'Nie masz wystarczającej liczby dni urlopu na żądanie';
        return;
      }
      if (requestedDays > 1) {
        errorMessage.value = 'Urlop na żądanie może trwać maksymalnie 1 dzień';
        return;
      }
    } else {
      if (requestedDays > employee.vacationDays) {
        errorMessage.value = 'Nie masz wystarczającej liczby dni urlopu wypoczynkowego';
        return;
      }
    }
  }

  final fields = [
    DropdownDialogField(
      label: 'Typ urlopu',
      hintText: 'Wybierz typ urlopu',
      items: [
        DropdownItem(value: 'Urlop wypoczynkowy', label: 'Urlop wypoczynkowy'),
        DropdownItem(value: 'Urlop na żądanie', label: 'Urlop na żądanie'),
      ],
      onChanged: (value) {
        leaveType.value = value;
        validateDates(selectedRange.value);
      }
    ),
    leaveStatusText,
    DatePickerDialogField(
      label: 'Wybierz zakres dat urlopu',
      selectedRange: selectedRange,
      onRangeChanged: (range) {
        selectedRange.value = range;
        validateDates(range);
      },
    ),
    errorText,
  ];

  final actions = [
    DialogActionButton(
      label: 'Zatwierdź',
      onPressed: () async {
        if (leaveType.value == null || selectedRange.value == null) {
          showCustomSnackbar(context, 'Wybierz typ urlopu i zakres dat');
          return;
        }
        if (errorMessage.value.isNotEmpty) {
          showCustomSnackbar(context, 'Popraw błędy przed zatwierdzeniem');
          return;
        }

        final leaveController = Get.find<LeaveController>();
        final startDate = selectedRange.value!.startDate!;
        final endDate = selectedRange.value!.endDate ?? startDate;

        try {
          // status "oczekujący" for employee requests (cause it needs approval)

          await leaveController.saveEmpLeave(
              startDate,
              endDate,
              leaveType.value!,
              "oczekujący"
          );
          Get.back();
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