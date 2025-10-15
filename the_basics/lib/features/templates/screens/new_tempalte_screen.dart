import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/features/templates/screens/all_templates_screen.dart';
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
            // these actions get used during editing
            if (action == 'save') {
              await templateController.checkRuleValues();
              if (templateController.errorMessage.isEmpty) {
                await templateController.updateTemplate(template!);

                templateController.isEditMode.value = false;
              }
            } else if (action == 'saveAsNew') {
              await templateController.checkRuleValues();
              if (templateController.errorMessage.isEmpty) {
                // after saving as new lets navigate back to the main template screen
                await templateController.saveTemplate(true);
                templateController.isEditMode.value = false;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TemplatesPage()),
                );
              }

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
                    // will display potential errors from controller
                    Text(templateController.errorMessage.value),

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

                                  // kafelki zmianowe
                                  // po kliknieciu user nadal powinien miec moc edycji w trybie nowego lub editu
                                  Expanded(
                                    child: Obx(() {
                                      final shifts = templateController
                                          .addedShifts
                                          .where(
                                              (s) => s.day == days[index])
                                          .toList();

                                      //  to make sure we are not in view
                                      final editingAllowed = !isViewMode || templateController.isEditMode.value;

                                      return ListView.builder(
                                        itemCount: shifts.length,
                                        itemBuilder: (context, i) {

                                          final shift = shifts[i];
                                          final isMissing = (template?.isDataMissing == true && shift.tagName == "BRAK");
                                          
                                          // wrap it in a Gesture Detector to make sure its editable after setting
                                          
                                          return GestureDetector(
                                            onTap: editingAllowed
                                                ? () {
                                              _showEditShiftDialog(
                                                context,
                                                templateController,
                                                tagsController,
                                                shift,
                                              );
                                            }
                                                : null,
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(
                                                  horizontal: 4, vertical: 2),
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                // if the tag was previously deleted, it will show up red and angry
                                                color: (shift.tagName == "BRAK")
                                                    ? Colors.redAccent
                                                    : Colors.deepPurple.shade300,
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${shift.tagName} (${shift.count})\n${shift.start.format(context)} - ${shift.end.format(context)}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                textAlign: TextAlign.center,
                                              ),
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

                    // save button - used when creating a new template
                    if (!isViewMode)
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.logo,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          onPressed: () async {
                            await templateController.checkRuleValues();
                            if (templateController.errorMessage.isEmpty) {
                              // save the template
                              await templateController.saveTemplate(false);

                              // move to all template screen - we push replacement to ovverride last
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => TemplatesPage()),
                              );

                            }else {
                            // we can maybe display popup about there being errors
                            // for time being only rules involving num of People are checked
                            // after UI is implemented I will create a time checking logic, just want to see what format the data will be in first

                              //or maybe no popup needed since error msg is there :X
                            }
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

  // okienko wyskakujace po kliknieciu zapisz podczas edycji, chwilowo 3 opcje wyboru
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
            onPressed: () {
              Get.back(result: 'saveAsNew');
            },
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

  // przyciski zasad ogólnych - chwilowo takie troche hardcoded, ale to musimy omówić czy chcemy te zasady mieć te same do każdego szablonu
  // czy może mieć katalog zasad do wyboru, które może pod szablon podłączyc K
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

  // number Input Dialog - chwilowo sluzy tylko do wprowadzania liczb w zasadach ogólnych
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

  // new shift dialog - kafelek ze zmianą, w którym K wybiera tag, ilość oraz godziny zmiany: tutaj tylko ten popup pytajacy jak to wszystko ma wygladac
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


// korzystamy do edycji kafelków, metoda podobna do tamej wyzej tylko z prefilled data
void _showEditShiftDialog(
    BuildContext context,
    TemplateController templateController,
    TagsController tagsController,
    ShiftModel shift,
    ) {

    final countController = TextEditingController(text: shift.count.toString());
  TimeOfDay startTime = shift.start;
  TimeOfDay endTime = shift.end;
  String selectedTagName = shift.tagName;
  String selectedTagId = shift.tagId;


  Get.dialog(
    AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: const Text('Edytuj zmianę', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final tags = tagsController.allTags;
              // if old tag was deleted, the dropdown will start empty to not cause error
              final dropdownValue = tags.any((tag) => tag.id == selectedTagId) ? selectedTagId : null;

              return DropdownButtonFormField<String>(
                value: dropdownValue,
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
                  final tag = tags.firstWhereOrNull((t) => t.id == value);
                  selectedTagId = tag?.id ?? '';
                  selectedTagName = tag?.tagName ?? '';
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
                final picked = await showTimePicker(
                  context: context,
                  initialTime: startTime,
                );
                if (picked != null) startTime = picked;
              },
              child: Text('Początek: ${startTime.format(context)}'),
            ),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: endTime,
                );
                if (picked != null) endTime = picked;
              },
              child: Text('Koniec: ${endTime.format(context)}'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Anuluj')),
        // actions for saving the edited shift
        ElevatedButton(
          onPressed: () {
            // we update the fields in the created shift
            final updatedShift = shift.copyWith(
              tagName: selectedTagName,
              count: int.tryParse(countController.text) ?? shift.count,
              start: startTime,
              end: endTime,
            );

            // we also update the shift in our added shifts list in the controller
            final index = templateController.addedShifts.indexWhere((s) => s.id == shift.id);
            if (index != -1) {
              templateController.addedShifts[index] = updatedShift;
              templateController.addedShifts.refresh(); // so ui refreshes
            }

            Get.back();
          },
          child: const Text('Zapisz'),
        ),
      ],
    ),
  );
}
}