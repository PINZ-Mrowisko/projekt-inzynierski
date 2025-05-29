import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:the_basics/data/repositiories/other/leave_repo.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';

import '../models/leave_model.dart';

/// RULES needed to be assured
/// employee cant take a leave in the past
/// leave duration cant be longer than available days
/// must take into account national holidays and substract them from duration
/// in display, add filtering options to show leave requests from the past, greyed out?


class LeaveController extends GetxController {
  static LeaveController get instance => Get.find();

  final LeaveRepo _leaveRepo = Get.find();
  final userController = Get.find<UserController>();

  final daysCount = TextEditingController();

  final RxList<LeaveModel> allLeaveRequests = <LeaveModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // we will use this to display in the upper section for the manager
  RxList<LeaveModel> get pendingRequests =>
      allLeaveRequests.where((r) => r.status == 'do rozpatrzenia').toList().obs;

  // display historic/ upcoming requests
  RxList<LeaveModel> get reviewedRequests =>
      allLeaveRequests.where((r) => r.status == 'zaakceptowany' || r.status == 'odrzucony').toList().obs;

  /// initialize: fetch all leave requests
  Future<void> initialize() async {
    try {
      isLoading(true);
      await fetchLeaves();
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// fetch all non-deleted leave requests
  Future<void> fetchLeaves() async {
    try {
      isLoading(true);
      errorMessage('');
      final marketId = userController.employee.value.marketId;
      if (marketId.isEmpty) throw 'Brakuje marketId';

      final leaves = await _leaveRepo.getAllLeaveRequests(marketId);
      allLeaveRequests.assignAll(leaves);
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', 'Nie udało się pobrać wniosków: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Save a new leave request
  Future<void> saveLeave(DateTime startDate, DateTime endDate, String leaveType) async {
    try {
      final marketId = userController.employee.value.marketId;

      final leaveId = FirebaseFirestore.instance
          .collection('Markets')
          .doc(marketId)
          .collection('LeaveReq')
          .doc()
          .id;

      final newLeave = LeaveModel(
        id: leaveId,
        marketId: marketId,
        userId: userController.employee.value.id,
        totalDays: 0,
        startDate: startDate, // put actual data into those
        endDate: endDate,
        status: 'do rozpatrzenia',
        insertedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        leaveType: leaveType,
      );

      await _leaveRepo.saveLeave(newLeave);
      await fetchLeaves();
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', 'Nie udało się zapisać wniosku: $e');
    } finally {
      isLoading(false);
    }
  }

  /// update a leave request (np. change status)
  Future<void> updateLeave(LeaveModel updatedLeave) async {
    try {
      isLoading(true);
      await _leaveRepo.updateLeave(updatedLeave);
      await fetchLeaves();
      Get.back(); // Zamknij dialog
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', 'Nie udało się zaktualizować wniosku: $e');
    } finally {
      isLoading(false);
    }
  }

  /// soft delete (set deletedAt)
  Future<void> deleteLeave(String marketId, String leaveId) async {
    try {
      isLoading(true);
      await _leaveRepo.deleteLeave(marketId, leaveId);
      await fetchLeaves();
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', 'Nie udało się usunąć wniosku: $e');
    } finally {
      isLoading(false);
    }
  }
}
