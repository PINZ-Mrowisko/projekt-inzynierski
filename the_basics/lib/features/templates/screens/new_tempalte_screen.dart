import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import '../../../utils/common_widgets/side_menu.dart';
import '../controllers/template_controller.dart';
import '../models/template_model.dart';
import '../models/template_shift_model.dart';

/// Screen for creating, viewing, and editing templates
class NewTemplatePage extends StatelessWidget {
  final TemplateModel? template;
  final bool isViewMode;

  const NewTemplatePage({super.key, this.template, this.isViewMode = false});

  @override
  Widget build(BuildContext context) {
    final templateController = Get.find<TemplateController>();
    final tagsController = Get.find<TagsController>();

    final days = ['Pon', 'Wt', 'Śr', 'Czw', 'Pt', 'Sob', 'Nd'];

    // Prefill template data when viewing or editing
    if (template != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        templateController.nameController.text = template!.templateName;
        templateController.descController.text = template!.description;
        templateController.minWomen.value = template!.minWomen!;
        templateController.maxMen.value = template!.maxMen!;
        templateController.minMen.value = template!.minMen!;
        templateController.maxWomen.value = template!.maxWomen!;

        final marketId = templateController.userController.employee.value.marketId;
        await templateController.loadShiftsForTemplate(marketId, template!.id);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      // only in view mode will we display the edit button
      floatingActionButton: isViewMode
          ? Obx(() => FloatingActionButton(
        backgroundColor: AppColors.logo,
        onPressed: () async {
          if (!templateController.isEditMode.value) {
            // after clicking the placeholder edit button we enter edit mode
            templateController.isEditMode.value = true;
          } else {
            // exit edit mode — show save/cancel dialog
            final action = await _showEditOptionsDialog(context);
            // i assumed we will have 3 options here, either normal save of changes to the
            // curr template, saving the changes to a new one or canceling
            if (action == 'save') {
              await templateController.updateTemplate(template!);
              templateController.isEditMode.value = false;
            } else if (action == 'saveAsNew') {
              await templateController.saveTemplate(true);
              templateController.isEditMode.value = false;
            } else if (action == 'cancel') {
              templateController.isEditMode.value = false;
              Get.snackbar('Anulowano', 'Edycja została anulowana');
            }
          }
        },
        child: Icon(
          templateController.isEditMode.value ? Icons.check : Icons.edit,
          color: Colors.white,
        ),
      ))
          : null,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SideMenu(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Obx(() {
                final editing = templateController.isEditMode.value;
                final readOnly = isViewMode && !editing;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- TITLE ----
                    TextField(
                      controller: templateController.nameController,
                      enabled: !readOnly,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.logo,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Wpisz nazwę szablonu...',
                        hintStyle: TextStyle(color: Colors.blue),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ---- OGÓLNE ZASADY ----
                    Row(
                      children: [
                        const Text(
                          'Ogólne zasady:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildRuleButton(context, templateController, 'minMen',
                            'Min mężczyzn', templateController.minMen, readOnly),
                        _buildRuleButton(context, templateController, 'maxMen',
                            'Max mężczyzn', templateController.maxMen, readOnly),
                        _buildRuleButton(
                            context,
                            templateController,
                            'minWomen',
                            'Min kobiet',
                            templateController.minWomen,
                            readOnly),
                        _buildRuleButton(
                            context,
                            templateController,
                            'maxWomen',
                            'Max kobiet',
                            templateController.maxWomen,
                            readOnly),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ---- 7 DAYS ----
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(days.length, (index) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      days[index],
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                  if (!readOnly)
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.logo,
                                      ),
                                      onPressed: () {
                                        _showAddShiftDialog(
                                          context,
                                          templateController,
                                          tagsController,
                                          days[index],
                                        );
                                      },
                                      icon: const Icon(Icons.add,
                                          color: Colors.white),
                                      label: const Text(
                                        'Dodaj zmianę',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  const SizedBox(height: 10),

                                  // ---- DISPLAY SHIFTS ----
                                  Expanded(
                                    child: Obx(() {
                                      final shifts = templateController
                                          .addedShifts
                                          .where(
                                              (s) => s.day == days[index])
                                          .toList();
                                      return ListView.builder(
                                        itemCount: shifts.length,
                                        itemBuilder: (context, i) {
                                          final shift = shifts[i];
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 2),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color:
                                              Colors.deepPurple.shade300,
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${shift.tagName} (${shift.count})\n${shift.start.format(context)} - ${shift.end.format(context)}',
                                              style: const TextStyle(
                                                  fontSize: 12),
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        },
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---- SAVE BUTTON ----
                    if (!isViewMode)
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.logo,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          onPressed: () async {
                            await templateController.saveTemplate(false);
                          },
                          icon:
                          const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Zapisz szablon',
                            style: TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Dialog for edit options ----
  Future<String?> _showEditOptionsDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Zakończyć edycję?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Wybierz co chcesz zrobić ze zmianami:',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: 'cancel'),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Get.back(result: 'saveAsNew'),
            child: const Text('Zapisz jako nowy'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: 'save'),
            child: const Text('Zapisz zmiany'),
          ),
        ],
      ),
    );
  }

  // ---- Rule Button Builder ----
  Widget _buildRuleButton(BuildContext context, TemplateController controller,
      String key, String label, RxInt value, bool readOnly) {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple.shade400,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        onPressed: readOnly
            ? null
            : () async {
          final input =
          await _showNumberInputDialog(context, label, value.value);
          if (input != null) controller.setRuleValue(key, input);
        },
        child: Text(
          '$label: ${value.value}',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    ));
  }

  // number Input Dialog
  Future<int?> _showNumberInputDialog(
      BuildContext context, String label, int currentValue) async {
    final controller = TextEditingController(text: currentValue.toString());
    return await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(label, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Wartość',
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Anuluj')),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null) Get.back(result: value);
            },
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
  }

  // new shift dialog
  void _showAddShiftDialog(BuildContext context,
      TemplateController templateController,
      TagsController tagsController,
      String day) {
    final countController = TextEditingController();
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    String? selectedTagName;
    String? selectedTagId;

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Dodaj zmianę',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                final tags = tagsController.allTags;
                return DropdownButtonFormField<String>(
                  dropdownColor: Colors.grey.shade800,
                  decoration: const InputDecoration(
                    labelText: 'Tag',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  items: tags
                      .map((tag) => DropdownMenuItem(
                    value: tag.id,
                    child: Text(tag.tagName,
                        style: const TextStyle(color: Colors.white)),
                  ))
                      .toList(),
                  onChanged: (value) {
                    final tag =
                    tags.firstWhereOrNull((element) => element.id == value);
                    selectedTagId = tag?.id;
                    selectedTagName = tag?.tagName;
                  },
                );
              }),
              const SizedBox(height: 10),
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Liczba osób',
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  startTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                },
                child: const Text('Wybierz początek zmiany'),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: () async {
                  endTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                },
                child: const Text('Wybierz koniec zmiany'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Anuluj')),
          ElevatedButton(
            onPressed: () {
              if (selectedTagId != null &&
                  startTime != null &&
                  endTime != null &&
                  countController.text.isNotEmpty) {
                final shift = ShiftModel(
                  id: UniqueKey().toString(),
                  tagId: selectedTagId!,
                  tagName: selectedTagName ?? '',
                  count: int.tryParse(countController.text) ?? 1,
                  start: startTime!,
                  end: endTime!,
                  day: day,
                );
                templateController.addShift(shift);
                Get.back();
              }
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }
}
