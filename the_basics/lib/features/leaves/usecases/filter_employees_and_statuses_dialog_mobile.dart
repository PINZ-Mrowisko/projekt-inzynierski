import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

void showEmployeesAndStatusesFilterDialogMobile(
    BuildContext context,
    RxList<String> selectedEmployees,
    RxList<String> selectedStatuses,
    UserController userController,
    LeaveController leaveController) {
  final tempSelectedEmployees = List<String>.from(selectedEmployees);
  final tempSelectedStatuses = List<String>.from(selectedStatuses);

  final uniqueStatuses = leaveController.allLeaveRequests
      .map((leave) => leave.status)
      .toSet()
      .toList();

  showDialog(
    context: context,
    builder: (context) => Transform.scale(
      scale: 0.85,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = MediaQuery.of(context).size.height * 0.6;

          return BaseDialog(
            width: 500,
            showCloseButton: true,
            child: StatefulBuilder(
              builder: (context, setState) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        "Filtruj wnioski urlopowe",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textColor2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pracownicy",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...userController.allEmployees.map((e) {
                                final name = '${e.firstName} ${e.lastName}';
                                final selected = tempSelectedEmployees.contains(name);
                                return CheckboxListTile(
                                  value: selected,
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        tempSelectedEmployees.add(name);
                                      } else {
                                        tempSelectedEmployees.remove(name);
                                      }
                                    });
                                  },
                                  title: Text(name),
                                  activeColor: AppColors.logo,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  dense: true,
                                );
                              }).toList(),
                              const SizedBox(height: 16),
                              Text(
                                "Statusy",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor2,
                                ),
                              ),
                              const SizedBox(height: 8),
                                ...uniqueStatuses.map((status) {
                                final selected = tempSelectedStatuses.contains(status);
                                return CheckboxListTile(
                                  value: selected,
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        tempSelectedStatuses.add(status);
                                      } else {
                                        tempSelectedStatuses.remove(status);
                                      }
                                    });
                                  },
                                  title: Text(capitalize(status)),
                                  activeColor: AppColors.logo,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  dense: true,
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            //height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  tempSelectedEmployees.clear();
                                  tempSelectedStatuses.clear();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text("Wyczyść", style: TextStyle(color: AppColors.textColor2),),
                            ),
                          ),
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 140,
                            //height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                selectedEmployees.assignAll(tempSelectedEmployees);
                                selectedStatuses.assignAll(tempSelectedStatuses);
                                leaveController.filterLeaves(selectedEmployees, selectedStatuses);
                                Navigator.of(context).pop();
                                showCustomSnackbar(context, "Filtry zostały zastosowane.");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text("Zastosuj", style: TextStyle(color: AppColors.textColor2),),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    ),
  );
}

String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

