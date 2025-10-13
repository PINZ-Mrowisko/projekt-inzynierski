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

  RxString searchQuery = ''.obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

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

  /// saves the created template in firestore
  Future<void> saveTemplate() async {
    try {
      isLoading(true);
      errorMessage('');

      final user = userController.employee.value;
      if (user.marketId.isEmpty) throw "Market ID not available";
      if (nameController.text.isEmpty) throw "Nazwa szablonu jest wymagana";

      // generate a new tempalte id to use in firestore
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

      // save via repo
      await _templateRepo.saveTemplate(newTemplate);

      // and then go through shifts and saved them to the same template
      // Save shifts subcollection
      for (var shift in addedShifts) {
        await _templateRepo.saveShift(user.marketId, templateId, shift);
      }

      // refresh the list
      await fetchTemplates();

      Get.snackbar('Sukces', 'Szablon został zapisany pomyślnie');
      nameController.clear();
      descController.clear();
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', 'Nie udało się zapisać szablonu: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // /// pobierz konkretny tag przez ID
  // Future<void> fetchTagById(String tagId) async {
  //   try {
  //     isLoading(true);
  //     final tag = await _tagsRepo.getTagById(tagId);
  //     if (tag != null) {
  //
  //     }
  //   } catch (e) {
  //     errorMessage(e.toString());
  //     Get.snackbar('Błąd', e.toString());
  //   } finally {
  //     isLoading(false);
  //   }
  // }
  //
  // Future<void> updateTag(TagsModel tag) async {
  //   try {
  //     isLoading(true);
  //     await _tagsRepo.updateTag(tag);
  //
  //     // odświeżamy listę tagów
  //     await fetchTags();
  //
  //     // zamykamy dialog edycji
  //     Get.back();
  //
  //     // wiadomosc o sukcesie
  //     //Get.snackbar('Sukces', 'Tag zaktualizowany pomyślnie');
  //   } catch (e) {
  //     errorMessage(e.toString());
  //     Get.snackbar('Błąd', e.toString());
  //   } finally {
  //     isLoading(false);
  //   }
  // }
  //
  // /// przez nasza strukture plikow musimy wykonywac takie dziedziczne aktualizowanie
  // /// uzytkownicy posiadaja nazwy tagów w sobie - przy aktualizacji nazwy tagu, musimy zmienic ja
  // /// u wszystkich affected uzytkowników
  // /// wyszukujemy tych co mają stary tag, wysyłamy ich do aktualizacji, aktualizujemy tag w kolekcji tagów
  // /// w obu kontrolerach aktualizujemy listy wszystkich tagów i pracowników, tak aby zawierały najnowsze dane
  //
  // Future<void> updateTagAndUsers(TagsModel oldTag, TagsModel newTag) async {
  //   try {
  //     isLoading(true);
  //
  //     // 1. Robimy batch (zeby wszystko bylo ladnie zgrabnie atomowo)
  //     final batch = FirebaseFirestore.instance.batch();
  //
  //
  //     // 2. Przechodzimy przez wszystkich userów z tagiem i zmieniamy w nich wartosci
  //     for (final user in userController.allEmployees) {
  //       if (user.tags.contains(oldTag.tagName)) {
  //         final updatedUser = user.copyWithUpdatedTags(oldTag.tagName, newTag.tagName);
  //
  //         final userRef = FirebaseFirestore.instance.collection('Users').doc(user.id);
  //
  //         final userRef2 = FirebaseFirestore.instance
  //             .collection('Markets')
  //             .doc(user.marketId)
  //             .collection('members')
  //             .doc(user.id);
  //
  //         batch.update(userRef, {'tags': updatedUser.tags});
  //
  //         batch.update(userRef2, {'tags': updatedUser.tags});
  //       }
  //     }
  //
  //     // 3. Aktualizujemy tag w kolekcji Tags
  //     //final tagRef = FirebaseFirestore.instance.collection('Tags').doc(oldTag.id);
  //     final tagRef = FirebaseFirestore.instance
  //         .collection('Markets')
  //         .doc(oldTag.marketId)
  //         .collection('Tags')
  //         .doc(oldTag.id);
  //
  //     batch.update(tagRef, newTag.toMap());
  //
  //     // 4. Wykonujemy wszystkie operacje naraz (atomowo)
  //     await batch.commit();
  //
  //     // 5. Odświeżamy dane
  //     await fetchTags();
  //     userController.fetchAllEmployees();
  //
  //   } catch (e) {
  //     Get.snackbar('Błąd', 'Nie udało się zaktualizować tagu: ${e.toString()}');
  //   } finally {
  //     isLoading(false);
  //   }
  // }
  //
  // /// returns the count of users with specified tag !
  // int countUsersWithTag(String tagName) {
  //   return userController.allEmployees
  //       .where((user) => user.tags.contains(tagName))
  //       .length;
  // }
  //
  // /// deletes a tag with a specific id - also in users collection !
  // Future<void> deleteTag(String tagId, String tagName, String marketId) async {
  //   try {
  //     isLoading(true);
  //
  //     // 1. Za pomocą batcha będziemy usuwac tagi z pracownikow i tagi z tagow
  //     final batch = FirebaseFirestore.instance.batch();
  //     for (final user in userController.allEmployees.where((u) => u.tags.contains(tagName))) {
  //       final userRef = FirebaseFirestore.instance.collection('Users').doc(user.id);
  //
  //       final userRef2 = FirebaseFirestore.instance
  //           .collection('Markets')
  //           .doc(marketId)
  //           .collection('members')
  //           .doc(user.id);
  //
  //       batch.update(userRef, {
  //         'tags': FieldValue.arrayRemove([tagName]),
  //         'updatedAt': Timestamp.now()
  //       });
  //
  //       batch.update(userRef2, {
  //         'tags': FieldValue.arrayRemove([tagName]),
  //         'updatedAt': Timestamp.now(),
  //       });
  //     }
  //
  //     // 2. Usuwamy tag z kolekcji Tags
  //     final tagRef = FirebaseFirestore.instance
  //         .collection('Markets')
  //         .doc(marketId)
  //         .collection('Tags')
  //         .doc(tagId);
  //
  //     batch.delete(tagRef);
  //
  //     await batch.commit();
  //     //await _tagsRepo.deleteTag(tagId);
  //
  //     // odświeżamy listę tagów i pracownikow
  //     await fetchTags();
  //     userController.fetchAllEmployees();
  //
  //     // zamykamy dialog edycji
  //     Get.back();
  //
  //     // wiadomosc o sukcesie
  //     //Get.snackbar('Sukces', 'Tag został trwale usunięty');
  //   } catch (e) {
  //     errorMessage(e.toString());
  //     Get.snackbar('Błąd', e.toString());
  //   } finally {
  //     isLoading(false);
  //   }
  // }
  //
  // void filterTags(String query) {
  //   searchQuery.value = query.trim();
  //
  //   if (query.isEmpty) {
  //     filteredTags.assignAll(allTags);
  //   } else {
  //
  //     final queryWords = query.toLowerCase().trim().split(' ')
  //       ..removeWhere((word) => word.isEmpty);
  //
  //     final results = allTags.where((tag) {
  //       final tagName = tag.tagName.toLowerCase();
  //       final description = tag.description.toLowerCase();
  //
  //       return queryWords.every((word) =>
  //       tagName.contains(word) ||
  //           description.contains(word));
  //     }).toList();
  //
  //     filteredTags.assignAll(results);
  //   }
  // }

  void resetFilters() {
    searchQuery.value = '';
    filteredTemplates.assignAll(allTemplates);
  }

}