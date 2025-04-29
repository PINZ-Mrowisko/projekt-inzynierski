import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/controllers/tags_controller.dart';
import 'package:the_basics/features/schedules/widgets/logged_navbar.dart';
import 'package:the_basics/features/schedules/widgets/tag_dialogs/add_dialog.dart';
import 'package:the_basics/features/schedules/widgets/tag_dialogs/delete_dialog.dart';
import 'package:the_basics/features/schedules/widgets/tag_dialogs/edit_dialog.dart';

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
        onPressed: () => Get.dialog(AddTagDialog()),
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
                        onPressed: () => Get.dialog(AddTagDialog()),
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
                                onPressed: () =>
                                    Get.dialog(
                                        EditTagDialog(tag: tag)
                                    ),
                              ),
                              IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      Get.dialog(DeleteTagDialog(tag: tag))
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
}