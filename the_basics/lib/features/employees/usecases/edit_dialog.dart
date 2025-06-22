import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

import '../../auth/models/user_model.dart';
import '../../tags/controllers/tags_controller.dart';
import '../controllers/user_controller.dart';

import '../usecases/delete_dialog.dart';
import '../usecases/show_confirmations.dart';

void showEditEmployeeDialog(BuildContext context, UserController userController, UserModel employee) {
    final firstNameController = TextEditingController(text: employee.firstName);
    final lastNameController = TextEditingController(text: employee.lastName);
    final emailController = TextEditingController(text: employee.email);
    final phoneController = TextEditingController(text: employee.phoneNumber);
    final hoursController = TextEditingController(text: employee.maxWeeklyHours.toString());

    final selectedTags = <String>[].obs..addAll(employee.tags);
    final tagsController = Get.find<TagsController>();

    final contractType = RxnString(employee.contractType);
    final shiftPreference = RxnString(employee.shiftPreference);

    final fields = [
      RowDialogField(children: [
        DialogInputField(label: 'Imię', controller: firstNameController),
        DialogInputField(label: 'Nazwisko', controller: lastNameController),
      ]),

      RowDialogField(children: [
        DialogInputField(label: 'Email', controller: emailController),
        DialogInputField(label: 'Numer telefonu', controller: phoneController),
      ]),

      RowDialogField(children: [
        DropdownDialogField(
          label: 'Typ umowy o pracę',
          selectedValue: contractType.value,
          hintText: 'Wybierz typ umowy...',
          items: [
            DropdownItem(value: 'Umowa o pracę', label: 'Umowa o pracę'),
            DropdownItem(value: 'Umowa zlecenie', label: 'Umowa zlecenie'),
          ],
          onChanged: (value) => contractType.value = value,
        ),
        DialogInputField(
          label: 'Maksymalna ilość godzin tygodniowo',
          controller: hoursController,
        ),
      ]),

      DropdownDialogField(
        label: 'Preferencje zmian',
        selectedValue: shiftPreference.value,
        hintText: 'Wybierz preferencje...',
        items: [
          DropdownItem(value: 'Poranne', label: 'Poranne'),
          DropdownItem(value: 'Popołudniowe', label: 'Popołudniowe'),
          DropdownItem(value: 'Brak preferencji', label: 'Brak preferencji'),
        ],
        onChanged: (value) => shiftPreference.value = value,
      ),

      MultiSelectDialogField(
        label: 'Tagi',
        items: tagsController.allTags.map((tag) => tag.tagName).toList(),
        selectedItems: selectedTags,
        onSelectionChanged: (selected) {
          selectedTags.assignAll(selected);
        },
        width: double.infinity,
      )
    ];

    final actions = [
      DialogActionButton(
        label: 'Usuń',
        backgroundColor: AppColors.warning,
        textColor: AppColors.white,
        onPressed: () => confirmDeleteEmployee(userController, employee.id, employee.firstName, employee.marketId),
      ),
      DialogActionButton(
        label: 'Zapisz',
        onPressed: () {
          try {
            if (firstNameController.text.isEmpty ||
                lastNameController.text.isEmpty ||
                emailController.text.isEmpty) {
              showCustomSnackbar(context, 'Wypełnij wszystkie wymagane pola');
              return;
            }

            showSaveConfirmationDialog(() async {
              try {
                final updatedEmployee = employee.copyWith(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  email: emailController.text,
                  phoneNumber: phoneController.text,
                  contractType: contractType.value,
                  maxWeeklyHours: int.tryParse(hoursController.text) ?? 40,
                  shiftPreference: shiftPreference.value,
                  tags: selectedTags.toList(),
                );
                Get.back();
                await userController.updateEmployee(updatedEmployee);
                //Get.back();
                showCustomSnackbar(context, 'Zmiany zostały zapisane.');
              } catch (e) {
                showCustomSnackbar(
                    context,
                    'Nie udało się zapisać zmian: ${e.toString()}'
                );
              }
            });
          } catch (e) {
            showCustomSnackbar(context, 'Wystąpił nieoczekiwany błąd',);
          }
        },
      ),
    ];

    Get.dialog(
        CustomFormDialog(
          title: 'Edytuj Pracownika',
          fields: fields,
          actions: actions,
          onClose: Get.back,
          width: 700,
          height: 750,
        ),
        barrierDismissible: false
    );
  }