import 'dart:math';

import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

void main() {
  final random = Random();

  group('AnonAccountHelpers', () {
    group('validateNonEmpty', () {
      test('should pass for valid non-empty string', () {
        expect(
          () => AnonAccountHelpers.validateNonEmpty('valid', 'testField', 'testOp'),
          returnsNormally,
        );
      });

      test('should throw for null string', () {
        expect(
          () => AnonAccountHelpers.validateNonEmpty(null, 'testField', 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should throw for empty string', () {
        expect(
          () => AnonAccountHelpers.validateNonEmpty('', 'testField', 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('property: validateNonEmpty should accept any non-empty string', () {
        // Property-based test with 5 iterations for development
        for (var i = 0; i < 5; i++) {
          final validString = _generateRandomNonEmptyString(random);
          final fieldName = 'field${random.nextInt(100)}';
          final operation = 'op${random.nextInt(100)}';

          expect(
            () => AnonAccountHelpers.validateNonEmpty(validString, fieldName, operation),
            returnsNormally,
          );
        }
      });

      test('property: validateNonEmpty should reject null and empty strings', () {
        // Property-based test with 5 iterations for development
        for (var i = 0; i < 5; i++) {
          final fieldName = 'field${random.nextInt(100)}';
          final operation = 'op${random.nextInt(100)}';

          // Test null
          expect(
            () => AnonAccountHelpers.validateNonEmpty(null, fieldName, operation),
            throwsA(isA<AuthenticationException>()),
          );

          // Test empty string
          expect(
            () => AnonAccountHelpers.validateNonEmpty('', fieldName, operation),
            throwsA(isA<AuthenticationException>()),
          );
        }
      });
    });

    group('validatePublicKey', () {
      test('should pass for valid ECDSA P-256 public key', () {
        // Valid 128-character hex string (64 bytes for ECDSA P-256)
        final validKey = 'a' * 128;
        expect(
          () => AnonAccountHelpers.validatePublicKey(validKey, 'testOp'),
          returnsNormally,
        );
      });

      test('should throw for invalid public key format', () {
        expect(
          () => AnonAccountHelpers.validatePublicKey('invalid', 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should throw for null public key', () {
        expect(
          () => AnonAccountHelpers.validatePublicKey(null, 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('property: validatePublicKey should accept valid ECDSA P-256 keys', () {
        // Property-based test with 5 iterations for development
        for (var i = 0; i < 5; i++) {
          final validKey = _generateFakePublicKeyString(random);
          final operation = 'op${random.nextInt(100)}';

          expect(
            () => AnonAccountHelpers.validatePublicKey(validKey, operation),
            returnsNormally,
          );
        }
      });

      test('property: validatePublicKey should reject invalid keys', () {
        // Property-based test with 5 iterations for development
        for (var i = 0; i < 5; i++) {
          final invalidKey = _generateInvalidPublicKey(random);
          final operation = 'op${random.nextInt(100)}';

          expect(
            () => AnonAccountHelpers.validatePublicKey(invalidKey, operation),
            throwsA(isA<AuthenticationException>()),
          );
        }
      });
    });

    group('requireEntity', () {
      test('should return entity when not null', () {
        const testEntity = 'test';
        final result = AnonAccountHelpers.requireEntity(
          testEntity,
          'TEST_ERROR',
          'Test message',
          'testOp',
          {'key': 'value'},
        );
        expect(result, equals(testEntity));
      });

      test('should throw when entity is null', () {
        expect(
          () => AnonAccountHelpers.requireEntity<String>(
            null,
            'TEST_ERROR',
            'Test message',
            'testOp',
            {'key': 'value'},
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('property: requireEntity should return non-null entities', () {
        // Property-based test with 5 iterations for development
        for (var i = 0; i < 5; i++) {
          final entity = 'entity${random.nextInt(1000)}';
          final errorCode = 'ERROR_${random.nextInt(100)}';
          final message = 'Message ${random.nextInt(100)}';
          final operation = 'op${random.nextInt(100)}';
          final details = {'key': 'value${random.nextInt(100)}'};

          final result = AnonAccountHelpers.requireEntity(
            entity,
            errorCode,
            message,
            operation,
            details,
          );

          expect(result, equals(entity));
        }
      });
    });

    group('requireAccount', () {
      test('should return account when not null', () {
        final account = AnonAccount(
          id: UuidValue.fromString('550e8400-e29b-41d4-a716-446655440000'),
          ultimateSigningPublicKeyHex: 'a' * 128, // ECDSA P-256 format
          encryptedDataKey: 'encrypted',
          ultimatePublicKey: 'b' * 128,
        );

        final result = AnonAccountHelpers.requireAccount(account, '1', 'testOp');
        expect(result, equals(account));
      });

      test('should throw when account is null', () {
        expect(
          () => AnonAccountHelpers.requireAccount(null, '1', 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('property: requireAccount should return valid accounts', () {
        // Property-based test with 5 iterations for development
        for (var i = 0; i < 5; i++) {
          final account = AnonAccount(
            id: UuidValue.fromString('550e8400-e29b-41d4-a716-446655440000'),
            ultimateSigningPublicKeyHex: _generateFakePublicKeyString(random),
            encryptedDataKey: 'encrypted${random.nextInt(1000)}',
            ultimatePublicKey: _generateFakePublicKeyString(random),
          );
          final accountIdentifier = 'account-${random.nextInt(1000) + 1}';
          final operation = 'op${random.nextInt(100)}';

          final result = AnonAccountHelpers.requireAccount(account, accountIdentifier, operation);
          expect(result, equals(account));
        }
      });
    });

    group('requireDevice', () {
      test('should return device when not null', () {
        final device = AccountDevice(
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
          anonAccountId: UuidValue.fromString('550e8400-e29b-41d4-a716-446655440000'),
          deviceSigningPublicKeyHex: 'a' * 128, // ECDSA P-256 format
          encryptedDataKey: 'encrypted',
          label: 'test device',
        );

        final result = AnonAccountHelpers.requireDevice(device, 'a' * 128, 'testOp');
        expect(result, equals(device));
      });

      test('should throw when device is null', () {
        expect(
          () => AnonAccountHelpers.requireDevice(null, 'a' * 128, 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('property: requireDevice should return valid devices', () {
        // Property-based test with 5 iterations for development
        for (var i = 0; i < 5; i++) {
          final device = AccountDevice(
            id: UuidValue.fromString('00000000-0000-0000-0000-${(i + 1).toString().padLeft(12, '0')}'),
            anonAccountId: UuidValue.fromString('550e8400-e29b-41d4-a716-446655440000'),
            deviceSigningPublicKeyHex: _generateFakePublicKeyString(random),
            encryptedDataKey: 'encrypted${random.nextInt(1000)}',
            label: 'device${random.nextInt(1000)}',
          );
          final publicKey = _generateFakePublicKeyString(random);
          final operation = 'op${random.nextInt(100)}';

          final result = AnonAccountHelpers.requireDevice(device, publicKey, operation);
          expect(result, equals(device));
        }
      });
    });

    group('requireActiveDevice', () {
      test('should return device when not null and not revoked', () {
        final device = AccountDevice(
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000002'),
          anonAccountId: UuidValue.fromString('550e8400-e29b-41d4-a716-446655440000'),
          deviceSigningPublicKeyHex: 'a' * 128, // ECDSA P-256 format
          encryptedDataKey: 'encrypted',
          label: 'test device',
          isRevoked: false,
        );

        final result = AnonAccountHelpers.requireActiveDevice(device, 'a' * 128, 'testOp');
        expect(result, equals(device));
      });

      test('should throw when device is null', () {
        expect(
          () => AnonAccountHelpers.requireActiveDevice(null, 'a' * 128, 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should throw when device is revoked', () {
        final device = AccountDevice(
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000003'),
          anonAccountId: UuidValue.fromString('550e8400-e29b-41d4-a716-446655440000'),
          deviceSigningPublicKeyHex: 'a' * 128, // ECDSA P-256 format
          encryptedDataKey: 'encrypted',
          label: 'test device',
          isRevoked: true,
        );

        expect(
          () => AnonAccountHelpers.requireActiveDevice(device, 'a' * 128, 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('property: requireActiveDevice should return non-revoked devices', () {
        // Property-based test with 5 iterations for development
        for (var i = 0; i < 5; i++) {
          final device = AccountDevice(
            id: UuidValue.fromString('00000000-0000-0000-0001-${(i + 1).toString().padLeft(12, '0')}'),
            anonAccountId: UuidValue.fromString('550e8400-e29b-41d4-a716-446655440000'),
            deviceSigningPublicKeyHex: _generateFakePublicKeyString(random),
            encryptedDataKey: 'encrypted${random.nextInt(1000)}',
            label: 'device${random.nextInt(1000)}',
            isRevoked: false, // Always non-revoked for this property
          );
          final publicKey = _generateFakePublicKeyString(random);
          final operation = 'op${random.nextInt(100)}';

          final result = AnonAccountHelpers.requireActiveDevice(device, publicKey, operation);
          expect(result, equals(device));
        }
      });

      test('property: requireActiveDevice should reject revoked devices', () {
        // Property-based test with 5 iterations for development
        for (var i = 0; i < 5; i++) {
          final device = AccountDevice(
            id: UuidValue.fromString('00000000-0000-0000-0002-${(i + 1).toString().padLeft(12, '0')}'),
            anonAccountId: UuidValue.fromString('550e8400-e29b-41d4-a716-446655440000'),
            deviceSigningPublicKeyHex: _generateFakePublicKeyString(random),
            encryptedDataKey: 'encrypted${random.nextInt(1000)}',
            label: 'device${random.nextInt(1000)}',
            isRevoked: true, // Always revoked for this property
          );
          final publicKey = _generateFakePublicKeyString(random);
          final operation = 'op${random.nextInt(100)}';

          expect(
            () => AnonAccountHelpers.requireActiveDevice(device, publicKey, operation),
            throwsA(isA<AuthenticationException>()),
          );
        }
      });
    });
  });
}

// Test data generators - These generate FAKE data for testing, not real cryptographic keys
String _generateRandomNonEmptyString(Random random) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final length = random.nextInt(50) + 1; // 1-50 characters
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}

String _generateFakePublicKeyString(Random random) {
  // Generate a fake 128-character hex string for testing (not a real ECDSA P-256 key)
  const chars = '0123456789abcdef';
  return List.generate(128, (index) => chars[random.nextInt(chars.length)]).join();
}

String _generateInvalidPublicKey(Random random) {
  // Generate various invalid key formats for testing
  final invalidTypes = [
    () => '', // Empty string
    () => 'invalid', // Too short
    () => 'g' * 128, // Invalid hex characters
    () => '0123456789abcdef' * 7, // Too short (112 chars)
    () => '0123456789abcdef' * 9, // Too long (144 chars)
  ];

  return invalidTypes[random.nextInt(invalidTypes.length)]();
}
