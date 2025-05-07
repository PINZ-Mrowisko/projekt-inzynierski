import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/controllers/tags_controller.dart';
import 'package:the_basics/features/schedules/widgets/side_menu.dart';
import 'package:the_basics/shared/widgets/notification_snackbar.dart';
import 'package:the_basics/utils/app_colors.dart';
import '../../models/tags_model.dart';
import 'package:the_basics/shared/widgets/confirmation_dialog.dart';
import 'package:the_basics/shared/widgets/custom_button.dart';
import 'package:the_basics/shared/widgets/search_bar.dart';
import 'package:the_basics/shared/widgets/generic_list.dart';

class TagsPage extends StatelessWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tagsController = Get.find<TagsController>();

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
            child: const SideMenu(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 80,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Tagi',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logo,
                          ),
                        ),
                        const Spacer(),
                        _buildSearchBar(),
                        const SizedBox(width: 16),
                        _buildAddTagButton(context, tagsController),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (tagsController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (tagsController.errorMessage.value.isNotEmpty) {
                        return Center(child: Text(tagsController.errorMessage.value));
                      }
                      if (tagsController.allTags.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Brak dostępnych tagów'),
                              ElevatedButton(
                                onPressed: () => _showAddTagDialog(context, tagsController),
                                child: const Text('Dodaj pierwszy tag'),
                              ),
                            ],
                          ),
                        );
                      }
                      return _buildTagsList(context, tagsController);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTagButton(BuildContext context, TagsController controller) {
    return CustomButton(
      text: 'Dodaj Tag',
      icon: Icons.add,
      onPressed: () => _showAddTagDialog(context, controller),
    );
  }

  Widget _buildSearchBar() {
    return const CustomSearchBar(
      hintText: 'Wyszukaj tag',
    );
  }

  Widget _buildTagsList(BuildContext context, TagsController controller) {
    return GenericList<TagsModel>(
      items: controller.allTags,
      onItemTap: (tag) => _showEditTagDialog(context, controller, tag),
      itemBuilder: (context, tag) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, 
            vertical: 12,
          ),
          title: Text(
            tag.tagName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor1,
            ),
          ),
          subtitle: Text(
            tag.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textColor2,
            ),
          ),
        );
      },
    );
  }

  void _showAddTagDialog(BuildContext context, TagsController controller) {
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
                        _showExitConfirmationDialog(() => Get.back());
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
                                if (controller.nameController.text.isEmpty) return;
                                await controller.saveTag(controller.userController.employee.value.marketId);
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

  void _showEditTagDialog(BuildContext context, TagsController controller, TagsModel tag) {
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
                        _showExitConfirmationDialog(() => Get.back());
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
                              onPressed: () => _confirmDeleteTag(controller, tag.id),
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
                                
                                _showSaveConfirmationDialog(() async {
                                  final updatedTag = tag.copyWith(
                                    tagName: nameController.text,
                                    description: descController.text,
                                    updatedAt: DateTime.now()
                                  );
                                  await controller.updateTag(updatedTag);
                                  Get.back();
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

  void _confirmDeleteTag(TagsController controller, String tagId) {
    Get.dialog(
      ConfirmationDialog(
        title: 'Czy na pewno chcesz\nusunąć Tag?',
        confirmText: 'Usuń',
        cancelText: 'Anuluj',
        confirmButtonColor: AppColors.warning,
        confirmTextColor: Colors.white,
        onConfirm: () async {
          Get.back();
          await controller.deleteTag(tagId);
          Get.back();
          showCustomSnackbar(Get.context!, 'Tag został pomyślnie usunięty.');
        },
      ),
      barrierDismissible: false,
    );
  }

  void _showExitConfirmationDialog(VoidCallback onConfirmExit) {
    Get.dialog(
      ConfirmationDialog(
        title: 'Czy na pewno chcesz wyjść?',
        subtitle: 'Twój progres nie zostanie zapisany.',
        confirmText: 'Wyjdź',
        cancelText: 'Anuluj',
        onConfirm: onConfirmExit,
      ),
      barrierDismissible: false,
    );
  }

  void _showSaveConfirmationDialog(VoidCallback onConfirmSave) {
    Get.dialog(
      ConfirmationDialog(
        title: 'Czy chcesz zatwierdzić zmiany?',
        confirmText: 'Zatwierdź',
        cancelText: 'Anuluj',
        onConfirm: onConfirmSave,
      ),
      barrierDismissible: false,
    );
  }
}