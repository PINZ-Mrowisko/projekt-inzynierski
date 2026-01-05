import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/dashboard/screens/mobile/dashboard_tiles_mobile/important_tile_mobile.dart';
import 'package:the_basics/features/dashboard/screens/mobile/dashboard_tiles_mobile/leaves_tile_mobile.dart';
import 'package:the_basics/features/dashboard/screens/mobile/dashboard_tiles_mobile/shift_tile_mobile.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/schedules/controllers/schedule_controller.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/bottom_menu_mobile/bottom_menu_mobile.dart';
import '../../../employees/controllers/user_controller.dart';

class ManagerDashboardMobileScreen extends StatefulWidget {
  const ManagerDashboardMobileScreen({super.key});

  @override
  State<ManagerDashboardMobileScreen> createState() => _ManagerDashboardMobileScreenState();
}

class _ManagerDashboardMobileScreenState extends State<ManagerDashboardMobileScreen> {
  final UserController userController = Get.find<UserController>();
  final LeaveController leaveController = Get.find<LeaveController>();
  final SchedulesController schedulesController =Get.find<SchedulesController>();
  final TagsController tagsController =Get.find<TagsController>();

  final isLoading = true.obs;
  final readyToShow = false.obs;

  final RxInt selectedTab = 0.obs;
  final RxInt currentMenuIndex = 2.obs;

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

      final tabs = [
        "Aktualna zmiana",
        "Wnioski",
        "Ważne",
      ];

      if (isLoading.value || !readyToShow.value) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 14),
            color: AppColors.pageBackground,
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      'Dashboard',
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
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 26),
                      color: AppColors.logo,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.logo)
        ),
      );
    }

      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 14),
            color: AppColors.pageBackground,
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      'Dashboard',
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
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 26),
                      color: AppColors.logo,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // TABS
            Obx(() {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    for (int i = 0; i < tabs.length; i++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => selectedTab.value = i,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: selectedTab.value == i
                                      ? AppColors.lightBlue
                                      : AppColors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                tabs[i],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: selectedTab.value == i
                                      ? AppColors.logolighter
                                      : AppColors.textColor2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            // TAB CONTENT
            Expanded(
              child: Obx(() {
                switch (selectedTab.value) {
                  case 0:
                    return shiftTab(userController, schedulesController, tagsController);

                  case 1:
                    return leavesTab(leaveController);

                  case 2:
                    return importantTab();

                  default:
                    return Container();
                }
              }),
            )
          ],
        ),
        bottomNavigationBar: MobileBottomMenu(currentIndex: currentMenuIndex),
      );
    });
  }
}
