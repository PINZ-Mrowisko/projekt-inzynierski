import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/dashboard/screens/web/dashboard_tiles/important_tile.dart';
import 'package:the_basics/features/dashboard/screens/web/dashboard_tiles/leaves_tile.dart';
import 'package:the_basics/features/dashboard/screens/web/dashboard_tiles/shift_tile.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/schedules/controllers/schedule_controller.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import '../../../employees/controllers/user_controller.dart';
import '../../../../utils/common_widgets/side_menu.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  final UserController userController = Get.find<UserController>();
  final LeaveController leaveController = Get.find<LeaveController>();
  final SchedulesController schedulesController =Get.find<SchedulesController>();
  final TagsController tagsController =Get.find<TagsController>();

  final isLoading = true.obs;
  final readyToShow = false.obs;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isLoading.value = true;
      readyToShow.value = false;
      
      try {
        await userController.fetchAllEmployees();
        await leaveController.fetchLeaves();
        await schedulesController.initialize();

        await Future.delayed(const Duration(milliseconds: 50));
        
        readyToShow.value = true;
      } finally {
        isLoading.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = userController.employee.value;

      if (user == null) {
        return Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppColors.logo)),
        );
      }

      if (isLoading.value || !readyToShow.value) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                child: SideMenu(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 80,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Dashboard",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.logo,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: AppColors.logo),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
              child: SideMenu(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 80,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Dashboard",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.logo,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: 300,
                                maxHeight: double.infinity,
                              ),
                              child: shiftTile(userController, schedulesController, tagsController),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: 300,
                                maxHeight: double.infinity,
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: leavesTile(leaveController),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: importantTile(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
