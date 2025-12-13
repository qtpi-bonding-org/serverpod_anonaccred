import 'dart:math';

import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/helpers.dart';
import 'package:test/test.dart';

void main() {
  final random = Random();

  group('AnonAccredHelpers', () {
    group('validateNonEmpty', () {
      test('should pass for valid non-empty string', () {
        expect(
          () => AnonAccredHelpers.validateNonEmpty('valid', 'testField', 'testOp'),
          returnsNormally,
        );
      });

      test('should throw for null string', () {
        expect(
          () => AnonAccredHelpers.validateNonEmpty(null, 'testField', 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should throw for empty string', () {
        expect(
          () => AnonAccredHelpers.validateNonEmpty('', 'testField', 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('property: validateNonEmpty should accept any non-empty string', () {
        // Property-based test with 5 iterations for development
        for (int i = 0; i < 5; i++) {
          final validString = _generateRandomNonEmptyString(random);
          final fieldName = 'field${random.nextInt(100)}';
          final operation = 'op${random.nextInt(100)}';
          
          expect(
            () => AnonAccredHelpers.validateNonEmpty(validString, fieldName, operation),
            returnsNormally,
          );
        }
      });

      test('property: validateNonEmpty should reject null and empty strings', () {
        // Property-based test with 5 iterations for development
        for (int i = 0; i < 5; i++) {
          final fieldName = 'field${random.nextInt(100)}';
          final operation = 'op${random.nextInt(100)}';
          
          // Test null
          expect(
            () => AnonAccredHelpers.validateNonEmpty(null, fieldName, operation),
            throwsA(isA<AuthenticationException>()),
          );
          
          // Test empty string
          expect(
            () => AnonAccredHelpers.validateNonEmpty('', fieldName, operation),
            throwsA(isA<AuthenticationException>()),
          );
        }
      });
    });

    group('validatePublicKey', () {
      test('should pass for valid Ed25519 public key', () {
        // Valid 64-character hex string (32 bytes)
        final validKey = 'a' * 64;
        expect(
          () => AnonAccredHelpers.validatePublicKey(validKey, 'testOp'),
          returnsNormally,
        );
      });

      test('should throw for invalid public key format', () {
        expect(
          () => AnonAccredHelpers.validatePublicKey('invalid', 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should throw for null public key', () {
        expect(
          () => AnonAccredHelpers.validatePublicKey(null, 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('property: validatePublicKey should accept valid Ed25519 keys', () {
        // Property-based test with 5 iterations for development
        for (int i = 0; i < 5; i++) {
          final validKey = _generateValidEd25519PublicKey(random);
          final operation = 'op${random.nextInt(100)}';
          
          expect(
            () => AnonAccredHelpers.validatePublicKey(validKey, operation),
            returnsNormally,
          );
        }
      });

      test('property: validatePublicKey should reject invalid keys', () {
        // Property-based test with 5 iterations for development
        for (int i = 0; i < 5; i++) {
          final invalidKey = _generateInvalidPublicKey(random);
          final operation = 'op${random.nextInt(100)}';
          
          expect(
            () => AnonAccredHelpers.validatePublicKey(invalidKey, operation),
            throwsA(isA<AuthenticationException>()),
          );
        }
      });
    });

    group('requireEntity', () {
      test('should return entity when not null', () {
        const testEntity = 'test';
        final result = AnonAccredHelpers.requireEntity(
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
          () => AnonAccredHelpers.requireEntity<String>(
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
        for (int i = 0; i < 5; i++) {
          final entity = 'entity${random.nextInt(1000)}';
          final errorCode = 'ERROR_${random.nextInt(100)}';
          final message = 'Message ${random.nextInt(100)}';
          final operation = 'op${random.nextInt(100)}';
          final details = {'key': 'value${random.nextInt(100)}'};
          
          final result = AnonAccredHelpers.requireEntity(
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
          id: 1,
          publicMasterKey: 'a' * 64,
          encryptedDataKey: 'encrypted',
        );
        
        final result = AnonAccredHelpers.requireAccount(account, 1, 'testOp');
        expect(result, equals(account));
      });

      test('should throw when account is null', () {
        expect(
          () => AnonAccredHelpers.requireAccount(null, 1, 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('property: requireAccount should return valid accounts', () {
        // Property-based test with 5 iterations for development
        for (int i = 0; i < 5; i++) {
          final account = AnonAccount(
            id: random.nextInt(1000) + 1,
            publicMasterKey: _generateValidEd25519PublicKey(random),
            encryptedDataKey: 'encrypted${random.nextInt(1000)}',
          );
          final accountId = random.nextInt(1000) + 1;
          final operation = 'op${random.nextInt(100)}';
          
          final result = AnonAccredHelpers.requireAccount(account, accountId, operation);
          expect(result, equals(account));
        }
      });
    });

    group('requireDevice', () {
      test('should return device when not null', () {
        final device = AccountDevice(
          id: 1,
          accountId: 1,
          publicSubKey: 'a' * 64,
          encryptedDataKey: 'encrypted',
          label: 'test device',
        );
        
        final result = AnonAccredHelpers.requireDevice(device, 'a' * 64, 'testOp');
        expect(result, equals(device));
      });

      test('should throw when device is null', () {
        expect(
          () => AnonAccredHelpers.requireDevice(null, 'a' * 64, 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('property: requireDevice should return valid devices', () {
        // Property-based test with 5 iterations for development
        for (int i = 0; i < 5; i++) {
          final device = AccountDevice(
            id: random.nextInt(1000) + 1,
            accountId: random.nextInt(1000) + 1,
            publicSubKey: _generateValidEd25519PublicKey(random),
            encryptedDataKey: 'encrypted${random.nextInt(1000)}',
            label: 'device${random.nextInt(1000)}',
          );
          final publicKey = _generateValidEd25519PublicKey(random);
          final operation = 'op${random.nextInt(100)}';
          
          final result = AnonAccredHelpers.requireDevice(device, publicKey, operation);
          expect(result, equals(device));
        }
      });
    });

    group('requireActiveDevice', () {
      test('should return device when not null and not revoked', () {
        final device = AccountDevice(
          id: 1,
          accountId: 1,
          publicSubKey: 'a' * 64,
          encryptedDataKey: 'encrypted',
          label: 'test device',
          isRevoked: false,
        );
        
        final result = AnonAccredHelpers.requireActiveDevice(device, 'a' * 64, 'testOp');
        expect(result, equals(device));
      });

      test('should throw when device is null', () {
        expect(
          () => AnonAccredHelpers.requireActiveDevice(null, 'a' * 64, 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should throw when device is revoked', () {
        final device = AccountDevice(
          id: 1,
          accountId: 1,
          publicSubKey: 'a' * 64,
          encryptedDataKey: 'encrypted',
          label: 'test device',
          isRevoked: true,
        );
        
        expect(
          () => AnonAccredHelpers.requireActiveDevice(device, 'a' * 64, 'testOp'),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('property: requireActiveDevice should return non-revoked devices', () {
        // Property-based test with 5 iterations for development
        for (int i = 0; i < 5; i++) {
          final device = AccountDevice(
            id: random.nextInt(1000) + 1,
            accountId: random.nextInt(1000) + 1,
            publicSubKey: _generateValidEd25519PublicKey(random),
            encryptedDataKey: 'encrypted${random.nextInt(1000)}',
            label: 'device${random.nextInt(1000)}',
            isRevoked: false, // Always non-revoked for this property
          );
          final publicKey = _generateValidEd25519PublicKey(random);
          final operation = 'op${random.nextInt(100)}';
          
          final result = AnonAccredHelpers.requireActiveDevice(device, publicKey, operation);
          expect(result, equals(device));
        }
      });

      test('property: requireActiveDevice should reject revoked devices', () {
        // Property-based test with 5 iterations for development
        for (int i = 0; i < 5; i++) {
          final device = AccountDevice(
            id: random.nextInt(1000) + 1,
            accountId: random.nextInt(1000) + 1,
            publicSubKey: _generateValidEd25519PublicKey(random),
            encryptedDataKey: 'encrypted${random.nextInt(1000)}',
            label: 'device${random.nextInt(1000)}',
            isRevoked: true, // Always revoked for this property
          );
          final publicKey = _generateValidEd25519PublicKey(random);
          final operation = 'op${random.nextInt(100)}';
          
          expect(
            () => AnonAccredHelpers.requireActiveDevice(device, publicKey, operation),
            throwsA(isA<AuthenticationException>()),
          );
        }
      });
    });
  });
}

// Test data generators
String _generateRandomNonEmptyString(Random random) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final length = random.nextInt(50) + 1; // 1-50 characters
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}

String _generateValidEd25519PublicKey(Random random) {
  // Generate a valid 64-character hex string (32 bytes)
  const chars = '0123456789abcdef';
  return List.generate(64, (index) => chars[random.nextInt(chars.length)]).join();
}

String _generateInvalidPublicKey(Random random) {
  // Generate various invalid key formats
  final invalidTypes = [
    () => '', // Empty string
    () => 'invalid', // Too short
    () => 'g' * 64, // Invalid hex characters
    () => '0123456789abcdef' * 3, // Too short (48 chars)
    () => '0123456789abcdef' * 5, // Too long (80 chars)
  ];
  
  return invalidTypes[random.nextInt(invalidTypes.length)]();
}