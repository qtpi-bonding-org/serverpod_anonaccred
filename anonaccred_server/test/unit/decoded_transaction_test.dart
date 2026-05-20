import 'dart:convert';
import 'package:anonaccred_server/src/payments/decoded_transaction.dart';
import 'package:test/test.dart';

/// Unit tests for DecodedTransaction model
///
/// These tests verify that the DecodedTransaction class correctly decodes
/// JWT tokens and extracts transaction information.
void main() {
  group('DecodedTransaction', () {
    // Sample transaction claims matching Apple's JWT structure
    final sampleClaims = {
      'transactionId': '123456789',
      'originalTransactionId': '123456789',
      'productId': 'com.example.app.coins_100',
      'bundleId': 'com.example.app',
      'purchaseDate': 1704067200000, // 2024-01-01 00:00:00 UTC
      'originalPurchaseDate': 1704067200000,
      'webOrderLineItemId': 'order_line_123',
      'quantity': 1,
      'type': 'Consumable',
      'appAccountToken': 'user_account_uuid',
    };

    test('fromClaims creates transaction with all fields', () {
      final transaction = DecodedTransaction.fromClaims(sampleClaims);

      expect(transaction.transactionId, equals('123456789'));
      expect(transaction.originalTransactionId, equals('123456789'));
      expect(transaction.productId, equals('com.example.app.coins_100'));
      expect(transaction.bundleId, equals('com.example.app'));
      expect(transaction.purchaseDate, equals(1704067200000));
      expect(transaction.originalPurchaseDate, equals(1704067200000));
      expect(transaction.webOrderLineItemId, equals('order_line_123'));
      expect(transaction.quantity, equals(1));
      expect(transaction.type, equals('Consumable'));
      expect(transaction.appAccountToken, equals('user_account_uuid'));
    });

    test('fromClaims handles optional fields as null', () {
      final claimsWithoutOptionals = {
        'transactionId': '123456789',
        'originalTransactionId': '123456789',
        'productId': 'com.example.app.coins_100',
        'bundleId': 'com.example.app',
        'purchaseDate': 1704067200000,
        'originalPurchaseDate': 1704067200000,
        'quantity': 1,
        'type': 'Consumable',
      };

      final transaction = DecodedTransaction.fromClaims(claimsWithoutOptionals);

      expect(transaction.webOrderLineItemId, isNull);
      expect(transaction.appAccountToken, isNull);
    });

    test('fromClaims throws on missing required field', () {
      final incompleteClaims = {
        'transactionId': '123456789',
        // Missing originalTransactionId
        'productId': 'com.example.app.coins_100',
        'bundleId': 'com.example.app',
        'purchaseDate': 1704067200000,
        'originalPurchaseDate': 1704067200000,
        'quantity': 1,
        'type': 'Consumable',
      };

      expect(
        () => DecodedTransaction.fromClaims(incompleteClaims),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('fromClaims throws on invalid field type', () {
      final invalidClaims = {
        'transactionId': '123456789',
        'originalTransactionId': '123456789',
        'productId': 'com.example.app.coins_100',
        'bundleId': 'com.example.app',
        'purchaseDate': '1704067200000', // Should be int, not String
        'originalPurchaseDate': 1704067200000,
        'quantity': 1,
        'type': 'Consumable',
      };

      expect(
        () => DecodedTransaction.fromClaims(invalidClaims),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('fromJWT decodes valid JWT token', () {
      // Create a simple JWT (header.payload.signature)
      // Note: This is not a real signed JWT, just for testing the decoding logic
      final header = base64Url.encode(utf8.encode(jsonEncode({
        'alg': 'ES256',
        'typ': 'JWT',
      })));

      final payload = base64Url.encode(utf8.encode(jsonEncode(sampleClaims)));

      // Fake signature (in real use, this would be a valid ES256 signature)
      final signature = base64Url.encode(utf8.encode('fake_signature'));

      final jwt = '$header.$payload.$signature';

      final transaction = DecodedTransaction.fromJWT(jwt);

      expect(transaction.transactionId, equals('123456789'));
      expect(transaction.productId, equals('com.example.app.coins_100'));
      expect(transaction.quantity, equals(1));
    });

    test('fromJWT throws on malformed JWT', () {
      // JWT with only 2 parts instead of 3
      const malformedJWT = 'header.payload';

      expect(
        () => DecodedTransaction.fromJWT(malformedJWT),
        throwsA(isA<FormatException>()),
      );
    });

    test('toString returns formatted string', () {
      final transaction = DecodedTransaction.fromClaims(sampleClaims);
      final str = transaction.toString();

      expect(str, contains('transactionId: 123456789'));
      expect(str, contains('productId: com.example.app.coins_100'));
      expect(str, contains('quantity: 1'));
    });

    test('equality works correctly', () {
      final transaction1 = DecodedTransaction.fromClaims(sampleClaims);
      final transaction2 = DecodedTransaction.fromClaims(sampleClaims);

      expect(transaction1, equals(transaction2));
      expect(transaction1.hashCode, equals(transaction2.hashCode));
    });

    test('inequality works correctly', () {
      final transaction1 = DecodedTransaction.fromClaims(sampleClaims);
      
      final differentClaims = Map<String, dynamic>.from(sampleClaims);
      differentClaims['transactionId'] = 'different_id';
      final transaction2 = DecodedTransaction.fromClaims(differentClaims);

      expect(transaction1, isNot(equals(transaction2)));
    });
  });
}
