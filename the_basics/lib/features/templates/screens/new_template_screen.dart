import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/features/templates/usecases/add_shift_dialog.dart';
import 'package:the_basics/features/templates/usecases/edit_general_rules_dialog.dart';
import 'package:the_basics/features/templates/usecases/edit_shift_dialog.dart';
import 'package:the_basics/features/templates/usecases/save_edits_dialog.dart';
import 'package:the_basics/features/templates/usecases/show_confirmations.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import '../../../utils/common_widgets/side_menu.dart';
import '../controllers/template_controller.dart';
import '../models/template_model.dart';
import 'package:intl/intl.dart';

import '../models/template_shift_model.dart';
import '../usecases/helpers/number_input_widget.dart';

/// Screen for creating, viewing, and editing templates
class NewTemplatePage extends StatelessWidget {
  final TemplateModel? template;
  final bool isViewMode;
  final DateFormat datetimeFormatter = DateFormat('dd.MM.yyyy');

   NewTemplatePage({super.key}) : 
    template = Get.arguments?['template'],
    isViewMode = Get.arguments?['isViewMode'] ?? false;
  

  @override
  Widget build(BuildContext context) {
    final templateController = Get.find<TemplateController>();
    final tagsController = Get.find<TagsController>();

    final days = ['Poniedziałek', 'Wtorek', 'Środa', 'Czwartek', 'Piątek', 'Sobota', 'Niedziela'];

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
        // using our new mapping logic, we go through consolidated shifts matching them
        await templateController.loadShiftsForTemplate(marketId, template!.id);
      });
    }

    return Obx(() {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SideMenu(
              onNavigation: (route) {
              final editing = templateController.isEditMode.value || !isViewMode;
              if (editing) {
                showLeaveConfirmationDialog(() {
                  templateController.clearController();
                  Get.toNamed(route);
                });
              } else {
                // if view mode -> navigate immediately
                Get.toNamed(route);
              }
            },
          ),
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
                    // ---- TITLE AND DATE ----
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, size: 28, color: AppColors.logo),
                              onPressed: () {
                                final editing = templateController.isEditMode.value || !isViewMode;
                                if (editing) {
                                  showLeaveConfirmationDialog(() {
                                    //fix so error msg doesnt block main view
                                    templateController.clearController();
                                    Get.offNamed('/szablony');
                                  });
                                } else {
                                  Get.offNamed('/szablony');
                                }
                              },
                            ),
                            SizedBox(width: readOnly ? 8 : 16),
                            // tytuł
                            Expanded(
                              child: readOnly
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Text(
                                        templateController.nameController.text.isNotEmpty
                                            ? templateController.nameController.text
                                            : template?.templateName ?? '',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.logo,
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      height: 56,
                                      child: TextField(
                                        controller: templateController.nameController,
                                        enabled: true,
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.logo,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Wpisz nazwę szablonu...',
                                          hintStyle: TextStyle(
                                            color: AppColors.logo.withOpacity(0.5),
                                            fontSize: 32,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: AppColors.white,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                            const SizedBox(width: 16),

                            // przyciski po prawej (edit i zakończ edycję / zapisz)
                            if (isViewMode)
                              Obx(() {
                                final editing = templateController.isEditMode.value;

                                return CustomButton(
                                  text: editing ? 'Zakończ' : 'Edytuj',
                                  icon: editing ? Icons.check : Icons.edit,
                                  // 3 opcje: anuluj, zapisz zmiany, zapisz jako nowy
                                  onPressed: () async {
                                    if (!editing) {
                                      templateController.isEditMode.value = true;
                                    } else {
                                      final action = await showEditOptionsDialog();
                                      if (action == 'save') {
                                        await templateController.checkRuleValues();
                                        if (templateController.errorMessage.isEmpty) {
                                          await templateController.updateTemplate(template!);
                                          templateController.isEditMode.value = false;
                                          showCustomSnackbar(context, 'Szablon został zaktualizowany');
                                        }
                                      } else if (action == 'saveAsNew') {
                                        await templateController.checkRuleValues();
                                        if (templateController.errorMessage.isEmpty) {
                                          await templateController.saveTemplate(true);
                                          templateController.isEditMode.value = false;
                                          Get.offNamed('/szablony');
                                          showCustomSnackbar(context, 'Szablon został zapisany jako nowy');
                                        }
                                      } else if (action == 'cancel') {
                                        templateController.isEditMode.value = false;
                                        showCustomSnackbar(context, 'Edycja została anulowana');
                                      }
                                    }
                                  },
                                  backgroundColor: AppColors.blue,
                                  textColor: AppColors.textColor2,
                                  width: 120,
                                  height: 56,
                                );
                              }),

                            // przycisk zapisu dla new template
                            if (!isViewMode)
                              CustomButton(
                                text: 'Zapisz',
                                icon: Icons.save,
                                onPressed: () async {
                                  await templateController.checkRuleValues();
                                  if (templateController.errorMessage.isEmpty) {
                                    await templateController.saveTemplate(false);
                                    Get.offNamed('/szablony');
                                  }
                                },
                                backgroundColor: AppColors.blue,
                                textColor: AppColors.textColor2,
                                width: 120,
                                height: 56,
                              ),
                            ],
                          ),

                        if (!readOnly) const SizedBox(height: 16),

                        // inserted date pod tytułem (tylku kiedy istnieje czyli przy edycji lub podglądzie)
                        if (isViewMode && template?.insertedAt != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Text(
                              datetimeFormatter.format(template!.insertedAt),
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.textColor2,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),
                      ],
                    ),
                    // ---- OGÓLNE ZASADY ----
                    Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Zasady ogólne:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.logolighter,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Wrap(
                            spacing: 20, // Increased spacing for the new larger widgets
                            runSpacing: 15,
                            children: [
                              NumberInputButtonsWidget(
                                label: 'Min mężczyzn',
                                initialValue: templateController.minMen.value,
                                minValue: 0,
                                onValueChanged: (value) {
                                  templateController.setRuleValue('minMen', value);
                                },
                                readOnly: readOnly,
                              ),
                              NumberInputButtonsWidget(
                                label: 'Max mężczyzn',
                                initialValue: templateController.maxMen.value,
                                minValue: 0,
                                onValueChanged: (value) {
                                  templateController.setRuleValue('maxMen', value);
                                },
                                readOnly: readOnly,
                              ),
                              NumberInputButtonsWidget(
                                label: 'Min kobiet',
                                initialValue: templateController.minWomen.value,
                                minValue: 0,
                                onValueChanged: (value) {
                                  templateController.setRuleValue('minWomen', value);
                                },
                                readOnly: readOnly,
                              ),
                              NumberInputButtonsWidget(
                                label: 'Max kobiet',
                                initialValue: templateController.maxWomen.value,
                                minValue: 0,
                                onValueChanged: (value) {
                                  templateController.setRuleValue('maxWomen', value);
                                },
                                readOnly: readOnly,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                    // will display potential errors from controller
                  if (templateController.errorMessage.value.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          templateController.errorMessage.value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // ---- 7 DAYS ----
                    Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(days.length, (index) {
                        return Flexible(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 8),
                                  child: Text(
                                    days[index],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                
                                // przycisk dodawania zmiany (jeżeli nie jest w trybie tylko do odczytu)
                                if (!readOnly)
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline,
                                        color: AppColors.logo, size: 28),
                                    onPressed: () {
                                      showAddShiftDialog(
                                        context,
                                        templateController,
                                        tagsController,
                                        days[index],
                                      );
                                    },
                                  ),

                                // kafelki zmianowe
                                // po kliknieciu user nadal powinien miec moc edycji w trybie nowego lub editu
                                // drag and drop zarowno w edicie jak i nowych szablonach
                                Expanded(
                                  child: DragTarget<ShiftModel>(
                                    builder: (context, candidateData, rejectedData) {
                                      return Obx(() {
                                        final shifts = templateController.addedShifts
                                            .where((s) => s.day == days[index])
                                            .toList();

                                        final editingAllowed = !isViewMode || templateController.isEditMode.value;

                                        return ListView.builder(
                                          padding: const EdgeInsets.all(8),
                                          itemCount: shifts.length,
                                          itemBuilder: (context, i) {
                                            final shift = shifts[i];
                                            // still control tag deletion
                                            final isError = (shift.tagNames == "BRAK");

                                            if (editingAllowed) {
                                              return Draggable<ShiftModel>(
                                                data: shift,
                                                feedback: Material(
                                                  child: Container(
                                                    width: 120,
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      // if tag is missing we color it red
                                                      color: isError ? AppColors.warning : AppColors.lightBlue,
                                                      borderRadius: BorderRadius.circular(14),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          shift.tagNames.join(', '),
                                                          style: TextStyle(
                                                            color: AppColors.textColor2,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          '${shift.start.format(context)} - ${shift.end.format(context)}',
                                                          style: TextStyle(
                                                            color: AppColors.textColor2,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${shift.count}x',
                                                          style: TextStyle(
                                                            color: AppColors.textColor2,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                childWhenDragging: Container(
                                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: (isError ? AppColors.warning : AppColors.lightBlue).withOpacity(0.3),
                                                    borderRadius: BorderRadius.circular(14),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        shift.tagNames.join(', '),
                                                        style: TextStyle(
                                                          color: AppColors.textColor2.withOpacity(0.5),
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '${shift.start.format(context)} - ${shift.end.format(context)}',
                                                        style: TextStyle(
                                                          color: AppColors.textColor2.withOpacity(0.5),
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${shift.count}x',
                                                        style: TextStyle(
                                                          color: AppColors.textColor2.withOpacity(0.5),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                child: GestureDetector(
                                                  onTap: editingAllowed ? () {
                                                    showEditShiftDialog(
                                                      context,
                                                      templateController,
                                                      tagsController,
                                                      shift,
                                                    );
                                                  } : null,
                                                  child: MouseRegion(
                                                    // profesjonalnie ! zmieniamy myszke mhm mhm czujecie to
                                                    cursor: editingAllowed
                                                        ? SystemMouseCursors.click
                                                        : SystemMouseCursors.basic,
                                                    child: AnimatedContainer(
                                                      duration: const Duration(milliseconds: 200),
                                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: isError ? AppColors.warning : AppColors.lightBlue,
                                                        borderRadius: BorderRadius.circular(14),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black26,
                                                            blurRadius: 4,
                                                            offset: const Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            shift.tagNames.join(', '),
                                                            style: TextStyle(
                                                              color: AppColors.textColor2,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            '${shift.start.format(context)} - ${shift.end.format(context)}',
                                                            style: TextStyle(
                                                                color: AppColors.textColor2,
                                                                fontSize: 13),
                                                          ),
                                                          Text(
                                                            '${shift.count}x',
                                                            style: TextStyle(
                                                              color: AppColors.textColor2,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              // when in view dragging should NOT be allowed!
                                              return GestureDetector(
                                                onTap: null,
                                                child: MouseRegion(
                                                  // basic cursor for basic viewing
                                                  cursor: SystemMouseCursors.basic,
                                                  child: Container(
                                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: isError ? AppColors.warning : AppColors.lightBlue,
                                                      borderRadius: BorderRadius.circular(14),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          shift.tagNames.join(', '),
                                                          style: TextStyle(
                                                            color: AppColors.textColor2,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          '${shift.start.format(context)} - ${shift.end.format(context)}',
                                                          style: TextStyle(
                                                              color: AppColors.textColor2,
                                                              fontSize: 13),
                                                        ),
                                                        Text(
                                                          '${shift.count}x',
                                                          style: TextStyle(
                                                            color: AppColors.textColor2,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      });
                                    },
                                    onWillAccept: (data) {
                                      // only accept drops when in edit mode
                                      return !isViewMode || templateController.isEditMode.value;
                                    },
                                    onAccept: (ShiftModel shift) {
                                      // move shift to this day (only works in edit mode due to onWillAccept)
                                      templateController.moveShift(shift.id, days[index]);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
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
    });
  }
 }