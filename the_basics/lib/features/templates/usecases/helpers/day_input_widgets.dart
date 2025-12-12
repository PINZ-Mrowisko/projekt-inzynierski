import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/templates/usecases/helpers/template_dialog_constants.dart';
import 'package:the_basics/utils/app_colors.dart';

class DaySelectionWidget extends StatelessWidget {
  final RxMap<String, bool> selectedDays;
  final Function(String) onDayTapped;

  const DaySelectionWidget({
    Key? key,
    required this.selectedDays,
    required this.onDayTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Zastosuj do dni:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor2,
          ),
        ),
        const SizedBox(height: 12),

        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: TemplateDialogConstants.polishDays.map((dayData) {
                final dayName = dayData['full']!;
                final dayShort = dayData['short']!;

                return Obx(() {
                  final isSelected = selectedDays[dayName] ?? false;

                  return GestureDetector(
                    onTap: () => onDayTapped(dayName),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.blue : AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.blue : AppColors.lightBlue,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          dayShort,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.white : AppColors.textColor2,
                          ),
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final selectedCount = selectedDays.values.where((isSelected) => isSelected).length;
              return Text(
                'Wybrano $selectedCount ${TemplateDialogConstants.getDayCountText(selectedCount)}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textColor2.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}