import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/leaves/models/leave_model.dart';
import 'package:the_basics/features/notifs/controllers/notif_controller.dart';
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
    final leaveController = Get.find<LeaveController>();

    final selectedEmployees = <String>[].obs;
    final selectedStatuses = <String>[].obs;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      leaveController.resetFilters();
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
                          'Wnioski urlopowe',
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
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: _buildEmployeeFilterDropdown(userController, selectedEmployees, leaveController, selectedStatuses),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: _buildStatusFilterDropdown(leaveController, selectedStatuses, selectedEmployees),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: _buildAddLeaveButton(context, leaveController),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (leaveController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (leaveController.errorMessage.value.isNotEmpty) {
                        return Center(child: Text(leaveController.errorMessage.value));
                      }
                      if (leaveController.filteredLeaves.isEmpty) {
                        return const Center(child: Text('Brak wniosków urlopowych'));
                      }
                      return _buildLeaveList(leaveController, userController);
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

  Widget _buildAddLeaveButton(BuildContext context, LeaveController controller) {
    return CustomButton(
      text: 'Dodaj urlop',
      icon: Icons.add,
      width: 140,

      /// this is for the managers leave - so no need to accept it I suppose, just move straight to accepted list
      onPressed: () => showAddManagerLeaveDialog(context, controller),
    );
  }

  Widget _buildEmployeeFilterDropdown(UserController userController, RxList<String> selectedEmployees, LeaveController controller, RxList<String> selectedStatuses) {
    return Obx(() {
      return CustomMultiSelectDropdown(
        items: userController.allEmployees.map((user) => '${user.firstName} ${user.lastName}').toList(),
        selectedItems: selectedEmployees,
        onSelectionChanged: (selected) {
          selectedEmployees.assignAll(selected);
          controller.filterLeaves(selectedEmployees, selectedStatuses);
          //print(selectedEmployees);
        },
        hintText: 'Filtruj po pracowniku',
        leadingIcon: Icons.filter_alt_outlined,
        widthPercentage: 0.2,
        maxWidth: 450,
        minWidth: 160,
      );
    });
  }


  /// THIS THINGIE ALLOWS: filter leave requests by status
  Widget _buildStatusFilterDropdown(LeaveController leaveController, RxList<String> selectedStatuses, RxList<String> selectedEmployees) {
    return Obx(() {

      // Get unique statuses by converting to a Set and back to List
      final uniqueStatuses = leaveController.allLeaveRequests
          .map((leave) => capitalize(leave.status))
          .toSet() // Removes duplicates
          .toList();

      return CustomMultiSelectDropdown(
        items: uniqueStatuses,
        selectedItems: selectedStatuses,
        onSelectionChanged: (selected) {
          selectedStatuses.assignAll(
            selected.map((s) {
              if (s == "Mój urlop") {
                return s;
              } else {
                return lowercase(s);
              }
            }).toList(),
          );
          leaveController.filterLeaves(selectedEmployees, selectedStatuses);
        },
        hintText: 'Filtruj po statusie',
        leadingIcon: Icons.filter_alt_outlined,
        widthPercentage: 0.2,
        maxWidth: 360,
        minWidth: 160,
      );
    });
  }

  Widget _buildLeaveList(LeaveController controller, UserController userController) {

    return GenericList<LeaveModel>(
      items: controller.filteredLeaves,
      itemBuilder: (context, item) {
        final formattedDate = item.startDate == item.endDate
            ? DateFormat('dd.MM.yyyy').format(item.startDate)
            : '${DateFormat('dd.MM.yyyy').format(item.startDate)} - ${DateFormat('dd.MM.yyyy').format(item.endDate)}';

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          title: Text(
            (item.comment == "Brak komentarza" || item.comment == '')
                ? item.name
                : '${item.name} - ${item.comment}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor1,
            ),
          ),
          subtitle: Text(
            formattedDate,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textColor2,
            ),
          ),
          trailing: item.status.toLowerCase() == 'oczekujący'
              ? _buildDecisionButtons(context, item, controller, userController)
              : _buildStatusChip(item.status),
        );
      },
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  String lowercase(String s) => s[0].toLowerCase() + s.substring(1);

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

    final fixStatus = capitalize(status);

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
            fixStatus,
            style: TextStyle(
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

  Widget _buildDecisionButtons(BuildContext context, LeaveModel leave, LeaveController controller, UserController userController) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDecisionButton(
          text: 'Odrzuć',
          color: AppColors.logo.withValues(alpha: 0.5),
          icon: Icons.close,
          onPressed: () async {
            try {
              final employee = await userController.getEmployeeById(
                  leave.userId, leave.marketId);
              if (employee == null) {
                showCustomSnackbar(context, 'Nie znaleziono pracownika');
                return;
              }
              // add back the holdiay days to the employee
              // convert to int so doesnt throw error
              final currentLeaves = int.tryParse(employee.numberOfLeaves.toString()) ?? 0;
              final totalDays = int.tryParse(leave.totalDays.toString()) ?? 0;

              final updatedEmployee = employee.copyWith(
                numberOfLeaves: currentLeaves - totalDays
              );

              // update the leave request
              final newLeave = leave.copyWith(status: "odrzucony");
              controller.updateLeave(newLeave);
              userController.updateEmployee(updatedEmployee);

              /// notify employee about status change : send notif
              Get.find<NotificationController>().leaveStatusChangeNotification(leave.userId, "denied");


              showCustomSnackbar(context,'Wniosek odrzucony');

            } catch (e) {
              showCustomSnackbar(context, 'Błąd: ${e.toString()}');
            }

          },
        ),
        const SizedBox(width: 8),
        _buildDecisionButton(
          text: 'Akceptuj',
          color: AppColors.logo,
          icon: Icons.check,
          onPressed: () {
            final newLeave = leave.copyWith(status: "zaakceptowany");
            controller.updateLeave(newLeave);

            /// CHNAGE STATUS TO ZAAKCEPTOWANY

            /// send notif to user about leave status change
            print(leave.userId);
            Get.find<NotificationController>().leaveStatusChangeNotification(leave.userId, "accepted");

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
            style: TextStyle(
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