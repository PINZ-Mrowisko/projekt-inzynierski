import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../features/leaves/models/leave_model.dart';
import '../exceptions.dart';

class LeaveRepo extends GetxController {
  static LeaveRepo get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// save a new leave request to a market's subcollection
  Future<void> saveLeave(LeaveModel leave) async {
    try {
      await _db
          .collection("Markets")
          .doc(leave.marketId)
          .collection("LeaveReq")
          .doc(leave.id)
          .set(leave.toMap());

      print("i did ti");
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (_) {
      throw 'Coś poszło nie tak :(';
    }
  }

  /// get all non-deleted leave requests for a given market
  Future<List<LeaveModel>> getAllLeaveRequests(String marketId) async {
    try {
      final snapshot = await _db
          .collection("Markets")
          .doc(marketId)
          .collection("LeaveReq")
          .where("isDeleted", isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs.map((e) => LeaveModel.fromSnapshot(e)).toList();
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (_) {
      throw 'Coś poszło nie tak :(';
    }
  }

  /// update an existing leave request
  Future<void> updateLeave(LeaveModel leave) async {
    try {
      await _db
          .collection("Markets")
          .doc(leave.marketId)
          .collection("LeaveReq")
          .doc(leave.id)
          .update(leave.toMap());
    } catch (e) {
      throw 'Nie udało się zaktualizować wniosku urlopowego: ${e.toString()}';
    }
  }

  /// soft-delete a leave request by setting deletedAt and isDeleted
  Future<void> deleteLeave(String marketId, String leaveId) async {
    try {
      final now = DateTime.now().toIso8601String();
      await _db
          .collection("Markets")
          .doc(marketId)
          .collection("LeaveReq")
          .doc(leaveId)
          .update({
        'isDeleted': true,
        'deletedAt': now,
      });
    } catch (e) {
      throw 'Nie udało się usunąć wniosku urlopowego: ${e.toString()}';
    }
  }
}
