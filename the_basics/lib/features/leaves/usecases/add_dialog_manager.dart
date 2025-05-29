import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

//to implement actual logic prferably with dynamic dropdown items
void showAddManagerLeaveDialog(BuildContext context) {
  final leaveType = RxnString();
  final selectedRange = Rx<PickerDateRange?>(null);

  //need to implemtnt fetch of leave days left
  final leaveStatusText = Obx(() {
    final type = leaveType.value;
    if (type == null) return const SizedBox.shrink();
    final statusMap = {
      'Urlop wypoczynkowy': 'Wykorzystanie urlopu wypoczynkowego 0/20',
      'Urlop na żądanie': 'Wykorzystanie urlopu na żądanie 0/4',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 22.0),
      child: Text(
        statusMap[type] ?? '',
        style: const TextStyle(color: AppColors.logo, fontSize: 14),
      ),
    );
  });


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
    leaveStatusText,
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
        showCustomSnackbar(context, 'Urlop został dodany do kalendarza');
      },
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