import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';

void showChooseExistingScheduleDialog(BuildContext context, Function(String?) onScheduleSelected) async {
  String? selectedSchedule;

  final result = await Get.dialog<String>(
    StatefulBuilder(
      builder: (context, setState) {
        return CustomFormDialog(
          title: 'Wybierz, z którego istniejącego grafiku skorzystać przy generacji',
          width: 600,
          height: 380,
          onClose: null,
          fields: [
            DropdownDialogField(
              label: 'Grafik',
              hintText: 'Wybierz grafik',
              items: [
                DropdownItem(value: 'schedule1', label: 'Maj 2025'),
                DropdownItem(value: 'schedule2', label: 'Wrzesień 2025'),
              ],
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
              label: 'Generuj grafik',
              onPressed: () {
                if (selectedSchedule != null) {
                  Get.back(result: selectedSchedule);
                } else {
                  Get.snackbar(
                    'Błąd',
                    'Proszę wybrać grafik',
                    backgroundColor: AppColors.warning,
                    colorText: AppColors.white,
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