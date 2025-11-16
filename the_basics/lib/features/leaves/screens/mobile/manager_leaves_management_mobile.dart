import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/leaves/models/leave_model.dart';
import 'package:the_basics/features/leaves/usecases/add_dialog_employee_mobile.dart';
import 'package:the_basics/features/leaves/usecases/add_dialog_manager_mobile.dart';
import 'package:the_basics/features/leaves/usecases/filter_employees_and_statuses_dialog_mobile.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/generic_list.dart';
import 'package:the_basics/utils/common_widgets/bottom_menu_mobile/bottom_menu_mobile.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import '../../usecases/add_dialog_employee.dart';

class ManagerLeavesManagementMobilePage extends StatelessWidget {
  ManagerLeavesManagementMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final leaveController = Get.find<LeaveController>();
    final RxInt _currentMenuIndex = 2.obs;

    final selectedEmployees = <String>[].obs;
    final selectedStatuses = <String>[].obs;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      leaveController.resetFilters();
    });

    return Obx(() => Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              color: AppColors.pageBackground,
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 14),
              child: SafeArea(
                bottom: false,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Wnioski',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _currentMenuIndex.value = 2;
                              Get.back();
                            },
                            icon: const Icon(Icons.arrow_back_ios, size: 26),
                            color: AppColors.logo,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              showEmployeesAndStatusesFilterDialogMobile(context, selectedEmployees, selectedStatuses, userController, leaveController);
                            },
                            icon: const Icon(Icons.filter_alt_outlined, size: 26),
                            color: AppColors.logo,
                          ),
                          IconButton(
                            onPressed: () => showAddManagerLeaveMobileDialog(context, leaveController),
                            icon: const Icon(Icons.add, size: 30),
                            color: AppColors.logo,
                          ),
                        ]
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Obx(() {
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
          bottomNavigationBar: MobileBottomMenu(currentIndex: _currentMenuIndex),
        ));
  }

  Widget _buildLeaveList(LeaveController controller, UserController userController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GenericList<LeaveModel>(
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
      )
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
          color: AppColors.logolighter,
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
              final duration = leave.totalDays;
              print(duration);
              final updatedEmployee = employee.copyWith(
                numberOfLeaves: employee.numberOfLeaves - leave.totalDays
              );

              // update the leave request
              final newLeave = leave.copyWith(status: "odrzucony");
              controller.updateLeave(newLeave);
              userController.updateEmployee(updatedEmployee);

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
