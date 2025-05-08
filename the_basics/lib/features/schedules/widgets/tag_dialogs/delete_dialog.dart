import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/models/tags_model.dart';
import '../../controllers/tags_controller.dart';

class DeleteTagDialog extends StatelessWidget {
  final TagsModel tag;
  final controller = Get.find<TagsController>();

  DeleteTagDialog({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final userCount = controller.countUsersWithTag(tag.tagName);
    final warningText = userCount > 0
        ? 'UWAGA: $userCount użytkowników ma ten tag!\nCzy na pewno chcesz usunąć "${tag.tagName}"?'
        : 'Czy na pewno chcesz usunąć tag "${tag.tagName}"?';

    return AlertDialog(
      title: const Text('Usuń tag'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(warningText),
          if (userCount > 0)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Tag zostanie usunięty z profili użytkowników',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text('Cofnij'),
        ),
        ElevatedButton(
          onPressed: () async {
            await controller.deleteTag(tag.id, tag.tagName);
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Usuń'),
        ),
      ],
    );
  }
}


