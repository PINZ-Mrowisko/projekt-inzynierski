import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/models/schedule_model.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/features/tags/models/tags_model.dart';
import 'package:the_basics/features/templates/usecases/helpers/dialog_action_buttons.dart';
import 'package:the_basics/features/templates/usecases/helpers/template_dialog_constants.dart';
import 'package:the_basics/features/templates/usecases/helpers/time_input_widgets.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/common_widgets/multi_select_dropdown.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

class ShiftEditDialog extends StatefulWidget {
  final ScheduleModel? shift;
  final DateTime selectedDate;
  final String employeeId;
  final String firstName;
  final String lastName;
  final List<String> employeeTags;
  final Function(ScheduleModel) onSave;
  final Function(ScheduleModel)? onDelete;

  const ShiftEditDialog({
    super.key,
    this.shift,
    required this.selectedDate,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.employeeTags,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<ShiftEditDialog> createState() => _ShiftEditDialogState();
}

class _ShiftEditDialogState extends State<ShiftEditDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late RxList<String> _selectedTagNames;
  final TagsController _tagsController = Get.find<TagsController>();

  @override
  void initState() {
    super.initState();
    _startTime = widget.shift?.start ?? const TimeOfDay(hour: 8, minute: 0);
    _endTime = widget.shift?.end ?? const TimeOfDay(hour: 16, minute: 0);

    _selectedTagNames = <String>[].obs;

    // Logika mapowania ID
    if (widget.shift != null && widget.shift!.tags.isNotEmpty) {
      final List<String> loadedNames = [];
      for (var tagIdentifier in widget.shift!.tags) {
        try {
          final tagModel = _tagsController.allTags.firstWhere(
                  (t) => t.id == tagIdentifier,
              orElse: () => TagsModel.empty()
          );
          if (tagModel.id.isNotEmpty) {
            loadedNames.add(tagModel.tagName);
          } else {
            // Fallback na nazwę
            if(_tagsController.allTags.any((t) => t.tagName == tagIdentifier)) {
              loadedNames.add(tagIdentifier);
            }
          }
        } catch (e) {
          print("Błąd mapowania: $e");
        }
      }
      _selectedTagNames.assignAll(loadedNames);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
        width: 550,
        child: StatefulBuilder(
          builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.shift == null ? 'Dodaj zmianę' : 'Edytuj zmianę',
                style: TemplateDialogConstants.titleStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Pracownik: ${widget.firstName} ${widget.lastName}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor2,
                ),
              ),
              const SizedBox(height: 24),
          
                // WYBÓR GODZIN
                  Row(
                    children: [
                      TimeInputWidget(
                        label: 'Start zmiany',
                        initialValue: _formatTime(_startTime),
                        filterTimeOptions: TemplateDialogConstants.filterTimeOptions,
                        onTimeSelected: (value) {
                  final time = TemplateDialogConstants.parseTime(value);
                  if (time != null) {
                    setState(() => _startTime = time);
                  }
                        },
                      ),
                      const SizedBox(width: 16),
                      TimeInputWidget(
                        label: 'Koniec zmiany',
                        initialValue: _formatTime(_endTime),
                        filterTimeOptions: TemplateDialogConstants.filterTimeOptions,
                        onTimeSelected: (value) {
                  final time = TemplateDialogConstants.parseTime(value);
                  if (time != null) {
                    setState(() => _endTime = time);
                  }
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
          
              // Tagi Dropdown
              const Text('Tagi', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() => CustomMultiSelectDropdown(
                items: _tagsController.allTags.map((t) => t.tagName).toList(),
                selectedItems: _selectedTagNames,
                onSelectionChanged: (list) => _selectedTagNames.assignAll(list),
                hintText: 'Wybierz tagi',
              )),
          
              // --- NOWA SEKCJA OSTRZEŻENIA ---
              Obx(() {
                // Sprawdzamy, czy którykolwiek z wybranych tagów NIE znajduje się w liście tagów pracownika
                // Porównujemy nazwy (String)
                final missingTags = _selectedTagNames.where(
                        (selected) => !widget.employeeTags.contains(selected)
                ).toList();
          
                if (missingTags.isEmpty) return const SizedBox.shrink();
          
                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pracownik nie posiada przydzielonego tagu: ${missingTags.join(", ")}',
                          style: TextStyle(color: Colors.orangeAccent[800], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              // -------------------------------
          
              const SizedBox(height: 32),
          
              // BUTTONY
              DialogActionButtons(
                onCancel: () => Get.back(),
                onConfirm: _validateAndSave,
                confirmText: 'Zapisz',
                showDeleteButton: widget.shift != null,
                onDelete: widget.shift != null ? () {
                  if (widget.onDelete != null) {
                    widget.onDelete!(widget.shift!);
                    Get.back();
                  }
                } : null,
              ),
            ],
          );
        }
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  // VALIDATIONS
  void _validateAndSave() {
    
    if (_selectedTagNames.isEmpty) {
      showCustomSnackbar(context, 'Wybierz przynajmniej jeden tag!');
      return;
    }

    final startTotalMinutes = _startTime.hour * 60 + _startTime.minute;
    final endTotalMinutes = _endTime.hour * 60 + _endTime.minute;
    
    if (endTotalMinutes <= startTotalMinutes) {
      showCustomSnackbar(context, 'Godzina końca musi być późniejsza niż godzina startu!');
      return;
    }

    final List<String> tagIdsToSave = [];
    for (var tagName in _selectedTagNames) {
      final tagModel = _tagsController.allTags.firstWhere(
        (t) => t.tagName == tagName,
        orElse: () => TagsModel.empty(),
      );
      if (tagModel.id.isNotEmpty) tagIdsToSave.add(tagModel.id);
    }

    final newShift = ScheduleModel(
      shiftDate: widget.selectedDate,
      employeeID: widget.employeeId,
      employeeFirstName: widget.firstName,
      employeeLastName: widget.lastName,
      start: _startTime,
      end: _endTime,
      duration: ((endTotalMinutes - startTotalMinutes) / 60).toInt(),
      tags: tagIdsToSave,
      monthOfUsage: widget.selectedDate.month,
      yearOfUsage: widget.selectedDate.year,
      insertedAt: widget.shift?.insertedAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
      isDataMissing: false,
    );

    widget.onSave(newShift);
    Get.back();
  }
}