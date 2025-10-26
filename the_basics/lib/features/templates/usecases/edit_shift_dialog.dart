import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/features/templates/controllers/template_controller.dart';
import 'package:the_basics/features/templates/models/template_shift_model.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

void showEditShiftDialog(
  BuildContext context,
  TemplateController templateController,
  TagsController tagsController,
  ShiftModel shift,
) {
  final countController = TextEditingController(text: shift.count.toString());
  final startTimeController = TextEditingController(
    text: '${shift.start.hour.toString().padLeft(2, '0')}:${shift.start.minute.toString().padLeft(2, '0')}'
  );
  final endTimeController = TextEditingController(
    text: '${shift.end.hour.toString().padLeft(2, '0')}:${shift.end.minute.toString().padLeft(2, '0')}'
  );
  
  String? selectedTagId = shift.tagId;
  String? selectedTagName = shift.tagName;

  // sprawdzenie formatu godziny HH:MM
  TimeOfDay? _parseTime(String timeText) {
    try {
      final parts = timeText.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null && hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Get.dialog(
    BaseDialog(
      width: 550,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edytuj zmianę',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: AppColors.textColor2,
            ),
          ),
          const SizedBox(height: 24),

          // tag
          const Text(
            'Tag',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor2,
            ),
          ),
          const SizedBox(height: 6),
          Obx(() {
            final tags = tagsController.allTags;
            final dropdownValue = tags.any((tag) => tag.id == selectedTagId) ? selectedTagId : null;

            return DropdownButtonFormField<String>(
              value: dropdownValue,
              dropdownColor: AppColors.white,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Wybierz tag',
              ),
              items: tags
                  .map((tag) => DropdownMenuItem(
                        value: tag.id,
                        child: Text(tag.tagName),
                      ))
                  .toList(),
              onChanged: (value) {
                final tag = tags.firstWhereOrNull((t) => t.id == value);
                selectedTagId = tag?.id;
                selectedTagName = tag?.tagName;
              },
            );
          }),
          const SizedBox(height: 16),

          // liczba osób
          const Text(
            'Liczba osób',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor2,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: countController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Wpisz liczbę osób',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // godziny w jednym wierszu
          Row(
            children: [
              // start zmiany
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start zmiany',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: startTimeController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        hintText: 'HH:MM',
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        // automatyczne dodawanie dwukropka
                        if (value.length == 2 && !value.contains(':')) {
                          startTimeController.text = '$value:';
                          startTimeController.selection = TextSelection.fromPosition(
                            TextPosition(offset: startTimeController.text.length),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // koniec zmiany
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Koniec zmiany',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: endTimeController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        hintText: 'HH:MM',
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        // automatyczne dodawanie dwukropka
                        if (value.length == 2 && !value.contains(':')) {
                          endTimeController.text = '$value:';
                          endTimeController.selection = TextSelection.fromPosition(
                            TextPosition(offset: endTimeController.text.length),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Wpisz godzinę w formacie 24h (np. 08:00, 14:30, 22:15)',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textColor2.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          // buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // przycisk usuń
              SizedBox(
                width: 127,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final index = templateController.addedShifts.indexWhere((s) => s.id == shift.id);
                    if (index != -1) {
                      templateController.addedShifts.removeAt(index);
                      templateController.addedShifts.refresh();
                    }
                    Get.back();
                    showCustomSnackbar(context, 'Zmiana została usunięta');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    'Usuń',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // przycisk anuluj
              SizedBox(
                width: 127,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    'Anuluj',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // przycisk zapisz
              SizedBox(
                width: 127,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // walidacja
                    if (selectedTagId == null) {
                      showCustomSnackbar(context, 'Wybierz tag!');
                      return;
                    }

                    if (countController.text.isEmpty) {
                      showCustomSnackbar(context, 'Wpisz liczbę osób!');
                      return;
                    }

                    final startTime = _parseTime(startTimeController.text);
                    final endTime = _parseTime(endTimeController.text);

                    if (startTime == null || endTime == null) {
                      showCustomSnackbar(context, 'Wpisz poprawne godziny w formacie HH:MM!');
                      return;
                    }

                    final updatedShift = shift.copyWith(
                      tagId: selectedTagId!,
                      tagName: selectedTagName ?? '',
                      count: int.parse(countController.text),
                      start: startTime,
                      end: endTime,
                    );

                    final index = templateController.addedShifts.indexWhere((s) => s.id == shift.id);
                    if (index != -1) {
                      templateController.addedShifts[index] = updatedShift;
                      templateController.addedShifts.refresh();
                    }

                    Get.back();
                    showCustomSnackbar(context, 'Zmiana została zaktualizowana');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    'Zapisz',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    barrierDismissible: false,
  );
}