import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('AccountEndpoint Integration Tests', (sessionBuilder, endpoints) {
    test('createAccount - successful account creation with valid Ed25519 key', () async {
      // Valid Ed25519 public key (64 hex characters) - using all lowercase
      const validPublicKey = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      const encryptedDataKey = 'encrypted_data_key_example_12345';

      final account = await endpoints.account.createAccount(
        sessionBuilder,
        validPublicKey,
        encryptedDataKey,
      );

      expect(account.publicMasterKey, equals(validPublicKey));
      expect(account.encryptedDataKey, equals(encryptedDataKey));
      expect(account.id, isNotNull);
      expect(account.createdAt, isNotNull);
    });

    test('createAccount - fails with invalid public key format', () async {
      const invalidPublicKey = 'invalid_key_too_short';
      const encryptedDataKey = 'encrypted_data_key_example_12345';

      expect(
        () => endpoints.account.createAccount(
          sessionBuilder,
          invalidPublicKey,
          encryptedDataKey,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('createAccount - fails with empty public key', () async {
      const emptyPublicKey = '';
      const encryptedDataKey = 'encrypted_data_key_example_12345';

      expect(
        () => endpoints.account.createAccount(
          sessionBuilder,
          emptyPublicKey,
          encryptedDataKey,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('createAccount - fails with empty encrypted data key', () async {
      const validPublicKey = 'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';
      const emptyEncryptedDataKey = '';

      expect(
        () => endpoints.account.createAccount(
          sessionBuilder,
          validPublicKey,
          emptyEncryptedDataKey,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('getAccountByPublicKey - successful lookup of existing account', () async {
      // Create an account first
      const validPublicKey = '1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      const encryptedDataKey = 'encrypted_data_key_example_67890';

      final createdAccount = await endpoints.account.createAccount(
        sessionBuilder,
        validPublicKey,
        encryptedDataKey,
      );

      // Now lookup the account
      final foundAccount = await endpoints.account.getAccountByPublicKey(
        sessionBuilder,
        validPublicKey,
      );

      expect(foundAccount, isNotNull);
      expect(foundAccount!.id, equals(createdAccount.id));
      expect(foundAccount.publicMasterKey, equals(validPublicKey));
      expect(foundAccount.encryptedDataKey, equals(encryptedDataKey));
    });

    test('getAccountByPublicKey - returns null for non-existent account', () async {
      const nonExistentPublicKey = '2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

      final foundAccount = await endpoints.account.getAccountByPublicKey(
        sessionBuilder,
        nonExistentPublicKey,
      );

      expect(foundAccount, isNull);
    });

    test('getAccountByPublicKey - fails with invalid public key format', () async {
      const invalidPublicKey = 'invalid_key_format';

      expect(
        () => endpoints.account.getAccountByPublicKey(sessionBuilder, invalidPublicKey),
        throwsA(isA<Exception>()),
      );
    });

    test('getAccountByPublicKey - fails with empty public key', () async {
      const emptyPublicKey = '';

      expect(
        () => endpoints.account.getAccountByPublicKey(sessionBuilder, emptyPublicKey),
        throwsA(isA<Exception>()),
      );
    });

    test('createAccount - prevents duplicate public key registration', () async {
      const duplicatePublicKey = '3123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      const encryptedDataKey1 = 'encrypted_data_key_first_12345';
      const encryptedDataKey2 = 'encrypted_data_key_second_67890';

      // Create first account
      await endpoints.account.createAccount(
        sessionBuilder,
        duplicatePublicKey,
        encryptedDataKey1,
      );

      // Attempt to create second account with same public key should fail
      expect(
        () => endpoints.account.createAccount(
          sessionBuilder,
          duplicatePublicKey,
          encryptedDataKey2,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('encrypted data preservation - data stored without decryption', () async {
      const validPublicKey = '4123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      const originalEncryptedData = 'complex_encrypted_data_with_special_chars_!@#\$%^&*()';

      final account = await endpoints.account.createAccount(
        sessionBuilder,
        validPublicKey,
        originalEncryptedData,
      );

      // Verify encrypted data is stored exactly as provided
      expect(account.encryptedDataKey, equals(originalEncryptedData));

      // Verify through lookup as well
      final foundAccount = await endpoints.account.getAccountByPublicKey(
        sessionBuilder,
        validPublicKey,
      );

      expect(foundAccount!.encryptedDataKey, equals(originalEncryptedData));
    });
  });
}