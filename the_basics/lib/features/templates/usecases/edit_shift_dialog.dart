import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/features/templates/controllers/template_controller.dart';
import 'package:the_basics/features/templates/models/template_shift_model.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'helpers/count_selector_widget.dart';
import 'helpers/dialog_action_buttons.dart';
import 'helpers/tags_selection_widget.dart';
import 'helpers/template_dialog_constants.dart';
import 'helpers/time_input_widgets.dart';

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

  final List<String>selectedTagIds = List<String>.from(shift.tagIds ?? []);
  final List<String>selectedTagNames = List<String>.from(shift.tagNames ?? []);

  bool obeyGeneralRules = shift.obeyGeneralRules;


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

  void validateAndSave() {
    // VALIDATION
    if (selectedTagIds.isEmpty) {
      showCustomSnackbar(context, 'Wybierz przynajmniej jeden tag!');
      return;
    }

    if (countController.text.isEmpty) {
      showCustomSnackbar(context, 'Wpisz liczbę osób!');
      return;
    }

    final startTime = TemplateDialogConstants.parseTime(startTimeController.text);
    final endTime = TemplateDialogConstants.parseTime(endTimeController.text);

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
      tagIds: List.from(selectedTagIds),
      tagNames: List.from(selectedTagNames),
      count: int.parse(countController.text),
      start: startTime,
      end: endTime,
      day: shift.day,
      obeyGeneralRules: obeyGeneralRules
    );

    final index = templateController.addedShifts.indexWhere((s) => s.id == shift.id);
    if (index != -1) {
      templateController.addedShifts[index] = updatedShift;
      templateController.addedShifts.refresh();
    }

    Get.back();
    showCustomSnackbar(context, 'Zmiana została zaktualizowana');
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
                style: TemplateDialogConstants.titleStyle,
              ),
              const SizedBox(height: 24),

              // TAGS FIELD
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

              // LICZBA OSÓB
              CountSelectorWidget(
                controller: countController,
                onIncrement: incrementCount,
                onDecrement: decrementCount,
              ),
              const SizedBox(height: 16),

              // GODZINY
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


              // BUTTONY
              DialogActionButtons(
                onCancel: () => Get.back(),
                onConfirm: validateAndSave,
                confirmText: 'Zapisz',
                showDeleteButton: true,
                onDelete: () {
                  final index = templateController.addedShifts.indexWhere((s) => s.id == shift.id);
                  if (index != -1) {
                    templateController.addedShifts.removeAt(index);
                    templateController.addedShifts.refresh();
                  }
                  Get.back();
                  showCustomSnackbar(context, 'Zmiana została usunięta');
                },
              ),
            ],
          );
        },
      ),
    ),
    barrierDismissible: false,
  );
}