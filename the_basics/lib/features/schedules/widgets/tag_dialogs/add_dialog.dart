import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tags_controller.dart';

class AddTagDialog extends StatelessWidget {
  final controller = Get.find<TagsController>();

  AddTagDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj nowy tag'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller.nameController,
            decoration: const InputDecoration(
              labelText: 'Nazwa',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.descController,
            decoration: const InputDecoration(
              labelText: 'Opis',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (controller.nameController.text.isEmpty) return;
            await controller.saveTag(
                controller.userController.employee.value.marketId);
            Get.back();
          },
          child: const Text('Dodaj'),
        ),
      ],
    );
  }
  }
