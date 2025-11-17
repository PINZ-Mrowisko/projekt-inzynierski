// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../../features/settings/models/user_settings_model.dart';
//
// class SettingsRepo {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   /// save new settings for a user
//   Future<void> saveSettings(SettingsModel settings, String marketId) async {
//     try {
//       await _db
//           .collection('Markets')
//           .doc(marketId)
//           .collection('members')
//           .doc(settings.userId)
//           .collection('Settings')
//           .doc('settings')
//           .set(settings.toMap());
//       //print('Notification settings saved for user: ${settings.userId}');
//     } catch (e) {
//       //print('Error saving notification settings: $e');
//       rethrow;
//     }
//   }
//
//   /// update existing settings for a user
//   Future<void> updateSettings(SettingsModel settings, String marketId) async {
//     try {
//       await _db
//           .collection('Markets')
//           .doc(marketId)
//           .collection('members')
//           .doc(settings.userId)
//           .collection('Settings')
//           .doc('settings')
//           .update(settings.toMap());
//       //print('Notification settings updated for user: ${settings.userId}');
//     } catch (e) {
//       //print('Error updating notification settings: $e');
//       rethrow;
//     }
//   }
//
//   /// get settings for a user
//   Future<SettingsModel> getSettings(String userId, String marketId) async {
//     try {
//       final doc = await _db
//           .collection('Markets')
//           .doc(marketId)
//           .collection('members')
//           .doc(userId)
//           .collection('Settings')
//           .doc('settings')
//           .get();
//
//       if (doc.exists) {
//         return SettingsModel.fromSnapshot(doc);
//       } else {
//         // we shall return default settings if not set yet
//         return SettingsModel(
//           userId: userId,
//           insertedAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         );
//       }
//     } catch (e) {
//       //print('Error fetching notification settings: $e');
//       rethrow;
//     }
//   }
// }
