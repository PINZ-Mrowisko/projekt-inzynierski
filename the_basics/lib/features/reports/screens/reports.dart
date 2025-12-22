import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/reports/usecases/show_export_dialog.dart';
import 'package:the_basics/features/reports/utils/report_exporter.dart';
import 'package:the_basics/features/reports/utils/report_tab_type.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/generic_list.dart';
import '../../auth/models/user_model.dart';
import '../../employees/controllers/user_controller.dart';
import '../../../../utils/common_widgets/side_menu.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  ReportsScreen({super.key});

   @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

  class _ReportsScreenState extends State<ReportsScreen> {
    final UserController userController = Get.find<UserController>();
    final LeaveController leaveController = Get.find<LeaveController>();

    final RxInt selectedTab = 0.obs;
    final Rx<UserModel?> _selectedUser = Rx<UserModel?>(null);

    final isLoading = true.obs;
    final readyToShow = false.obs;
    final isExporting = false.obs;

    final GlobalKey _yearlyChartKey = GlobalKey();
    final GlobalKey _monthlyChartKey = GlobalKey();
    final GlobalKey _sundaysChartKey = GlobalKey();

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
                              return _yearlyLeaveTotalsTab(userController, leaveController);
                            case 1:
                              return _monthlyLeavesTotalsTab(leaveController);
                            case 2:
                              return _workingSundaysTab(userController);
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
        );
      });
    }

    // YEARLY TOTAL OF LEAVES PER EMPLOYEE TAB
    Widget _yearlyLeaveTotalsTab(
      UserController userController, LeaveController leaveController) {
      final employees = userController.allEmployees.toList();
      final currentYear = DateTime.now().year;

      if (employees.isEmpty) {
        return Center(
          child: Text(
            "Brak pracowników do wyświetlenia",
            style: TextStyle(fontSize: 16, color: AppColors.textColor2),
          ),
        );
      }

      final employeeTotals = employees.map((emp) {
        final acceptedLeaves = leaveController.allLeaveRequests
            .where((l) =>
                l.userId == emp.id &&
                l.status.toLowerCase() == 'zaakceptowany' &&
                l.startDate.year == currentYear)
            .toList();
        final totalDays = acceptedLeaves.fold<int>(0, (sum, l) => sum + l.totalDays);
        return {'employee': emp, 'totalDays': totalDays};
      }).toList();

      employeeTotals.sort((a, b) => (b['totalDays'] as int).compareTo(a['totalDays'] as int));

      // BAR CHART DATA
      final barGroups = <BarChartGroupData>[];
      int index = 0;
      int maxDays = 0;

      for (final item in employeeTotals) {
        final emp = item['employee'] as UserModel;
        final totalDays = item['totalDays'] as int;

        if (totalDays > maxDays) maxDays = totalDays;

        barGroups.add(
          BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: totalDays.toDouble(),
                color: AppColors.logolighter,
                width: 16,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
        );
        index++;
      }

      // X AXIS LABELS
      Widget bottomTitles(double value, TitleMeta meta) {
        final idx = value.toInt();
        if (idx < 0 || idx >= employeeTotals.length) return Container();
        final name = (employeeTotals[idx]['employee'] as UserModel).firstName ?? '';
        return SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text(
            name,
            style: TextStyle(fontSize: 12, color: AppColors.textColor2),
            textAlign: TextAlign.center,
          ),
        );
      }

      // Y AXIS LABELS
      Widget leftTitles(double value, TitleMeta meta) {
        return SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text(
            value.toInt().toString(),
            style: TextStyle(fontSize: 12, color: AppColors.textColor2),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                "Urlopy w roku $currentYear",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.logo,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: RepaintBoundary(
                  key: _yearlyChartKey,
                  child: BarChart(
                    BarChartData(
                      maxY: (maxDays * 1.2).ceilToDouble(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: bottomTitles,
                            reservedSize: 40,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: leftTitles,
                            reservedSize: 30,
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: barGroups,
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        horizontalInterval: 1,
                      ),
                      alignment: BarChartAlignment.spaceAround,
                  
                      // TOOLTIP
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: AppColors.pageBackground,
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final employee = employeeTotals[group.x.toInt()]['employee'] as UserModel;
                            final days = rod.toY.toInt();
                            return BarTooltipItem(
                              '${employee.firstName}\n$days dni',
                              TextStyle(
                                color: AppColors.textColor2,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // MONTHLY TOTAL OF LEAVES IN A YEAR PER EMPLOYEE TAB
    Widget _monthlyLeavesTotalsTab(LeaveController leaveController) {
      final currentYear = DateTime.now().year; 

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildUserDropdown(),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final selectedUser = _selectedUser.value;

                if (selectedUser == null) {
                  return Center(
                    child: Text(
                      "Wybierz pracownika aby wyświetlić dane",
                      style: TextStyle(fontSize: 16, color: AppColors.textColor2),
                    ),
                  );
                }

                // MONTHLY TOTALS CALCULATION
                final monthlyTotals = List<int>.filled(12, 0);

                for (final leave in leaveController.allLeaveRequests) {
                  if (leave.userId == selectedUser.id &&
                      leave.status.toLowerCase() == 'zaakceptowany' &&
                      leave.startDate.year == currentYear) {
                    final monthIndex = leave.startDate.month - 1; // 0-based index
                    monthlyTotals[monthIndex] += leave.totalDays;
                  }
                }

                // MAXIMUM Y VALUE FOR CHART
                final maxY = (monthlyTotals.reduce((a, b) => a > b ? a : b) * 1.2)
                    .ceilToDouble();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        "Urlopy w roku $currentYear",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.logo,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: RepaintBoundary(
                          key: _monthlyChartKey,
                          child: BarChart(
                            BarChartData(
                              maxY: maxY > 0 ? maxY : 10,
                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) => SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                        value.toInt().toString(),
                                        style: TextStyle(fontSize: 12, color: AppColors.textColor2),
                                      ),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      const monthLabels = [
                                        "Sty","Lut","Mar","Kwi","Maj","Cze","Lip","Sie","Wrz","Paź","Lis","Gru"
                                      ];
                                      if (value.toInt() < 0 || value.toInt() > 11) return Container();
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(
                                          monthLabels[value.toInt()],
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: true,
                                horizontalInterval: 1,
                              ),
                              barGroups: List.generate(12, (i) {
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: monthlyTotals[i].toDouble(),
                                      color: AppColors.logolighter,
                                      width: 16,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ],
                                );
                              }),
                              alignment: BarChartAlignment.spaceAround,
                          
                              // TOOLTIP
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipBgColor: AppColors.pageBackground,
                                  tooltipPadding: const EdgeInsets.all(8),
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    final monthNames = [
                                      "Styczeń","Luty","Marzec","Kwiecień","Maj","Czerwiec",
                                      "Lipiec","Sierpień","Wrzesień","Październik","Listopad","Grudzień"
                                    ];
                                    final days = rod.toY.toInt();
                                    return BarTooltipItem(
                                      '${monthNames[group.x.toInt()]}\n$days dni',
                                      TextStyle(
                                        color: AppColors.textColor2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      );
    }

    // WORKING SUNDAYS TAB 
    // TODO: implement actual data fetching and display ALSO SORT IT BY NUMBER OF WORKING SUNDAYS
    Widget _workingSundaysTab(UserController userController) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(
              child: Obx(() {
                final users = userController.allEmployees.toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      "Brak użytkowników.",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return RepaintBoundary(
                  key: _sundaysChartKey,
                  child: GenericList<UserModel>(
                    items: users,
                    itemBuilder: (context, user) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        title: Text(
                          "${user.firstName} ${user.lastName}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor1,
                          ),
                        ),
                        subtitle: Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textColor2,
                          ),
                        ),
                        trailing: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.logolighter,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            "3",
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      );
    }

    Widget _buildExportReportButton(
      BuildContext context,
    ) {
      return CustomButton(
        text: 'Eksportuj',
        icon: Icons.download,
        width: 140,
        onPressed: () => showExportDialog(context, _exportCurrentTab),
      );
    }

    Widget _buildUserDropdown() {
      final userController = Get.find<UserController>();

      return Obx(() {
        final users = userController.allEmployees.toList();

        return SizedBox(
          height: 56,
          child: DropdownButtonFormField<UserModel>(
            value: _selectedUser.value,
            hint: Text(
              "Wybierz pracownika",
              style: TextStyle(
                color: AppColors.textColor2,
                fontSize: 16,
              ),
            ),
            items: users.map((user) {
              return DropdownMenuItem<UserModel>(
                value: user,
                child: Text(
                  "${user.firstName} ${user.lastName}",
                  style: TextStyle(fontSize: 16, color: AppColors.textColor1),
                ),
              );
            }).toList(),
            onChanged: (user) {
              _selectedUser.value = user;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              hoverColor: AppColors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              height: 1.0,
              color: AppColors.textColor1,
            ),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: AppColors.textColor2),
            dropdownColor: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            elevation: 4,
            menuMaxHeight: 300,
            itemHeight: 48,
          ),
        ).paddingOnly(bottom: 8);
      });
    }

  void _exportCurrentTab() {
    switch (selectedTab.value) {
      case 0:
        ReportExporter.exportToPdf(
          type: ReportTabType.yearlyLeaves,
          chartKey: _yearlyChartKey,
          title: 'Urlopy roczne ${DateTime.now().year}',
        );
        break;

      case 1:
        ReportExporter.exportToPdf(
          type: ReportTabType.monthlyLeaves,
          chartKey: _monthlyChartKey,
          title: 'Urlopy - ${_selectedUser.value?.firstName ?? ""} ${_selectedUser.value?.lastName ?? ""} ${DateTime.now().year}',
        );
        break;

      case 2:
        ReportExporter.exportToPdf(
          type: ReportTabType.workingSundays,
          chartKey: _sundaysChartKey,
          title: 'Niedziele handlowe ${DateTime.now().year}',
        );
        break;
    }
  }

}
