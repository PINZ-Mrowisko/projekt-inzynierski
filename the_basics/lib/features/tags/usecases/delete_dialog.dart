import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';

import '../../../utils/common_widgets/confirmation_dialog.dart';
import '../../../utils/common_widgets/notification_snackbar.dart';
import '../controllers/tags_controller.dart';

void confirmDeleteTag(TagsController controller, String tagId, String tagName) {
  final userCount = controller.countUsersWithTag(tagName);
  String warningText;
  if (userCount == 1) {
    warningText = '$userCount użytkownik ma ten tag!\nCzy na pewno chcesz usunąć "$tagName"?';
  } else if (userCount > 1) {
    warningText = '$userCount użytkowników ma ten tag!\nCzy na pewno chcesz usunąć "$tagName"?';
  } else {
    warningText = 'Czy na pewno chcesz usunąć tag "$tagName"?';
  }

  Get.dialog(
    ConfirmationDialog(
      title: warningText,
      confirmText: 'Usuń',
      cancelText: 'Anuluj',
      confirmButtonColor: AppColors.warning,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await controller.deleteTag(tagId, tagName);
        Get.back();
        Get.back();
        showCustomSnackbar(Get.context!, 'Tag został pomyślnie usunięty.');
      },
    ),
    barrierDismissible: false,
  );
}
