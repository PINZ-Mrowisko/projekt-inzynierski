// dedicated pop up for mobile employee search
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/common_widgets/search_bar.dart';

void showEmployeeSearchDialog(BuildContext context, RxList<String> selectedTags) {
  final userController = Get.find<UserController>();
  final TextEditingController searchController =
      TextEditingController(text: userController.searchQuery.value);

  showDialog(
    context: context,
    builder: (context) => Transform.scale(
      scale: 0.85,
      child: BaseDialog(
        width: 500,
        showCloseButton: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Wyszukaj pracownika",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textColor2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  CustomSearchBar(
                    hintText: 'Wpisz imię lub nazwisko',
                    widthPercentage: 1.0,
                    maxWidth: 400,
                    minWidth: 200,
                    onChanged: (query) {
                      userController.searchQuery.value = query;
                      userController.filterEmployees(selectedTags);
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: 140,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          searchController.clear();
                        });
                        userController.searchQuery.value = '';
                        userController.filterEmployees(selectedTags);
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
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
