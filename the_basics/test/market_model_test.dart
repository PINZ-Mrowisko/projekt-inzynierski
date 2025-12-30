import 'package:flutter_test/flutter_test.dart';
import 'package:the_basics/features/auth/models/market_model.dart';

void main() {
  group('MarketModel', () {
    final now = DateTime.now();

    final market = MarketModel(
      id: 'market_1',
      marketName: 'SuperMarket',
      createdBy: 'user_1',
      isDeleted: false,
      insertedAt: now,
      updatedAt: now,
    );

    test('toMap should return correct map', () {
      final map = market.toMap();

      expect(map['id'], 'market_1');
      expect(map['marketName'], 'SuperMarket');
      expect(map['createdBy'], 'user_1');
      expect(map['isDeleted'], false);
      expect(map['insertedAt'], now.toIso8601String());
      expect(map['updatedAt'], now.toIso8601String());
      expect(map['deletedAt'], null);
    });

    test('fromMap should create correct MarketModel', () {
      final map = {
        'id': 'market_1',
        'marketName': 'SuperMarket',
        'createdBy': 'user_1',
        'isDeleted': false,
        'insertedAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'deletedAt': null,
      };

      final model = MarketModel.fromMap(map);

      expect(model.id, 'market_1');
      expect(model.marketName, 'SuperMarket');
      expect(model.createdBy, 'user_1');
      expect(model.isDeleted, false);
      expect(model.insertedAt, now);
      expect(model.updatedAt, now);
      expect(model.deletedAt, null);
    });

    test('copyWith should update specified fields', () {
      final updated = market.copyWith(
        marketName: 'NewMarket',
        isDeleted: true,
        deletedAt: now,
      );

      expect(updated.id, market.id); // id stays the same
      expect(updated.createdBy, market.createdBy); // createdBy stays the same
      expect(updated.marketName, 'NewMarket');
      expect(updated.isDeleted, true);
      expect(updated.deletedAt, now);
      expect(updated.insertedAt, market.insertedAt); // insertedAt stays the same
      expect(updated.updatedAt.isAfter(market.updatedAt), true); // updatedAt is now
    });

    test('empty should return MarketModel with default values', () {
      final emptyMarket = MarketModel.empty();

      expect(emptyMarket.id, '');
      expect(emptyMarket.marketName, '');
      expect(emptyMarket.createdBy, '');
      expect(emptyMarket.isDeleted, false);
      expect(emptyMarket.insertedAt, isA<DateTime>());
      expect(emptyMarket.updatedAt, isA<DateTime>());
      expect(emptyMarket.deletedAt, null);
    });
  });
}
