import 'package:test/test.dart';
import 'package:quanitya_cloud_server/src/models/i_consumable_delivery.dart';

void main() {
  group('IConsumableDelivery Interface', () {
    group('Mock Implementation for Testing', () {
      late MockConsumableDelivery mockDelivery;

      setUp(() {
        mockDelivery = MockConsumableDelivery(
          accountId: 12345,
          consumableType: 'coins',
          quantity: 100.0,
          orderId: 'order_abc123',
          deliveredAt: DateTime(2024, 1, 15, 10, 30, 0),
          paymentRail: 'apple_iap',
          productId: 'com.app.coins_100',
          idempotencyKey: 'transaction_xyz789',
        );
      });

      test('returns correct accountId', () {
        expect(mockDelivery.accountId, equals(12345));
      });

      test('returns correct consumableType', () {
        expect(mockDelivery.consumableType, equals('coins'));
      });

      test('returns correct quantity', () {
        expect(mockDelivery.quantity, equals(100.0));
      });

      test('returns correct orderId', () {
        expect(mockDelivery.orderId, equals('order_abc123'));
      });

      test('returns correct deliveredAt', () {
        expect(
          mockDelivery.deliveredAt,
          equals(DateTime(2024, 1, 15, 10, 30, 0)),
        );
      });

      test('returns correct paymentRail', () {
        expect(mockDelivery.paymentRail, equals('apple_iap'));
      });

      test('returns correct productId', () {
        expect(mockDelivery.productId, equals('com.app.coins_100'));
      });

      test('returns correct idempotencyKey', () {
        expect(mockDelivery.idempotencyKey, equals('transaction_xyz789'));
      });

      test('supports different payment rails', () {
        final googleDelivery = MockConsumableDelivery(
          accountId: 67890,
          consumableType: 'gems',
          quantity: 50.0,
          orderId: 'order_def456',
          deliveredAt: DateTime(2024, 2, 20, 14, 45, 0),
          paymentRail: 'google_iap',
          productId: 'com.app.gems_50',
          idempotencyKey: 'purchase_token_abc',
        );

        expect(googleDelivery.paymentRail, equals('google_iap'));
        expect(googleDelivery.idempotencyKey, equals('purchase_token_abc'));
      });

      test('supports fractional quantities', () {
        final fractionalDelivery = MockConsumableDelivery(
          accountId: 11111,
          consumableType: 'premium_currency',
          quantity: 0.5,
          orderId: 'order_frac789',
          deliveredAt: DateTime.now(),
          paymentRail: 'apple_iap',
          productId: 'com.app.premium_half',
          idempotencyKey: 'txn_frac123',
        );

        expect(fractionalDelivery.quantity, equals(0.5));
      });

      test('handles large account IDs', () {
        final largeAccountDelivery = MockConsumableDelivery(
          accountId: 999999999,
          consumableType: 'max_coins',
          quantity: 1000000.0,
          orderId: 'order_large',
          deliveredAt: DateTime.now(),
          paymentRail: 'apple_iap',
          productId: 'com.app.max',
          idempotencyKey: 'txn_large',
        );

        expect(largeAccountDelivery.accountId, equals(999999999));
      });
    });

    group('Interface Contract Verification', () {
      test('IConsumableDelivery can be implemented by different classes', () {
        final appleDelivery = AppleConsumableDeliveryTestImpl(
          accountId: 1,
          consumableType: 'coins',
          quantity: 100.0,
          orderId: 'order_1',
          deliveredAt: DateTime.now(),
          productId: 'com.app.coins',
          transactionId: 'txn_1',
        );

        final googleDelivery = GoogleConsumableDeliveryTestImpl(
          accountId: 2,
          consumableType: 'gems',
          quantity: 50.0,
          orderId: 'order_2',
          deliveredAt: DateTime.now(),
          productId: 'com.app.gems',
          purchaseToken: 'token_2',
        );

        expect(appleDelivery, isA<IConsumableDelivery>());
        expect(googleDelivery, isA<IConsumableDelivery>());
        expect(appleDelivery.paymentRail, equals('apple_iap'));
        expect(googleDelivery.paymentRail, equals('google_iap'));
      });
    });
  });
}

/// Mock implementation of IConsumableDelivery for unit testing.
class MockConsumableDelivery implements IConsumableDelivery {
  @override
  final int accountId;

  @override
  final String consumableType;

  @override
  final double quantity;

  @override
  final String orderId;

  @override
  final DateTime deliveredAt;

  @override
  final String paymentRail;

  @override
  final String productId;

  @override
  final String idempotencyKey;

  MockConsumableDelivery({
    required this.accountId,
    required this.consumableType,
    required this.quantity,
    required this.orderId,
    required this.deliveredAt,
    required this.paymentRail,
    required this.productId,
    required this.idempotencyKey,
  });
}

/// Test implementation for Apple IAP delivery.
class AppleConsumableDeliveryTestImpl implements IConsumableDelivery {
  @override
  final int accountId;

  @override
  final String consumableType;

  @override
  final double quantity;

  @override
  final String orderId;

  @override
  final DateTime deliveredAt;

  @override
  final String productId;

  final String transactionId;

  AppleConsumableDeliveryTestImpl({
    required this.accountId,
    required this.consumableType,
    required this.quantity,
    required this.orderId,
    required this.deliveredAt,
    required this.productId,
    required this.transactionId,
  });

  @override
  String get paymentRail => 'apple_iap';

  @override
  String get idempotencyKey => transactionId;
}

/// Test implementation for Google IAP delivery.
class GoogleConsumableDeliveryTestImpl implements IConsumableDelivery {
  @override
  final int accountId;

  @override
  final String consumableType;

  @override
  final double quantity;

  @override
  final String orderId;

  @override
  final DateTime deliveredAt;

  @override
  final String productId;

  final String purchaseToken;

  GoogleConsumableDeliveryTestImpl({
    required this.accountId,
    required this.consumableType,
    required this.quantity,
    required this.orderId,
    required this.deliveredAt,
    required this.productId,
    required this.purchaseToken,
  });

  @override
  String get paymentRail => 'google_iap';

  @override
  String get idempotencyKey => purchaseToken;
}