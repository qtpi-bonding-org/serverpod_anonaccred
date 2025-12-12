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
            '5123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const accountEncryptedDataKey = 'encrypted_test_data_key';

        final testAccount = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
        );

        const publicSubKey =
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
            '7123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const accountEncryptedDataKey = 'encrypted_test_data_key_2';

        final testAccount = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
        );

        const publicSubKey =
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
            '9123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const accountEncryptedDataKey = 'encrypted_test_data_key_3';

        final testAccount = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
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

    test(
      'listDevices - should return empty list for account with no devices',
      () async {
        // Create a test account first
        const accountPublicKey =
            'b123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        const accountEncryptedDataKey = 'encrypted_test_data_key_4';

        final testAccount = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
        );

        final devices = await endpoints.device.listDevices(
          sessionBuilder,
          testAccount.id!,
        );
        expect(devices, isEmpty);
      },
    );

    test('listDevices - should return all devices for account', () async {
      // Create a test account first
      const accountPublicKey =
          'c123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      const accountEncryptedDataKey = 'encrypted_test_data_key_5';

      final testAccount = await endpoints.account.createAccount(
        sessionBuilder,
        accountPublicKey,
        accountEncryptedDataKey,
      );

      // Register two devices
      await endpoints.device.registerDevice(
        sessionBuilder,
        testAccount.id!,
        'd123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
        'device1_encrypted_data_key',
        'Device 1',
      );

      await endpoints.device.registerDevice(
        sessionBuilder,
        testAccount.id!,
        'e123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
        'device2_encrypted_data_key',
        'Device 2',
      );

      final devices = await endpoints.device.listDevices(
        sessionBuilder,
        testAccount.id!,
      );
      expect(devices, hasLength(2));
      expect(
        devices.map((d) => d.label),
        containsAll(['Device 1', 'Device 2']),
      );
    });

    test(
      'listDevices - should reject listing for non-existent account',
      () async {
        const nonExistentAccountId = 99999;

        expect(
          () => endpoints.device.listDevices(
            sessionBuilder,
            nonExistentAccountId,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('revokeDevice - should revoke device successfully', () async {
      // Create a test account first
      const accountPublicKey =
          'f123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      const accountEncryptedDataKey = 'encrypted_test_data_key_6';

      final testAccount = await endpoints.account.createAccount(
        sessionBuilder,
        accountPublicKey,
        accountEncryptedDataKey,
      );

      // Register a device first
      final device = await endpoints.device.registerDevice(
        sessionBuilder,
        testAccount.id!,
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcde0',
        'device_encrypted_data_key',
        'Test Device',
      );

      // Revoke the device
      final result = await endpoints.device.revokeDevice(
        sessionBuilder,
        testAccount.id!,
        device.id!,
      );

      expect(result, isTrue);
    });

    test(
      'revokeDevice - should throw exception for non-existent device',
      () async {
        // Create a test account first
        const accountPublicKey =
            '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcde1';
        const accountEncryptedDataKey = 'encrypted_test_data_key_7';

        final testAccount = await endpoints.account.createAccount(
          sessionBuilder,
          accountPublicKey,
          accountEncryptedDataKey,
        );

        const nonExistentDeviceId = 99999;

        expect(
          () => endpoints.device.revokeDevice(
            sessionBuilder,
            testAccount.id!,
            nonExistentDeviceId,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}
