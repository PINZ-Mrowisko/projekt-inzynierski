import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/controllers/tags_controller.dart';
import 'package:the_basics/features/schedules/widgets/logged_navbar.dart';

import '../../models/tags_model.dart';

class TagsPage extends StatelessWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // always use get find to catch the already existing instance of the controller
    final tagsController = Get.find<TagsController>();

    return Scaffold(
      backgroundColor: Colors.white,
      /// add tag button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTagDialog(context, tagsController),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          LoggedNavBar(),
          Expanded(
            child: Obx(() {
              if (tagsController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (tagsController.errorMessage.value.isNotEmpty) {
                return Center(child: Text(tagsController.errorMessage.value));
              }

              if (tagsController.allTags.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Brak dostępnych tagów'),

                      /// display add tags button in case of no tags in storage
                      ElevatedButton(
                        onPressed: () => _showAddTagDialog(context, tagsController),
                        child: const Text('Dodaj pierwszy tag'),
                      ),
                    ],
                  ),
                );
              }
              // place holder display
              return Column(
                children: [
                  // Search bar could be added here later
                  Expanded(
                    child: ListView.builder(
                      itemCount: tagsController.allTags.length,
                      itemBuilder: (_, index) {
                        final tag = tagsController.allTags[index];
                        return ListTile(
                          title: Text(tag.tagName),
                          subtitle: Text(tag.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditTagDialog(
                                    context,
                                    tagsController,
                                    tag
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _confirmDeleteTag(
                                    tagsController,
                                    tag.id
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

/// *****************************///
/// methods for handling the tags///
/// *****************************///

void _showAddTagDialog(BuildContext context, TagsController controller) {

  Get.dialog(
    AlertDialog(
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
            await controller.saveTag(controller.userController.employee.value.marketId);
            Get.back();
          },
          child: const Text('Dodaj'),
        ),
      ],
    ),
  );
}

void _showEditTagDialog(
    BuildContext context,
    TagsController controller,
    TagsModel tag
    ) {
  final nameController = TextEditingController(text: tag.tagName);
  final descController = TextEditingController(text: tag.description);

  Get.dialog(
    AlertDialog(
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

            await controller.updateTag(updatedTag);
            Get.back();
          },
          child: const Text('Zapisz zmiany'),
        ),
      ],
    ),
  );
}

void _confirmDeleteTag(TagsController controller, String tagId) {
  Get.dialog(
    AlertDialog(
      title: const Text('Usuń tag'),
      /// TO DO:
      /// dodac check czy istnieja prcownicy z tym tagiem
      content: const Text('Czy jesteś pewien, że chcesz usunąć ten tag?'),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text('Cofnij'),
        ),
        ElevatedButton(
          onPressed: () async {
            await controller.deleteTag(tagId);
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Usuń'),
        ),
      ],
    ),
  );
}
}
