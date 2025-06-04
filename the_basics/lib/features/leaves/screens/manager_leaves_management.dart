import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/common_widgets/multi_select_dropdown.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/common_widgets/custom_button.dart';
import '../../../utils/common_widgets/generic_list.dart';
import '../../../utils/common_widgets/side_menu.dart';
import '../../employees/controllers/user_controller.dart';

import '../usecases/add_dialog_manager.dart';

class ManagerLeavesManagementPage extends StatelessWidget {
  const ManagerLeavesManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final tagsController = Get.find<TagsController>(); // to delete later
    final selectedEmployees = <String>[].obs;
    final selectedStatuses = <String>[].obs;

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
                          'Wnioski urlopowe',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logo,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: _buildEmployeeFilterDropdown(userController, selectedEmployees),
                        ),
                        const SizedBox(width: 16),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: _buildStatusFilterDropdown(tagsController, selectedStatuses),
                        ),
                        const SizedBox(width: 16),
                        _buildAddLeaveButton(context, userController),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildLeaveList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddLeaveButton(BuildContext context, UserController controller) {
    return CustomButton(
      text: 'Dodaj urlop',
      icon: Icons.add,
      width: 140,
      onPressed: () => showAddManagerLeaveDialog(context),
    );
  }

  //need to implement actual logic
  Widget _buildEmployeeFilterDropdown(UserController userController, RxList<String> selectedEmployees) {
    return Obx(() {
      double screenWidth = MediaQuery.of(Get.context!).size.width;
      double dropdownWidth = screenWidth * 0.2;
      if (dropdownWidth > 360) dropdownWidth = 360;

      return CustomMultiSelectDropdown(
        items: userController.allEmployees.map((user) => '${user.firstName} ${user.lastName}').toList(),
        selectedItems: selectedEmployees,
        onSelectionChanged: (selected) {
          selectedEmployees.assignAll(selected);
        },
        hintText: 'Filtruj po pracowniku',
        width: dropdownWidth,
        leadingIcon: Icons.filter_alt_outlined,
      );
    });
  }

  //need to implement actual logic (!!!! change from tags to dynamic fetch of statuses -> i couldnt hardcode it since dynamic fetch is required for widget to work)
  Widget _buildStatusFilterDropdown(TagsController tagsController, RxList<String> selectedStatuses) {
    return Obx(() {
      double screenWidth = MediaQuery.of(Get.context!).size.width;
      double dropdownWidth = screenWidth * 0.2;
      if (dropdownWidth > 360) dropdownWidth = 360;

      return CustomMultiSelectDropdown(
        items: tagsController.allTags.map((tag) => tag.tagName).toList(),
        selectedItems: selectedStatuses,
        onSelectionChanged: (selected) {
          selectedStatuses.assignAll(selected);
        },
        hintText: 'Filtruj po statusie',
        width: dropdownWidth,
        leadingIcon: Icons.filter_alt_outlined,
      );
    });
  }

  //need to implement actual logic (dynamic fetch of leave requests)
  Widget _buildLeaveList() {
    final leaveRequests = [
      {
        'employee': 'Jan Kowalski',
        'type': 'Urlop na żądanie',
        'date': '1 kwietnia',
        'status': 'Oczekujący',
      },
      {
        'employee': 'Anna Nowak',
        'type': 'Urlop wypoczynkowy',
        'date': '3 - 7 lutego',
        'status': 'Zaakceptowany',
      },
      {
        'employee': 'Marek Wiśniewski',
        'type': 'Urlop wypoczynkowy',
        'date': '2 - 3 stycznia',
        'status': 'Odrzucony',
      },
      {
        'employee': 'Kierownik',
        'type': 'Urlop wypoczynkowy',
        'date': '2 - 3 stycznia',
        'status': 'Mój urlop',
      },
    ];

    return GenericList<Map<String, String>>(
      items: leaveRequests,
      itemBuilder: (context, item) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          title: Text(
            '${item['employee']} - ${item['type']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor1,
            ),
          ),
          subtitle: Text(
            item['date']!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textColor2,
            ),
          ),
          trailing: item['status']!.toLowerCase() == 'oczekujący'
              ? _buildDecisionButtons(context, item)
              : _buildStatusChip(item['status']!),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    IconData icon;

    switch (status.toLowerCase()) {
      case 'zaakceptowany':
        icon = Icons.check;
        break;
      case 'odrzucony':
        icon = Icons.close;
        break;
      case 'oczekujący':
        icon = Icons.access_time;
        break;
      case 'mój urlop':
        icon = Icons.sunny;
        break;
      default:
        icon = Icons.help_outline;
    }

    return RawChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textColor2,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.33,
              letterSpacing: 0.5,
              color: AppColors.textColor2,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: const Color(0xFFCAC4D0),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDecisionButtons(BuildContext context, Map<String, String> item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDecisionButton(
          text: 'Odrzuć',
          color: AppColors.logo.withValues(alpha: 0.5),
          icon: Icons.close,
          onPressed: () {
            //to implement actual logic
            showCustomSnackbar(context,'Wniosek odrzucony');
          },
        ),
        const SizedBox(width: 8),
        _buildDecisionButton(
          text: 'Akceptuj',
          color: AppColors.logo,
          icon: Icons.check,
          onPressed: () {
            //to implement actual logic
            showCustomSnackbar(context,'Wniosek zaakceptowany');
          },
        ),
      ],
    );
  }

  Widget _buildDecisionButton({
    required String text,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return RawChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.white,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.33,
              letterSpacing: 0.5,
              color: AppColors.white,
            ),
          ),
        ],
      ),
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: color,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }
}