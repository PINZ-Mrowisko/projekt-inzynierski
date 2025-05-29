import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import '../../../../utils/common_widgets/side_menu.dart';
import '../../../employees/controllers/user_controller.dart';
import '../../../../utils/app_colors.dart';
import 'package:the_basics/features/employees/screens/employee_management.dart';
import '../../../tags/controllers/tags_controller.dart';


class MainCalendar extends StatelessWidget {
  const MainCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    final tagsController = Get.find<TagsController>();
    final selectedTags = <String>[].obs;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
            child: const SideMenu(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 80,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Grafik ogólny',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logo,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: buildTagFilterDropdown(
                            tagsController,
                            selectedTags,
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        buildSearchBar(),
                        const SizedBox(width: 16),
                        
                        CustomButton(
                          onPressed: () {},
                          text: "Generuj grafik",
                          width: 155,
                          icon: Icons.edit,
                        ),
                        const SizedBox(width: 10),
                        
                        CustomButton(
                          onPressed: () {},
                          text: "Eksportuj",
                          width: 125,
                          icon: Icons.download,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Obx(
                      () => Text(
                        controller.employee.value.firstName,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
