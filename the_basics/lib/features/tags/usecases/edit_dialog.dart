import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/usecases/show_confirmations.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

import '../../../utils/app_colors.dart';
import '../controllers/tags_controller.dart';
import '../models/tags_model.dart';
import 'delete_dialog.dart';

void showEditTagDialog(BuildContext context, TagsController controller, TagsModel tag) {
    final nameController = TextEditingController(text: tag.tagName);
    final descController = TextEditingController(text: tag.description);

    Get.dialog(
      CustomFormDialog(
        title: 'Edytuj Tag',
        onClose: () => Get.back(),
        fields: [
          DialogInputField(
            label: 'Nazwa',
            controller: nameController,
          ),
          DialogInputField(
            label: 'Opis',
            controller: descController,
          ),
        ],
        actions: [
          DialogActionButton(
            label: 'Usuń',
            onPressed: () => confirmDeleteTag(controller, tag.id, tag.tagName, tag.marketId),
            backgroundColor: AppColors.warning,
            textColor: AppColors.white,
          ),
          DialogActionButton(
            label: 'Zapisz',
            onPressed: () async {
              try {
                if (nameController.text.isEmpty) {
                  showCustomSnackbar(context, 'Nazwa tagu nie może być pusta');
                  return;
                }
                // test if tag with the updated name exists already
                final t = controller.tagExists(controller.userController.employee.value.marketId, controller.nameController.text, tagID: tag.id);

                // if tag exists finds a match in the tags collestion, it displays a match
                if (await t){
                  showCustomSnackbar(context, controller.tagExistanceMessage.value); Navigator.of(Get.overlayContext!, rootNavigator: true).pop() ;return;
                } else {
                showSaveConfirmationDialog(() async {
                  try {
                    final updatedTag = tag.copyWith(
                      tagName: nameController.text,
                      description: descController.text,
                      updatedAt: DateTime.now(),
                    );


                    await controller.updateTagAndUsers(tag, updatedTag);


                    Navigator.of(Get.overlayContext!, rootNavigator: true).pop();

                    showCustomSnackbar(context, 'Zmiany zostały zapisane.');
                  } catch (e) {
                    showCustomSnackbar(context, 'Błąd podczas aktualizacji tagu: ${e.toString()}');
                  }
                });};
              } catch (e) {
                //showCustomSnackbar(context, 'Wystąpił nieoczekiwany błąd');
              }
            },
            backgroundColor: AppColors.blue,
            textColor: AppColors.textColor2,
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }