import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/features/templates/controllers/template_controller.dart';
import 'package:the_basics/features/templates/models/template_shift_model.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

void showAddShiftDialog(
    BuildContext context,
    TemplateController templateController,
    TagsController tagsController,
    String day,
    ) {
  final countController = TextEditingController(text: '1');
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  String? selectedTagId;
  String? selectedTagName;

  // Polish day names and abbreviations
  final List<Map<String, String>> days = [
    {'full': 'Poniedziałek', 'short': 'Pn'},
    {'full': 'Wtorek', 'short': 'Wt'},
    {'full': 'Środa', 'short': 'Śr'},
    {'full': 'Czwartek', 'short': 'Cz'},
    {'full': 'Piątek', 'short': 'Pt'},
    {'full': 'Sobota', 'short': 'Sb'},
    {'full': 'Niedziela', 'short': 'Nd'},
  ];

  final RxMap<String, bool> selectedDays = <String, bool>{}.obs;
  for (final dayData in days) {
    selectedDays[dayData['full']!] = dayData['full'] == day;
  }

  // generate time options every 30 minutes from 00:00 to 23:30
  final List<String> timeOptions = List.generate(48, (index) {
    final hour = (index ~/ 2).toString().padLeft(2, '0');
    final minute = (index % 2 == 0) ? '00' : '30';
    return '$hour:$minute';
  });

  // helper to parse time
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

  // filter time options based on input
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
      return commonWorkHours.take(48).toList();
    }

    // Try to match exact time or partial match
    return timeOptions.where((time) {
      return time.toLowerCase().contains(input.toLowerCase());
    }).toList();
  }
  // increment count
  void incrementCount() {
    final current = int.tryParse(countController.text) ?? 1;
    countController.text = (current + 1).toString();
  }

  // decrement count
  void decrementCount() {
    final current = int.tryParse(countController.text) ?? 1;
    if (current > 1) {
      countController.text = (current - 1).toString();
    }
  }

  Get.dialog(
    BaseDialog(
      width: 550,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dodaj zmianę',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: AppColors.textColor2,
            ),
          ),
          const SizedBox(height: 24),

          // wybierz tag
          Text(
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
            return DropdownButtonFormField<String>(
              value: selectedTagId,
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

          // liczba osób with +/- pryciskami dla ulatwienia
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

                // plusik
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

          // godziny w jednym wierszu - single input with autocomplete
          Row(
            children: [
              // start zmiany
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
                          // Sync with our controller
                          fieldTextEditingController.addListener(() {
                            startTimeController.text = fieldTextEditingController.text;
                          });

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
                                  // Show dropdown when icon is clicked
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
                                width: 200, // Fixed width for dropdown
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

              // koniec zmiany
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
                          // sync with our controller
                          fieldTextEditingController.addListener(() {
                            endTimeController.text = fieldTextEditingController.text;
                          });

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
                                  // only show dropdown when icon is clicked
                                  fieldFocusNode.requestFocus();
                                },
                              ),
                            ),
                            onChanged: (value) {
                              // dwie kropki
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
          // podpowiedź
          const SizedBox(height: 8),
          Text(
            'Wpisz godzinę (np. 8:30) lub wybierz z listy',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textColor2.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          /// NEW FUNCTION : APPLY SHIFT TILE TO MULTIPLE DAYS
          Text(
            'Zastosuj do dni:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor2,
            ),
          ),
          const SizedBox(height: 12),

          // Day circles
          Obx(() {
            final selectedCount = selectedDays.values.where((isSelected) => isSelected).length;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: days.map((dayData) {
                    final dayName = dayData['full']!;
                    final dayShort = dayData['short']!;
                    final isSelected = selectedDays[dayName] ?? false;

                    return GestureDetector(
                      onTap: () {
                        selectedDays[dayName] = !isSelected;
                        selectedDays.refresh();
                      },
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
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  'Wybrano $selectedCount ${_getDayCountText(selectedCount)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textColor2.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              SizedBox(
                width: 150,
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

                    // validate that end time is after start time !
                    final startTotalMinutes = startTime.hour * 60 + startTime.minute;
                    final endTotalMinutes = endTime.hour * 60 + endTime.minute;
                    if (endTotalMinutes <= startTotalMinutes) {
                      showCustomSnackbar(context, 'Godzina końca musi być późniejsza niż godzina startu!');
                      return;
                    }

                    /// validate new day stuff
                    // check if at least one day is selected
                    final selectedDayCount = selectedDays.values.where((isSelected) => isSelected).length;
                    if (selectedDayCount == 0) {
                      showCustomSnackbar(context, 'Wybierz przynajmniej jeden dzień!');
                      return;
                    }

                    // create shifts for all selected days
                    for (final dayEntry in selectedDays.entries) {
                      if (dayEntry.value) {
                        final shift = ShiftModel(
                          id: UniqueKey().toString(),
                          tagId: selectedTagId!,
                          tagName: selectedTagName ?? '',
                          count: int.parse(countController.text),
                          start: startTime,
                          end: endTime,
                          day: dayEntry.key,
                        );
                        templateController.addShift(shift);
                      }
                    }

                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'Dodaj zmiany',
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

// aby bylo pieknie i po polsku
String _getDayCountText(int count) {
  if (count == 1) return 'dzień';
  if (count >= 2 && count <= 4) return 'dni';
  return 'dni';
}