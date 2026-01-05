import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/features/templates/controllers/template_controller.dart';
import 'package:the_basics/features/templates/models/template_shift_model.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'helpers/count_selector_widget.dart';
import 'helpers/day_input_widgets.dart';
import 'helpers/dialog_action_buttons.dart';
import 'helpers/tags_selection_widget.dart';
import 'helpers/template_dialog_constants.dart';
import 'helpers/time_input_widgets.dart';

void showAddShiftDialog(
    BuildContext context,
    TemplateController templateController,
    TagsController tagsController,
    String day,
    ) {
  final countController = TextEditingController(text: '1');
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();

  final selectedTagIds = <String>[];
  final selectedTagNames = <String>[];

  bool obeyGeneralRules = true;

  final selectedDays = <String, bool>{}.obs;
  for (final dayData in TemplateDialogConstants.polishDays) {
    selectedDays[dayData['full']!] = dayData['full'] == day;
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

  void validateAndSubmit() {
    // validation logic here (same as before)
    if (selectedTagIds.isEmpty) {
      showCustomSnackbar(context, 'Wybierz przynajmniej jeden tag!');
      return;
    }


    // create shifts
    for (final dayEntry in selectedDays.entries) {
      if (dayEntry.value) {
        final shift = ShiftModel(
          id: UniqueKey().toString(),
          tagIds: List.from(selectedTagIds),
          tagNames: List.from(selectedTagNames),
          count: int.parse(countController.text),
          start: TemplateDialogConstants.parseTime(startTimeController.text)!,
          end: TemplateDialogConstants.parseTime(endTimeController.text)!,
          day: dayEntry.key,
          obeyGeneralRules: obeyGeneralRules,
        );
        templateController.addShift(shift);
      }
    }

    Get.back();
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
                'Dodaj zmianę',
                style: TemplateDialogConstants.titleStyle,
              ),
              const SizedBox(height: 24),

              // Tags selection
              TagsSelectionWidget(
                tagsController: tagsController,
                initialTagIds: selectedTagIds,
                initialTagNames: selectedTagNames,
                onSelectionChanged: (ids, names) {
                  selectedTagIds
                    ..clear()
                    ..addAll(ids);
                  selectedTagNames
                    ..clear()
                    ..addAll(names);
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),

              // Count selector
              CountSelectorWidget(
                controller: countController,
                onIncrement: incrementCount,
                onDecrement: decrementCount,
              ),
              const SizedBox(height: 16),

              // Time inputs
              Row(
                children: [
                  TimeInputWidget(
                    label: 'Start zmiany',
                    initialValue: startTimeController.text,
                    filterTimeOptions: TemplateDialogConstants.filterTimeOptions,
                    onTimeSelected: (value) {
                      startTimeController.text = value;
                    },
                  ),
                  const SizedBox(width: 16),
                  TimeInputWidget(
                    label: 'Koniec zmiany',
                    initialValue: endTimeController.text,
                    filterTimeOptions: TemplateDialogConstants.filterTimeOptions,
                    onTimeSelected: (value) {
                      endTimeController.text = value;
                    },
                  ),
                ],
              ),
              // Time hint
              const SizedBox(height: 8),
              Text(
                'Wpisz godzinę (np. 8:30) lub wybierz z listy',
                style: TemplateDialogConstants.hintStyle,
              ),
              const SizedBox(height: 24),

              // Day selection
              DaySelectionWidget(
                selectedDays: selectedDays,
                onDayTapped: (dayName) {
                  selectedDays[dayName] = !(selectedDays[dayName] ?? false);
                },
              ),
              const SizedBox(height: 24),

              // checkmark for general rule application
              Row(
                children: [
                  Checkbox(
                    value: !obeyGeneralRules,
                    onChanged: (value) {
                      setState(() {
                        obeyGeneralRules = !(value ?? false);
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Nie aplikuj zasad ogólnych do tej zmiany',
                      style: TemplateDialogConstants.hintStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),


              // Action buttons
              DialogActionButtons(
                onCancel: () => Get.back(),
                onConfirm: validateAndSubmit,
                confirmText: 'Dodaj zmiany',
              ),
            ],
          );
        },
      ),
    ),
    barrierDismissible: false,
  );
}