import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';

void showGenerationMethodDialog(BuildContext context, Function(String?) onMethodSelected) async {
  String? selectedMethod;

  final result = await Get.dialog<String>(
    StatefulBuilder(
      builder: (context, setState) {
        return CustomFormDialog(
          title: 'Wybierz sposób generowania grafiku',
          width: 600,
          height: 325,
          onClose: null,
          fields: [
            DropdownDialogField(
              label: 'Sposób generacji',
              hintText: 'Wybierz sposób generacji',
              items: [
                DropdownItem(value: 'template', label: 'Na podstawie szablonu'),
                DropdownItem(value: 'existing_schedule', label: 'Na podstawie istniejącego grafiku'),
              ],
              onChanged: (value) {
                setState(() {
                  selectedMethod = value;
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
                if (selectedMethod != null) {
                  Get.back(result: selectedMethod);
                } else {
                  Get.snackbar(
                    'Błąd',
                    'Proszę wybrać sposób generacji',
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
    onMethodSelected(result);
  }
}