// Update tags_selection_widget.dart to handle initial values better
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
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
        const SizedBox(height: 6),

        Obx(() {
          final tags = widget.tagsController.allTags;

          return Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: MultiSelectDialogField<String>(
              items: tags
                  .map((tag) => MultiSelectItem<String>(tag.id, tag.tagName))
                  .toList(),
              initialValue: selectedTagIds,
              onSelectionChanged: (values) {
                selectedTagIds = List.from(values);
                selectedTagNames = values
                    .map((id) => tags.firstWhereOrNull((t) => t.id == id)?.tagName ?? '')
                    .toList();

                widget.onSelectionChanged(selectedTagIds, selectedTagNames);
              },
              title: Text('Wybierz tagi'),
              buttonText: Text(
                selectedTagNames.isEmpty
                    ? 'Wybierz tagi'
                    : 'Wybrano ${selectedTagNames.length} tagów',
                style: TextStyle(
                  color: selectedTagNames.isEmpty
                      ? Colors.grey
                      : AppColors.textColor2,
                ),
              ),
              buttonIcon: Icon(Icons.arrow_drop_down, color: AppColors.textColor2),
              onConfirm: (values) {
                selectedTagIds = List.from(values);
                selectedTagNames = values
                    .map((id) => tags.firstWhereOrNull((t) => t.id == id)?.tagName ?? '')
                    .toList();

                widget.onSelectionChanged(selectedTagIds, selectedTagNames);
                setState(() {});
              },
              itemsTextStyle: TextStyle(
                fontSize: 16,
                color: AppColors.textColor2,
              ),
              selectedItemsTextStyle: TextStyle(
                fontSize: 16,
                color: AppColors.blue,
                fontWeight: FontWeight.bold,
              ),
              searchable: true,
              searchHint: 'Szukaj tagów...',
              validator: (values) {
                if (values == null || values.isEmpty) {
                  return 'Wybierz przynajmniej jeden tag';
                }
                return null;
              },
              dialogHeight: 400,
              dialogWidth: 400,
            ),
          );
        })
      ],
    );
  }
}