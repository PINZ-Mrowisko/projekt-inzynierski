import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/reports/usecases/show_export_dialog.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/generic_list.dart';
import '../../auth/models/user_model.dart';
import '../../employees/controllers/user_controller.dart';
import '../../../../utils/common_widgets/side_menu.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatelessWidget {
  ReportsScreen({super.key});

  final RxInt selectedTab = 0.obs;
  final Rx<UserModel?> _selectedUser = Rx<UserModel?>(null);

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Obx(() {
      final user = userController.employee.value;

      if (user == null) {
        return Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppColors.logo)),
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
                            return _yearlyLeaveTotalsTab();
                          case 1:
                            return _monthlyLeavesTotalsTab();
                          case 2:
                            return _workingSundaysTab();
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
  Widget _yearlyLeaveTotalsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 10,
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 16,
                  getTitlesWidget: (value, _) {
                    const titles = ["Sty", "Lut", "Mar", "Kwi"];
                    return Text(
                      titles[value.toInt()],
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(toY: 4, color: AppColors.blue),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(toY: 7, color: AppColors.blue),
                ],
              ),
              BarChartGroupData(
                x: 2,
                barRods: [
                  BarChartRodData(toY: 3, color: AppColors.blue),
                ],
              ),
              BarChartGroupData(
                x: 3,
                barRods: [
                  BarChartRodData(toY: 6, color: AppColors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MONTHLY TOTAL OF LEAVES IN A YEAR PER EMPLOYEE TAB
  Widget _monthlyLeavesTotalsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildUserDropdown(),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              height: 240,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 16,
                        getTitlesWidget: (value, _) {
                          const titles = ["Sty", "Lut", "Mar", "Kwi"];
                          return Text(
                            titles[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(toY: 4, color: AppColors.blue),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(toY: 7, color: AppColors.blue),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(toY: 3, color: AppColors.blue),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(toY: 6, color: AppColors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ])
      );
  }

  // WORKING SUNDAYS TAB
  Widget _workingSundaysTab() {
    final userController = Get.find<UserController>();

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

              return GenericList<UserModel>(
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
                    trailing: Icon(
                      user.hasLoggedIn ? Icons.check_circle : Icons.hourglass_empty,
                      color: user.hasLoggedIn ? Colors.green : Colors.orange,
                    ),
                  );
                },
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
      onPressed: () => showExportDialog(context),
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
            // TODO: logika filtrowania wykresu po wybranym użytkowniku
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

}
