import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/confirmation_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

import '../controllers/user_controller.dart';

void confirmDeleteEmployee(UserController controller, String employeeId, String employeeName) {
    Get.dialog(
      ConfirmationDialog(
        title: 'Czy na pewno chcesz usunąć pracownika "$employeeName"?',
        confirmText: 'Usuń',
        cancelText: 'Anuluj',
        confirmButtonColor: AppColors.warning,
        confirmTextColor: AppColors.white,
        onConfirm: () async {
          try {
            Get.back();
            await controller.deleteEmployee(employeeId);
            Get.back();
            showCustomSnackbar(Get.context!, 'Pracownik został pomyślnie usunięty.');
          } catch (e) {
            Get.back();
            showCustomSnackbar(
                Get.context!,
                'Błąd podczas usuwania pracownika: ${e.toString()}'
            );
          }
        },
      ),
      barrierDismissible: false,
    );
  }