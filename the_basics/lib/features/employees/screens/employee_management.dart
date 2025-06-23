import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/models/user_model.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/common_widgets/custom_button.dart';
import '../../../utils/common_widgets/generic_list.dart';
import '../../../utils/common_widgets/multi_select_dropdown.dart';
import '../../../utils/common_widgets/search_bar.dart';
import '../../../utils/common_widgets/side_menu.dart';
import '../../tags/controllers/tags_controller.dart';
import '../controllers/user_controller.dart';

import '../usecases/add_dialog.dart';
import '../usecases/edit_dialog.dart';

class EmployeeManagementPage extends StatelessWidget {
  const EmployeeManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final tagsController = Get.find<TagsController>();
    final selectedTags = <String>[].obs;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.resetFilters();
    });

    // init on page load
    ever(selectedTags, (tags) {
      userController.filterEmployees(tags);
    });

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
                          'Pracownicy',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logo,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: _buildTagFilterDropdown(
                            tagsController,
                            selectedTags,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildSearchBar(selectedTags),
                        const SizedBox(width: 16),
                        _buildAddEmployeeButton(context, userController),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Obx(() {
                      if (userController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      // if (userController.errorMessage.value.isNotEmpty) {
                      //   return Center(
                      //     child: Column(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Text(
                      //           userController.errorMessage.value,
                      //           style: TextStyle(color: Colors.red),
                      //           textAlign: TextAlign.center,
                      //         ),
                      //         const SizedBox(height: 16),
                      //         ElevatedButton(
                      //           onPressed: () {
                      //             userController.errorMessage(''); // Clear error
                      //           },
                      //           child: const Text('Spróbuj ponownie'),
                      //         ),
                      //       ],
                      //     ),
                      //   );
                      // }
                      if (userController.filteredEmployees.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Brak dostępnych pracowników'),
                            ],
                          ),
                        );
                      }
                      return _buildEmployeesList(context, userController);
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

  Widget _buildTagFilterDropdown(TagsController tagsController, RxList<String> selectedTags) {
    return Obx(() {
      return CustomMultiSelectDropdown(
        items: tagsController.allTags.map((tag) => tag.tagName).toList(),
        selectedItems: selectedTags,
        onSelectionChanged: (selected) {
          selectedTags.assignAll(selected);
        },
        hintText: 'Filtruj po tagach',
        leadingIcon: Icons.filter_alt_outlined,
        widthPercentage: 0.2,
        maxWidth: 360,
        minWidth: 160,
      );
    });
  }

  Widget _buildAddEmployeeButton(
    BuildContext context,
    UserController controller,
  ) {
    return CustomButton(
      text: 'Dodaj Pracownika',
      icon: Icons.add,
      width: 180,
      onPressed: () => showAddEmployeeDialog(context, controller),
    );
  }

  Widget _buildSearchBar(RxList<String> selectedTags) {
    final userController = Get.find<UserController>();
  
    return CustomSearchBar(
      hintText: 'Wyszukaj pracownika',
      widthPercentage: 0.2,
      maxWidth: 360,
      minWidth: 160,
      onChanged: (query) {
        userController.searchQuery.value = query;
        userController.filterEmployees(selectedTags);
      },
    );
  }

  Widget _buildEmployeesList(BuildContext context, UserController controller) {
    return GenericList<UserModel>(
      items: controller.filteredEmployees,
      onItemTap: (employee) => showEditEmployeeDialog(context, controller, employee),
      itemBuilder: (context, employee) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          title: Text(
            '${employee.firstName} ${employee.lastName}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor1,
            ),
          ),
          subtitle: _buildEmployeeTags(employee.tags),
        );
      },
    );
  }

  Widget _buildEmployeeTags(List<String> tags) {
    if (tags.isEmpty) {
      return const Text(
        'Brak tagów',
        style: TextStyle(fontSize: 14, color: AppColors.textColor2),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          tags
              .map(
                (tag) => RawChip(
                  label: Text(
                    tag,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.33,
                      letterSpacing: 0.5,
                      color: AppColors.textColor2,
                    ),
                  ),
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Color(0xFFCAC4D0), width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
    );
  }
}
