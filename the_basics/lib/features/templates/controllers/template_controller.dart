import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:the_basics/data/repositiories/other/template_repo.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/templates/models/template_model.dart';

import '../models/template_shift_model.dart';


class TemplateController extends GetxController {
  static TemplateController get instance => Get.find();

  final nameController = TextEditingController();
  final descController = TextEditingController();

  final TemplateRepo _templateRepo = Get.find();

  // we will temporarly hold new created "shifts" (kafelki w szablonach), so we can later use them when saving a template
  RxList<ShiftModel> addedShifts = <ShiftModel>[].obs;

  // for general rules
  RxInt minMen = 0.obs;
  RxInt maxMen = 0.obs;
  RxInt minWomen = 0.obs;
  RxInt maxWomen = 0.obs;

  // create an observable list that will hold chosen templete data
  // that would make extracting the data for the alg easier
  // during setting up the schedule, K chooses one of the templetes and those lists get filled with filtered data
  RxList<TemplateModel> allTemplates= <TemplateModel>[].obs;
  RxList<TemplateModel> filteredTemplates= <TemplateModel>[].obs;

  //used for filtering template names
  RxString searchQuery = ''.obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // controll the edit state of the form
  final isEditMode = false.obs;

  void enableEditMode() => isEditMode.value = true;
  void cancelEditMode() => isEditMode.value = false;

  final userController = Get.find<UserController>();

  Future<void> initialize() async {
    try {
      isLoading(true);
      await fetchTemplates();
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// adds a shift to the current working list
  void addShift(ShiftModel shift) {
    addedShifts.add(shift);
  }

  /// clears shifts (we do after saving template)
  void clearShifts() {
    addedShifts.clear();
  }

  /// handles the setting of the observable variables
  void setRuleValue(String type, int value) {
    switch (type) {
      case 'minMen':
        minMen.value = value;
        break;
      case 'maxMen':
        maxMen.value = value;
        break;
      case 'minWomen':
        minWomen.value = value;
        break;
      case 'maxWomen':
        maxWomen.value = value;
        break;
    }
  }

  Future <void> checkRuleValues() async{

    if(nameController.text == ''){
      errorMessage.value = "Nazwa szablonu nie może być pusta.";
      return;
    };

    if (minWomen.value < 0 || maxWomen.value <0 || minMen.value < 0 || maxMen.value < 0) {
      errorMessage.value = "Ograniczenie nie może być ujemne.";
      return;
    };

    if (minMen.value  > maxMen.value) {
      errorMessage.value = "Ograniczenie górne nie może być mniejsze od dolnego. (mężczyźni)";
      return;
    };
    if (minWomen.value > maxWomen.value) {
      errorMessage.value = "Ograniczenie górne nie może być mniejsze od dolnego. (kobiety)";
      return;
    }
    errorMessage.value = '';
    return;
  }

  /// fetches all available templates in a list, which is saved in the controller
  Future <void> fetchTemplates() async{
    try {
      isLoading(true);
      errorMessage('');
      //print("Fetching tags... MarketID: ${userController.employee.value.marketId}");
      final marketId = userController.employee.value.marketId;

      if (marketId.isEmpty) throw "Market ID not available";

      /// fetch tags from tags repo
      final templates = await _templateRepo.getAllTemplates(marketId);

      /// save the tags locally for later use
      allTemplates.assignAll(templates);
      filteredTemplates.assignAll(templates);

    } catch (e) {
      //display error msg
      errorMessage(e.toString());
      Get.snackbar('Error', 'Failed to load tags: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> saveTemplate(bool asNew) async {
    try {
      isLoading(true);
      errorMessage('');

      final user = userController.employee.value;
      if (user.marketId.isEmpty) throw "Market ID not available";
      if (nameController.text.isEmpty) throw "Nazwa szablonu jest wymagana";

      final templateId = FirebaseFirestore.instance
          .collection('Markets')
          .doc(user.marketId)
          .collection('Templates')
          .doc()
          .id;

      final newTemplate = TemplateModel(
        id: templateId,
        templateName: nameController.text.trim(),
        description: descController.text.trim(),
        marketId: user.marketId,
        minWomen: minWomen.value,
        maxWomen: maxWomen.value,
        minMen: minMen.value,
        maxMen: maxMen.value,
        isDeleted: false,
        insertedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _templateRepo.saveTemplate(newTemplate);

      // and then go through shifts and saved them to the same template
      // Save shifts subcollection
      for (var shift in addedShifts) {
        await _templateRepo.saveShift(user.marketId, templateId, shift);
      }

      await fetchTemplates();

      nameController.clear();
      descController.clear();
      Get.snackbar('Sukces', 'Szablon został zapisany pomyślnie');
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', 'Nie udało się zapisać szablonu: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }


  Future<void> updateTemplate(TemplateModel template) async {
    try {
      isLoading(true);
      errorMessage('');

      if (nameController.text.isEmpty) {
        Get.snackbar('Błąd', 'Nazwa szablonu nie może być pusta');
        return;
      }

      final updatedTemplate = template.copyWith(
        templateName: nameController.text.trim(),
        description: descController.text.trim(),
        minMen: minMen.value,
        maxMen: maxMen.value,
        minWomen: minWomen.value,
        maxWomen: maxWomen.value,
        updatedAt: DateTime.now(),
      );

      await _templateRepo.updateTemplate(updatedTemplate);

      await _templateRepo.updateTemplateShifts(
        template.marketId,
        template.id,
        addedShifts,
      );

      await fetchTemplates();

      Get.snackbar('Sukces', 'Szablon został zaktualizowany');
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', 'Nie udało się zaktualizować szablonu: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }


  /// we will use this when viewing the shifts, first we want to store them in the controller list
  /// we call this method in newTemplatePage to fill the list
  Future<void> loadShiftsForTemplate(String marketId, String templateId) async {
    final shiftsSnapshot = await FirebaseFirestore.instance
        .collection('Markets')
        .doc(marketId)
        .collection('Templates')
        .doc(templateId)
        .collection('Shifts')
        .get();

    final shifts = shiftsSnapshot.docs
        .map((doc) => ShiftModel.fromSnapshot(doc))
        .toList();

    addedShifts.assignAll(shifts);
  }


  Future<void> clearController() async {
    isLoading(true);
    addedShifts.clear();

    nameController.clear();
    descController.clear();

    minMen = 0.obs;
    maxMen = 0.obs;
    minWomen = 0.obs;
    maxWomen = 0.obs;

    isEditMode.value = false;
    isLoading(false);
  }

  void filterTemplates(String query) {
    searchQuery.value = query.trim();

    if (query.isEmpty) {
      filteredTemplates.assignAll(allTemplates);
    } else {

      final queryWords = query.toLowerCase().trim().split(' ')
        ..removeWhere((word) => word.isEmpty);

      final results = allTemplates.where((template) {
        final templateName = template.templateName.toLowerCase();

        return queryWords.every((word) =>
        templateName.contains(word));
      }).toList();

      filteredTemplates.assignAll(results);
    }
  }

  void resetFilters() {
    searchQuery.value = '';
    filteredTemplates.assignAll(allTemplates);
  }

  Future<void> deleteTemplate(String marketId, String templateId) async {
    _templateRepo.softDeleteTemplate(marketId: marketId, templateId: templateId);
    Get.snackbar('Success', 'Template has been deleted');

    // after successful deletion refresh the list
    fetchTemplates();
  }

}