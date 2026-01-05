import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../features/schedules/models/schedule_doc_model.dart';
import '../exceptions.dart';

class ScheduleRepo extends GetxController {
  static ScheduleRepo get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;


  /// cały dokument grafiku, łącznie z polami u góry + mapa generated_shifts która zamieniamy na listę schedule models
  Future<ScheduleDocumentModel?> getScheduleDocument({
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
        return ScheduleDocumentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching schedule document: $e');
      return null;
    }
  }

  /// used in controller to grab a specific schedule by ID
  /// this returns a raw map -> teoretycznie również tu siedzi ta górna część schedule, ale tej metody uzywam w kontrolerze aby z mapy pobrac sobie "generated_schedules"
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


  /// saves the whole big schedule (so general data + Map "generated_schedules"
  Future<void> saveScheduleDocument(ScheduleDocumentModel doc, String marketId) async {
    try {
      final scheduleRef = _db
          .collection("Markets")
          .doc(marketId)
          .collection("Schedules")
          .doc();

      await scheduleRef.set({
        ...doc.toFirestore(),
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

  Future<ScheduleDocumentModel?> updateSchedule({
    required String marketId,
    required String scheduleId,
    required Map<String, dynamic> generatedSchedule
  }) async {
    try {
      await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Schedules')
          .doc(scheduleId)
          .update({
        'generated_schedule': generatedSchedule
      });

      return null;
    } catch (e) {
      print('Error fetching schedule document: $e');
      return null;
    }
  }


  ///  pobierz ID aktualnie opublikowanego grafiku
  ///  chwilowo jest to bardzo simplified - tylko jeden grafik moze byc opublikowany w tym samym czasie
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
  /// this works with our
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