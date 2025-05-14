import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/controllers/tags_controller.dart';
import 'package:the_basics/features/schedules/widgets/form_dialog.dart';
import 'package:the_basics/features/schedules/widgets/side_menu.dart';
import 'package:the_basics/features/schedules/widgets/notification_snackbar.dart';
import 'package:the_basics/utils/app_colors.dart';
import '../../models/tags_model.dart';
import 'package:the_basics/features/schedules/widgets/confirmation_dialog.dart';
import 'package:the_basics/features/schedules/widgets/custom_button.dart';
import 'package:the_basics/features/schedules/widgets/search_bar.dart';
import 'package:the_basics/features/schedules/widgets/generic_list.dart';

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

  //need to implement logic
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
    controller.nameController.clear();
    controller.descController.clear();

    Get.dialog(
      CustomFormDialog(
        title: 'Dodaj nowy Tag',
        onClose: () => Get.back(),
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
            label: 'Dodaj Tag',
            onPressed: () async {
              try {
                if (controller.nameController.text.isEmpty) {
                  showCustomSnackbar(context, 'Nazwa tagu nie może być pusta');
                  return;
                }
                await controller.saveTag(controller.userController.employee.value.marketId);
                Get.back();
                showCustomSnackbar(context, 'Tag został dodany.');
              } catch (e) {
                showCustomSnackbar(context, 'Błąd podczas dodawania tagu: ${e.toString()}');
              }
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showEditTagDialog(BuildContext context, TagsController controller, TagsModel tag) {
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
            onPressed: () => _confirmDeleteTag(controller, tag.id, tag.tagName),
            backgroundColor: AppColors.warning,
            textColor: AppColors.white,
          ),
          DialogActionButton(
            label: 'Zapisz',
            onPressed: () {
              try {
                if (nameController.text.isEmpty) {
                  showCustomSnackbar(context, 'Nazwa tagu nie może być pusta');
                  return;
                }
                _showSaveConfirmationDialog(() async {
                  try {
                    final updatedTag = tag.copyWith(
                      tagName: nameController.text,
                      description: descController.text,
                      updatedAt: DateTime.now(),
                    );
                    await controller.updateTag(updatedTag);
                    Get.back();
                    Get.back();
                    showCustomSnackbar(context, 'Zmiany zostały zapisane.');
                  } catch (e) {
                    showCustomSnackbar(context, 'Błąd podczas aktualizacji tagu: ${e.toString()}');
                  }
                });
              } catch (e) {
                showCustomSnackbar(context, 'Wystąpił nieoczekiwany błąd');
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

  void _confirmDeleteTag(TagsController controller, String tagId, String tagName) {
    final userCount = controller.countUsersWithTag(tagName);
    String warningText;
    String? confirmText;
    if (userCount == 1) {
      warningText = '$userCount użytkownik ma ten tag!';
      confirmText = 'Czy na pewno chcesz usunąć "$tagName"?';
    } else if (userCount > 1) {
      warningText = '$userCount użytkowników ma ten tag!';
      confirmText = 'Czy na pewno chcesz usunąć "$tagName"?';
    } else {
      warningText = 'Czy na pewno chcesz usunąć tag "$tagName"?';
      confirmText = null;
    }

    Get.dialog(
      ConfirmationDialog(
        title: warningText,
        subtitle: confirmText,
        confirmText: 'Usuń',
        cancelText: 'Anuluj',
        confirmButtonColor: AppColors.warning,
        confirmTextColor: AppColors.white,
        onConfirm: () async {
          try {
            await controller.deleteTag(tagId, tagName);
            Get.back();
            Get.back();
            showCustomSnackbar(Get.context!, 'Tag został pomyślnie usunięty.');
          } catch (e) {
            Get.back();
            showCustomSnackbar(Get.context!, 'Błąd podczas usuwania tagu: ${e.toString()}',);
          }
        },
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