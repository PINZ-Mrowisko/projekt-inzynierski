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
  final String role;
  final bool isDeleted;
  final DateTime insertedAt;
  final DateTime updatedAt;
  final int numberOfLeaves;
  final bool hasLoggedIn;
  final bool leaveNotifs;
  final bool scheduleNotifs;
  final String gender;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.marketId,
    this.phoneNumber = "123",
    this.contractType = "Umowa o pracę",
    this.maxWeeklyHours = 0,
    this.shiftPreference = "Brak preferencji",
    this.tags = const [],
    this.role = 'employee', // default role
    this.isDeleted = false,
    required this.insertedAt,
    required this.updatedAt,
    this.numberOfLeaves = 0,
    this.hasLoggedIn = false,
    this.scheduleNotifs = true,
    this.leaveNotifs = true,
    this.gender = 'Nie określono',
  });

  static UserModel empty() => UserModel(
    id: '',
    firstName: '',
    lastName: '',
    email: '',
    marketId: '',
    tags: [],
    role: 'employee',
    insertedAt: DateTime.now(),
    updatedAt: DateTime.now(),
    numberOfLeaves: 0,
    hasLoggedIn: false,
    scheduleNotifs: true,
    leaveNotifs: true,
    gender: 'Nie określono',
  );

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
      'role': role,
      'isDeleted': isDeleted,
      'insertedAt': Timestamp.fromDate(insertedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'numberOfLeaves': numberOfLeaves,
      'hasLoggedIn': hasLoggedIn,
      'scheduleNotifs': scheduleNotifs,
      'leaveNotifs': leaveNotifs,
      'gender': gender,
    };
  }

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
        tags: List<String>.from(map['tags'] ?? []),
        role: map['role'] ?? 'employee',
        isDeleted: map['isDeleted'] ?? false,
        insertedAt: (map['insertedAt']).toDate(),
        updatedAt: (map['updatedAt']).toDate(),
        marketId: map['marketId'] ?? '',
        numberOfLeaves: map['numberOfLeaves'] ?? 0,
        hasLoggedIn: map['hasLoggedIn'] ?? false,
        scheduleNotifs: map['scheduleNotifs'] ?? true,
        leaveNotifs: map['leaveNotifs'] ?? true,
        gender: map['gender'] ?? 'Nie określono',
      );
    } else {
      return UserModel.empty();
    }
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) return UserModel.empty();

    final data = doc.data()!;
    return UserModel(
      id: doc.id,
      firstName: data['firstName']?.toString() ?? '',
      lastName: data['lastName']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phoneNumber: data['phoneNumber']?.toString() ?? '',
      contractType: data['contractType']?.toString() ?? "Umowa o pracę",
      maxWeeklyHours: (data['maxWeeklyHours'] as num?)?.toInt() ?? 40,
      shiftPreference: data['shiftPreference']?.toString() ?? 'Brak preferencji',
      tags: List<String>.from(data['tags'] ?? []),
      role: data['role']?.toString() ?? 'employee',
      isDeleted: data['isDeleted'] as bool? ?? false,
      insertedAt: (data['insertedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      marketId: data['marketId']?.toString() ?? '',
      numberOfLeaves: (data['numberOfLeaves'] as num?)?.toInt() ?? 0,
      hasLoggedIn: data['hasLoggedIn'] as bool? ?? false,
      scheduleNotifs: data['scheduleNotifs'] as bool? ?? true,
      leaveNotifs: data['leaveNotifs'] as bool? ?? true,
      gender: data['gender']?.toString() ?? 'Nie określono',
    );
  }

/// TODO : fix this method
  UserModel copyWithUpdatedTags(String oldTagName, String newTagName) {
    final updatedTags = tags.map((tag) => tag == oldTagName ? newTagName : tag).toList();
    return copyWith(tags: updatedTags);
  }

  UserModel copyWith({
    String? id,
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
    bool? hasLoggedIn,
    int? numberOfLeaves,
    bool? leaveNotifs,
    bool? scheduleNotifs,
    String? gender,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      marketId: marketId ?? this.marketId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contractType: contractType ?? this.contractType,
      maxWeeklyHours: maxWeeklyHours ?? this.maxWeeklyHours,
      shiftPreference: shiftPreference ?? this.shiftPreference,
      tags: tags ?? this.tags,
      role: role,
      isDeleted: isDeleted ?? this.isDeleted,
      insertedAt: insertedAt,
      updatedAt: DateTime.now(),
        numberOfLeaves: numberOfLeaves ?? this.numberOfLeaves,
      hasLoggedIn: hasLoggedIn ?? this.hasLoggedIn,
      scheduleNotifs: scheduleNotifs ?? this.scheduleNotifs,
      leaveNotifs: leaveNotifs ?? this.leaveNotifs,
      gender: gender ?? this.gender,
    );
  }
}