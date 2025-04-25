import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:the_basics/data/repositiories/user/user_repo.dart';
import 'package:the_basics/features/auth/models/user_model.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  Rx<UserModel> employee = UserModel.empty().obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final userRepo = Get.put(UserRepo());
  final localStorage = GetStorage();

  late final RxBool isAdmin;

  @override
  void onInit() async{
    super.onInit();
    isAdmin = false.obs;
    await fetchCurrentUserRecord();

  }

  Future<void> fetchCurrentUserRecord() async{
    try {
      isLoading(true);
      final employee = await userRepo.fetchCurrentUserDetails();
      print("User loaded: ${employee.firstName}");
      print("User loaded: ${employee.marketId}");
      // assign the curr user to the observable var
      this.employee(employee);

      _setAdminStatus(employee);

    } catch (e) {
      errorMessage(e.toString());
      employee(UserModel.empty());
    } finally {
      isLoading(false);
    }
  }

  void _setAdminStatus(UserModel user) {
    final adminStatus = user.tags.contains('Kierownik');
    isAdmin(adminStatus);
    localStorage.write('IS_ADMIN', adminStatus);
  }

}