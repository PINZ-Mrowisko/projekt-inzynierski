import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/app_colors.dart';

class TagsSelectionWidget extends StatefulWidget {
  final TagsController tagsController;
  final List<String> initialTagIds;
  final List<String> initialTagNames;
  final Function(List<String>, List<String>) onSelectionChanged;

  const TagsSelectionWidget({
    Key? key,
    required this.tagsController,
    required this.initialTagIds,
    required this.initialTagNames,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<TagsSelectionWidget> createState() => _TagsSelectionWidgetState();
}

class _TagsSelectionWidgetState extends State<TagsSelectionWidget> {
  late List<String> selectedTagIds;
  late List<String> selectedTagNames;

  @override
  void initState() {
    super.initState();
    selectedTagIds = List.from(widget.initialTagIds);
    selectedTagNames = List.from(widget.initialTagNames);
  }

  void toggleTag(String id, String name) {
    setState(() {
      if (selectedTagIds.contains(id)) {
        selectedTagIds.remove(id);
        selectedTagNames.remove(name);
      } else {
        selectedTagIds.add(id);
        selectedTagNames.add(name);
      }
    });

    widget.onSelectionChanged(selectedTagIds, selectedTagNames);
  }

  // aby usunac mozliwa konfuzje co do wybranych tagow
  String _polishTagCountText(int count) {
    if (count == 0) return "0 wybranych tagów";
    if (count == 1) return "1 wybrany tag";
    if (count >= 2 && count <= 4) return "$count wybrane tagi";
    return "$count wybranych tagów";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tagi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor2,
          ),
        ),
        SizedBox(height: 6),

        Obx(() {
          final tags = widget.tagsController.allTags;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map<Widget>((tag) {
                  final bool isSelected = selectedTagIds.contains(tag.id);

                  return GestureDetector(
                    onTap: () => toggleTag(tag.id, tag.tagName),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 150),
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.blue : Colors.grey,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.blue : Colors.grey,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        tag.tagName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textColor1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 12),

              Text(
                _polishTagCountText(selectedTagIds.length),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textColor2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
