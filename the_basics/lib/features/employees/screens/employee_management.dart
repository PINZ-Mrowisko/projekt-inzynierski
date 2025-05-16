import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/models/user_model.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/common_widgets/confirmation_dialog.dart';
import '../../../utils/common_widgets/custom_button.dart';
import '../../../utils/common_widgets/form_dialog.dart';
import '../../../utils/common_widgets/generic_list.dart';
import '../../../utils/common_widgets/multi_select_dropdown.dart';
import '../../../utils/common_widgets/notification_snackbar.dart';
import '../../../utils/common_widgets/search_bar.dart';
import '../../../utils/common_widgets/side_menu.dart';
import '../../tags/controllers/tags_controller.dart';
import '../controllers/user_controller.dart';


class EmployeeManagementPage extends StatelessWidget {
  const EmployeeManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final tagsController = Get.find<TagsController>();
    final selectedTags = <String>[].obs;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
            child: const SideMenu(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 80,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Pracownicy',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logo,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: _buildTagFilterDropdown(tagsController, selectedTags),
                        ),
                        const SizedBox(width: 16),
                        _buildSearchBar(),
                        const SizedBox(width: 16),
                        _buildAddEmployeeButton(context, userController),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (userController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (userController.errorMessage.value.isNotEmpty) {
                        return Center(child: Text(userController.errorMessage.value));
                      }
                      if (userController.allEmployees.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Brak dostępnych pracowników'),
                              ElevatedButton(
                                onPressed: () => _showAddEmployeeDialog(context, userController),
                                child: const Text('Dodaj pierwszego pracownika'),
                              ),
                            ],
                          ),
                        );
                      }
                      return _buildEmployeesList(context, userController);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //need to implement actual logic
  Widget _buildTagFilterDropdown(TagsController tagsController, RxList<String> selectedTags) {
  return Obx(() {
    double screenWidth = MediaQuery.of(Get.context!).size.width;
    double dropdownWidth = screenWidth * 0.2;
    if (dropdownWidth > 360) dropdownWidth = 360;

    return CustomMultiSelectDropdown(
      items: tagsController.allTags.map((tag) => tag.tagName).toList(),
      selectedItems: selectedTags,
      onSelectionChanged: (selected) {
        selectedTags.assignAll(selected);
      },
      hintText: 'Filtruj po tagach',
      width: dropdownWidth,
      leadingIcon: Icons.filter_alt_outlined,
    );
  });
}


  Widget _buildAddEmployeeButton(BuildContext context, UserController controller) {
    return CustomButton(
      text: 'Dodaj Pracownika',
      icon: Icons.add,
      width: 184,
      onPressed: () => _showAddEmployeeDialog(context, controller),
    );
  }

  //need to implement logic
  Widget _buildSearchBar() {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double searchBarWidth = screenWidth * 0.2;
  if (searchBarWidth > 360) searchBarWidth = 360;

  return CustomSearchBar(
    hintText: 'Wyszukaj pracownika',
    width: searchBarWidth,
  );
}


  Widget _buildEmployeesList(BuildContext context, UserController controller) {
    return GenericList<UserModel>(
      items: controller.allEmployees,
      onItemTap: (employee) => _showEditEmployeeDialog(context, controller, employee),
      itemBuilder: (context, employee) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          title: Text(
            '${employee.firstName} ${employee.lastName}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor1,
            ),
          ),
          subtitle: _buildEmployeeTags(employee.tags),
        );
      },
    );
  }

  Widget _buildEmployeeTags(List<String> tags) {
    if (tags.isEmpty) {
      return const Text(
        'Brak tagów',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textColor2,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => RawChip(
        label: Text(
          tag,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            fontSize: 12,
            height: 1.33,
            letterSpacing: 0.5,
            color: AppColors.textColor2,
          ),
        ),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(
            color: Color(0xFFCAC4D0),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      )).toList(),
    );
  }

  void _showAddEmployeeDialog(BuildContext context, UserController userController) {
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
            Get.back();
            showCustomSnackbar(context, 'Pracownik został pomyślnie dodany.');
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
          height: 750,
          width: 700,
        ),
        barrierDismissible: false
    );
  }

  void _showEditEmployeeDialog(BuildContext context, UserController userController, UserModel employee) {
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
        onPressed: () => _confirmDeleteEmployee(userController, employee.id, employee.firstName),
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

            _showSaveConfirmationDialog(() async {
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
                Get.back();
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
          height: 750,
          width: 700,
        ),
        barrierDismissible: false
    );
  }

  void _confirmDeleteEmployee(UserController controller, String employeeId, String employeeName) {
    Get.dialog(
      ConfirmationDialog(
        title: 'Czy na pewno chcesz usunąć pracownika "$employeeName"?',
        confirmText: 'Usuń',
        cancelText: 'Anuluj',
        confirmButtonColor: AppColors.warning,
        confirmTextColor: AppColors.white,
        onConfirm: () async {
          try {
            Get.back();
            await controller.deleteEmployee(employeeId);
            Get.back();
            showCustomSnackbar(Get.context!, 'Pracownik został pomyślnie usunięty.');
          } catch (e) {
            Get.back();
            showCustomSnackbar(
                Get.context!,
                'Błąd podczas usuwania pracownika: ${e.toString()}'
            );
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  void _showSaveConfirmationDialog(VoidCallback onConfirmSave) {
    Get.dialog(
      ConfirmationDialog(
        title: 'Czy chcesz zatwierdzić zmiany?',
        confirmText: 'Zatwierdź',
        cancelText: 'Anuluj',
        onConfirm: onConfirmSave,
      ),
      barrierDismissible: false,
    );
  }
}