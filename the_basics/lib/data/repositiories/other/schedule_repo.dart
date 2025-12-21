import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../features/schedules/models/schedule_doc_model.dart';
import '../../../features/schedules/models/schedule_model.dart';
import '../../../features/templates/models/template_model.dart';
import '../exceptions.dart';

class ScheduleRepo extends GetxController {
  static ScheduleRepo get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;


  Future<void> saveSchedule(ScheduleModel shift, String marketId) async {
    try {
      final scheduleRef = _db
          .collection("Markets")
          .doc(marketId)
          .collection("Schedules")
          .doc();

      await scheduleRef.set({
        ...shift.toMap(),
        'id': scheduleRef.id,
      });
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (_) {
      throw 'Coś poszło nie tak przy zapisie zmiany :(';
    }
  }

  /// get all schedules for a given market
  Future<List<ScheduleModel>> getAllSchedules(String marketId) async {
    try {
      final snapshot = await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Schedules')
          .where('isDeleted', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs
          .map((e) => ScheduleModel.fromSnapshot(e))
          .toList();
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (_) {
      throw 'Coś poszło nie tak przy pobieraniu grafików :(';
    }
  }


  /// get shifts for a specific employee - we will use this in the individual view
  Future<List<ScheduleModel>> getSchedulesByEmployee(
      String marketId,
      String employeeId
      ) async {
    try {
      final snapshot = await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Schedules')
          .where('employeeID', isEqualTo: employeeId)
          .where('isDeleted', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs
          .map((e) => ScheduleModel.fromSnapshot(e))
          .toList();
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (e) {
      throw 'Nie udało się pobrać grafików pracownika: ${e.toString()}';
    }
  }

  /// cały dokument grafiku, łącznie z polami u góry
  Future<ScheduleDocument?> getScheduleDocument({
    required String marketId,
    required String scheduleId,
  }) async {
    try {
      final doc = await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Schedules')
          .doc(scheduleId)
          .get();

      if (doc.exists) {
        return ScheduleDocument.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching schedule document: $e');
      return null;
    }
  }

  ///  pobierz aktualnie opublikowane grafik
  ///  chwilowo jest to bardzo simplified - tylko jeden grafik moze byc opublikowany w tym samym czasie
  ///  pobieramy juz tą część generated_schedule - nie trzeba nam reszty

  Future<String?> getPublishedScheduleID(String marketId) async {
    try {
      final query = await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Schedules')
          .where('isCurrentlyPublished', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final scheduleId = query.docs.first.id;
        return scheduleId;
      }
      return null;
    } catch (e) {
      print('Error fetching published schedule: $e');
      return null;
    }
  }


  /// Unpublish wszystkie inne grafiki
  Future<void> unpublishOtherSchedules({
    required String marketId,
    required String currentScheduleId,
  }) async {
    try {
      final query = await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Schedules')
          .where('isCurrentlyPublished', isEqualTo: true)
          .get();

      final batch = _db.batch();

      for (final doc in query.docs) {
        if (doc.id != currentScheduleId) {
          batch.update(doc.reference, {
            'isCurrentlyPublished': false,
            'unpublishedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (query.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      print('Error unpublishing schedules: $e');
      rethrow;
    }
  }


  // Aktualizuj flagę publikacji
  Future<void> updatePublishStatus({
    required String marketId,
    required String scheduleId,
    required bool isPublished,
  }) async {
    await _db
        .collection('Markets')
        .doc(marketId)
        .collection('Schedules')
        .doc(scheduleId)
        .update({
      'isCurrentlyPublished': isPublished,
      'publishedAt': isPublished ? FieldValue.serverTimestamp() : null,
    });
  }


  Future<Map<String, dynamic>?> getGeneratedScheduleById({
    required String marketId,
    required String scheduleId,
  }) async {
    try {
      final doc = await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Schedules')
          .doc(scheduleId)
          .get();

      if (doc.exists) {
        final data = doc.data();

        return {
          'id': doc.id,
          ...data!,
        };
      }
      return null;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Nie udało się pobrać wygenerowanego grafiku: ${e.toString()}';
    }
  }


  /// update schedule data - can be used for editing later with drag and drop
  Future<void> updateSchedule(ScheduleModel schedule, String scheduleId, String marketId) async {
    try {
      await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Schedules')
          .doc(scheduleId)
          .update(schedule.toMap());
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (e) {
      throw 'Nie udało się zaktualizować grafiku: ${e.toString()}';
    }
  }

  /// soft delete a schedule (mark as deleted)
  Future<void> softDeleteSchedule({
    required String marketId,
    required String scheduleId,
  }) async {
    try {
      await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Schedules')
          .doc(scheduleId)
          .update({
        'isDeleted': true,
        'deletedAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (e) {
      throw 'Nie udało się oznaczyć grafiku jako usuniętego: ${e.toString()}';
    }
  }

}