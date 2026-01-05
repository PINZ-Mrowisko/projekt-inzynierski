// dedicated pop up for mobile tag filtering 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

void showTagsFilterDialog(BuildContext context, RxList<String> selectedTags) {
  final tagsController = Get.find<TagsController>();
  final userController = Get.find<UserController>();

  final List<String> tempSelectedTags = List.from(selectedTags);

  showDialog(
    context: context,
    builder: (context) => Transform.scale(
      scale: 0.85,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = MediaQuery.of(context).size.height * 0.5;

          return BaseDialog(
            width: 551,
            showCloseButton: true,
            child: StatefulBuilder(
              builder: (context, setState) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 28),
                      Text(
                        "Filtruj po tagach",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textColor2,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: tagsController.allTags.map((tag) {
                              final tagName = tag.tagName;
                              final selected = tempSelectedTags.contains(tagName);
                              return CheckboxListTile(
                                value: selected,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      tempSelectedTags.add(tagName);
                                    } else {
                                      tempSelectedTags.remove(tagName);
                                    }
                                  });
                                },
                                title: Text(
                                  tagName,
                                  style: TextStyle(
                                    color: AppColors.textColor2,
                                    fontSize: 16,
                                  ),
                                ),
                                activeColor: AppColors.logo,
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                dense: true,
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  tempSelectedTags.clear();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text(
                                "Wyczyść",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 140,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                selectedTags.assignAll(tempSelectedTags);
                                userController.filterEmployees(selectedTags);
                                Navigator.of(context).pop();
                                showCustomSnackbar(
                                  context,
                                  "Filtry zostały zastosowane.",
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text(
                                "Zastosuj",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    ),
  );
}