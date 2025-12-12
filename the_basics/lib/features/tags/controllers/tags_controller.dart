import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:the_basics/data/repositiories/other/tags_repo.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/tags/models/tags_model.dart';

import '../../../data/repositiories/other/template_repo.dart';
import '../../templates/controllers/template_controller.dart';


class TagsController extends GetxController {
  static TagsController get instance => Get.find();

  final nameController = TextEditingController();
  final descController = TextEditingController();

  final TagsRepo _tagsRepo = Get.find();

  //create an observable list that will hold all the tag data
  RxList<TagsModel> allTags = <TagsModel>[].obs;
  RxList<TagsModel> filteredTags = <TagsModel>[].obs;

  RxString searchQuery = ''.obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString tagExistanceMessage = ''.obs;


  final userController = Get.find<UserController>();

  Future<void> initialize() async {
    try {
      isLoading(true);
      //print("fetchin tags");
      await fetchTags();
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// fetches all available tags in a list, which is saved in the controller
  Future <void> fetchTags() async{
    try {
      isLoading(true);
      errorMessage('');
      //print("Fetching tags... MarketID: ${userController.employee.value.marketId}");
      final marketId = userController.employee.value.marketId;
      if (marketId.isEmpty) throw "Market ID not available";

      /// fetch tags from tags repo
      final tags = await _tagsRepo.getAllTags(marketId);
      //print("Tags loaded: ${tags.length} items");
      /// save the tags locally for later use
      allTags.assignAll(tags);
      filteredTags.assignAll(tags);

    } catch (e) {
      //display error msg
      errorMessage(e.toString());
      Get.snackbar('Error', 'Failed to load tags: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  /// checks if a tag with the given name already exists in the market.
  Future<bool> tagExists(String marketId, String tagName, {String? tagID}) async {
    try{
    final snapshot = await FirebaseFirestore.instance
        .collection('Markets')
        .doc(marketId)
        .collection('Tags')
        .where('tagName', isEqualTo: tagName)
        .get();

    // check if the tag we got is the tag with the same ID, if yes then exclude
    if(tagID != null) {
      // this is the case used in editing

      final matchingTags = snapshot.docs.where((doc) => doc.id != tagID);
      tagExistanceMessage.value = matchingTags.isNotEmpty ? "Tag o podanej nazwie już istnieje." : "here2";
      return matchingTags.isNotEmpty;
    }else {
      // this is the check in creation
      return snapshot.docs.isNotEmpty;
    }

    return snapshot.docs.isNotEmpty;
  } catch (e) {
      tagExistanceMessage.value = 'Błąd podczas sprawdzania tagu';
      return false;
    }

  }

  /// saves the provided tag in Firestore
  Future <void> saveTag(String marketId) async{
    try {

      final tagName = nameController.text.trim();
      final exists = await tagExists(marketId, tagName);

        // generate a custom tag id from firebase
        //final tagId = FirebaseFirestore.instance.collection('Tags').doc().id;

        final tagId = FirebaseFirestore.instance
            .collection('Markets')
            .doc(marketId)
            .collection('Tags')
            .doc()
            .id;

        final newTag = TagsModel(
          id: tagId,
          tagName: nameController.text,
          description: descController.text,
          marketId: marketId,
          insertedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save the provided tag through the tag Repo
        final tagsRepo = Get.put(TagsRepo());
        await tagsRepo.saveTag(newTag);

        // we need to fetch the new updated list of tags
        fetchTags();

    } catch (e) {
      //display error msg
      errorMessage(e.toString());
      Get.snackbar('Error', 'Failed to load tags: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  /// pobierz konkretny tag przez ID
  Future<void> fetchTagById(String tagId) async {
    try {
      isLoading(true);
      final tag = await _tagsRepo.getTagById(tagId);
      if (tag != null) {

      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateTag(TagsModel tag) async {
    try {
      isLoading(true);
      final exists = await tagExists(tag.marketId, tag.tagName);
      if (tagExistanceMessage.value.isNotEmpty) {
        return;
      } else {
        await _tagsRepo.updateTag(tag);

        // odświeżamy listę tagów
        await fetchTags();

        // zamykamy dialog edycji
        Get.back();

        // wiadomosc o sukcesie
        //Get.snackbar('Sukces', 'Tag zaktualizowany pomyślnie');
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// przez nasza strukture plikow musimy wykonywac takie dziedziczne aktualizowanie
  /// uzytkownicy posiadaja nazwy tagów w sobie - przy aktualizacji nazwy tagu, musimy zmienic ja
  /// u wszystkich affected uzytkowników
  /// wyszukujemy tych co mają stary tag, wysyłamy ich do aktualizacji, aktualizujemy tag w kolekcji tagów
  /// w obu kontrolerach aktualizujemy listy wszystkich tagów i pracowników, tak aby zawierały najnowsze dane

  /// teraz updated: musimy ulepszać tagi również w szablonach
  Future<void> updateTagAndUsers(TagsModel oldTag, TagsModel newTag) async {
    try {
      final TemplateRepo _templateRepo = Get.find();

      isLoading(true);

      // 1. Robimy batch (zeby wszystko bylo ladnie zgrabnie atomowo)
      final batch = FirebaseFirestore.instance.batch();


      // 2. Przechodzimy przez wszystkich userów z tagiem i zmieniamy w nich wartosci
      for (final user in userController.allEmployees) {
        if (user.tags.contains(oldTag.tagName)) {
          final updatedUser = user.copyWithUpdatedTags(oldTag.tagName, newTag.tagName);

          final userRef = FirebaseFirestore.instance.collection('Users').doc(user.id);

          final userRef2 = FirebaseFirestore.instance
              .collection('Markets')
              .doc(user.marketId)
              .collection('members')
              .doc(user.id);

          batch.update(userRef, {'tags': updatedUser.tags});

          batch.update(userRef2, {'tags': updatedUser.tags});
        }
      }

      // 3. Aktualizujemy tag w kolekcji Tags
      //final tagRef = FirebaseFirestore.instance.collection('Tags').doc(oldTag.id);
      final tagRef = FirebaseFirestore.instance
          .collection('Markets')
          .doc(oldTag.marketId)
          .collection('Tags')
          .doc(oldTag.id);

      batch.update(tagRef, newTag.toMap());

      // 4. Wykonujemy wszystkie operacje naraz (atomowo)
      await batch.commit();

      // 5. odpalamy update taga w szablonach
      await _templateRepo.updateTagInTemplates(
        oldTag.marketId,
        oldTag.tagName,
        newTag.tagName,
      );

      // 6. Odświeżamy dane
      await fetchTags();
      userController.fetchAllEmployees();
      await Get.find<TemplateController>().fetchTemplates();

    } catch (e) {
      Get.snackbar('Błąd', 'Nie udało się zaktualizować tagu: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  /// returns the count of users with specified tag !
  int countUsersWithTag(String tagName) {
    return userController.allEmployees
        .where((user) => user.tags.contains(tagName))
        .length;
  }

  /// deletes a tag with a specific id - also in users collection !
  Future<void> deleteTag(String tagId, String tagName, String marketId) async {
    try {
      isLoading(true);
      final TemplateRepo _templateRepo = Get.find();

      // 1. Za pomocą batcha będziemy usuwac tagi z pracownikow i tagi z tagow
      final batch = FirebaseFirestore.instance.batch();
      for (final user in userController.allEmployees.where((u) => u.tags.contains(tagName))) {
        final userRef = FirebaseFirestore.instance.collection('Users').doc(user.id);

        final userRef2 = FirebaseFirestore.instance
            .collection('Markets')
            .doc(marketId)
            .collection('members')
            .doc(user.id);

        batch.update(userRef, {
          'tags': FieldValue.arrayRemove([tagName]),
          'updatedAt': Timestamp.now()
        });

        batch.update(userRef2, {
          'tags': FieldValue.arrayRemove([tagName]),
          'updatedAt': Timestamp.now(),
        });
      }

      // 2. Usuwamy tag z kolekcji Tags
      final tagRef = FirebaseFirestore.instance
          .collection('Markets')
          .doc(marketId)
          .collection('Tags')
          .doc(tagId);

      batch.delete(tagRef);

      await batch.commit();
      //await _tagsRepo.deleteTag(tagId);

      // musimy jeszcze przjesc przez szablony w danym markecie i sprawidz wystepowanie tagu tam:
      _templateRepo.deleteTagInTemplates(marketId, tagName);
      await Get.find<TemplateController>().fetchTemplates();


      // odświeżamy listę tagów i pracownikow
      await fetchTags();
      userController.fetchAllEmployees();

      // zamykamy dialog edycji
      Get.back();

      // wiadomosc o sukcesie
      //Get.snackbar('Sukces', 'Tag został trwale usunięty');
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', e.toString());
    } finally {
      isLoading(false);
    }
  }

  void filterTags(String query) {
    searchQuery.value = query.trim();

    if (query.isEmpty) {
      filteredTags.assignAll(allTags);
    } else {
      isLoading(true);
      final queryWords = query.toLowerCase().trim().split(' ')
        ..removeWhere((word) => word.isEmpty);

      final results = allTags.where((tag) {
        final tagName = tag.tagName.toLowerCase();
        final description = tag.description.toLowerCase();

        return queryWords.every((word) =>
        tagName.contains(word) ||
            description.contains(word));
      }).toList();

      filteredTags.assignAll(results);
      isLoading(false);
    }
  }

  void resetFilters() {
    searchQuery.value = '';
    filteredTags.assignAll(allTags);
  }

}