import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/controllers/tags_controller.dart';
import 'package:the_basics/features/schedules/widgets/logged_navbar.dart';

class TagsPage extends StatelessWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tagsController = Get.find<TagsController>();

    return Scaffold(
      backgroundColor: Colors.white,
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
                return const Center(child: Text('No tags available'));
              }

              return SizedBox(
                height: 100, // Set a fixed height for horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tagsController.allTags.length,
                  itemBuilder: (_, index) {
                    final tag = tagsController.allTags[index];
                    return Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tag.tagName,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(tag.description),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
