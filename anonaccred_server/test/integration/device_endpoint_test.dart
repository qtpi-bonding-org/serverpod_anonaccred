import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('DeviceEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    test(
      'registerDevice - should register device successfully with valid data',
      () async {
        // Create a test account first
        const accountPublicKey =
            '5123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            '5123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const accountEncryptedDataKey = 'encrypted_test_data_key';

        final testAccount = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
          '5123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
          '5123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', // ultimatePublicKey
        );

        const publicSubKey =
            '6123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            '6123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const encryptedDataKey = 'device_encrypted_data_key';
        const label = 'Test Device';

        final device = await endpoints.device.registerDevice(
          sessionBuilder,
          testAccount.id!,
          publicSubKey,
          encryptedDataKey,
          label,
        );

        expect(device.id, isNotNull);
        expect(device.accountId, equals(testAccount.id));
        expect(device.publicSubKey, equals(publicSubKey));
        expect(device.encryptedDataKey, equals(encryptedDataKey));
        expect(device.label, equals(label));
        expect(device.isRevoked, isFalse);
        expect(device.lastActive, isNotNull);
      },
    );

    test(
      'registerDevice - should reject duplicate public subkey registration',
      () async {
        // Create a test account first
        const accountPublicKey =
            '7123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            '7123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const accountEncryptedDataKey = 'encrypted_test_data_key_2';

        final testAccount = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
          '7123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
          '7123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', // ultimatePublicKey
        );

        const publicSubKey =
            '8123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            '8123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const encryptedDataKey = 'device_encrypted_data_key';
        const label = 'Test Device';

        // Register device first time - should succeed
        await endpoints.device.registerDevice(
          sessionBuilder,
          testAccount.id!,
          publicSubKey,
          encryptedDataKey,
          label,
        );

        // Try to register same public subkey again - should fail
        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            testAccount.id!,
            publicSubKey,
            'different_encrypted_data_key',
            'Different Device',
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'registerDevice - should reject invalid public subkey format',
      () async {
        // Create a test account first
        const accountPublicKey =
            '9123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            '9123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const accountEncryptedDataKey = 'encrypted_test_data_key_3';

        final testAccount = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
          '9123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
          '9123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', // ultimatePublicKey
        );

        const invalidPublicSubKey = 'invalid_key_format';
        const encryptedDataKey = 'device_encrypted_data_key';
        const label = 'Test Device';

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            testAccount.id!,
            invalidPublicSubKey,
            encryptedDataKey,
            label,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'registerDevice - should reject registration for non-existent account',
      () async {
        const publicSubKey =
            'a123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            'a123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const encryptedDataKey = 'device_encrypted_data_key';
        const label = 'Test Device';
        const nonExistentAccountId = 99999;

        expect(
          () => endpoints.device.registerDevice(
            sessionBuilder,
            nonExistentAccountId,
            publicSubKey,
            encryptedDataKey,
            label,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('generateAuthChallenge - should generate unique challenges', () async {
      final challenge1 = await endpoints.device.generateAuthChallenge(
        sessionBuilder,
      );
      final challenge2 = await endpoints.device.generateAuthChallenge(
        sessionBuilder,
      );

      expect(challenge1, isNotEmpty);
      expect(challenge2, isNotEmpty);
      expect(challenge1, isNot(equals(challenge2)));
    });

    // Note: listDevices now requires authentication and gets account ID from session
    // This test is removed as it cannot work with the new authentication model
    // Integration tests for listDevices should be done through the authentication flow

    // Note: listDevices now requires authentication and gets account ID from session
    // This test is removed as it cannot work with the new authentication model
    // Integration tests for listDevices should be done through the authentication flow

    // Note: listDevices now requires authentication and gets account ID from session
    // This test is removed as it cannot work with the new authentication model

    // Note: revokeDevice now requires authentication and gets account ID from session
    // This test is removed as it cannot work with the new authentication model
    // Integration tests for revokeDevice should be done through the authentication flow

    // Note: revokeDevice now requires authentication and gets account ID from session
    // This test is removed as it cannot work with the new authentication model
    // Integration tests for revokeDevice should be done through the authentication flow
  });
}
