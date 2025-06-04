import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import '../../../utils/common_widgets/custom_button.dart';
import '../../../utils/common_widgets/generic_list.dart';
import '../../../utils/common_widgets/search_bar.dart';
import '../../../utils/common_widgets/side_menu.dart';
import '../models/tags_model.dart';

import '../usecases/add_dialog.dart';
import '../usecases/edit_dialog.dart';

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
            child: SideMenu(),
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
                                onPressed: () => showAddTagDialog(context, tagsController),
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
      onPressed: () => showAddTagDialog(context, controller),
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
      onItemTap: (tag) => showEditTagDialog(context, controller, tag),
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
}