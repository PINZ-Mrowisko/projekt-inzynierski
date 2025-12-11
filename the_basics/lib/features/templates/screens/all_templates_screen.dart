import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/templates/models/template_model.dart';
import 'package:the_basics/features/templates/usecases/delete_dialog.dart';
import 'package:the_basics/utils/app_colors.dart';
import '../../../utils/common_widgets/custom_button.dart';
import '../../../utils/common_widgets/generic_list.dart';
import '../../../utils/common_widgets/search_bar.dart';
import '../../../utils/common_widgets/side_menu.dart';
import '../controllers/template_controller.dart';
import 'new_template_screen.dart';


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

    return Obx(() {
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
                        Text(
                          'Szablony',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logo,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: _buildSearchBar(),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: _buildAddTemplateButton(context, templateController),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: _buildSortButton(context, templateController),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (templateController.isLoading.value) {
                        return Center(child: CircularProgressIndicator(color: AppColors.logo));
                      }
                      if (templateController.errorMessage.value.isNotEmpty) {
                        return Center(child: Text(templateController.errorMessage.value));
                      }
                      if (templateController.filteredTemplates.isEmpty) {
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
                      return _buildTemplateList(context, templateController);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    });
  }

  Widget _buildAddTemplateButton(BuildContext context, TemplateController controller) {
    return CustomButton(
      text: 'Stwórz szablon',
      icon: Icons.add,
      width: 160,
      // navigate to new create controller page
      onPressed: () => (
          controller.clearController(),
          Get.toNamed('/szablony/nowy-szablon', arguments: {'isViewMode': false})
          //make sure the page isnt set to viewing
      //     Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => NewTemplatePage(isViewMode: false)),
      // )),
    )
    );
  }

  Widget _buildSortButton(BuildContext context, TemplateController controller) {
    return CustomButton(
      text: 'Sortuj',
      icon: Icons.sort,
      width: 110,
      onPressed: controller.sortByDate,
      backgroundColor: AppColors.blue,
    );
  }

  Widget _buildSearchBar() {
    final templateController = Get.find<TemplateController>();
    // tutaj jest filtering
    return CustomSearchBar(
      hintText: 'Wyszukaj szablon',
      widthPercentage: 0.2,
      maxWidth: 360,
      minWidth: 160,
      onChanged: (query) {
        templateController.searchQuery.value = query;
        templateController.filterTemplates(query);
      } ,
    );
  }

  Widget _buildTemplateList(BuildContext context, TemplateController controller) {
    return GetBuilder<TemplateController>(
      builder: (controller) {
        return GenericList<TemplateModel>(
          items: controller.filteredTemplates,
          // i guess on tap we will navigate to the "newTemplateScreen", but just with options limited to viewing / editing ?
          onItemTap: (template) =>
          (
          // clear the controller of the changes from last screen
          controller.clearController(),
          Get.toNamed('/szablony/edytuj-szablon', arguments: {
            'template': template, 
            'isViewMode': true
          })
      ),
      itemBuilder: (context, template) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
            ),
              title: Text(
                template.templateName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor1,
                ),
              ),
              subtitle: Text(
                "${template.insertedAt.day}.${template.insertedAt
                    .month}.${template.insertedAt.year}",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textColor2,
                ),
              ),
              leading: template.isDataMissing == true
                  ? Icon(Icons.warning_amber, color: Colors.redAccent)
                  : null,
          // trailing delete button
          trailing: IconButton(
            tooltip: "Usuń szablon",
              onPressed: () async {
                confirmDeleteTemplate(template, template.marketId);
              },
              icon: Icon(Icons.delete, color: AppColors.warning),
              ),
            );
          },
        );

      }
    );
  }
}