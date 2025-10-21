import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import '../../../utils/app_colors.dart';
import '../controllers/tags_controller.dart';

void showAddTagDialog(BuildContext context, TagsController controller) {
  controller.nameController.clear();
  controller.descController.clear();

  void _performAddOperation() async {
    try {
      if (controller.nameController.text.isEmpty) {
        showCustomSnackbar(context, 'Nazwa tagu nie może być pusta');
        return;
      } else {
        final t = controller.tagExists(controller.userController.employee.value.marketId, controller.nameController.text);
        // we check if tag exists, if yes then just display the msg and cancel the saving
        if (await t) {
          showCustomSnackbar(context, controller.tagExistanceMessage.value);
          return;
        } else {
          await controller.saveTag(controller.userController.employee.value.marketId);
          Get.back();
          showCustomSnackbar(context, 'Tag został dodany.');
        }
      }
    } catch (e) {
      showCustomSnackbar(context, 'Błąd podczas dodawania tagu: ${e.toString()}');
    }
  }

  Get.dialog(
    Obx(() => CustomFormDialog(
      title: 'Dodaj nowy Tag',
      onClose: () {
        if (!controller.isLoading.value) Get.back();
      },
      fields: [
        DialogInputField(
          label: 'Nazwa',
          controller: controller.nameController,
        ),
        DialogInputField(
          label: 'Opis',
          controller: controller.descController,
        ),
      ],
      actions: [
        DialogActionButton(
          label: controller.isLoading.value ? 'Dodawanie...' : 'Dodaj Tag',
          onPressed: controller.isLoading.value ? (){} : _performAddOperation,
          backgroundColor: AppColors.blue,
          textColor: AppColors.textColor2,
        ),
      ],
    )),
    barrierDismissible: false,
  );
}