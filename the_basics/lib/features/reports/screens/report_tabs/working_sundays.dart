// WORKING SUNDAYS TAB 
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/schedules/controllers/schedule_controller.dart';
import 'package:the_basics/utils/app_colors.dart';

Widget workingSundaysTab(UserController userController, sundaysChartKey) {
      final scheduleController = Get.find<SchedulesController>();
      final currentYear = DateTime.now().year;
      final employees = userController.allEmployees.toList();

      if (employees.isEmpty) {
        return Center(
          child: Text(
            "Brak pracowników do wyświetlenia",
            style: TextStyle(fontSize: 16, color: AppColors.textColor2),
          ),
        );
      }

      // get from schedules
      final employeeSundays = employees.map((emp) {
        // count sundays worked this year
        final sundays = scheduleController.individualShifts
            .where((shift) {
              return shift.employeeID == emp.id &&
                    shift.shiftDate.year == currentYear &&
                    shift.shiftDate.weekday == 7 &&
                    !shift.isDeleted;
            })
            .length;
        
        return {'employee': emp, 'sundays': sundays};
      }).toList();

      // sort by sundays desc
      employeeSundays.sort((a, b) => (b['sundays'] as int).compareTo(a['sundays'] as int));

      // BAR CHART DATA
      final barGroups = <BarChartGroupData>[];
      int index = 0;
      int maxSundays = 0;

      for (final item in employeeSundays) {
        final sundays = item['sundays'] as int;
        if (sundays > maxSundays) maxSundays = sundays;

        barGroups.add(
          BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: sundays.toDouble(),
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
        if (idx < 0 || idx >= employeeSundays.length) return Container();
        final name = (employeeSundays[idx]['employee'] as UserModel).lastName ?? '';
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
                "Niedziele handlowe w roku $currentYear",
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
                  key: sundaysChartKey,
                  child: BarChart(
                    BarChartData(
                      maxY: maxSundays > 0 ? (maxSundays * 1.2).ceilToDouble() : 10,
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
                            final employee = employeeSundays[group.x.toInt()]['employee'] as UserModel;
                            final sundays = rod.toY.toInt();
                            return BarTooltipItem(
                              '${employee.firstName}\n$sundays ${sundays == 1 ? "niedziela" : sundays < 5 ? "niedziele" : "niedziel"}',
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