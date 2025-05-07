import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:the_basics/data/repositiories/user/user_repo.dart';
import 'package:the_basics/features/auth/models/user_model.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  Rx<UserModel> employee = UserModel.empty().obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  //final userRepo = Get.put(UserRepo());
  final UserRepo userRepo = Get.find();

  final localStorage = GetStorage();

  //create an observable list that will hold all the employee data
  RxList<UserModel> allEmployees = <UserModel>[].obs;

  final RxBool isAdmin = false.obs;

  Future<void> initialize() async {
    try {
      isLoading(true);
      final user = await fetchCurrentUserRecord();
      print("After await fetchCurrentUserRecord: User=${user.firstName}, MarketID=${user.marketId}");

      if (user != null) {
        print("After await fetchCurrentUserRecord: User=${employee.value.firstName}, MarketID=${employee.value.marketId}");
        await fetchAllEmployees();
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<UserModel> fetchCurrentUserRecord() async{
    try {
      isLoading(true);
      final user = await userRepo.fetchCurrentUserDetails();
      // assign the curr user to the observable var
      employee.value = user;

      _setAdminStatus(user);

      return user;

    } catch (e) {
      print("Error occurred: $e");
      errorMessage(e.toString());
      employee.value = UserModel.empty();

      return UserModel.empty();
    } finally {
      isLoading(false);
    }
  }

  void _setAdminStatus(UserModel user) {
    final adminStatus = user.tags.contains('Kierownik');
    isAdmin.value = adminStatus;
    return;
  }

  /// gets all available, not deleted employees from current market
  Future<void> fetchAllEmployees() async{
    try {
      isLoading(true);
      errorMessage('');

      print("im in this function fetching all employees");

      final marketId = employee.value.marketId;

      if (marketId.isEmpty) throw "Market ID not available here in all users";

      /// fetch all employees from tags repo
      final employees = await userRepo.getAllEmployees(marketId);
      print("succesfully got employees");

      /// save the employees locally for later use
      allEmployees.assignAll(employees);

    } catch (e) {
      errorMessage(e.toString());
      print("Error occurred: $e");
    } finally {
      isLoading(false);
    }
  }

  /// adds a new employee to the FB
  Future<void> addNewEmployee(UserModel employee) async {
    try {
      isLoading(true);
      errorMessage('');



      // Validate market ID
      if (employee.marketId.isEmpty) {
        throw "Market ID not available";
      }

      // Add employee through repository
      await userRepo.addNewEmployee(employee);

      // Refresh the list
      await fetchAllEmployees();

      Get.snackbar('Sukces', 'Pracownik dodany pomyślnie!');
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', 'Nie udało się dodać pracownika: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }



}