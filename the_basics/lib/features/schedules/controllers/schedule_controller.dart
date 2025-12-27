import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../data/repositiories/other/schedule_repo.dart';
import '../../employees/controllers/user_controller.dart';
import '../models/schedule_model.dart';


/// possible issues with the complexity of schedule controller
/// because of the build of Firebase Files, there is a divide between ScheduleModel and ScheduleDocModel
/// our controller (this one) keeps a list of scheduleModels - those are singular "shifts", containing day, worker, start, end, etc. - this is the Schedule Model
/// the ScheduleDoc Model contains the general info about the schedule - creator, creation date, year, month of use etc.
/// In Firebase each ScheduleDoc contains a map "generated_schedules" - that is the transformed list of ScheduleModels
/// when updating, editing the schedule in the App we will need to save the WHOLE scheduleDocModel
/// so the basic data fields + SheduleModels mapped back into "generated_schedules" map

/// please use the method : convertShiftsToGeneratedSchedule() to get : List of Shedule Models -> Map
/// use method: fetchAndParseGeneratedSchedule() to get : Map -> List of Shedule Models



class SchedulesController extends GetxController {
  static SchedulesController get instance => Get.find();

  final ScheduleRepo _scheduleRepo = Get.find();

  RxList<ScheduleModel> individualShifts = <ScheduleModel>[].obs;

  // when editing the shedule, we can mayhaps use this ?
  RxList<ScheduleModel> updatedShifts = <ScheduleModel>[].obs;

  RxMap<String, dynamic> rawScheduleData = <String, dynamic>{}.obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // displayed ID is changed for editing, to temporarily changed view schedule
  final RxString displayedScheduleID = ''.obs;
  final RxString publishedScheduleID = ''.obs;

  Future<void> initialize() async {
    try {
      isLoading(true);

      final userController = Get.find<UserController>();
      final marketId = userController.employee.value.marketId;

      if (marketId.isEmpty) {
        return;
      }

      // 1. opublikowany grafik - chwilowo tylko 1 mozliwy
      // pobieramy jego ID, aby następnie móc go sobie pobierać
      final ID = await _scheduleRepo.getPublishedScheduleID(marketId);

      if (ID != null) {
        publishedScheduleID.value = ID;
        displayedScheduleID.value = ID;


        // 2. ładujemy do kontrolera
        await fetchAndParseGeneratedSchedule(
          marketId: marketId,
          scheduleId: ID,
        );
      } else {
        print('Brak opublikowanego grafiku');
      }

    } catch (e) {
    } finally {
      isLoading(false);
    }
  }

