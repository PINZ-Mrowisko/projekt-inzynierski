// MONTHLY TOTAL OF LEAVES IN A YEAR PER EMPLOYEE TAB
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/utils/app_colors.dart';

Widget monthlyLeavesTotalsTab(LeaveController leaveController, monthlyChartKey, selectedUser) {
      final currentYear = DateTime.now().year; 

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildUserDropdown(selectedUser),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {

                if (selectedUser.value == null) {
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
                  final status = leave.status.toLowerCase();

                  if (leave.userId == selectedUser.value.id &&
                      (status == 'zaakceptowany' || status == 'mój urlop') &&
                      leave.startDate.year == currentYear) {
                    final monthIndex = leave.startDate.month - 1;
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
                          key: monthlyChartKey,
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
                                      '${monthNames[group.x.toInt()]}\n$days ${days == 1 ? "dzień" : days < 5 ? "dni" : "dni"}',
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

Widget _buildUserDropdown(selectedUser) {
      final userController = Get.find<UserController>();

      return Obx(() {
        final users = userController.allEmployees.toList();

        return SizedBox(
          height: 56,
          child: DropdownButtonFormField<UserModel>(
            value: selectedUser.value,
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
              selectedUser.value = user;
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