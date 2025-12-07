import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
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

  List<String> selectedTagIds = List.from(shift.tagIds ?? []);
  List<String> selectedTagNames = List.from(shift.tagNames ?? []);

  final List<String> timeOptions = List.generate(48, (index) {
    final hour = (index ~/ 2).toString().padLeft(2, '0');
    final minute = (index % 2 == 0) ? '00' : '30';
    return '$hour:$minute';
  });

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

  List<String> _filterTimeOptions(String input) {
    if (input.isEmpty) {
      final commonWorkHours = [
        '06:00', '06:30', '07:00', '07:30', '08:00', '08:30',
        '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
        '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
        '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
        '18:00', '18:30', '19:00', '19:30', '20:00', '20:30',
        '21:00', '21:30', '22:00', '22:30', '23:00', '23:30'
      ];
      return commonWorkHours.take(12).toList();
    }

    return timeOptions.where((time) {
      return time.toLowerCase().contains(input.toLowerCase());
    }).toList();
  }

  void incrementCount() {
    final current = int.tryParse(countController.text) ?? 1;
    countController.text = (current + 1).toString();
  }

  void decrementCount() {
    final current = int.tryParse(countController.text) ?? 1;
    if (current > 1) {
      countController.text = (current - 1).toString();
    }
  }

  Get.dialog(
    BaseDialog(
      width: 550,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edytuj zmianę',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textColor2,
                ),
              ),
              const SizedBox(height: 24),

              // --------------------
              //      TAGS FIELD
              // --------------------
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tagi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Obx(() {
                    final tags = tagsController.allTags;

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: MultiSelectDialogField<String>(
                        items: tags
                            .map((tag) => MultiSelectItem<String>(tag.id, tag.tagName))
                            .toList(),
                        initialValue: selectedTagIds,
                        onSelectionChanged: (values) {
                          selectedTagIds
                            ..clear()
                            ..addAll(values);

                          selectedTagNames
                            ..clear()
                            ..addAll(
                              values.map((id) =>
                              tags.firstWhereOrNull((t) => t.id == id)?.tagName ?? ''),
                            );

                          setState(() {});
                        },
                        title: Text('Wybierz tagi'),
                        buttonText: Text(
                          selectedTagNames.isEmpty ? 'Wybierz tagi' : 'Wybrano ${selectedTagNames.length} tagów',
                          style: TextStyle(
                            color: selectedTagNames.isEmpty ? Colors.grey : AppColors.textColor2,
                          ),
                        ),
                        buttonIcon: Icon(Icons.arrow_drop_down, color: AppColors.textColor2),
                        onConfirm: (values) {
                          selectedTagIds.clear();
                          selectedTagNames.clear();

                          selectedTagIds.addAll(values);

                          // Find tag names
                          for (var tagId in selectedTagIds) {
                            final tag = tags.firstWhereOrNull((t) => t.id == tagId);
                            if (tag != null) {
                              selectedTagNames.add(tag.tagName);
                            }
                          }

                          setState(() {}); // refresh UI !!!!!
                        },
                        itemsTextStyle: TextStyle(
                          fontSize: 16,
                          color: AppColors.textColor2,
                        ),
                        selectedItemsTextStyle: TextStyle(
                          fontSize: 16,
                          color: AppColors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        searchable: true,
                        searchHint: 'Szukaj tagów...',
                        validator: (values) {
                          if (values == null || values.isEmpty) {
                            return 'Wybierz przynajmniej jeden tag';
                          }
                          return null;
                        },
                        dialogHeight: 400,
                        dialogWidth: 400,
                      ),
                    );
                  })
                ],
              ),
              const SizedBox(height: 16),

              // --------------------
              //   LICZBA OSÓB
              // --------------------
              Text(
                'Liczba osób',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor2,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 56,
                child: Row(
                  children: [
                    // Minus button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: decrementCount,
                        icon: Icon(Icons.remove, color: AppColors.textColor2),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Container(
                      width: 120,
                      child: TextField(
                        controller: countController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Ilość',
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Plus button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: incrementCount,
                        icon: Icon(Icons.add, color: AppColors.textColor2),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --------------------
              //   GODZINY
              // --------------------
              Row(
                children: [
                  // Start time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start zmiany',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 56,
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              return _filterTimeOptions(textEditingValue.text);
                            },
                            onSelected: (String selection) {
                              startTimeController.text = selection;
                            },
                            fieldViewBuilder: (
                                BuildContext context,
                                TextEditingController fieldTextEditingController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted,
                                ) {
                              // sync with our controller
                              fieldTextEditingController.addListener(() {
                                startTimeController.text = fieldTextEditingController.text;
                              });

                              fieldTextEditingController.text = startTimeController.text;

                              return TextField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                  hintText: 'HH:MM lub wybierz',
                                  filled: true,
                                  fillColor: AppColors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.arrow_drop_down, color: AppColors.textColor2),
                                    onPressed: () {
                                      fieldFocusNode.requestFocus();
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.length == 2 && !value.contains(':')) {
                                    fieldTextEditingController.text = '$value:';
                                    fieldTextEditingController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: fieldTextEditingController.text.length),
                                    );
                                  }
                                },
                              );
                            },
                            optionsViewBuilder: (
                                BuildContext context,
                                AutocompleteOnSelected<String> onSelected,
                                Iterable<String> options,
                                ) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4,
                                  child: Container(
                                    constraints: const BoxConstraints(maxHeight: 200),
                                    width: 200,
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        final option = options.elementAt(index);
                                        return InkWell(
                                          onTap: () {
                                            onSelected(option);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            color: AppColors.white,
                                            child: Text(
                                              option,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.textColor2,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // End time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Koniec zmiany',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 56,
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              return _filterTimeOptions(textEditingValue.text);
                            },
                            onSelected: (String selection) {
                              endTimeController.text = selection;
                            },
                            fieldViewBuilder: (
                                BuildContext context,
                                TextEditingController fieldTextEditingController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted,
                                ) {
                              fieldTextEditingController.addListener(() {
                                endTimeController.text = fieldTextEditingController.text;
                              });

                              fieldTextEditingController.text = endTimeController.text;

                              return TextField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                  hintText: 'HH:MM lub wybierz',
                                  filled: true,
                                  fillColor: AppColors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.arrow_drop_down, color: AppColors.textColor2),
                                    onPressed: () {
                                      fieldFocusNode.requestFocus();
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  // Automatically add colon
                                  if (value.length == 2 && !value.contains(':')) {
                                    fieldTextEditingController.text = '$value:';
                                    fieldTextEditingController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: fieldTextEditingController.text.length),
                                    );
                                  }
                                },
                              );
                            },
                            optionsViewBuilder: (
                                BuildContext context,
                                AutocompleteOnSelected<String> onSelected,
                                Iterable<String> options,
                                ) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4,
                                  child: Container(
                                    constraints: const BoxConstraints(maxHeight: 200),
                                    width: 200,
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        final option = options.elementAt(index);
                                        return InkWell(
                                          onTap: () {
                                            onSelected(option);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            color: AppColors.white,
                                            child: Text(
                                              option,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.textColor2,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Time hint
              const SizedBox(height: 8),
              Text(
                'Wpisz godzinę (np. 8:30) lub wybierz z listy',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textColor2.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),

              // --------------------
              //   BUTTONY
              // --------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // CANCEL
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
                      child: Text(
                        'Anuluj',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),

                  // SAVE
                  SizedBox(
                    width: 127,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // VALIDATION
                        if (selectedTagIds.isEmpty) {
                          showCustomSnackbar(context, 'Wybierz przynajmniej jeden tag!');
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

                        final startTotalMinutes = startTime.hour * 60 + startTime.minute;
                        final endTotalMinutes = endTime.hour * 60 + endTime.minute;
                        if (endTotalMinutes <= startTotalMinutes) {
                          showCustomSnackbar(context, 'Godzina końca musi być późniejsza niż godzina startu!');
                          return;
                        }

                        final updatedShift = shift.copyWith(
                          tagIds: selectedTagIds,
                          tagNames: selectedTagNames,
                          count: int.parse(countController.text),
                          start: startTime,
                          end: endTime,
                          // we keep the same day as original
                          day: shift.day,
                        );

                        // and update the shift in the controller
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
                      child: Text(
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
          );
        },
      ),
    ),
    barrierDismissible: false,
  );
}