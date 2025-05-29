import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/common_widgets/custom_button.dart';
import '../../../utils/common_widgets/generic_list.dart';
import '../../../utils/common_widgets/side_menu.dart';
import '../../employees/controllers/user_controller.dart';

import '../usecases/add_dialog_employee.dart';

class EmployeeLeavesManagementPage extends StatelessWidget {
  const EmployeeLeavesManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    //not in use for now
    final userController = Get.find<UserController>();

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
                          'Wnioski urlopowe',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logo,
                          ),
                        ),
                        const Spacer(),
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
      text: 'Złóż wniosek o urlop',
      icon: Icons.add,
      width: 190,
      onPressed: () => showAddEmployeeLeaveDialog(context),
    );
  }

  //to implement actual logic (dynamic list of leave requests)
  Widget _buildLeaveList() {
    final leaveRequests = [
      {'type': 'Urlop na żądanie', 'date': '1 kwietnia', 'status': 'Oczekujący'},
      {'type': 'Urlop wypoczynkowy', 'date': '3 - 7 lutego', 'status': 'Zaakceptowany'},
      {'type': 'Urlop wypoczynkowy', 'date': '2 - 3 stycznia', 'status': 'Odrzucony'},
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
            item['type']!,
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
          trailing: _buildStatusChip(item['status']!),
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
}