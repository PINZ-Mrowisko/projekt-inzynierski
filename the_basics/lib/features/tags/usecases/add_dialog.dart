import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/usecases/show_confirmations.dart';
import '../../../utils/app_colors.dart';
import '../controllers/tags_controller.dart';

void showAddTagDialog(BuildContext context, TagsController controller) {
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
                    if (controller.nameController.text.isNotEmpty ||
                        controller.descController.text.isNotEmpty) {
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
                      'Dodaj Tag',
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
                            controller: controller.nameController,
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
                            controller: controller.descController,
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
                            onPressed: () async {
                              /// handle adding of a tag
                              if (controller.nameController.text.isEmpty) return;
                              await controller.saveTag(controller.userController.employee.value.marketId);

                              // clear controller for later use
                              controller.descController.clear();
                              controller.nameController.clear();

                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: const Text(
                              'Dodaj Tag',
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