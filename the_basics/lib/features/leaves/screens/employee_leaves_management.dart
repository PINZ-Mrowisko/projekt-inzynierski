import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:the_basics/features/leaves/models/leave_model.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/common_widgets/custom_button.dart';
import '../../../utils/common_widgets/generic_list.dart';
import '../../../utils/common_widgets/side_menu.dart';
import '../../employees/controllers/user_controller.dart';

import '../controllers/leave_controller.dart';
import '../usecases/add_dialog_employee.dart';

class EmployeeLeavesManagementPage extends StatelessWidget {
  const EmployeeLeavesManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final leaveController = Get.find<LeaveController>();

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
                              child: _buildAddLeaveButton(context, userController),
                            ),
                          ],
                         ),
                        )
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

  Widget _buildAddLeaveButton(BuildContext context, UserController controller) {
    return CustomButton(
      text: 'Złóż wniosek o urlop',
      icon: Icons.add,
      width: 190,
      onPressed: () => showAddEmployeeLeaveDialog(context),
    );
  }

  //to implement actual logic (dynamic list of leave requests)
  Widget _buildLeaveList(LeaveController controller, UserController userController) {
    // we filter requests to show only the current employee's requests - sort newest top
    final employeeRequests = controller.allLeaveRequests
        .where((request) => request.userId == userController.employee.value.id)
        .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));

    if (employeeRequests.isEmpty) {
      return const Center(child: Text('Brak złożonych wniosków urlopowych'));
    }

    return GenericList<LeaveModel>(
      items: employeeRequests,
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
                ? "Nieobecność"
                : 'Nieobecność - ${item.comment}',
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
          trailing: _buildStatusChip(item.status),
        );
      },
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

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
}