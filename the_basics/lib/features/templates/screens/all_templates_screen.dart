import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/templates/models/template_model.dart';
import 'package:the_basics/utils/app_colors.dart';
import '../../../utils/common_widgets/custom_button.dart';
import '../../../utils/common_widgets/generic_list.dart';
import '../../../utils/common_widgets/side_menu.dart';
import '../controllers/template_controller.dart';
import 'new_tempalte_screen.dart';


class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final templateController = Get.find<TemplateController>();

    // wykonuje sie po zabojstwie widgetu
    // resetujemy filtry po przejsciu na inny ekran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      templateController.resetFilters();
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
            child: SideMenu(),
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
                          'Szablony',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logo,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildAddTagButton(context, templateController),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (templateController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (templateController.errorMessage.value.isNotEmpty) {
                        return Center(child: Text(templateController.errorMessage.value));
                      }
                      if (templateController.allTemplates.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Brak utworzonych szablonów.')
                            ],
                          ),
                        );
                      }
                      //  if there are no error msgs in the controller, we will just build the template list
                      return _buildTagsList(context, templateController);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTagButton(BuildContext context, TemplateController controller) {
    return CustomButton(
      text: 'Stwórz szablon',
      icon: Icons.add,
      width: 130,
      // navigate to new create controller page
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NewTemplatePage()),
      ),
    );
  }

  // Widget _buildSearchBar() {
  //   final tagsController = Get.find<TagsController>();
  //   return CustomSearchBar(
  //     hintText: 'Wyszukaj tag',
  //     widthPercentage: 0.2,
  //     maxWidth: 360,
  //     minWidth: 160,
  //     onChanged: (query) {
  //       tagsController.searchQuery.value = query;
  //       tagsController.filterTags(query);
  //     } ,
  //   );
  // }

  Widget _buildTagsList(BuildContext context, TemplateController controller) {
    return GenericList<TemplateModel>(
      items: controller.allTemplates,
      // i guess on tap we will navigate to the "newTemplateScreen", but just with options limited to viewing / editing ?
      onItemTap: (template) => (print("oho")),
      itemBuilder: (context, template) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          title: Text(
            template.templateName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor1,
            ),
          ),
          subtitle: Text(
            template.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textColor2,
            ),
          ),
        );
      },
    );
  }
}