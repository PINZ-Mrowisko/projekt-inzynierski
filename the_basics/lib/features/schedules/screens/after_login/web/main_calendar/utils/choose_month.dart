import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

void showChooseMonth(BuildContext context, Function(String?) onScheduleSelected) async {
  String? selectedSchedule;

  final List<DropdownItem> monthItems = [];
  final DateTime now = DateTime.now();

  final List<String> plMonths = [
    '', 'Styczeń', 'Luty', 'Marzec', 'Kwiecień', 'Maj', 'Czerwiec',
    'Lipiec', 'Sierpień', 'Wrzesień', 'Październik', 'Listopad', 'Grudzień'
  ];

  for (int i = 1; i <= 3; i++) {
    final DateTime futureDate = DateTime(now.year, now.month + i, 1);

    final String monthName = plMonths[futureDate.month];
    final String label = '$monthName ${futureDate.year}';

    final String value = '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}';

    monthItems.add(DropdownItem(value: value, label: label));
  }

  final result = await Get.dialog<String>(
    StatefulBuilder(
      builder: (context, setState) {
        return CustomFormDialog(
          title: 'Wybierz miesiąc docelowy dla generowanego grafiku',
          width: 600,
          height: 380,
          onClose: null,
          fields: [
            DropdownDialogField(
              label: 'Miesiąc',
              hintText: 'Wybierz miesiąc',
              items: monthItems,
              onChanged: (value) {
                setState(() {
                  selectedSchedule = value;
                });
              },
            ),
          ],
          actions: [
            DialogActionButton(
              label: 'Anuluj',
              onPressed: () => Get.back(result: null),
              backgroundColor: AppColors.lightBlue,
              textColor: AppColors.textColor2,
            ),
            DialogActionButton(
              label: 'Dalej',
              onPressed: () {
                if (selectedSchedule != null) {
                  Get.back(result: selectedSchedule);
                } else {
                  showCustomSnackbar(
                    context,
                    "Proszę wybrać grafik.",
                  );
                }
              },
              backgroundColor: AppColors.blue,
              textColor: AppColors.textColor2,
            ),
          ],
        );
      },
    ),
    barrierDismissible: false,
  );

  if (result != null) {
    onScheduleSelected(result);
  }
}