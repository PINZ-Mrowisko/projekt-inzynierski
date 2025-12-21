import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/common_widgets/multi_select_dropdown.dart';
import 'package:the_basics/utils/common_widgets/search_bar.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import '../utils/calendar_state_manager.dart';

class CalendarFilters extends StatelessWidget {
  const CalendarFilters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tagsController = Get.find<TagsController>();
    final userController = Get.find<UserController>();
    final stateManager = Get.find<CalendarStateManager>();

    return Row(
      children: [
        Flexible(
          child: _buildTagFilterDropdown(tagsController, stateManager),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: _buildSearchBar(userController, stateManager),
        ),
      ],
    );
  }

  Widget _buildTagFilterDropdown(
      TagsController tagsController,
      CalendarStateManager stateManager,
      ) {
    return Obx(() {
      return CustomMultiSelectDropdown(
        items: tagsController.allTags.map((tag) => tag.tagName).toList(),
        selectedItems: stateManager.selectedTags,
        onSelectionChanged: stateManager.updateSelectedTags,
        hintText: 'Filtruj po tagach',
        leadingIcon: Icons.filter_alt_outlined,
        widthPercentage: 0.2,
        maxWidth: 360,
        minWidth: 160,
      );
    });
  }

  Widget _buildSearchBar(
      UserController userController,
      CalendarStateManager stateManager,
      ) {
    return CustomSearchBar(
      hintText: 'Wyszukaj pracownika',
      widthPercentage: 0.2,
      maxWidth: 360,
      minWidth: 160,
      onChanged: (query) {
        userController.searchQuery.value = query;
        userController.filterEmployees(stateManager.selectedTags);
      },
    );
  }
}