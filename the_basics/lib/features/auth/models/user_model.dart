import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String marketId;
  final String phoneNumber;
  final String contractType;
  final int maxWeeklyHours;
  final String shiftPreference;
  final List<String> tags;
  final bool isDeleted;
  final DateTime insertedAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.marketId,
    this.phoneNumber = "123",
    this.contractType = "Umowa o pracę",
    this.maxWeeklyHours = 40,
    this.shiftPreference = "Brak preferencji",
    required this.tags,
    this.isDeleted = false,
    required this.insertedAt,
    required this.updatedAt,
  });

  /// Create an empty user model
  static UserModel empty() => UserModel(id: '', firstName: '', lastName: '', email: '', marketId: '', tags: [], insertedAt: DateTime.now(), updatedAt: DateTime.now());

  /// Convert model to json map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'marketId': marketId,
      'phoneNumber': phoneNumber,
      'contractType': contractType,
      'maxWeeklyHours': maxWeeklyHours,
      'shiftPreference': shiftPreference,
      'tags': tags,
      'isDeleted': isDeleted,
      'insertedAt': Timestamp.fromDate(insertedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create User from Firestore document
  factory UserModel.fromMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data() != null) {
      final map = doc.data()!;
      return UserModel(
        id: map['id'] ?? '',
        firstName: map['firstName'] ?? '',
        lastName: map['lastName'] ?? '',
        email: map['email'] ?? '',
        phoneNumber: map['phoneNumber'] ?? '',
        contractType: map['contractType'] ?? "Umowa o pracę",
        maxWeeklyHours: map['maxWeeklyHours'] ?? 40,
        shiftPreference: map['shiftPreference'] ?? 'Brak preferencji',
        tags: List<String>.from(map['tags']),
        isDeleted: map['isDeleted'] ?? false,
        insertedAt: (map['insertedAt']).toDate(),
        updatedAt: (map['updatedAt']).toDate(),
        marketId: map['marketId'] ?? '',
      );
    } else {
      return UserModel.empty();
    }
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) return UserModel.empty();

    final data = doc.data()!;
    return UserModel(
      id: doc.id, // Use document ID instead of field
      firstName: data['firstName']?.toString() ?? '',
      lastName: data['lastName']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phoneNumber: data['phoneNumber']?.toString() ?? '',
      contractType: data['contractType']?.toString() ?? "Umowa o pracę",
      maxWeeklyHours: (data['maxWeeklyHours'] as num?)?.toInt() ?? 40,
      shiftPreference: data['shiftPreference']?.toString() ?? 'Brak preferencji',
      tags: List<String>.from(data['tags'] ?? []),
      isDeleted: data['isDeleted'] as bool? ?? false,
      insertedAt: (data['insertedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      marketId: data['marketId']?.toString() ?? '',
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? marketId,
    String? phoneNumber,
    String? contractType,
    int? maxWeeklyHours,
    String? shiftPreference,
    List<String>? tags,
    bool? isDeleted,
  }) {
    return UserModel(
      id: id,
      //userId: userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      marketId: marketId ?? this.marketId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contractType: contractType ?? this.contractType,
      maxWeeklyHours: maxWeeklyHours ?? this.maxWeeklyHours,
      shiftPreference: shiftPreference ?? this.shiftPreference,
      tags: tags ?? this.tags,
      isDeleted: isDeleted ?? this.isDeleted,
      insertedAt: insertedAt,
      updatedAt: DateTime.now(), // Update timestamp on modification
    );
  }
}