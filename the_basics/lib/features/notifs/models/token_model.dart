//FCM Tokens - a new one gets created each time the app gets launched
// they are saved specifically per user


import 'package:cloud_firestore/cloud_firestore.dart';

class TokenModel {
  final String userId; // employee ID
  final String token; // FCM token
  final String deviceInfo; // device platform and info
  final String platform; // android
  final String appVersion; // app version
  final DateTime insertedAt;
  final DateTime lastActive;
  final bool isActive;

  TokenModel({
    required this.userId,
    required this.token,
    required this.deviceInfo,
    required this.platform,
    required this.appVersion,
    required this.insertedAt,
    required this.lastActive,
    this.isActive = true,
  });

  static TokenModel empty() => TokenModel(
    userId: '',
    token: '',
    deviceInfo: '',
    platform: '',
    appVersion: '',
    insertedAt: DateTime.now(),
    lastActive: DateTime.now(),
    isActive: false,
  );

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'token': token,
      'deviceInfo': deviceInfo,
      'platform': platform,
      'appVersion': appVersion,
      'insertedAt': insertedAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory TokenModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return TokenModel(
      userId: map['userId'] ?? '',
      token: map['token'] ?? '',
      deviceInfo: map['deviceInfo'] ?? '',
      platform: map['platform'] ?? '',
      appVersion: map['appVersion'] ?? '',
      insertedAt: DateTime.parse(map['insertedAt']),
      lastActive: DateTime.parse(map['lastActive']),
      isActive: map['isActive'] ?? false,
    );
  }

  TokenModel copyWith({
    String? userId,
    String? token,
    String? deviceInfo,
    String? platform,
    String? appVersion,
    DateTime? insertedAt,
    DateTime? lastActive,
    bool? isActive,
  }) {
    return TokenModel(
      userId: userId ?? this.userId,
      token: token ?? this.token,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      insertedAt: insertedAt ?? this.insertedAt,
      lastActive: lastActive ?? this.lastActive,
      isActive: isActive ?? this.isActive,
    );
  }
}