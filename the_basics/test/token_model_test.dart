import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:the_basics/features/notifs/models/token_model.dart'; 

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late DateTime insertedAt;
  late DateTime lastActive;
  late TokenModel token;

  setUp(() {
    insertedAt = DateTime.utc(2024, 1, 1, 10);
    lastActive = DateTime.utc(2024, 1, 2, 12);

    token = TokenModel(
      userId: 'user123',
      token: 'fcm_token',
      deviceInfo: 'Pixel 7',
      platform: 'android',
      appVersion: '1.0.0',
      insertedAt: insertedAt,
      lastActive: lastActive,
      isActive: true,
    );
  });

  group('empty', () {
    test('returns inactive empty TokenModel', () {
      final empty = TokenModel.empty();

      expect(empty.userId, '');
      expect(empty.token, '');
      expect(empty.deviceInfo, '');
      expect(empty.platform, '');
      expect(empty.appVersion, '');
      expect(empty.isActive, false);
      expect(empty.insertedAt.isBefore(DateTime.now()), true);
      expect(empty.lastActive.isBefore(DateTime.now()), true);
    });
  });

  group('toMap', () {
    test('converts TokenModel to correct map', () {
      final map = token.toMap();

      expect(map['userId'], 'user123');
      expect(map['token'], 'fcm_token');
      expect(map['deviceInfo'], 'Pixel 7');
      expect(map['platform'], 'android');
      expect(map['appVersion'], '1.0.0');
      expect(map['insertedAt'], insertedAt.toIso8601String());
      expect(map['lastActive'], lastActive.toIso8601String());
      expect(map['isActive'], true);
    });
  });

  group('fromSnapshot', () {
    test('creates TokenModel from Firestore snapshot', () {
      final doc = MockDocumentSnapshot();

      when(() => doc.data()).thenReturn({
        'userId': 'userABC',
        'token': 'new_token',
        'deviceInfo': 'iPhone',
        'platform': 'ios',
        'appVersion': '2.0.0',
        'insertedAt': insertedAt.toIso8601String(),
        'lastActive': lastActive.toIso8601String(),
        'isActive': true,
      });

      final result = TokenModel.fromSnapshot(doc);

      expect(result.userId, 'userABC');
      expect(result.token, 'new_token');
      expect(result.deviceInfo, 'iPhone');
      expect(result.platform, 'ios');
      expect(result.appVersion, '2.0.0');
      expect(result.insertedAt, insertedAt);
      expect(result.lastActive, lastActive);
      expect(result.isActive, true);
    });

    test('uses defaults when optional fields are missing', () {
      final doc = MockDocumentSnapshot();

      when(() => doc.data()).thenReturn({
        'insertedAt': insertedAt.toIso8601String(),
        'lastActive': lastActive.toIso8601String(),
      });

      final result = TokenModel.fromSnapshot(doc);

      expect(result.userId, '');
      expect(result.token, '');
      expect(result.deviceInfo, '');
      expect(result.platform, '');
      expect(result.appVersion, '');
      expect(result.insertedAt, insertedAt);
      expect(result.lastActive, lastActive);
      expect(result.isActive, false);
    });
  });

  group('copyWith', () {
    test('creates copy with updated values', () {
      final copied = token.copyWith(
        token: 'updated_token',
        platform: 'ios',
        isActive: false,
      );

      expect(copied.userId, token.userId);
      expect(copied.token, 'updated_token');
      expect(copied.deviceInfo, token.deviceInfo);
      expect(copied.platform, 'ios');
      expect(copied.appVersion, token.appVersion);
      expect(copied.insertedAt, token.insertedAt);
      expect(copied.lastActive, token.lastActive);
      expect(copied.isActive, false);
    });

    test('returns identical object when no params passed', () {
      final copied = token.copyWith();

      expect(copied.userId, token.userId);
      expect(copied.token, token.token);
      expect(copied.deviceInfo, token.deviceInfo);
      expect(copied.platform, token.platform);
      expect(copied.appVersion, token.appVersion);
      expect(copied.insertedAt, token.insertedAt);
      expect(copied.lastActive, token.lastActive);
      expect(copied.isActive, token.isActive);
    });
  });
}
