import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/schedules/controllers/schedule_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

void showChooseExistingScheduleDialog(BuildContext context, Function(String?) onScheduleSelected) async {
  final scheduleController = Get.find<SchedulesController>();
  final userController = Get.find<UserController>();

  bool isLoaderOpen = true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final marketId = userController.employee.value.marketId;

    final allSchedules = await scheduleController.fetchAllRecentSchedules(marketId);

    if (isLoaderOpen && context.mounted) {
      Navigator.of(context).pop();
      isLoaderOpen = false;
    }

    final now = DateTime.now();
    final validSchedules = allSchedules.where((schedule) {
      if (schedule.yearOfUsage < now.year) return true;
      if (schedule.yearOfUsage == now.year && schedule.monthOfUsage <= now.month) {
        return true;
      }
      return false;
    }).toList();

    if (validSchedules.isEmpty) {
      await Get.dialog(
        Builder(
          builder: (context) {
            return CustomFormDialog(
              title: 'Brak dostępnych grafików',
              width: 500,
              height: 350,
              onClose: null,
              fields: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Nie znaleziono żadnych historycznych ani bieżących grafików, na podstawie których można by wygenerować nowy plan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textColor2),
                  ),
                ),
              ],
              actions: [
                DialogActionButton(
                  label: 'Rozumiem',
                  onPressed: () => Get.back(), // Zamknij okno
                  backgroundColor: AppColors.blue,
                  textColor: AppColors.textColor2,
                ),
              ],
            );
          }
        ),
        barrierDismissible: true,
      );
      return; // Koniec funkcji
    }

    final scheduleItems = validSchedules.map((schedule) {
      final monthName = _getMonthName(schedule.monthOfUsage);
      return DropdownItem(
        value: schedule.id ?? '',
        label: '$monthName ${schedule.yearOfUsage}',
      );
    }).toList();

    String? selectedSchedule;

    final result = await Get.dialog<String>(
      StatefulBuilder(
        builder: (context, setState) {
          return CustomFormDialog(
            title: 'Wybierz bazowy grafik',
            width: 600,
            height: 380,
            onClose: null,
            fields: [
              DropdownDialogField(
                label: 'Grafik bazowy',
                hintText: 'Wybierz miesiąc z listy',
                items: scheduleItems,
                onChanged: (value) {
                  setState(() {
                    selectedSchedule = value;
                  });
                },
              ),
            ],
            actions: [
              DialogActionButton(
                label: 'Anuluj',
                onPressed: () => Get.back(result: null),
                backgroundColor: AppColors.lightBlue,
                textColor: AppColors.textColor2,
              ),
              DialogActionButton(
                label: 'Generuj grafik',
                onPressed: () {
                  if (selectedSchedule != null) {
                    Get.back(result: selectedSchedule);
                  } else {
                    showCustomSnackbar(context, "Proszę wybrać grafik.");
                  }
                },
                backgroundColor: AppColors.blue,
                textColor: AppColors.textColor2,
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );

    if (result != null) {
      onScheduleSelected(result);
    }

  } catch (e) {
    if (isLoaderOpen && context.mounted) {
      Navigator.of(context).pop();
      isLoaderOpen = false;
    }
    print("Błąd: $e");
  }
}

String _getMonthName(int month) {
  const months = [
    '', 'Styczeń', 'Luty', 'Marzec', 'Kwiecień', 'Maj', 'Czerwiec',
    'Lipiec', 'Sierpień', 'Wrzesień', 'Październik', 'Listopad', 'Grudzień'
  ];
  if (month < 1 || month > 12) return '';
  return months[month];
}