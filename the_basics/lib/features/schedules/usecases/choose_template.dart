import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';

void showChooseTemplateDialog(BuildContext context, Function(String?) onTemplateSelected) async {
  String? selectedTemplate;

  final result = await Get.dialog<String>(
    StatefulBuilder(
      builder: (context, setState) {
        return CustomFormDialog(
          title: 'Wybierz, z którego szablonu skorzystać przy generowaniu grafiku',
          width: 600,
          height: 380,
          onClose: null,
          fields: [
            DropdownDialogField(
              label: 'Szablon',
              hintText: 'Wybierz szablon',
              items: [
                DropdownItem(value: 'template1', label: 'Nazwa szablonu'),
                DropdownItem(value: 'template2', label: 'Fajniejsza nazwa szablonu'),
              ],
              onChanged: (value) {
                setState(() {
                  selectedTemplate = value;
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
                if (selectedTemplate != null) {
                  Get.back(result: selectedTemplate);
                } else {
                  Get.snackbar(
                    'Błąd',
                    'Proszę wybrać szablon',
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
    onTemplateSelected(result);
  }
}