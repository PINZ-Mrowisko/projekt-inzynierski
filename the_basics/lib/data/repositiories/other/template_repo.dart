import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../features/templates/controllers/template_controller.dart';
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

    for (final templateDoc in templatesSnapshot.docs) {
      final templateData = templateDoc.data();
      final shiftsMap = templateData['shiftsMap'] as Map<String, dynamic>?;

      if (shiftsMap == null || shiftsMap.isEmpty) {
        continue;
      }

      bool changesMade = false;

      final updatedShiftsMap = Map<String, dynamic>.from(shiftsMap);

      for (final entry in updatedShiftsMap.entries) {
        final timeSlotKey = entry.key;
        final timeSlotData = entry.value as Map<String, dynamic>;
        final requirements = timeSlotData['requirements'] as List<dynamic>?;

        if (requirements == null || requirements.isEmpty) {
          continue;
        }

        final updatedRequirements = <Map<String, dynamic>>[];
        bool requirementChanged = false;

        for (final req in requirements) {
          final requirement = req as Map<String, dynamic>;

          if (requirement['tagName'] == oldTagName) {
            updatedRequirements.add({
              'tagId': requirement['tagId'],
              'tagName': newTagName,
              'count': requirement['count'],
            });
            requirementChanged = true;
          } else {
            // if not keep the requirement as is
            updatedRequirements.add(Map<String, dynamic>.from(requirement));
          }
        }

        if (requirementChanged) {
          final updatedTimeSlotData = Map<String, dynamic>.from(timeSlotData);
          updatedTimeSlotData['requirements'] = updatedRequirements;
          updatedShiftsMap[timeSlotKey] = updatedTimeSlotData;
          changesMade = true;
        }
      }

      if (changesMade) {
        await templateDoc.reference.update({
          'shiftsMap': updatedShiftsMap,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  Future<void> deleteTagInTemplates(String marketId, String tagName) async {
    final controller = Get.find<TemplateController>();
    controller.isLoading.value = true;

    try {
      final firestore = FirebaseFirestore.instance;
      final templatesRef = firestore.collection('Markets').doc(marketId).collection('Templates');

      final templatesSnapshot = await templatesRef.get();

      for (final templateDoc in templatesSnapshot.docs) {
        final templateData = templateDoc.data();
        final shiftsMap = templateData['shiftsMap'] as Map<String, dynamic>?;

        //if no shifts then simple
        if (shiftsMap == null || shiftsMap.isEmpty) {
          continue;
        }

        bool hasMissingData = false;
        bool changesMade = false;

        final updatedShiftsMap = Map<String, dynamic>.from(shiftsMap);

        for (final entry in updatedShiftsMap.entries) {
          final timeSlotKey = entry.key;
          final timeSlotData = entry.value as Map<String, dynamic>;
          final requirements = timeSlotData['requirements'] as List<dynamic>?;

          if (requirements == null || requirements.isEmpty) {
            continue;
          }

          final updatedRequirements = <Map<String, dynamic>>[];
          bool requirementChanged = false;

          for (final req in requirements) {
            final requirement = req as Map<String, dynamic>;

            if (requirement['tagName'] == tagName) {
              // Replace with "BRAK" (missing) tag
              updatedRequirements.add({
                'tagId': requirement['tagId'],
                'tagName': 'BRAK',
                'count': requirement['count'],
              });
              hasMissingData = true;
              requirementChanged = true;
            } else {
              // keep the requirements and add to our old list
              updatedRequirements.add(Map<String, dynamic>.from(requirement));
            }
          }

          // if requirements were changed we update the time slot
          if (requirementChanged) {
            final updatedTimeSlotData = Map<String, dynamic>.from(timeSlotData);
            updatedTimeSlotData['requirements'] = updatedRequirements;
            updatedShiftsMap[timeSlotKey] = updatedTimeSlotData;
            changesMade = true;
          }
        }
        if (changesMade) {
          await templateDoc.reference.update({
            'shiftsMap': updatedShiftsMap,
            'isDataMissing': hasMissingData,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      print('Error deleting tag in templates: $e');
      rethrow;
    } finally {
      controller.isLoading.value = false;
    }
  }

  Future<void> markTemplateAsComplete(String marketId, String templateId) async {
    await _db
        .collection('Markets')
        .doc(marketId)
        .collection('Templates')
        .doc(templateId)
        .update({'isDataMissing': false});
  }


}
