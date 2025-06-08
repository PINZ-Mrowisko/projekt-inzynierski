import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import '../../auth/models/user_model.dart';
import '../../tags/controllers/tags_controller.dart';
import '../controllers/user_controller.dart';

void showAddEmployeeDialog(BuildContext context, UserController userController) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final hoursController = TextEditingController(text: '40');

    final selectedTags = <String>[].obs;
    final tagsController = Get.find<TagsController>();

    final contractType = RxnString();
    final shiftPreference = RxnString();

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
        label: 'Dodaj',
        onPressed: () async {
          if (firstNameController.text.isEmpty ||
              lastNameController.text.isEmpty ||
              emailController.text.isEmpty ||
              contractType.value == null) {
            showCustomSnackbar(context, 'Wypełnij wszystkie wymagane pola');
            return;
          }

          final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
          final email = emailController.text.trim();

          if (!emailRegex.hasMatch(email)) {
            showCustomSnackbar(context, 'Podaj poprawny adres email.');
            return;
          }

          final existing = await FirebaseFirestore.instance
              .collection('Markets')
              .doc(userController.employee.value.marketId)
              .collection('members')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          if (existing.docs.isNotEmpty) {
            showCustomSnackbar(context, 'Pracownik z tym adresem email już istnieje.');
            return;
          }


          final userId = FirebaseFirestore.instance.collection('Users').doc().id;
          final newEmployee = UserModel(
            id: userId,
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            email: emailController.text,
            marketId: userController.employee.value.marketId,
            phoneNumber: phoneController.text,
            contractType: contractType.value!,
            maxWeeklyHours: int.tryParse(hoursController.text) ?? 40,
            shiftPreference: shiftPreference.value ?? 'Brak preferencji',
            tags: selectedTags.toList(),
            isDeleted: false,
            insertedAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          try {
            Get.back();
            await userController.addNewEmployee(newEmployee);
            //Get.back();
            //showCustomSnackbar(context, 'Pracownik został pomyślnie dodany.');
          } catch (e) {
            Get.back();
            showCustomSnackbar(context, 'Nie udało się dodać pracownika: ${e.toString()}');
          }
        },
      ),
    ];

    Get.dialog(
        CustomFormDialog(
          title: 'Dodaj nowego Pracownika',
          fields: fields,
          actions: actions,
          onClose: Get.back,
          width: 700,
          height: 750,
        ),
        barrierDismissible: false
    );
  }