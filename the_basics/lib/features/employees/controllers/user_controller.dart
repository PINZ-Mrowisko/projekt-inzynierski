import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:the_basics/data/repositiories/user/user_repo.dart';
import 'package:the_basics/features/auth/models/user_model.dart';

import '../../../data/repositiories/auth/auth_repo.dart';

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

      //print("im in this function fetching all employees");

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

  String generateSecurePassword({int length = 12}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()-_=+';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }


  Future<String> createNewEmployeeAccount(String email) async {
    // after adding the employee to the user list + market members, we also need to allow them to authenticate
    // we will do it through email+pswd auth

    String pswd = generateSecurePassword();

    // new user gets created - hopefully
    final userCred = await AuthRepo.instance.registerWithEmailAndPassword(email, pswd);

    // Optionally send password reset email here
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

    print("Created auth account for $email and sent reset email");

    //TODO add some sort of check if user with same email exists already?

    return userCred.user!.uid;
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

      //Get.snackbar('Sukces', 'Pracownik dodany pomyślnie!');
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', 'Nie udało się dodać pracownika: ${e.toString()}');
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
      Get.snackbar('Sukces', 'Pracownik edytowany pomyślnie!');
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



}