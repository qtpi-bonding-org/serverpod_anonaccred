import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('AccountEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    test(
      'createAccount - successful account creation with valid ECDSA P-256 key',
      () async {
        // Valid ECDSA P-256 public key (128 hex characters)
        const validPublicKey =
            'a123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdefa123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const encryptedDataKey = 'encrypted_data_key_example_12345';
        const ultimatePublicKey = 
            'b123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdefb123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          validPublicKey,
          encryptedDataKey,
          ultimatePublicKey,
        );

        expect(account.publicMasterKey, equals(validPublicKey));
        expect(account.encryptedDataKey, equals(encryptedDataKey));
        expect(account.id, isNotNull);
        expect(account.createdAt, isNotNull);
      },
    );

    test('createAccount - fails with invalid public key format', () async {
      const invalidPublicKey = 'invalid_key_too_short';
      const encryptedDataKey = 'encrypted_data_key_example_12345';
      const ultimatePublicKey = 
          'c123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdefc123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

      expect(
        () => endpoints.account.createAccount(
          sessionBuilder,
          invalidPublicKey,
          encryptedDataKey,
          ultimatePublicKey,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('createAccount - fails with empty public key', () async {
      const emptyPublicKey = '';
      const encryptedDataKey = 'encrypted_data_key_example_12345';
      const ultimatePublicKey = 
          'd123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdefd123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

      expect(
        () => endpoints.account.createAccount(
          sessionBuilder,
          emptyPublicKey,
          encryptedDataKey,
          ultimatePublicKey,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('createAccount - fails with empty encrypted data key', () async {
      const validPublicKey =
          'e123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdefe123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      const emptyEncryptedDataKey = '';
      const ultimatePublicKey = 
          'f123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdeff123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

      expect(
        () => endpoints.account.createAccount(
          sessionBuilder,
          validPublicKey,
          emptyEncryptedDataKey,
          ultimatePublicKey,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'getAccountByPublicKey - successful lookup of existing account',
      () async {
        // Create an account first
        const validPublicKey =
            '1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const encryptedDataKey = 'encrypted_data_key_example_67890';
        const ultimatePublicKey = 
            '2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

        final createdAccount = await endpoints.account.createAccount(
          sessionBuilder,
          validPublicKey,
          encryptedDataKey,
          ultimatePublicKey,
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
      },
    );

    test(
      'getAccountByPublicKey - returns null for non-existent account',
      () async {
        const nonExistentPublicKey =
            '3123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef3123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

        final foundAccount = await endpoints.account.getAccountByPublicKey(
          sessionBuilder,
          nonExistentPublicKey,
        );

        expect(foundAccount, isNull);
      },
    );

    test(
      'getAccountByPublicKey - fails with invalid public key format',
      () async {
        const invalidPublicKey = 'invalid_key_format';

        expect(
          () => endpoints.account.getAccountByPublicKey(
            sessionBuilder,
            invalidPublicKey,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('getAccountByPublicKey - fails with empty public key', () async {
      const emptyPublicKey = '';

      expect(
        () => endpoints.account.getAccountByPublicKey(
          sessionBuilder,
          emptyPublicKey,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'createAccount - prevents duplicate public key registration',
      () async {
        const duplicatePublicKey =
            '4123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef4123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const encryptedDataKey1 = 'encrypted_data_key_first_12345';
        const encryptedDataKey2 = 'encrypted_data_key_second_67890';
        const ultimatePublicKey1 = 
            '5123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef5123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const ultimatePublicKey2 = 
            '6123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef6123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

        // Create first account
        await endpoints.account.createAccount(
          sessionBuilder,
          duplicatePublicKey,
          encryptedDataKey1,
          ultimatePublicKey1,
        );

        // Attempt to create second account with same public key should fail
        expect(
          () => endpoints.account.createAccount(
            sessionBuilder,
            duplicatePublicKey,
            encryptedDataKey2,
            ultimatePublicKey2,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'encrypted data preservation - data stored without decryption',
      () async {
        const validPublicKey =
            '7123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef7123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const originalEncryptedData =
            r'complex_encrypted_data_with_special_chars_!@#$%^&*()';
        const ultimatePublicKey = 
            '8123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef8123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

        final account = await endpoints.account.createAccount(
          sessionBuilder,
          validPublicKey,
          originalEncryptedData,
          ultimatePublicKey,
        );

        // Verify encrypted data is stored exactly as provided
        expect(account.encryptedDataKey, equals(originalEncryptedData));

        // Verify through lookup as well
        final foundAccount = await endpoints.account.getAccountByPublicKey(
          sessionBuilder,
          validPublicKey,
        );

        expect(foundAccount!.encryptedDataKey, equals(originalEncryptedData));
      },
    );
  });
}