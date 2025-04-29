import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/models/tags_model.dart';
import '../../controllers/tags_controller.dart';

class EditTagDialog extends StatelessWidget {
  final TagsModel tag;
  final controller = Get.find<TagsController>();

  EditTagDialog({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: tag.tagName);
    final descController = TextEditingController(text: tag.description);

    return AlertDialog(
      title: const Text('Edytuj Tag'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nazwa Tagu',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descController,
            decoration: const InputDecoration(
              labelText: 'Opis',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          Text("Zmiany w tagu będą aplikowane do wszystkich pracowników posiadających ten tag!"),
        ],

      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.isEmpty) return;

            final updatedTag = tag.copyWith(
                tagName: nameController.text,
                description: descController.text,
                updatedAt: DateTime.now()
            );

            await controller.updateTagAndUsers(tag, updatedTag);
            Get.back();
          },
          child: const Text('Zapisz zmiany'),
        ),
      ],
    );
  }
}


