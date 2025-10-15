import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../features/templates/models/template_model.dart';
import '../../../features/templates/models/template_shift_model.dart';
import '../exceptions.dart';

class TemplateRepo extends GetxController {
  static TemplateRepo get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// save a new template under a market
  /// the file structure is like: markets - templates -> inside templates we have general template data and also shifts subcollection
  Future<void> saveTemplate(TemplateModel template) async {
    try {
      await _db
          .collection("Markets")
          .doc(template.marketId)
          .collection("Templates")
          .doc(template.id)
          .set(template.toMap());
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (_) {
      throw 'Coś poszło nie tak przy zapisie szablonu :(';
    }
  }

  /// save all shifts connected to a template
  Future<void> saveShift(String marketId, String templateId, ShiftModel shift) async {
    try {
      await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Templates')
          .doc(templateId)
          .collection('Shifts')
          .doc(shift.id)
          .set(shift.toMap());
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (e) {
      throw 'Nie udało się zapisać zmiany: $e';
    }
  }


  /// get all templates for a given market
  Future<List<TemplateModel>> getAllTemplates(String marketId) async {
    try {
      final snapshot = await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Templates')
          .where('isDeleted', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs
          .map((e) => TemplateModel.fromSnapshot(e))
          .toList();
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (_) {
      throw 'Coś poszło nie tak przy pobieraniu szablonów :(';
    }
  }

  /// get a specific template by ID
  Future<TemplateModel?> getTemplateById({
    required String marketId,
    required String templateId,
  }) async {
    try {
      final doc = await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Templates')
          .doc(templateId)
          .get();

      if (doc.exists) return TemplateModel.fromSnapshot(doc);
      return null;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (e) {
      throw 'Nie udało się pobrać szablonu: ${e.toString()}';
    }
  }

  /// update template data
  Future<void> updateTemplate(TemplateModel template) async {
    try {
      await _db
          .collection('Markets')
          .doc(template.marketId)
          .collection('Templates')
          .doc(template.id)
          .update(template.toMap());
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (e) {
      throw 'Nie udało się zaktualizować szablonu: ${e.toString()}';
    }
  }

  /// update all shifts conencted to a template when editing
  Future<void> updateTemplateShifts(
      String marketId, String templateId, List<ShiftModel> shifts) async {
    final shiftsRef = _db
        .collection('Markets')
        .doc(marketId)
        .collection('Templates')
        .doc(templateId)
        .collection('Shifts');

    // clear old shifts - completely deletes the subcollection
    final existingShifts = await shiftsRef.get();
    for (final doc in existingShifts.docs) {
      await doc.reference.delete();
    }

    // save all new shifts
    for (final shift in shifts) {
      await shiftsRef.doc(shift.id).set(shift.toMap());
    }
  }

  /// delete template (hard delete)
  Future<void> deleteTemplate({
    required String marketId,
    required String templateId,
  }) async {
    try {
      await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Templates')
          .doc(templateId)
          .delete();
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (e) {
      throw 'Nie udało się usunąć szablonu: ${e.toString()}';
    }
  }

  /// soft delete (we mark as deleted)
  Future<void> softDeleteTemplate({
    required String marketId,
    required String templateId,
  }) async {
    try {
      await _db
          .collection('Markets')
          .doc(marketId)
          .collection('Templates')
          .doc(templateId)
          .update({
        'isDeleted': true,
        'deletedAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (e) {
      throw 'Nie udało się oznaczyć szablonu jako usunięty: ${e.toString()}';
    }
  }

  /// we use in TagsController after updating a tag
  Future<void> updateTagInTemplates(String marketId, String oldTagName, String newTagName) async {
    final firestore = FirebaseFirestore.instance;
    final templatesRef = firestore.collection('Markets').doc(marketId).collection('Templates');

    final templatesSnapshot = await templatesRef.get();

    // we go through shift subcollections in each Template Tree
    for (final templateDoc in templatesSnapshot.docs) {
      final shiftsRef = templateDoc.reference.collection('Shifts');
      final shiftsSnapshot = await shiftsRef.get();

      // batch it up
      final batch = firestore.batch();

      for (final shiftDoc in shiftsSnapshot.docs) {
        final shiftData = shiftDoc.data();

        if (shiftData['tagName'] != null) {
          if (shiftData['tagName'] == (oldTagName)) {
            batch.update(shiftDoc.reference, {'tagName': newTagName});
          }
        }
      }

      // end the batch
      await batch.commit();
    }
  }

  Future<void> deleteTagInTemplates(String marketId, String tagName) async {
    final firestore = FirebaseFirestore.instance;
    final templatesRef = firestore.collection('Markets').doc(marketId).collection('Templates');

    final templatesSnapshot = await templatesRef.get();

    for (final templateDoc in templatesSnapshot.docs) {
      final shiftsRef = templateDoc.reference.collection('Shifts');
      final shiftsSnapshot = await shiftsRef.get();

      final batch = firestore.batch();
      bool hasMissingData = false; // track if this template lost any tag

      for (final shiftDoc in shiftsSnapshot.docs) {
        final shiftData = shiftDoc.data();

        if (shiftData['tagName'] != null && shiftData['tagName'] == tagName) {
          batch.update(shiftDoc.reference, {'tagName': 'BRAK'});
          hasMissingData = true;
        }
      }

      // Commit the batch for this template
      if (hasMissingData) {
        await batch.commit();

        // Mark the template as having missing data
        await templateDoc.reference.update({'isDataMissing': true});
      }
    }
  }



}
