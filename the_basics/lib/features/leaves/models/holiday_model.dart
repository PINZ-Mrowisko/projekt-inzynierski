import 'package:cloud_firestore/cloud_firestore.dart';

class Holiday {
  final DateTime date;
  final String name;

  Holiday({required this.date, required this.name});

  factory Holiday.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data();
    return Holiday(
      date: map?['date'] is Timestamp
          ? (map?['date'] as Timestamp).toDate()
          : DateTime.parse(map?['date']),
      name: map?['name'] ?? '',
    );
  }

}
