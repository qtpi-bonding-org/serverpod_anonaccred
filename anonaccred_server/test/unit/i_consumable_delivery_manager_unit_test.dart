import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:quanitya_cloud_server/src/models/i_consumable_delivery.dart';
import 'package:quanitya_cloud_server/src/models/i_consumable_delivery_manager.dart';

void main() {
  group('IConsumableDeliveryManager Interface', () {
    group('Mock Implementation for Testing', () {
      late MockDeliveryManager manager;
      late Session session;

      setUp(() {
        manager = MockDeliveryManager();
        session = MockSession();
      });

      test('findByIdempotencyKey returns null for non-existent key', () async {
        final result = await manager.findByIdempotencyKey(session, 'non_existent');
        expect(result, isNull);
      });

      test('findByIdempotencyKey returns delivery when exists', () async {
        await manager.recordDelivery(
          session,
          productId: 'com.app.coins_100',
          accountId: 12345,
          consumableType: 'coins',
          quantity: 100.0,
          orderId: 'order_abc123',
          platformSpecificData: {'transactionId': 'transaction_xyz789'},
        );

        final result = await manager.findByIdempotencyKey(session, 'transaction_xyz789');
        expect(result, isNotNull);
        expect(result!.idempotencyKey, equals('transaction_xyz789'));
        expect(result.accountId, equals(12345));
        expect(result.consumableType, equals('coins'));
        expect(result.quantity, equals(100.0));
      });

      test('recordDelivery creates delivery with correct fields', () async {
        final delivery = await manager.recordDelivery(
          session,
          productId: 'com.app.coins_100',
          accountId: 12345,
          consumableType: 'coins',
          quantity: 100.0,
          orderId: 'order_abc123',
          platformSpecificData: {'transactionId': 'txn_123'},
        );

        expect(delivery.productId, equals('com.app.coins_100'));
        expect(delivery.accountId, equals(12345));
        expect(delivery.consumableType, equals('coins'));
        expect(delivery.quantity, equals(100.0));
        expect(delivery.orderId, equals('order_abc123'));
        expect(delivery.deliveredAt, isNotNull);
      });

      test('recordDelivery extracts transactionId from platformSpecificData', () async {
        final delivery = await manager.recordDelivery(
          session,
          productId: 'com.app.gems_50',
          accountId: 67890,
          consumableType: 'gems',
          quantity: 50.0,
          orderId: 'order_def456',
          platformSpecificData: {'transactionId': 'txn_gems_001'},
        );

        expect(delivery.idempotencyKey, equals('txn_gems_001'));
      });

      test('getDeliveriesForAccount returns empty list for account with no deliveries', () async {
        final result = await manager.getDeliveriesForAccount(session, 99999);
        expect(result, isEmpty);
      });

      test('getDeliveriesForAccount returns all deliveries for account', () async {
        await manager.recordDelivery(
          session,
          productId: 'com.app.coins_100',
          accountId: 12345,
          consumableType: 'coins',
          quantity: 100.0,
          orderId: 'order_1',
          platformSpecificData: {'transactionId': 'txn_1'},
        );
        await manager.recordDelivery(
          session,
          productId: 'com.app.gems_50',
          accountId: 12345,
          consumableType: 'gems',
          quantity: 50.0,
          orderId: 'order_2',
          platformSpecificData: {'transactionId': 'txn_2'},
        );
        await manager.recordDelivery(
          session,
          productId: 'com.app.coins_200',
          accountId: 12345,
          consumableType: 'coins',
          quantity: 200.0,
          orderId: 'order_3',
          platformSpecificData: {'transactionId': 'txn_3'},
        );

        final result = await manager.getDeliveriesForAccount(session, 12345);
        expect(result, hasLength(3));
        expect(result.map((d) => d.consumableType), containsAll(['coins', 'gems']));
      });

      test('getDeliveriesForAccount only returns deliveries for specified account', () async {
        await manager.recordDelivery(
          session,
          productId: 'com.app.coins_100',
          accountId: 12345,
          consumableType: 'coins',
          quantity: 100.0,
          orderId: 'order_1',
          platformSpecificData: {'transactionId': 'txn_1'},
        );
        await manager.recordDelivery(
          session,
          productId: 'com.app.coins_100',
          accountId: 67890,
          consumableType: 'coins',
          quantity: 100.0,
          orderId: 'order_2',
          platformSpecificData: {'transactionId': 'txn_2'},
        );

        final result12345 = await manager.getDeliveriesForAccount(session, 12345);
        final result67890 = await manager.getDeliveriesForAccount(session, 67890);

        expect(result12345, hasLength(1));
        expect(result67890, hasLength(1));
        expect(result12345.first.accountId, equals(12345));
        expect(result67890.first.accountId, equals(67890));
      });

      test('idempotency - same transactionId returns same delivery', () async {
        final delivery1 = await manager.recordDelivery(
          session,
          productId: 'com.app.coins_100',
          accountId: 12345,
          consumableType: 'coins',
          quantity: 100.0,
          orderId: 'order_1',
          platformSpecificData: {'transactionId': 'txn_idempotent'},
        );

        final existing = await manager.findByIdempotencyKey(session, 'txn_idempotent');
        expect(existing, isNotNull);
        expect(existing!.idempotencyKey, equals(delivery1.idempotencyKey));
      });

      test('supports different payment rails via generic type', () async {
        final appleManager = AppleMockDeliveryManager();
        final googleManager = GoogleMockDeliveryManager();

        expect(appleManager, isA<IConsumableDeliveryManager<IConsumableDelivery>>());
        expect(googleManager, isA<IConsumableDeliveryManager<IConsumableDelivery>>());
      });
    });

    group('Interface Contract Verification', () {
      test('IConsumableDeliveryManager can be implemented with generic type', () {
        final appleManager = AppleMockDeliveryManager();
        final googleManager = GoogleMockDeliveryManager();

        expect(appleManager, isA<IConsumableDeliveryManager<AppleTestDelivery>>());
        expect(googleManager, isA<IConsumableDeliveryManager<GoogleTestDelivery>>());
      });

      test('findByIdempotencyKey signature is correct', () async {
        final manager = AppleMockDeliveryManager();
        final session = MockSession();

        final result = manager.findByIdempotencyKey(session, 'test_key');
        expect(result, isA<Future<AppleTestDelivery?>>());
      });

      test('recordDelivery signature is correct', () async {
        final manager = AppleMockDeliveryManager();
        final session = MockSession();

        final result = manager.recordDelivery(
          session,
          productId: 'com.app.test',
          accountId: 1,
          consumableType: 'test',
          quantity: 1.0,
          orderId: 'order_1',
          platformSpecificData: {},
        );
        expect(result, isA<Future<AppleTestDelivery>>());
      });

      test('getDeliveriesForAccount signature is correct', () async {
        final manager = AppleMockDeliveryManager();
        final session = MockSession();

        final result = manager.getDeliveriesForAccount(session, 1);
        expect(result, isA<Future<List<AppleTestDelivery>>>());
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

/// Mock delivery manager for testing the interface.
class MockDeliveryManager implements IConsumableDeliveryManager<MockConsumableDelivery> {
  final _deliveries = <String, MockConsumableDelivery>{};
  final _accountDeliveries = <int, List<MockConsumableDelivery>>{};

  @override
  Future<MockConsumableDelivery?> findByIdempotencyKey(
    Session session,
    String idempotencyKey,
  ) async {
    return _deliveries[idempotencyKey];
  }

  @override
  Future<MockConsumableDelivery> recordDelivery(
    Session session, {
    required String productId,
    required int accountId,
    required String consumableType,
    required double quantity,
    required String orderId,
    required Map<String, dynamic> platformSpecificData,
  }) async {
    final transactionId = platformSpecificData['transactionId'] as String? ?? 'unknown';
    final delivery = MockConsumableDelivery(
      accountId: accountId,
      consumableType: consumableType,
      quantity: quantity,
      orderId: orderId,
      deliveredAt: DateTime.now(),
      paymentRail: 'apple_iap',
      productId: productId,
      idempotencyKey: transactionId,
    );

    _deliveries[transactionId] = delivery;
    _accountDeliveries.putIfAbsent(accountId, () => []).add(delivery);

    return delivery;
  }

  @override
  Future<List<MockConsumableDelivery>> getDeliveriesForAccount(
    Session session,
    int accountId,
  ) async {
    return _accountDeliveries[accountId] ?? [];
  }
}

/// Apple-specific test delivery implementation.
class AppleTestDelivery implements IConsumableDelivery {
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

  AppleTestDelivery({
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

/// Google-specific test delivery implementation.
class GoogleTestDelivery implements IConsumableDelivery {
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

  GoogleTestDelivery({
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

/// Apple-specific mock delivery manager.
class AppleMockDeliveryManager implements IConsumableDeliveryManager<AppleTestDelivery> {
  final _deliveries = <String, AppleTestDelivery>{};

  @override
  Future<AppleTestDelivery?> findByIdempotencyKey(
    Session session,
    String idempotencyKey,
  ) async {
    return _deliveries[idempotencyKey];
  }

  @override
  Future<AppleTestDelivery> recordDelivery(
    Session session, {
    required String productId,
    required int accountId,
    required String consumableType,
    required double quantity,
    required String orderId,
    required Map<String, dynamic> platformSpecificData,
  }) async {
    final transactionId = platformSpecificData['transactionId'] as String? ?? 'unknown';
    final delivery = AppleTestDelivery(
      accountId: accountId,
      consumableType: consumableType,
      quantity: quantity,
      orderId: orderId,
      deliveredAt: DateTime.now(),
      productId: productId,
      transactionId: transactionId,
    );
    _deliveries[transactionId] = delivery;
    return delivery;
  }

  @override
  Future<List<AppleTestDelivery>> getDeliveriesForAccount(
    Session session,
    int accountId,
  ) async {
    return _deliveries.values.where((d) => d.accountId == accountId).toList();
  }
}

/// Google-specific mock delivery manager.
class GoogleMockDeliveryManager implements IConsumableDeliveryManager<GoogleTestDelivery> {
  final _deliveries = <String, GoogleTestDelivery>{};

  @override
  Future<GoogleTestDelivery?> findByIdempotencyKey(
    Session session,
    String idempotencyKey,
  ) async {
    return _deliveries[idempotencyKey];
  }

  @override
  Future<GoogleTestDelivery> recordDelivery(
    Session session, {
    required String productId,
    required int accountId,
    required String consumableType,
    required double quantity,
    required String orderId,
    required Map<String, dynamic> platformSpecificData,
  }) async {
    final purchaseToken = platformSpecificData['purchaseToken'] as String? ?? 'unknown';
    final delivery = GoogleTestDelivery(
      accountId: accountId,
      consumableType: consumableType,
      quantity: quantity,
      orderId: orderId,
      deliveredAt: DateTime.now(),
      productId: productId,
      purchaseToken: purchaseToken,
    );
    _deliveries[purchaseToken] = delivery;
    return delivery;
  }

  @override
  Future<List<GoogleTestDelivery>> getDeliveriesForAccount(
    Session session,
    int accountId,
  ) async {
    return _deliveries.values.where((d) => d.accountId == accountId).toList();
  }
}

/// Mock session for testing.
class MockSession implements Session {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}