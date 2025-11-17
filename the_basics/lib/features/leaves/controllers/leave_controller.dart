import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
  final RxList<LeaveModel> filteredLeaves = <LeaveModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // we will use this to display in the upper section for the manager
  RxList<LeaveModel> get pendingRequests =>
      allLeaveRequests.where((r) => r.status == 'Oczekujący').toList().obs;

  // display historic/ upcoming requests
  RxList<LeaveModel> get acceptedRequests =>
      allLeaveRequests.where((r) => r.status == 'Zaakceptowany' || r.status == 'Mój urlop').toList().obs;

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

  // will use during sorting
  int _statusPriority(String status) {
    switch (status) {
      case 'Oczekujący':
        return 0;
      case 'Zaakceptowany':
      case 'Mój urlop':
        return 1;
      default:
        return 2;
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

      final nonDeletedEmpIds = userController.allEmployees
          .where((emp) => !emp.isDeleted)
          .map((emp) => emp.id)
          .toSet();

      // get only the leaves of emps that arent deleted
      final validLeaves = leaves.where((leave) => nonDeletedEmpIds.contains(leave.userId)).toList();

      // new sorting logic - show leaves that are closest to now() at top, descending further in the future
      // at the bottom show leaves that are from the past - maybe we can mark them somehow
      // for example pull leaves from only last past month + future to minimize the num stored in controller
      validLeaves.sort((a, b) {
        final now = DateTime.now();

        // Status priority first
        final statusCompare = _statusPriority(a.status).compareTo(_statusPriority(b.status));
        if (statusCompare != 0) return statusCompare;

        // check if leave is current - started but not ended
        final aIsActive = a.startDate.isBefore(now) && a.endDate.isAfter(now);
        final bIsActive = b.startDate.isBefore(now) && b.endDate.isAfter(now);

        // check if leave is future
        final aIsFuture = a.startDate.isAfter(now);
        final bIsFuture = b.startDate.isAfter(now);

        // check if leave is past
        final aIsPast = a.endDate.isBefore(now);
        final bIsPast = b.endDate.isBefore(now);

        //  active leaves > future leaves > past leaves
        if (aIsActive && !bIsActive) return -1;
        if (!aIsActive && bIsActive) return 1;

        if (aIsFuture && bIsPast) return -1;
        if (aIsPast && bIsFuture) return 1;

        if (aIsFuture && bIsFuture) {
          return a.startDate.compareTo(b.startDate); // future: earlier dates first
        } else if (aIsPast && bIsPast) {
          return b.startDate.compareTo(a.startDate); // past: more recent first
        } else {
          return a.startDate.compareTo(b.startDate); // active: earlier starts first
        }
      });


      allLeaveRequests.assignAll(validLeaves);
      filteredLeaves.assignAll(validLeaves);

      acceptedRequests.assignAll(
      allLeaveRequests.where((r) => r.status == 'Zaakceptowany' || r.status == 'Mój urlop').toList().obs);


    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', 'Nie udało się pobrać wniosków: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Save a new leave request - KIEROWNIK
  Future<void> saveLeave(DateTime startDate, DateTime endDate, String status, int requestedDays, String? comment) async {
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
        comment: comment
      );

      await _leaveRepo.saveLeave(newLeave);
      await fetchLeaves();

      // bedziemy liczyc liczbe dni nieobecnosci, zaczynajac od 0 - mozna resetowac np na poczatku roku

      // if status = urlop kierownika
      if (status == 'Mój urlop') {

        // teraz nie rozrozniamy typow urlopow po prostu dodajemy liczbe requested days do liczby nieobecnosci
        userController.updateEmployee(
          userController.employee.value.copyWith(
            numberOfLeaves: userController.employee.value.numberOfLeaves + requestedDays
          )
        );

      }

    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Błąd', 'Nie udało się zapisać wniosku: $e');
    } finally {
      isLoading(false);
    }
  }


  /// FOR EMPLOYEEEES
  Future<void> saveEmpLeave(DateTime startDate, DateTime endDate, String status, int requestedDays, String? comment) async {
    try {
      final marketId = userController.employee.value.marketId;
      final requestedDays = endDate.difference(startDate).inDays + 1;

      final managerID = await userController.getManagerId(marketId);

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
        comment: comment,
        managerId: managerID
      );

      await _leaveRepo.saveLeave(newLeave);
      await fetchLeaves();

      /// we don't substract the holiday days just yet - only when the Manager accepts the request?
      ///
      /// or maybe its better to substract now, and then add them back if the request is denied ?????
      /// vote today for your favorite option
      ///
      /// NEW: lets add the leave days now, substract if kierownik denies
      userController.updateEmployee(
                 userController.employee.value.copyWith(
                   numberOfLeaves: userController.employee.value.numberOfLeaves + requestedDays,
                 )
               );


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
    // Normalizujemy daty do postaci bez czasu
    final normalizeDate = (DateTime date) => DateTime(date.year, date.month, date.day);
    final newStart = normalizeDate(startDate);
    final newEnd = normalizeDate(endDate);

    for (final leave in allLeaveRequests) {
      if (leave.userId == userId) {
        final leaveStart = normalizeDate(leave.startDate);
        final leaveEnd = normalizeDate(leave.endDate);

        // Sprawdzamy wszystkie możliwe przypadki nakładania się zakresów jakie sobie dacie rade wymyslic
        final hasOverlap = !(newEnd.isBefore(leaveStart) || newStart.isAfter(leaveEnd));

        if (hasOverlap) {
          return leave;
        }
      }
    }
    return null;
  }

  void filterLeaves(List<String> selectedEmps, List<String> selectedStatuses) {

    if (selectedEmps.isEmpty && selectedStatuses.isEmpty) {
      filteredLeaves.assignAll(allLeaveRequests);
      return;
    }

    var results = allLeaveRequests.toList();

    if (selectedStatuses.isNotEmpty) {
      results = allLeaveRequests.where((request) =>
          selectedStatuses.contains(request.status)).toList();
    }

    if (selectedEmps.isNotEmpty) {
      results = results.where((request) {
        final employee = userController.allEmployees.firstWhereOrNull(
                (e) => e.id == request.userId
        );
        return employee != null && selectedEmps.contains(
            '${employee.firstName} ${employee.lastName}'
        );
      }).toList();
    }

    filteredLeaves.assignAll(results);

  }

  void resetFilters() {
    filteredLeaves.assignAll(allLeaveRequests);
  }

}
