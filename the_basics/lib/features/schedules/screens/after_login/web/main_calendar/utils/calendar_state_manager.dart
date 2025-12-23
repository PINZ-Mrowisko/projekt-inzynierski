import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/schedules/controllers/schedule_controller.dart';

import '../../../../../../auth/models/user_model.dart';

class CalendarStateManager {
  final RxBool isLoading = false.obs;
  final RxBool isScheduleLoading = false.obs;
  final RxBool areEmployeesLoaded = false.obs; // controll the flow in controllers
  final RxList<String> selectedTags = <String>[].obs;

  UserController get _userController => Get.find<UserController>();
  SchedulesController get _scheduleController => Get.find<SchedulesController>();

  RxList<UserModel> get filteredEmployees => _userController.filteredEmployees;

  Future<void> initialize() async {
    final userController = Get.find<UserController>();

    if (userController.allEmployees.isEmpty) {
      await userController.fetchAllEmployees();
    }

    areEmployeesLoaded.value = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userController.resetFilters();
    });

    ever(selectedTags, (tags) {
      _userController.filterEmployees(tags);
    });
  }

  Future<void> loadSchedule({
    required String marketId,
    required String scheduleId,
  }) async {
    try {
      isScheduleLoading.value = true;
      await _scheduleController.fetchAndParseGeneratedSchedule(
        marketId: marketId,
        scheduleId: scheduleId,
      );
    } catch (e) {
      Get.snackbar('Błąd', 'Nie udało się załadować grafiku');
    } finally {
      isScheduleLoading.value = false;
    }
  }

  void updateSelectedTags(List<String> selected) {
    selectedTags.assignAll(selected);
  }

  void dispose() {
    isLoading.close();
    isScheduleLoading.close();
    selectedTags.close();
  }
}