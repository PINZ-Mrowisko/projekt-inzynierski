import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/schedules/controllers/tags_controller.dart';
import 'package:the_basics/features/schedules/controllers/user_controller.dart';
import '../../widgets/logged_navbar.dart';

class EmployeeManagementPage extends StatelessWidget {
  EmployeeManagementPage({super.key});

  final UserController userController = Get.find();
  final TagsController tagsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const LoggedNavBar(),
          // add a temp refresh button to pull all employees in
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => userController.fetchAllEmployees(),
          ),
          Expanded(
            child: _buildEmployeeList(),
          ),
        ],
      ),
      /// add new employees
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEmployeeDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmployeeList() {
    return Obx(() {
      if (userController.isLoading.value && userController.allEmployees.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (userController.allEmployees.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No employees found'),
              const SizedBox(height: 16),

            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => userController.fetchAllEmployees(),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: userController.allEmployees.length,
          itemBuilder: (context, index) {
            final employee = userController.allEmployees[index];
            return _buildEmployeeCard(employee);
          },
        ),
      );
    });
  }

  Widget _buildEmployeeCard(UserModel employee) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {}, // Add navigation to employee details if needed
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${employee.firstName} ${employee.lastName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(employee.email),
              const SizedBox(height: 4),
              Text('Contract: ${employee.contractType}'),
              const SizedBox(height: 4),
              Text('Max hours: ${employee.maxWeeklyHours}'),
              const SizedBox(height: 8),
              _buildTagsChips(employee.tags),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagsChips(List<String> tagIds) {
    return Wrap(
      spacing: 4,
      children: tagIds.map((tagId) {
        final tag = tagsController.allTags.firstWhereOrNull(
              (t) => t.id == tagId,
        );
        return tag != null
            ? Chip(
          label: Text(tag.tagName),
          backgroundColor: Colors.blue[50],
        )
            : const SizedBox.shrink();
      }).toList(),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final hoursController = TextEditingController(text: '40');

    String? contractType;
    String? shiftPreference;
    final selectedTags = <String>[].obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Dodaj nowego pracownika'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Imię',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nazwisko',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Numer telefonu',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Typ umowy o pracę',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Umowa o pracę',
                    child: Text('Umowa o pracę'),
                  ),
                  DropdownMenuItem(
                    value: 'Umowa zlecenie',
                    child: Text('Umowa zlecenie'),
                  ),
                ],
                onChanged: (value) => contractType = value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hoursController,
                decoration: const InputDecoration(
                  labelText: 'Maksymalne godziny tygodniowo',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Preferencje zmian',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Poranne',
                    child: Text('Poranne'),
                  ),
                  DropdownMenuItem(
                    value: 'Popołudniowe',
                    child: Text('Popołudniowe'),
                  ),
                  DropdownMenuItem(
                    value: 'Brak preferencji',
                    child: Text('Brak preferencji'),
                  ),
                ],
                onChanged: (value) => shiftPreference = value,
              ),
              const SizedBox(height: 16),
              const Text('Wybierz tagi:'),
              Obx(() => Wrap(
                spacing: 8,
                children: tagsController.allTags.map((tag) {
                  return FilterChip(
                    label: Text(tag.tagName),
                    selected: selectedTags.contains(tag.tagName),
                    onSelected: (selected) {
                      if (selected) {
                        selectedTags.add(tag.tagName);
                      } else {
                        selectedTags.remove(tag.tagName);
                      }
                    },
                  );
                }).toList(),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (firstNameController.text.isEmpty ||
                  lastNameController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  contractType == null) {
                Get.snackbar('Error', 'Wypełnij wszystkie wymagane pola');
                return;
              }
              final userId = FirebaseFirestore.instance.collection('Users').doc().id;

              final newEmployee = UserModel(
                id: userId, // Will be generated by Firestore
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                email: emailController.text,
                marketId: userController.employee.value.marketId,
                phoneNumber: phoneController.text,
                contractType: contractType!,
                maxWeeklyHours: int.tryParse(hoursController.text) ?? 40,
                shiftPreference: shiftPreference ?? 'Flexible',
                tags: selectedTags.toList(),
                isDeleted: false,
                insertedAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              await userController.addNewEmployee(newEmployee);
              Get.back();
            },
            child: const Text('Add Employee'),
          ),
        ],
      ),
    );
  }
}