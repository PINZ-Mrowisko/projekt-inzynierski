/// THIS IS THE OLD METHOD
/// TO DO: move current implementation from employee_managemnt to here

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/models/user_model.dart';
import '../../tags/controllers/tags_controller.dart';
import '../controllers/user_controller.dart';

class EditEmployeeDialog extends StatelessWidget {
  final UserModel employee;

  EditEmployeeDialog({super.key, required this.employee});

  final tagsController = Get.find<TagsController>();
  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    final firstNameController = TextEditingController(text: employee.firstName);
    final lastNameController = TextEditingController(text: employee.lastName);
    final emailController = TextEditingController(text: employee.email);
    final phoneController = TextEditingController(text: employee.phoneNumber);
    final hoursController = TextEditingController(text: employee.maxWeeklyHours.toString());

    final contractType = RxnString(employee.contractType);
    final shiftPreference = RxnString(employee.shiftPreference);
    final selectedTags = <String>[].obs..addAll(employee.tags);

    return AlertDialog(
      title: const Text('Edytuj pracownika'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(firstNameController, 'Imię'),
            const SizedBox(height: 16),
            _buildTextField(lastNameController, 'Nazwisko'),
            const SizedBox(height: 16),
            _buildTextField(emailController, 'Email', type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(phoneController, 'Numer telefonu', type: TextInputType.phone),
            const SizedBox(height: 16),
            _buildDropdown(contractType, 'Typ umowy o pracę', [
              'Umowa o pracę',
              'Umowa zlecenie',
            ]),
            const SizedBox(height: 16),
            _buildTextField(hoursController, 'Maksymalne godziny tygodniowo', type: TextInputType.number),
            const SizedBox(height: 16),
            _buildDropdown(shiftPreference, 'Preferencje zmian', [
              'Poranne',
              'Popołudniowe',
              'Brak preferencji',
            ]),
            const SizedBox(height: 16),
            const Text('Wybierz tagi:'),
            Obx(() => Wrap(
              spacing: 8,
              children: tagsController.allTags.map((tag) {
                return FilterChip(
                  label: Text(tag.tagName),
                  selected: selectedTags.contains(tag.tagName),
                  onSelected: (selected) {
                    selected ? selectedTags.add(tag.tagName) : selectedTags.remove(tag.tagName);
                  },
                );
              }).toList(),
            )),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Anuluj')),
        ElevatedButton(
          onPressed: () async {
            if (firstNameController.text.isEmpty ||
                lastNameController.text.isEmpty ||
                emailController.text.isEmpty) {
              Get.snackbar('Błąd', 'Wypełnij wszystkie wymagane pola');
              return;
            }

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

            try {
              // Show loading indicator
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );
              await userController.updateEmployee(updatedEmployee);

              // close both dialogs (loading and add employee)
              Navigator.of(Get.overlayContext!, rootNavigator: true).pop(); // loading
              Navigator.of(Get.overlayContext!, rootNavigator: true).pop(); // confirmation

            } catch (e){
              Navigator.of(Get.overlayContext!, rootNavigator: true).pop(); // close loading dialog if error occurs
              Get.snackbar('Błąd', 'Nie udało się zaktualizować pracownika: ${e.toString()}');
            }


            Get.back();
          },
          child: const Text('Zapisz zmiany'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? type}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }

  Widget _buildDropdown(RxnString variable, String label, List<String> options) {
    return Obx(() => DropdownButtonFormField<String>(
      value: variable.value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: options.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
      onChanged: (value) => variable.value = value,
    ));
  }
}
