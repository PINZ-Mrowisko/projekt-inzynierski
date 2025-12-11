import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/notifs/controllers/notif_controller.dart';
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

    // wykonuje sie po zabojstwie widgetu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tagsController.resetFilters();
    });

    return Obx(() {
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
                        Text(
                          'Tagi',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logo,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: _buildSearchBar(),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: _buildAddTagButton(context, tagsController),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (tagsController.isLoading.value) {
                        return Center(child: CircularProgressIndicator(color: AppColors.logo));
                      }
                      if (tagsController.errorMessage.value.isNotEmpty) {
                        return Center(child: Text(tagsController.errorMessage.value));
                      }
                      if (tagsController.filteredTags.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Brak dostępnych tagów')
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
    });
  }

  Widget _buildAddTagButton(BuildContext context, TagsController controller) {
    final tagsController = Get.find<NotificationController>();


    return CustomButton(
      text: 'Dodaj Tag',
      icon: Icons.add,
      width: 130,
      //onPressed: () => showAddTagDialog(context, controller),
      onPressed: tagsController.testSendScheduleNotification,
    );
  }

  Widget _buildSearchBar() {
    final tagsController = Get.find<TagsController>();
    return CustomSearchBar(
      hintText: 'Wyszukaj tag',
      widthPercentage: 0.2,
      maxWidth: 360,
      minWidth: 160,
      onChanged: (query) {
        tagsController.searchQuery.value = query;
        tagsController.filterTags(query);
      } ,
    );
  }

  Widget _buildTagsList(BuildContext context, TagsController controller) {
    return GenericList<TagsModel>(
      items: controller.filteredTags,
      onItemTap: (tag) => showEditTagDialog(context, controller, tag),
      itemBuilder: (context, tag) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, 
            vertical: 12,
          ),
          title: Text(
            tag.tagName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor1,
            ),
          ),
          subtitle: Text(
            tag.description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textColor2,
            ),
          ),
        );
      },
    );
  }
}