import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:the_basics/data/repositiories/user/user_repo.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import '../../../data/repositiories/user/user_settings_repo.dart';
import '../../../utils/common_widgets/notification_snackbar.dart';
import '../models/user_settings_model.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  Rx<UserModel> employee = UserModel.empty().obs;
  final Rx<SettingsModel?> settings = Rx<SettingsModel?>(null);

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  //final userRepo = Get.put(UserRepo());
  final UserRepo userRepo = Get.find();
  final SettingsRepo _settingsRepo = Get.find();

  final localStorage = GetStorage();

  final RxString searchQuery = ''.obs;

  //create an observable list that will hold all the employee data
  RxList<UserModel> allEmployees = <UserModel>[].obs;

  // we will use this to display emps in the emp manage screen
  final RxList<UserModel> filteredEmployees = <UserModel>[].obs;

  final RxBool isAdmin = false.obs;

  Future<void> initialize() async {
    try {
      isLoading(true);
      final user = await fetchCurrentUserRecord();
      loadSettings();

      await fetchAllEmployees();
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
      //print("Error occurred: $e");
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

      //print("im in this function fetching all employees");

      final marketId = employee.value.marketId;

      if (marketId.isEmpty) throw "Market ID not available here in all users";

      /// fetch all employees from tags repo
      final employees = await userRepo.getAllEmployees(marketId);
      //print("succesfully got employees");

      /// save the employees locally for later use
      allEmployees.assignAll(employees);
      filteredEmployees.assignAll(employees);

    } catch (e) {
      errorMessage(e.toString());
      //print("Error occurred: $e");
    } finally {
      isLoading(false);
    }
  }

  String generateSecurePassword({int length = 12}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }


  Future<String> createNewEmployeeAccount(String email) async {
    String password = generateSecurePassword();
    final cleanEmail = email.trim().toLowerCase();
    final functions = FirebaseFunctions.instanceFor(region: 'europe-central2');

    try {
      final payload = <String, dynamic>{
        "email": cleanEmail,
        "password": password
      };

      dynamic result = await functions.httpsCallable('createAuthUser').call(
          payload);

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: cleanEmail);
      } catch (e) {
        //print('Fallback password reset failed: $e');
        // Non-critical error - still return the UID
      }

      final uid = result.data['uid'];
      return uid;
    } on FirebaseFunctionsException catch (e) {
      //print('Cloud Function error: ${e.code} - ${e.message}');

      String userMessage;
      switch (e.code) {
        case 'already-exists':
          userMessage = 'Konto z tym emailem już istnieje';
          break;
        case 'invalid-argument':
          userMessage = 'Nieprawidłowy format email';
          break;
        default:
          userMessage = 'Błąd tworzenia konta (${e.code})';
      }
      throw userMessage;
    } catch (e) {
      //print('Unexpected error: $e');
      throw 'Wystąpił nieoczekiwany błąd';
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

      if (employee.role.isEmpty) {
        throw "Rola pracownika jest wymagana";
      }

      // this is responisble for creating a new auth account for the emp
      // we call the cloud function to handle the creation
      String authUid = await createNewEmployeeAccount(employee.email);

      final newUserTemp = UserModel(
          id: authUid,
          firstName: '',
          lastName: '',
          email: '',
          marketId: employee.marketId,
          tags: [],
          role: 'employee',
          insertedAt: DateTime.now(),
          updatedAt: DateTime.now()
      );

      final newEmp = employee.copyWith(id: authUid);

      // Add employee through repository
      await userRepo.addNewEmployee(newEmp, newUserTemp);

      // Refresh the list
      await fetchAllEmployees();

      Get.context != null
          ? showCustomSnackbar(Get.context!, 'Pracownik dodany pomyślnie!')
          : null;

    } catch (e) {
      Get.context != null
          ? showCustomSnackbar(Get.context!, 'Błąd: ${e.toString()}')
          : null;
    } finally {
      isLoading(false);
    }
  }

  /// updates the provided employee
  Future<void> updateEmployee(UserModel updatedEmployee) async {
    try {
      //print("oto imie usera ${updatedEmployee.firstName}");
      //print("oto id usera ${updatedEmployee.id}");
      if (updatedEmployee.id.isEmpty) {
        throw 'ID użytkownika jest pusty – nie można wykonać aktualizacji.';
      }
      //print("oto id usera ${updatedEmployee.id}");
      isLoading(true);
      await userRepo.updateUserDetails(updatedEmployee);
      await fetchAllEmployees(); // Refresh the list
      //Get.snackbar('Sukces', 'Pracownik edytowany pomyślnie!');
    } catch (e) {
      Get.snackbar('Error', 'Nie udało się zaktualizować pracownika: ${e.toString()}');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  /// deletes the provided employee
  /// TODO LATER: check whether employee is part of any schedules before deleting
  Future<bool> deleteEmployee(String employeeId, String marketId) async {
    try {
      isLoading(true);
      await userRepo.removeUser(employeeId, marketId);

      await fetchAllEmployees(); // Refresh the list

      //Get.snackbar('Sukces', 'Pracownik usunięty pomyślnie!');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Nie udało się usunąć pracownika: ${e.toString()}');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<UserModel?> getEmployeeById(String userId, String marketId) async {
    try {
      return await userRepo.getUserDetails(userId, marketId);
    } catch (e) {
      Get.snackbar('Error', 'Nie udało się wyłowić pracownika: ${e.toString()}');
      return null;
    }
  }

  Future<String?> getManagerId(String marketId) async {
    try {
      final UserModel? user= await userRepo.getManager(marketId);
      return user?.id;
    } catch (e) {
      Get.snackbar('Error', 'Nie udało się wyłowić pracownika: ${e.toString()}');
      return null;
    }
  }


  /// //////////////////////// ///
  ///    SETTINGS CONTROL    /////
  /// /////////////////////// ///

  /// Load settings from repo
  Future<void> loadSettings() async {
    if (employee.value.id.isEmpty) return;
    try {
      print("here trying");
      final fetchedSettings = await _settingsRepo.getSettings(
        employee.value.id,
        employee.value.marketId,
      );
      print("oura");
      settings.value = fetchedSettings;
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> updateSettings({
    required String field,
    required bool value,
  }) async {
    if (settings.value == null) return;

    // create new settings with updated field
    SettingsModel updated = settings.value!;

    if (field == "newSchedule") {
      updated = settings.value!.copyWith(newSchedule: value);
    } else if (field == "leaveStatus") {
      updated = settings.value!.copyWith(leaveStatus: value);
    } else if (field == "leaveRequests") {
      updated = settings.value!.copyWith(leaveRequests: value);
    }
    try {
      await _settingsRepo.updateSettings(updated, employee.value.marketId);
      settings.value = updated; // update local state
    } catch (e) {
      print('Error updating $field: $e');
    }
  }



  void filterEmployeesByTags(List<String> selectedTags) {
    if (selectedTags.isEmpty) {
      filteredEmployees.assignAll(allEmployees);
      return;
    }

    filteredEmployees.assignAll(allEmployees.where((employee) {
      return selectedTags.every((tag) => employee.tags.contains(tag));
    }).toList());
  }

  void filterEmployees(List<String> selectedTags) {
    final currentQuery = searchQuery.value.trim();

    if (currentQuery.isEmpty && selectedTags.isEmpty) {
      filteredEmployees.assignAll(allEmployees);
      return;
    }

    // we start with all emps
    var results = allEmployees.toList();

    if (selectedTags.isNotEmpty) {
      results = allEmployees.where((employee) =>
          selectedTags.every((tag) => employee.tags.contains(tag))
      ).toList();
    }

    if (currentQuery.isNotEmpty) {
      // rozbijamy na słowa tak aby zapobiec psuciu przez spacje
      final queryWords = currentQuery.toLowerCase().split(' ')
        ..removeWhere((word) => word.isEmpty);

      results = results.where((employee) {
        final firstName = employee.firstName.toLowerCase();
        final lastName = employee.lastName.toLowerCase();
        final email = employee.email.toLowerCase();

        // spawdzamy czy wszystkie słowa zapytania pasują do któregokolwiek pola
        return queryWords.every((word) =>
        firstName.contains(word) ||
            lastName.contains(word) ||
            email.contains(word));
      }).toList();
      }

      filteredEmployees.assignAll(results);
    }

  void resetFilters() {
    searchQuery.value = '';
    filteredEmployees.assignAll(allEmployees);
  }




}