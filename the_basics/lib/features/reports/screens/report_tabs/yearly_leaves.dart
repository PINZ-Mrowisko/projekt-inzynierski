// YEARLY TOTAL OF LEAVES PER EMPLOYEE TAB
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/utils/app_colors.dart';

Widget yearlyLeaveTotalsTab(
      UserController userController, LeaveController leaveController, yearlyChartKey) {
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

      // X AXIS LABELS - OBRÓCONE 45 STOPNI
      Widget bottomTitles(double value, TitleMeta meta) {
        final idx = value.toInt();
        if (idx < 0 || idx >= employeeTotals.length) return Container();
        final name =
            (employeeTotals[idx]['employee'] as UserModel).lastName ?? '';
        return SideTitleWidget(
          axisSide: meta.axisSide,
          angle: -0.5,
          child: Text(
            name,
            style: TextStyle(fontSize: 11, color: AppColors.textColor2),
            textAlign: TextAlign.right,
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
                  key: yearlyChartKey,
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
                              '${employee.firstName}\n$days ${days == 1 ? "dzień" : days < 5 ? "dni" : "dni"}',
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