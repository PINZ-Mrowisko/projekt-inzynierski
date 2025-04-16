class UserModel {
  final String id;
  //final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String marketName;
  final String phoneNumber;
  final String contractType;
  final int maxWeeklyHours;
  final String shiftPreference;
  final bool isDeleted;
  final DateTime insertedAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    //required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.marketName,
    this.phoneNumber = "123",
    this.contractType = "Umowa o pracę",
    this.maxWeeklyHours = 40,
    this.shiftPreference = "Morning",
    this.isDeleted = false,
    required this.insertedAt,
    required this.updatedAt,
  });

  // Convert model to json map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      //'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'contractType': contractType,
      'maxWeeklyHours': maxWeeklyHours,
      'shiftPreference': shiftPreference,
      'isDeleted': isDeleted,
      'insertedAt': insertedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create User from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      //userId: map['userId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      contractType: map['contractType'] ?? 'Full-time',
      maxWeeklyHours: map['maxWeeklyHours'] ?? 40,
      shiftPreference: map['shiftPreference'] ?? 'No preference',
      isDeleted: map['isDeleted'] ?? false,
      insertedAt: DateTime.parse(map['insertedAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      marketName: map['marketName'] ?? '',
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? marketName,
    String? phoneNumber,
    String? contractType,
    int? maxWeeklyHours,
    String? shiftPreference,
    bool? isDeleted,
  }) {
    return UserModel(
      id: id,
      //userId: userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      marketName: marketName ?? this.marketName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contractType: contractType ?? this.contractType,
      maxWeeklyHours: maxWeeklyHours ?? this.maxWeeklyHours,
      shiftPreference: shiftPreference ?? this.shiftPreference,
      isDeleted: isDeleted ?? this.isDeleted,
      insertedAt: insertedAt,
      updatedAt: DateTime.now(), // Update timestamp on modification
    );
  }
}