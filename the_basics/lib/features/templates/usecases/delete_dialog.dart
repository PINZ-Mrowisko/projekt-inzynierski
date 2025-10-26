import 'package:get/get.dart';
import 'package:the_basics/features/templates/controllers/template_controller.dart';
import 'package:the_basics/features/templates/models/template_model.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/confirmation_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

void confirmDeleteTemplate(TemplateModel template, String marketId) {
  final controller = Get.find<TemplateController>();

  Get.dialog(
    ConfirmationDialog(
      title: 'Czy na pewno chcesz usunąć szablon "${template.templateName}"?',
      confirmText: 'Usuń',
      cancelText: 'Anuluj',
      confirmButtonColor: AppColors.warning,
      confirmTextColor: AppColors.white,
      onConfirm: () async {
        try {
          await controller.deleteTemplate (template.marketId, template.id);
          Get.back();
          showCustomSnackbar(
            Get.context!,
            'Szablon został pomyślnie usunięty.',
          );
        } catch (e) {
          Get.back();
          showCustomSnackbar(
            Get.context!,
            'Błąd podczas usuwania szablonu: ${e.toString()}',
          );
        }
      },
    ),
    barrierDismissible: false,
  );
}
