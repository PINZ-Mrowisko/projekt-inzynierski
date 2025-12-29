import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/models/schedule_model.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/features/tags/models/tags_model.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/multi_select_dropdown.dart';

class ShiftEditDialog extends StatefulWidget {
  final ScheduleModel? shift;
  final DateTime selectedDate;
  final String employeeId;
  final String firstName;
  final String lastName;
  final List<String> employeeTags; // <--- NOWE POLE: Umiejętności pracownika
  final Function(ScheduleModel) onSave;
  final Function(ScheduleModel)? onDelete;

  const ShiftEditDialog({
    super.key,
    this.shift,
    required this.selectedDate,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.employeeTags, // <--- Dodaj do konstruktora
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

    // Logika mapowania ID -> Nazwy (z poprzedniego kroku)
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

  // ... metoda _selectTime bez zmian ...
  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.logo),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked; else _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.shift == null ? 'Dodaj zmianę' : 'Edytuj zmianę',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.logo),
            ),
            const SizedBox(height: 8),
            Text(
              'Pracownik: ${widget.firstName} ${widget.lastName}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // ... Wybór godzin (Row) bez zmian ...
            Row(
              children: [
                Expanded(child: Column(children: [
                  const Text('Start', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(onTap: () => _selectTime(context, true), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.access_time), const SizedBox(width: 8), Text(_startTime.format(context))]))),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(children: [
                  const Text('Koniec', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(onTap: () => _selectTime(context, false), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.access_time), const SizedBox(width: 8), Text(_endTime.format(context))]))),
                ])),
              ],
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
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pracownik nie posiada prydzielonego tagu: ${missingTags.join(", ")}',
                        style: TextStyle(color: Colors.orange[800], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }),
            // -------------------------------

            const SizedBox(height: 32),

            // Przyciski (Kod zapisu bez zmian, tylko kopiuję dla kontekstu)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.shift != null) ...[
                  TextButton(
                    onPressed: () {
                      if (widget.onDelete != null) { widget.onDelete!(widget.shift!); Get.back(); }
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Usuń'),
                  ),
                  const Spacer(),
                ],
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Anuluj'),
                ),
                const SizedBox(width: 8),
                CustomButton(
                  onPressed: () {
                    double startDouble = _startTime.hour + _startTime.minute / 60.0;
                    double endDouble = _endTime.hour + _endTime.minute / 60.0;
                    if (endDouble <= startDouble) {
                      Get.snackbar('Błąd', 'Koniec musi być po starcie', backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }

                    final List<String> tagIdsToSave = [];
                    for (var tagName in _selectedTagNames) {
                      final tagModel = _tagsController.allTags.firstWhere((t) => t.tagName == tagName, orElse: () => TagsModel.empty());
                      if (tagModel.id.isNotEmpty) tagIdsToSave.add(tagModel.id);
                    }

                    final newShift = ScheduleModel(
                      shiftDate: widget.selectedDate,
                      employeeID: widget.employeeId,
                      employeeFirstName: widget.firstName,
                      employeeLastName: widget.lastName,
                      start: _startTime,
                      end: _endTime,
                      duration: (endDouble - startDouble).toInt(),
                      tags: tagIdsToSave,
                      insertedAt: widget.shift?.insertedAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                      isDeleted: false,
                      isDataMissing: false,
                    );

                    widget.onSave(newShift);
                    Get.back();
                  },
                  text: 'Zapisz',
                  width: 100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}