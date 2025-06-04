import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:the_basics/data/repositiories/other/leave_repo.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';

import '../models/holiday_model.dart';
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
  final RxList<Holiday> holidays = <Holiday>[].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // we will use this to display in the upper section for the manager
  RxList<LeaveModel> get pendingRequests =>
      allLeaveRequests.where((r) => r.status == 'oczekujący').toList().obs;

  // display historic/ upcoming requests
  RxList<LeaveModel> get acceptedRequests =>
      allLeaveRequests.where((r) => r.status == 'zaakceptowany' || r.status == 'mój urlop').toList().obs;

  /// initialize: fetch all leave requests
  Future<void> initialize() async {
    try {
      isLoading(true);
      await fetchLeaves();
      await loadHolidays();
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

  /// Save a new leave request - KIEROWNIK
  Future<void> saveLeave(DateTime startDate, DateTime endDate, String leaveType, String status, int requestedDays) async {
    try {
      // maybe add looking for overlap here as well

      final marketId = userController.employee.value.marketId;

      final leaveId = FirebaseFirestore.instance
          .collection('Markets')
          .doc(marketId)
          .collection('LeaveReq')
          .doc()
          .id;

      final newLeave = LeaveModel(
        id: leaveId,
        name: '${userController.employee.value.firstName} ${userController.employee.value.lastName}',
        marketId: marketId,
        userId: userController.employee.value.id,
        totalDays: requestedDays,
        startDate: startDate,
        endDate: endDate,
        status: status,
        insertedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        leaveType: leaveType,
      );

      await _leaveRepo.saveLeave(newLeave);
      await fetchLeaves();

      // jako że kierownik nie potrzebuje zatwierdzania - odejmujemy mu od razu dni od licznika
      if (status == 'mój urlop') {
        if (leaveType == 'Urlop na żądanie') {
            userController.updateEmployee(
              userController.employee.value.copyWith(
                onDemandDays: userController.employee.value.onDemandDays - requestedDays,
              ),
            );
          } else {
            userController.updateEmployee(
              userController.employee.value.copyWith(
                vacationDays: userController.employee.value.vacationDays - requestedDays,
              ),
            );
          }
      }

    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', 'Nie udało się zapisać wniosku: $e');
    } finally {
      isLoading(false);
    }
  }


  /// FOR EMPLOYEEEES
  Future<void> saveEmpLeave(DateTime startDate, DateTime endDate, String leaveType, String status) async {
    try {
      final marketId = userController.employee.value.marketId;
      final requestedDays = endDate.difference(startDate).inDays + 1;

      final leaveId = FirebaseFirestore.instance
          .collection('Markets')
          .doc(marketId)
          .collection('LeaveReq')
          .doc()
          .id;

      final newLeave = LeaveModel(
        id: leaveId,
        name: '${userController.employee.value.firstName} ${userController.employee.value.lastName}',
        marketId: marketId,
        userId: userController.employee.value.id,
        totalDays: 0,
        startDate: startDate,
        endDate: endDate,
        status: status,
        insertedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        leaveType: leaveType,
      );

      await _leaveRepo.saveLeave(newLeave);
      await fetchLeaves();

      /// we don't substract the holiday days just yet - only when the Manager accepts the request?
      ///
      /// or maybe its better to substract now, and then add them back if the request is denied ?????
      /// vote today for your favorite option
      ///
      if (leaveType == 'Urlop na żądanie') {
        userController.updateEmployee(
          userController.employee.value.copyWith(
            onDemandDays: userController.employee.value.onDemandDays - requestedDays,
          ),
        );
      } else {
        userController.updateEmployee(
          userController.employee.value.copyWith(
            vacationDays: userController.employee.value.vacationDays - requestedDays,
          ),
        );
      }

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
      //Get.back(); // Zamknij dialog
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

  // loads all available Holidays into the list, so we can use them during leave planning
  Future<void> loadHolidays() async {
    final snapshot = await FirebaseFirestore.instance.collection('Holidays').get();
    holidays.assignAll( snapshot.docs.map((e) => Holiday.fromFirestore(e)).toList());
  }


  // looks for conflicts while date validating in leave requests
  LeaveModel? getOverlappingLeave(DateTime startDate, DateTime endDate, String userId) {
    for (final leave in acceptedRequests) {
      if (leave.userId == userId) {
        final leaveStart = leave.startDate;
        final leaveEnd = leave.endDate;

        if ((startDate.isBefore(leaveEnd) && endDate.isAfter(leaveStart))) {
          return leave;
        }
      }
    }
    return null;
  }
}
