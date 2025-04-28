import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:the_basics/data/repositiories/other/tags_repo.dart';
import 'package:the_basics/features/schedules/controllers/user_controller.dart';
import 'package:the_basics/features/schedules/models/tags_model.dart';

class TagsController extends GetxController {
  static TagsController get instance => Get.find();

  final nameController = TextEditingController();
  final descController = TextEditingController();

  final _tagsRepo = Get.put(TagsRepo());

  //create an observable list that will hold all the tag data
  RxList<TagsModel> allTags = <TagsModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final userController = Get.find<UserController>();

  /// pull all the available tags when the app is launched for the first time
  @override
  void onInit() {
    fetchTags();
    super.onInit();
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
      final tagId = FirebaseFirestore.instance.collection('Tags').doc().id;

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
      Get.snackbar('Sukces', 'Tag zaktualizowany pomyślnie');
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// deletes a tag with a specific id
  Future<void> deleteTag(String tagId) async {
    try {
      isLoading(true);
      await _tagsRepo.deleteTag(tagId);

      // odświeżamy listę tagów
      await fetchTags();

      // zamykamy dialog edycji
      Get.back();

      // wiadomosc o sukcesie
      Get.snackbar('Sukces', 'Tag został trwale usunięty');
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', e.toString());
    } finally {
      isLoading(false);
    }
  }
}