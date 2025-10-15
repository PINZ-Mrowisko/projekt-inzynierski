import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/templates/models/template_model.dart';
import 'package:the_basics/utils/app_colors.dart';
import '../../../utils/common_widgets/custom_button.dart';
import '../../../utils/common_widgets/generic_list.dart';
import '../../../utils/common_widgets/search_bar.dart';
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
                        const Spacer(),

                        const SizedBox(width: 16),
                        _buildSearchBar(),
                        _buildAddTemplateButton(context, templateController),
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
  }

  Widget _buildAddTemplateButton(BuildContext context, TemplateController controller) {
    return CustomButton(
      text: 'Stwórz szablon',
      icon: Icons.add,
      width: 130,
      // navigate to new create controller page
      onPressed: () => (
          controller.clearController(),

          //make sure the page isnt set to viewing
          Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NewTemplatePage(isViewMode: false)),
      )),
    );
  }

  Widget _buildSearchBar() {
    final templateController = Get.find<TemplateController>();
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
    return GenericList<TemplateModel>(
      items: controller.filteredTemplates,
      // i guess on tap we will navigate to the "newTemplateScreen", but just with options limited to viewing / editing ?
      onItemTap: (template) => (
          // clear the controller of the changes from last screen
          controller.clearController(),
          Get.to(() => NewTemplatePage(template: template, isViewMode: true))
      ),
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
            "${template.insertedAt.day}.${template.insertedAt.month}.${template.insertedAt.year}",
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textColor2,
            ),
          ),
          // trailing delete button
          trailing: IconButton(
            tooltip: "Usuń szablon",
              onPressed: () async {
                final confirm = await _showDeleteDialog(context, template);
                if (confirm == true) {
                  await controller.deleteTemplate(template.marketId, template.id);
                }
              },
              icon: const Icon(Icons.delete, color: Colors.redAccent),
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteDialog(
      BuildContext context, TemplateModel template) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Usuń szablon',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Czy na pewno chcesz usunąć szablon "${template.templateName}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text('Usuń'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

}