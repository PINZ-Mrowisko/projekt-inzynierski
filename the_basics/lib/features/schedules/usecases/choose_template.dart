import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/templates/controllers/template_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

void showChooseTemplateDialog(BuildContext context, Function(String?) onTemplateSelected) async {
  String? selectedTemplate;

  final templateController = Get.find<TemplateController>();


  // only grab templates without errors (so no missing tags)
  final templateItems = templateController.allTemplates
      .where((t) => t.isDataMissing == false)
      .map((t) => DropdownItem(
    value: t.id,
    label: t.templateName,
  )).toList();


  if (templateItems.isEmpty) {
    showCustomSnackbar(
      context,
      "Brak dostępnych szablonów. Stwórz nowy szablon lub usuń błędy w istniejącym.",
    );
    return;
  }

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
              items: templateItems,
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
                  showCustomSnackbar(
                    context,
                    "Proszę wybrać szablon.",
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