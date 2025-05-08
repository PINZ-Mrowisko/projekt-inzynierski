import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/models/user_model.dart';
import '../../controllers/tags_controller.dart';
import '../../controllers/user_controller.dart';

class AddEmployeeDialog extends StatelessWidget {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final hoursController = TextEditingController(text: '40');

  final selectedTags = <String>[].obs;
  final tagsController = Get.find<TagsController>();
  final userController = Get.find<UserController>();

  final contractType = RxnString();
  final shiftPreference = RxnString();

  AddEmployeeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj nowego pracownika'),
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
            // Obx(() => Wrap(
            //   spacing: 8,
            //   children: tagsController.allTags.map((tag) {
            //     return FilterChip(
            //       label: Text(tag.tagName),
            //       selected: selectedTags.contains(tag.tagName),
            //       onSelected: (selected) {
            //         selected ? selectedTags.add(tag.tagName) : selectedTags.remove(tag.tagName);
            //       },
            //     );
            //   }).toList(),
            // )),
            Wrap(
              spacing: 8,
              children: tagsController.allTags.map((tag) => Obx(() => FilterChip(
                label: Text(tag.tagName),
                selected: selectedTags.contains(tag.tagName),
                onSelected: (selected) {
                  selected ? selectedTags.add(tag.tagName) : selectedTags.remove(tag.tagName);
                },
              ))).toList(),
            )
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Anuluj')),
        ElevatedButton(
          onPressed: () async {
            if (firstNameController.text.isEmpty ||
                lastNameController.text.isEmpty ||
                emailController.text.isEmpty ||
                contractType.value == null) {
              Get.snackbar('Błąd', 'Wypełnij wszystkie wymagane pola');
              return;
            }

            final userId = FirebaseFirestore.instance.collection('Users').doc().id;
            print("oto user id $userId");
            print('Selected tags: ${selectedTags.toList()}');
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

            await userController.addNewEmployee(newEmployee);
            Get.back();
          },
          child: const Text('Dodaj pracownika'),
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
