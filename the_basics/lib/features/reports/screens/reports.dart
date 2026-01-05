import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/reports/screens/report_tabs/monthly_leaves.dart';
import 'package:the_basics/features/reports/screens/report_tabs/working_sundays.dart';
import 'package:the_basics/features/reports/screens/report_tabs/yearly_leaves.dart';
import 'package:the_basics/features/reports/usecases/show_export_dialog.dart';
import 'package:the_basics/features/reports/utils/report_exporter.dart';
import 'package:the_basics/features/reports/utils/report_tab_type.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import '../../auth/models/user_model.dart';
import '../../employees/controllers/user_controller.dart';
import '../../../../utils/common_widgets/side_menu.dart';

class ReportsScreen extends StatefulWidget {
  ReportsScreen({super.key});

   @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

  class _ReportsScreenState extends State<ReportsScreen> {
    final UserController userController = Get.find<UserController>();
    final LeaveController leaveController = Get.find<LeaveController>();

    final RxInt selectedTab = 0.obs;
    final Rx<UserModel?> selectedUser = Rx<UserModel?>(null);

    final isLoading = true.obs;
    final readyToShow = false.obs;
    final isExporting = false.obs;

    final GlobalKey yearlyChartKey = GlobalKey();
    final GlobalKey monthlyChartKey = GlobalKey();
    final GlobalKey sundaysChartKey = GlobalKey();

    @override
    void initState() {
      super.initState();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        isLoading.value = true;
        readyToShow.value = false;

        try {
          await userController.fetchAllEmployees();
          await leaveController.fetchLeaves();
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
              child: Center(
                child: CircularProgressIndicator(color: AppColors.logo),
              ),
            ),
          ],
        ),
      );
    }

    final tabs = [
      "Urlopy w skali rocznej",
      "Urlopy w skali miesięcznej",
      "Niedziele handlowe",
    ];

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
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
                              "Raporty",
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
                                    child: _buildExportReportButton(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // TABS
                      Obx(() {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (int i = 0; i < tabs.length; i++)
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => selectedTab.value = i,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      margin: const EdgeInsets.only(right: 16),
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
                                      child: Text(
                                        tabs[i],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: selectedTab.value == i
                                              ? AppColors.logolighter
                                              : AppColors.textColor2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      //TAB CONTENT
                      Expanded(
                        child: Obx(() {
                          switch (selectedTab.value) {
                            case 0:
                              return yearlyLeaveTotalsTab(userController, leaveController, yearlyChartKey);
                            case 1:
                              return monthlyLeavesTotalsTab(leaveController, monthlyChartKey, selectedUser);
                            case 2:
                              return workingSundaysTab(userController,sundaysChartKey);
                            default:
                              return Container();
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // LOADING OVERLAY
        if (isExporting.value)
          Container(
            color: AppColors.pageBackground.withOpacity(0.8),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: AppColors.logo,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Eksportowanie...\n',
                            style: TextStyle(
                              color: AppColors.logo,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'To może potrwać kilka sekund.\nProszę czekać.',
                            style: TextStyle(
                              color: AppColors.textColor2,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    )
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  });
}

Widget _buildExportReportButton(BuildContext context) {
  return CustomButton(
    text: 'Eksportuj',
    icon: Icons.download,
    width: 140,
    onPressed: () {
      if (!isExporting.value) {
        showExportDialog(context, _exportCurrentTab);
      }
    },
  );
}

Future<void> _exportCurrentTab() async {
  isExporting.value = true;
    
  try {
    // DELAY FOR SMOOTHNESS
    await Future.delayed(const Duration(milliseconds: 300));
      
    switch (selectedTab.value) {
      case 0:
        await ReportExporter.exportToPdf(
          type: ReportTabType.yearlyLeaves,
          chartKey: yearlyChartKey,
          title: 'Urlopy roczne ${DateTime.now().year}',
        );
        break;

      case 1:
        await ReportExporter.exportToPdf(
          type: ReportTabType.monthlyLeaves,
          chartKey: monthlyChartKey,
          title: 'Urlopy - ${selectedUser.value?.firstName ?? ""} ${selectedUser.value?.lastName ?? ""} ${DateTime.now().year}',
        );
        break;

      case 2:
        await ReportExporter.exportToPdf(
          type: ReportTabType.workingSundays,
          chartKey: sundaysChartKey,
          title: 'Niedziele handlowe ${DateTime.now().year}',
        );
        break;
      }
      if (mounted && context.mounted) {
        showCustomSnackbar(context, "Raport został pomyślnie zapisany.");
      }
    } catch (e) {
      if (mounted && context.mounted) {
        showCustomSnackbar(context, "Wystąpił błąd podczas eksportu raportu: $e");
      }
    } finally {
      isExporting.value = false;
    }
  }

}