  /// fetch and parse a generated schedule into individual shifts
  /// this current logic implies 1 month being kept at all times in the controller
  /// we could in theory load all published Months, but that needs to be discussed
  Future<void> fetchAndParseGeneratedSchedule({
    required String marketId,
    required String scheduleId,
  }) async {
    try {
      isLoading(true);
      errorMessage('');
      individualShifts.clear();
      rawScheduleData.clear();


      // fetch raw schedule data
      final scheduleData = await _scheduleRepo.getGeneratedScheduleById(
        marketId: marketId,
        scheduleId: scheduleId,
      );

      if (scheduleData == null) {
        errorMessage.value = 'Schedule not found';
        return;
      }


      // raw data for metadata display
      rawScheduleData.addAll(scheduleData);

      final generatedSchedule = scheduleData['generated_schedule'] as Map<String, dynamic>?;



      if (generatedSchedule == null || generatedSchedule.isEmpty) {
        errorMessage.value = 'No generated schedule data found';
        return;
      }

      // parse each date entry into individual ScheduleModel objects
      final List<ScheduleModel> parsedShifts = [];

      for (final entry in generatedSchedule.entries) {
        final dateString = entry.key;
        final dateData = entry.value as Map<String, dynamic>;



        // extract assignments for this date
        final assignments = dateData['assignments'] as List<dynamic>? ?? [];


        if (assignments.isNotEmpty) {
          final startStr = dateData['start'] as String? ?? '00:00';
          final endStr = dateData['end'] as String? ?? '00:00';

          final startTime = _parseTimeOfDay(startStr);
          final endTime = _parseTimeOfDay(endStr);

          for (int i = 0; i < assignments.length; i++) {
            final assignment = assignments[i];

            if (assignment is Map<String, dynamic>) {
              final assignmentMap = assignment;

              final shift = ScheduleModel(
                shiftDate: DateTime.parse(dateString),
                employeeID: assignmentMap['workerId'] as String? ?? '',
                employeeFirstName: assignmentMap['firstName'] as String? ?? '',
                employeeLastName: assignmentMap['lastName'] as String? ?? '',
                start: startTime,
                end: endTime,
                duration: (dateData['duration'] as num?)?.toInt() ?? 0,
                tags: List<String>.from(assignmentMap['tags'] as List<dynamic>? ?? []),
                isDataMissing: false,
                isDeleted: false,
                insertedAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              parsedShifts.add(shift);
            } else {
              print('Assignment $i is not a Map, type: ${assignment.runtimeType}');
            }
          }
        } else {
          print('No assignments found for date $dateString');
        }
      }

      // sort by date
      parsedShifts.sort((a, b) => a.shiftDate.compareTo(b.shiftDate));

      individualShifts.assignAll(parsedShifts);


    } catch (e) {
      errorMessage.value = 'Failed to load schedule: $e';
      Get.snackbar('Error', 'Failed to load schedule: ${e.toString()}');
      rethrow;
    } finally {
      isLoading(false);
    }
  }


  /// parse : individual shifts back to generated_schedules Map
  /// changes List of ScheduleModels -> Map ready to be saved in FB
  Map<String, dynamic> convertShiftsToGeneratedSchedule(List<ScheduleModel> shifts) {
    final Map<String, Map<String, dynamic>> scheduleByDate = {};

    for (final shift in shifts) {
      final dateKey = '${shift.shiftDate.year}-${shift.shiftDate.month.toString().padLeft(2, '0')}-${shift.shiftDate.day.toString().padLeft(2, '0')}';

      if (!scheduleByDate.containsKey(dateKey)) {
        scheduleByDate[dateKey] = {
          'start': '${shift.start.hour.toString().padLeft(2, '0')}:${shift.start.minute.toString().padLeft(2, '0')}',
          'end': '${shift.end.hour.toString().padLeft(2, '0')}:${shift.end.minute.toString().padLeft(2, '0')}',
          'assignments': [],
          'duration': shift.duration
        };
      }

      final assignment = {
        'workerId': shift.employeeID,
        'firstName': shift.employeeFirstName,
        'lastName': shift.employeeLastName,
        'tags': shift.tags,

      };

      scheduleByDate[dateKey]!['assignments'].add(assignment);
    }

    return scheduleByDate;
  }


  // zapis zaktualizowanego grafiku - chwilowo tylko czesc generated_schedules, ale mozna rownie dobrze dorobic całosc
  // a więc tu aktualizujemy zarówną główną część Shedule + opcjonalnie generated_shifts mapę

  Future<void> saveUpdatedScheduleDocument({
    required String marketId,
    required String scheduleId,
    required List<ScheduleModel> updatedShifts,
  }) async {
    try {

      // convert modified shifts into new Map list
      final generatedSchedule = convertShiftsToGeneratedSchedule(updatedShifts);

      // call method from Repo rewriting all changes
      await _scheduleRepo.updateSchedule(marketId: marketId, scheduleId: scheduleId, generatedSchedule: generatedSchedule);

      // and lastly update local state
      individualShifts.assignAll(updatedShifts);

      Get.snackbar('Sukces', 'Grafik zapisany');
    } catch (e) {
      Get.snackbar('Błąd', 'Nie udało się zapisać: $e');
      rethrow;
    }
  }

  Future<void> publishSchedule({
    required String marketId,
    required String scheduleId,
  }) async {
    try {
      isLoading(true);

      // mark all other schedules as unpublished
      await _scheduleRepo.unpublishOtherSchedules(marketId: marketId, currentScheduleId: scheduleId);

      // modify currently published status

      await _scheduleRepo.updatePublishStatus(
        marketId: marketId,
        scheduleId: scheduleId,
        isPublished: true,
      );

      // fetch specified schedule as main
      await fetchAndParseGeneratedSchedule(
        marketId: marketId,
        scheduleId: scheduleId,
      );

      // set displayed schedule as new
      publishedScheduleID.value = scheduleId;
      displayedScheduleID.value = scheduleId;


    } catch (e) {
      Get.snackbar('Błąd', 'Nie udało się opublikować: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }


  /// wywolanie algorytmu dla wybranego templatu
  Future<String> generateScheduleFromTemplate({
    required String templateId,
    required String marketId,
  }) async {
    try {
      isLoading(true);
      errorMessage('');

      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      if (idToken == null) {
        throw Exception('Brak autoryzacji - użytkownik nie jest zalogowany');
      }

      // wykonujemy request - z tego co rozumiem nie mozemy tu pobrac w jakikolwiek sposob generated schedule ID

      final response = await http.get(
        Uri.parse('https://scheduling-algorithm-166365589002.europe-central2.run.app/run-algorithmv2/$templateId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      // print('status odpowiedzi: ${response.statusCode}');
      // print('body: ${response.body}');

      if (response.statusCode == 200) {

        // we find the ID of the newly generated schedule
        final scheduleId = await _fetchLatestGeneratedScheduleId(
          marketId: marketId,
          templateId: templateId,
        );

        if (scheduleId.isEmpty) {
          throw Exception('Nie znaleziono wygenerowanego grafiku w bazie');
        }
        // and return it back to our method
        return scheduleId;
      }

      return 'ugh';

      } catch (e) {
      errorMessage.value = 'Błąd generowania: $e';
      rethrow;
    } finally {
      isLoading(false);
    }
  }


  /// pobierz ID najnowszego wygenerowanego grafiku dla template
  /// ta metoda dziala tylko jak znajdzie sie rozwiazanie  - bo wtedy jest template ID
  Future<String> _fetchLatestGeneratedScheduleId({
    required String marketId,
    required String templateId,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;


      final querySnapshot = await firestore
          .collection('Markets')
          .doc(marketId)
          .collection('Schedules')
          .where('templateUsed', isEqualTo: templateId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return '';
      }

      final latestDoc = querySnapshot.docs.first;
      final scheduleId = latestDoc.id;

      return scheduleId;

    } catch (e) {
      print('Błąd pobierania grafiku: $e');
      return '';
    }
  }


  /// helper to parse time string to TimeOfDay
  TimeOfDay _parseTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      print('Error parsing time: $timeString');
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  /// get shifts for a specific employee
  List<ScheduleModel> getShiftsForEmployee(String employeeId) {
    return individualShifts
        .where((shift) => shift.employeeID == employeeId)
        .toList();
  }

  Future<void> clearController() async {
    isLoading(true);
    individualShifts.clear();
    errorMessage.value = '';
    isLoading(false);
  }
}