import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:the_basics/data/repositiories/other/tags_repo.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/tags/models/tags_model.dart';


class TagsController extends GetxController {
  static TagsController get instance => Get.find();

  final nameController = TextEditingController();
  final descController = TextEditingController();

  final TagsRepo _tagsRepo = Get.find();

  //create an observable list that will hold all the tag data
  RxList<TagsModel> allTags = <TagsModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final userController = Get.find<UserController>();

  Future<void> initialize() async {
    try {
      isLoading(true);
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
      //print("Tags loaded: ${allTags.length} items");
      /// save the tags locally for later use
      allTags.assignAll(tags);

    } catch (e) {
      //display error msg
      errorMessage(e.toString());
      Get.snackbar('Error', 'Failed to load tags: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  /// saves the provided tag in Firestore
  Future <void> saveTag(String marketId) async{
    try {
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
      await _tagsRepo.updateTag(tag);

      // odświeżamy listę tagów
      await fetchTags();

      // zamykamy dialog edycji
      Get.back();

      // wiadomosc o sukcesie
      //Get.snackbar('Sukces', 'Tag zaktualizowany pomyślnie');
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

  Future<void> updateTagAndUsers(TagsModel oldTag, TagsModel newTag) async {
    try {
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

      // 5. Odświeżamy dane
      await fetchTags();
      userController.fetchAllEmployees();

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
}