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

  List<ScheduleModel> _originalShiftsSnapshot = [];

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

  /// UPDATED
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
        final dateShifts = entry.value as List<dynamic>?; // now LIST of assignments

        if (dateShifts == null || dateShifts.isEmpty) {
          print('No shifts found for date $dateString');
          continue;
        }

        // extract each shift data
        for (final shiftData in dateShifts) {
          if (shiftData is! Map<String, dynamic>) {
            print('Shift data is not a Map, type: ${shiftData.runtimeType}');
            continue;
          }

          final assignments = shiftData['assignments'] as List<dynamic>? ?? [];
          final startStr = shiftData['start'] as String? ?? '00:00';
          final endStr = shiftData['end'] as String? ?? '00:00';
          final duration = (shiftData['duration'] as num?)?.toDouble() ?? 0.0;

          final startTime = _parseTimeOfDay(startStr);
          final endTime = _parseTimeOfDay(endStr);

          // for every assignment in assignments list
          for (final assignment in assignments) {
            if (assignment is! Map<String, dynamic>) {
              print('Assignment is not a Map, type: ${assignment.runtimeType}');
              continue;
            }

            final shift = ScheduleModel(
              shiftDate: DateTime.parse(dateString),
              employeeID: assignment['workerId'] as String? ?? '',
              employeeFirstName: assignment['firstName'] as String? ?? '',
              employeeLastName: assignment['lastName'] as String? ?? '',
              start: startTime,
              end: endTime,
              duration: duration.toInt(),
              tags: List<String>.from(assignment['tags'] as List<dynamic>? ?? []),
              isDataMissing: false,
              isDeleted: false,
              insertedAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            parsedShifts.add(shift);
          }
        }
      }

      // sort by date
      parsedShifts.sort((a, b) => a.shiftDate.compareTo(b.shiftDate));

      _originalShiftsSnapshot = List.from(parsedShifts);

      individualShifts.assignAll(parsedShifts);

      print('[DEBUG] Successfully parsed ${parsedShifts.length} shifts');

    } catch (e) {
      errorMessage.value = 'Failed to load schedule: $e';
      Get.snackbar('Error', 'Failed to load schedule: ${e.toString()}');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  void createLocalSnapshot() {
    // Tworzymy kopię aktualnej listy jako punkt odniesienia
    _originalShiftsSnapshot = List.from(individualShifts);
    print('Utworzono snapshot: ${_originalShiftsSnapshot.length} zmian');
  }

// 2. Upewnij się, że discardLocalChanges wygląda tak (już ją masz, ale dla pewności):
  void discardLocalChanges() {
    if (_originalShiftsSnapshot.isNotEmpty) {
      individualShifts.assignAll(_originalShiftsSnapshot);
    } else {
      // Fallback: jeśli snapshot pusty, a coś było na liście, to czyścimy,
      // ale lepiej żeby snapshot był utworzony przy wejściu.
      if(individualShifts.isNotEmpty) individualShifts.clear();
    }
  }
  
  /// UPDATED
  /// convert list of ScheduleModel shifts back into generated_schedule Map format
  Map<String, dynamic> convertShiftsToGeneratedSchedule(List<ScheduleModel> shifts) {
    final Map<String, List<Map<String, dynamic>>> scheduleByDate = {};

    for (final shift in shifts) {
      final dateKey = '${shift.shiftDate.year}-${shift.shiftDate.month.toString().padLeft(2, '0')}-${shift.shiftDate.day.toString().padLeft(2, '0')}';

      // find if this shift time already exists for the date
      final existingShiftIndex = scheduleByDate[dateKey]?.indexWhere((s) => 
        s['start'] == '${shift.start.hour.toString().padLeft(2, '0')}:${shift.start.minute.toString().padLeft(2, '0')}' &&
        s['end'] == '${shift.end.hour.toString().padLeft(2, '0')}:${shift.end.minute.toString().padLeft(2, '0')}'
      );

      if (existingShiftIndex != null && existingShiftIndex >= 0) {
        // add to existing shift
        final assignment = {
          'workerId': shift.employeeID,
          'firstName': shift.employeeFirstName,
          'lastName': shift.employeeLastName,
          'tags': shift.tags,
        };
        scheduleByDate[dateKey]![existingShiftIndex]['assignments'].add(assignment);
      } else {
        // create new shift entry
        if (!scheduleByDate.containsKey(dateKey)) {
          scheduleByDate[dateKey] = [];
        }

        final newShift = {
          'start': '${shift.start.hour.toString().padLeft(2, '0')}:${shift.start.minute.toString().padLeft(2, '0')}',
          'end': '${shift.end.hour.toString().padLeft(2, '0')}:${shift.end.minute.toString().padLeft(2, '0')}',
          'assignments': [
            {
              'workerId': shift.employeeID,
              'firstName': shift.employeeFirstName,
              'lastName': shift.employeeLastName,
              'tags': shift.tags,
            }
          ],
          'duration': shift.duration,
          'date': dateKey,
          'day': _getDayName(shift.shiftDate),
        };

        scheduleByDate[dateKey]!.add(newShift);
      }
    }

    return scheduleByDate;
  }

  /// helper to get day name from DateTime
  String _getDayName(DateTime date) {
    const dayNames = ['Poniedziałek', 'Wtorek', 'Środa', 'Czwartek', 'Piątek', 'Sobota', 'Niedziela'];
    return dayNames[date.weekday - 1];
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
      _originalShiftsSnapshot = List.from(updatedShifts);

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

  // Dodaj te metody wewnątrz klasy SchedulesController

  /// Dodaj nową zmianę do lokalnej listy
  void addLocalShift(ScheduleModel newShift) {
    individualShifts.add(newShift);
    individualShifts.refresh(); // Wymusza odświeżenie GetX
  }

  /// Zaktualizuj istniejącą zmianę
  void updateLocalShift(ScheduleModel oldShift, ScheduleModel updatedShift) {
    final index = individualShifts.indexOf(oldShift);
    if (index != -1) {
      individualShifts[index] = updatedShift;
      individualShifts.refresh();
    }
  }

  /// Usuń zmianę z lokalnej listy
  void deleteLocalShift(ScheduleModel shift) {
    individualShifts.remove(shift);
    individualShifts.refresh();
  }
}