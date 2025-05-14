import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/usecases/show_confirmations.dart';

import '../../../utils/app_colors.dart';
import '../controllers/tags_controller.dart';
import '../models/tags_model.dart';
import 'delete_dialog.dart';

void showEditTagDialog(BuildContext context, TagsController controller, TagsModel tag) {
  final nameController = TextEditingController(text: tag.tagName);
  final descController = TextEditingController(text: tag.description);

  Get.dialog(
    Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 547,
          height: 463,
          decoration: BoxDecoration(
            color: AppColors.pageBackground,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 16,
                top: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () {
                    if (nameController.text != tag.tagName ||
                        descController.text != tag.description) {
                      showExitConfirmationDialog(() => Get.back());
                    } else {
                      Get.back();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edytuj Tag',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nazwa',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textColor1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 56,
                          child: TextField(
                            controller: nameController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.white,
                              hoverColor: Colors.transparent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Opis',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textColor1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 56,
                          child: TextField(
                            controller: descController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.white,
                              hoverColor: Colors.transparent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 109,
                          height: 40,
                          child: ElevatedButton(
                            /// DELETING LOGIC
                            onPressed: () => confirmDeleteTag(controller, tag.id, tag.tagName),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: const Text(
                              'Usuń Tag',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 109,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (nameController.text.isEmpty) return;

                              showSaveConfirmationDialog(() async {
                                final updatedTag = tag.copyWith(
                                    tagName: nameController.text,
                                    description: descController.text,
                                    updatedAt: DateTime.now()
                                );
                                await controller.updateTagAndUsers(tag, updatedTag);

                                Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
                              });

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: const Text(
                              'Zapisz',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textColor2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}