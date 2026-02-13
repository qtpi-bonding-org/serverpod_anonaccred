import 'package:test/test.dart';
import 'package:quanitya_cloud_server/src/generated/apple_consumable_delivery.dart';
import 'package:quanitya_cloud_server/src/models/apple_consumable_delivery.dart';
import 'package:quanitya_cloud_server/src/models/i_consumable_delivery.dart';

void main() {
  group('AppleConsumableDelivery', () {
    group('IConsumableDelivery Implementation', () {
      late AppleConsumableDeliveryImpl delivery;

      setUp(() {
        delivery = AppleConsumableDeliveryImpl(
          id: 1,
          transactionId: 'txn_abc123',
          originalTransactionId: 'orig_txn_abc123',
          productId: 'com.app.coins_100',
          accountId: 12345,
          consumableType: 'coins',
          quantity: 100.0,
          orderId: 'order_abc123',
          deliveredAt: DateTime(2024, 1, 15, 10, 30, 0),
        );
      });

      test('implements IConsumableDelivery interface', () {
        expect(delivery, isA<IConsumableDelivery>());
      });

      test('returns correct id', () {
        expect(delivery.id, equals(1));
      });

      test('returns correct transactionId', () {
        expect(delivery.transactionId, equals('txn_abc123'));
      });

      test('returns correct originalTransactionId', () {
        expect(delivery.originalTransactionId, equals('orig_txn_abc123'));
      });

      test('returns correct accountId', () {
        expect(delivery.accountId, equals(12345));
      });

      test('returns correct consumableType', () {
        expect(delivery.consumableType, equals('coins'));
      });

      test('returns correct quantity', () {
        expect(delivery.quantity, equals(100.0));
      });

      test('returns correct orderId', () {
        expect(delivery.orderId, equals('order_abc123'));
      });

      test('returns correct deliveredAt', () {
        expect(
          delivery.deliveredAt,
          equals(DateTime(2024, 1, 15, 10, 30, 0)),
        );
      });

      test('returns correct productId', () {
        expect(delivery.productId, equals('com.app.coins_100'));
      });

      test('returns apple_iap for paymentRail', () {
        expect(delivery.paymentRail, equals('apple_iap'));
      });

      test('returns transactionId for idempotencyKey', () {
        expect(delivery.idempotencyKey, equals('txn_abc123'));
      });

      test('idempotencyKey equals transactionId', () {
        expect(delivery.idempotencyKey, equals(delivery.transactionId));
      });
    });

    group('fromGenerated Factory', () {
      test('creates instance from generated AppleConsumableDelivery', () {
        // Create a generated delivery
        final generated = AppleConsumableDelivery(
          id: 2,
          transactionId: 'txn_xyz789',
          originalTransactionId: 'orig_txn_xyz789',
          productId: 'com.app.gems_50',
          accountId: 67890,
          consumableType: 'gems',
          quantity: 50.0,
          orderId: 'order_xyz789',
          deliveredAt: DateTime(2024, 2, 20, 14, 45, 0),
        );

        final delivery = AppleConsumableDeliveryImpl.fromGenerated(generated);

        expect(delivery.id, equals(2));
        expect(delivery.transactionId, equals('txn_xyz789'));
        expect(delivery.originalTransactionId, equals('orig_txn_xyz789'));
        expect(delivery.productId, equals('com.app.gems_50'));
        expect(delivery.accountId, equals(67890));
        expect(delivery.consumableType, equals('gems'));
        expect(delivery.quantity, equals(50.0));
        expect(delivery.orderId, equals('order_xyz789'));
        expect(delivery.deliveredAt, equals(DateTime(2024, 2, 20, 14, 45, 0)));
        expect(delivery.paymentRail, equals('apple_iap'));
        expect(delivery.idempotencyKey, equals('txn_xyz789'));
      });
    });

    group('Interface Contract', () {
      test('AppleConsumableDelivery returns apple_iap payment rail', () {
        final delivery = AppleConsumableDeliveryImpl(
          transactionId: 'txn_test',
          originalTransactionId: 'orig_txn_test',
          productId: 'com.app.test',
          accountId: 1,
          consumableType: 'test',
          quantity: 1.0,
          orderId: 'order_test',
          deliveredAt: DateTime.now(),
        );

        expect(delivery.paymentRail, equals('apple_iap'));
      });

      test('idempotencyKey is unique per delivery', () {
        final delivery1 = AppleConsumableDeliveryImpl(
          transactionId: 'txn_unique_1',
          originalTransactionId: 'orig_1',
          productId: 'com.app.product',
          accountId: 1,
          consumableType: 'coins',
          quantity: 100.0,
          orderId: 'order_1',
          deliveredAt: DateTime.now(),
        );

        final delivery2 = AppleConsumableDeliveryImpl(
          transactionId: 'txn_unique_2',
          originalTransactionId: 'orig_2',
          productId: 'com.app.product',
          accountId: 1,
          consumableType: 'coins',
          quantity: 100.0,
          orderId: 'order_2',
          deliveredAt: DateTime.now(),
        );

        expect(delivery1.idempotencyKey, isNot(equals(delivery2.idempotencyKey)));
        expect(delivery1.idempotencyKey, equals('txn_unique_1'));
        expect(delivery2.idempotencyKey, equals('txn_unique_2'));
      });

      test('handles fractional quantities', () {
        final delivery = AppleConsumableDeliveryImpl(
          transactionId: 'txn_frac',
          originalTransactionId: 'orig_frac',
          productId: 'com.app.premium',
          accountId: 1,
          consumableType: 'premium_currency',
          quantity: 0.5,
          orderId: 'order_frac',
          deliveredAt: DateTime.now(),
        );

        expect(delivery.quantity, equals(0.5));
      });

      test('handles large account IDs', () {
        final delivery = AppleConsumableDeliveryImpl(
          transactionId: 'txn_large',
          originalTransactionId: 'orig_large',
          productId: 'com.app.max',
          accountId: 999999999,
          consumableType: 'max_coins',
          quantity: 1000000.0,
          orderId: 'order_large',
          deliveredAt: DateTime.now(),
        );

        expect(delivery.accountId, equals(999999999));
      });

      test('handles null id', () {
        final delivery = AppleConsumableDeliveryImpl(
          transactionId: 'txn_null_id',
          originalTransactionId: 'orig_null_id',
          productId: 'com.app.test',
          accountId: 1,
          consumableType: 'test',
          quantity: 1.0,
          orderId: 'order_null_id',
          deliveredAt: DateTime.now(),
        );

        expect(delivery.id, isNull);
      });
    });
  });
}