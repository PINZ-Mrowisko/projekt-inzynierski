import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

//to implement actual logic prferably with dynamic dropdown items
void showAddLeaveDialog(BuildContext context) {
  final leaveType = RxnString();
  final selectedRange = Rx<PickerDateRange?>(null);

  final fields = [
    DropdownDialogField(
      label: 'Typ urlopu',
      hintText: 'Wybierz typ urlopu',
      items: [
        DropdownItem(value: 'Urlop wypoczynkowy', label: 'Urlop wypoczynkowy'),
        DropdownItem(value: 'Urlop na żądanie', label: 'Urlop na żądanie'),
      ],
      onChanged: (value) => leaveType.value = value,
    ),
    DatePickerDialogField(
      label: 'Wybierz zakres dat urlopu',
      selectedRange: selectedRange,
      onRangeChanged: (range) {
        selectedRange.value = range;
      },
    ),
  ];

  final actions = [
    DialogActionButton(
      label: 'Zatwierdź',
      onPressed: () {
        if (leaveType.value == null || selectedRange.value == null) {
          showCustomSnackbar(context, 'Wybierz typ urlopu i zakres dat');
          return;
        }
        Get.back();
        showCustomSnackbar(context, 'Wniosek urlopowy został złożony');
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
      height: 655,
    ),
    barrierDismissible: false,
  );
}