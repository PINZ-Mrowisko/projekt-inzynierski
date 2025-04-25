import 'package:get/get.dart';
import 'package:the_basics/data/repositiories/user/tags_repo.dart';
import 'package:the_basics/features/schedules/controllers/user_controller.dart';
import 'package:the_basics/features/schedules/models/tags_model.dart';

class TagsController extends GetxController {
  static TagsController get instance => Get.find();

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

  Future <void> fetchTags() async{
    try {
      isLoading(true);
      errorMessage('');
      print("Fetching tags... MarketID: ${userController.employee.value.marketId}");
      final marketId = userController.employee.value.marketId;
      if (marketId.isEmpty) throw "Market ID not available";

      /// fetch tags from tags repo
      final tags = await _tagsRepo.getAllTags(marketId);
      print("Tags loaded: ${allTags.length} items");
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

}