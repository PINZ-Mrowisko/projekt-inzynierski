import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/schedules/controllers/tags_controller.dart';
import 'package:the_basics/features/schedules/controllers/user_controller.dart';
import '../../widgets/employee_dialogs/add_dialog.dart';
import '../../widgets/employee_dialogs/delete_dialog.dart';
import '../../widgets/employee_dialogs/edit_dialog.dart';

class EmployeeManagementPage extends StatelessWidget {
  EmployeeManagementPage({super.key});

  final UserController userController = Get.find();
  final TagsController tagsController = Get.find();

  @override
  Widget build(BuildContext context) {
    print("All tags: ${tagsController.allTags.map((e) => e.tagName)}");
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
        onPressed: () => Get.dialog(AddEmployeeDialog()),
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
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${employee.firstName} ${employee.lastName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    Get.dialog(EditEmployeeDialog(employee: employee));
                  } else if (value == 'delete') {
                    showConfirmDeleteDialog(employee.id);
                  }
                },
              ),
            ],
          ),

              const SizedBox(height: 8),
              Text(employee.id),
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
    return Obx(() {
      if (tagsController.isLoading.value) {
        return const CircularProgressIndicator();
      }

      // Handle empty/null cases
      if (tagIds.isEmpty) {
        return const Chip(
          label: Text('No tags'),
          backgroundColor: Colors.red,
        );
      }


      return Wrap(
        spacing: 4,
        children: tagIds.map((tagId) {
          final tag = tagsController.allTags.firstWhereOrNull(
                (t) => t.tagName == tagId,
          );
          return tag != null
              ? Chip(
            label: Text(tag.tagName),
            backgroundColor: Colors.blue[50],
          )
          : Container();
        }).toList(),
      );
    });
  }


}