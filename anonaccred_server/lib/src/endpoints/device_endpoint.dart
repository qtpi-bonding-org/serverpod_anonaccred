import 'package:serverpod/serverpod.dart';
import '../crypto_auth.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';

/// Device management endpoints for Ed25519-based device registration and authentication
///
/// This endpoint provides device management functionality including:
/// - Device registration with Ed25519 subkeys
/// - Challenge-response authentication
/// - Device revocation and listing
/// - Integration with existing AccountDevice model from Phase 1
class DeviceEndpoint extends Endpoint {
  /// Register new device with account
  ///
  /// Creates a new device registration associated with an account.
  /// The device is identified by its Ed25519 public subkey.
  ///
  /// Parameters:
  /// - [accountId]: The account to associate the device with
  /// - [publicSubKey]: Ed25519 public key for the device (64 hex chars)
  /// - [encryptedDataKey]: Device-encrypted SDK (never decrypted server-side)
  /// - [label]: Human-readable device name
  ///
  /// Returns the created AccountDevice with assigned ID.
  ///
  /// Throws AuthenticationException if:
  /// - Public subkey format is invalid
  /// - Account does not exist
  /// - Public subkey is already registered
  /// - Required parameters are empty
  Future<AccountDevice> registerDevice(
    Session session,
    int accountId,
    String publicSubKey,
    String encryptedDataKey,
    String label,
  ) async {
    try {
      // Validate input parameters
      if (publicSubKey.isEmpty) {
        final exception =
            AnonAccredExceptionFactory.createAuthenticationException(
              code: AnonAccredErrorCodes.authMissingKey,
              message: 'Public subkey is required for device registration',
              operation: 'registerDevice',
              details: {'publicSubKey': 'empty'},
            );

        throw exception;
      }

      if (encryptedDataKey.isEmpty) {
        final exception =
            AnonAccredExceptionFactory.createAuthenticationException(
              code: AnonAccredErrorCodes.cryptoInvalidMessage,
              message: 'Encrypted data key is required for device registration',
              operation: 'registerDevice',
              details: {'encryptedDataKey': 'empty'},
            );

        throw exception;
      }

      if (label.isEmpty) {
        final exception =
            AnonAccredExceptionFactory.createAuthenticationException(
              code: AnonAccredErrorCodes.cryptoInvalidMessage,
              message: 'Device label is required for device registration',
              operation: 'registerDevice',
              details: {'label': 'empty'},
            );

        throw exception;
      }

      // Validate public subkey format
      if (!CryptoAuth.isValidPublicKey(publicSubKey)) {
        final exception =
            AnonAccredExceptionFactory.createAuthenticationException(
              code: AnonAccredErrorCodes.cryptoInvalidPublicKey,
              message: 'Invalid Ed25519 public subkey format',
              operation: 'registerDevice',
              details: {
                'publicSubKeyLength': publicSubKey.length.toString(),
                'expectedLength': '64',
                'accountId': accountId.toString(),
              },
            );

        throw exception;
      }

      // Check if account exists
      final account = await AnonAccount.db.findById(session, accountId);
      if (account == null) {
        final exception =
            AnonAccredExceptionFactory.createAuthenticationException(
              code: AnonAccredErrorCodes.authAccountNotFound,
              message: 'Account not found',
              operation: 'registerDevice',
              details: {'accountId': accountId.toString()},
            );

        throw exception;
      }

      // Check for duplicate public subkey
      final existingDevice = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.publicSubKey.equals(publicSubKey),
      );

      if (existingDevice != null) {
        final exception =
            AnonAccredExceptionFactory.createAuthenticationException(
              code: AnonAccredErrorCodes.authDuplicateDevice,
              message: 'Public subkey already registered',
              operation: 'registerDevice',
              details: {
                'publicSubKey': publicSubKey,
                'existingDeviceId': existingDevice.id.toString(),
                'accountId': accountId.toString(),
              },
            );

        throw exception;
      }

      // Create new device
      final device = AccountDevice(
        accountId: accountId,
        publicSubKey: publicSubKey,
        encryptedDataKey: encryptedDataKey,
        label: label,
        lastActive: DateTime.now(),
        isRevoked: false,
      );

      // Insert device into database
      final insertedDevice = await AccountDevice.db.insertRow(session, device);

      return insertedDevice;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      // Log unexpected error

      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to register device: ${e.toString()}',
        operation: 'registerDevice',
        details: {'error': e.toString(), 'accountId': accountId.toString()},
      );
    }
  }

  /// Authenticate device with challenge-response
  ///
  /// Performs Ed25519 signature verification for device authentication.
  /// Updates the device's last active timestamp on successful authentication.
  ///
  /// Parameters:
  /// - [publicSubKey]: Ed25519 public key for the device
  /// - [challenge]: The challenge string that was signed
  /// - [signature]: Ed25519 signature of the challenge
  ///
  /// Returns AuthenticationResult with success/failure information.
  Future<AuthenticationResult> authenticateDevice(
    Session session,
    String publicSubKey,
    String challenge,
    String signature,
  ) async {
    try {
      // Validate input parameters
      if (publicSubKey.isEmpty) {
        return AuthenticationResultFactory.failure(
          errorCode: AnonAccredErrorCodes.authMissingKey,
          errorMessage: 'Public subkey is required for authentication',
          details: {'publicSubKey': 'empty'},
        );
      }

      if (challenge.isEmpty) {
        return AuthenticationResultFactory.failure(
          errorCode: AnonAccredErrorCodes.cryptoInvalidMessage,
          errorMessage: 'Challenge is required for authentication',
          details: {'challenge': 'empty'},
        );
      }

      if (signature.isEmpty) {
        return AuthenticationResultFactory.failure(
          errorCode: AnonAccredErrorCodes.cryptoInvalidSignature,
          errorMessage: 'Signature is required for authentication',
          details: {'signature': 'empty'},
        );
      }

      // Find device by public subkey
      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.publicSubKey.equals(publicSubKey),
      );

      if (device == null) {
        return AuthenticationResultFactory.failure(
          errorCode: AnonAccredErrorCodes.authDeviceNotFound,
          errorMessage: 'Device not found',
          details: {'publicSubKey': publicSubKey},
        );
      }

      // Check if device is revoked
      if (device.isRevoked) {
        return AuthenticationResultFactory.failure(
          errorCode: AnonAccredErrorCodes.authDeviceRevoked,
          errorMessage: 'Device has been revoked',
          details: {
            'deviceId': device.id.toString(),
            'publicSubKey': publicSubKey,
          },
        );
      }

      // Verify challenge-response signature
      final verificationResult = await CryptoAuth.verifyChallengeResponse(
        publicSubKey,
        challenge,
        signature,
      );

      if (verificationResult.success) {
        // Update last active timestamp
        final updatedDevice = await AccountDevice.db.updateRow(
          session,
          device.copyWith(lastActive: DateTime.now()),
        );

        return AuthenticationResultFactory.success(
          accountId: device.accountId,
          deviceId: device.id,
          details: {
            'publicSubKey': publicSubKey,
            'lastActive': updatedDevice.lastActive.toIso8601String(),
          },
        );
      } else {
        return verificationResult; // Return the failure result from crypto verification
      }
    } on Exception catch (e) {
      // Log unexpected error

      return AuthenticationResultFactory.failure(
        errorCode: AnonAccredErrorCodes.databaseError,
        errorMessage: 'Authentication failed: ${e.toString()}',
        details: {'error': e.toString(), 'publicSubKey': publicSubKey},
      );
    }
  }

  /// Generate authentication challenge
  ///
  /// Creates a cryptographically secure challenge string for client use.
  /// The challenge should be signed by the client's private key and returned
  /// for verification via authenticateDevice.
  ///
  /// Returns a hex-encoded challenge string.
  Future<String> generateAuthChallenge(Session session) async =>
      CryptoAuth.generateChallenge();

  /// Revoke device access
  ///
  /// Marks a device as revoked, preventing future authentication attempts.
  /// The device record is preserved for audit purposes.
  ///
  /// Parameters:
  /// - [accountId]: The account that owns the device
  /// - [deviceId]: The device to revoke
  ///
  /// Returns true if revocation succeeded.
  ///
  /// Throws AuthenticationException if account/device validation fails or device not found.
  Future<bool> revokeDevice(
    Session session,
    int accountId,
    int deviceId,
  ) async {
    try {
      // Verify account exists first
      final account = await AnonAccount.db.findById(session, accountId);
      if (account == null) {
        final exception =
            AnonAccredExceptionFactory.createAuthenticationException(
              code: AnonAccredErrorCodes.authAccountNotFound,
              message: 'Account not found',
              operation: 'revokeDevice',
              details: {'accountId': accountId.toString()},
            );

        throw exception;
      }

      // Find device and verify it belongs to the account
      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.id.equals(deviceId) & t.accountId.equals(accountId),
      );

      if (device == null) {
        final exception =
            AnonAccredExceptionFactory.createAuthenticationException(
              code: AnonAccredErrorCodes.authDeviceNotFound,
              message: 'Device not found or does not belong to account',
              operation: 'revokeDevice',
              details: {
                'accountId': accountId.toString(),
                'deviceId': deviceId.toString(),
              },
            );

        throw exception;
      }

      // Mark device as revoked
      await AccountDevice.db.updateRow(
        session,
        device.copyWith(isRevoked: true),
      );

      return true;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      // Log unexpected error

      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to revoke device: ${e.toString()}',
        operation: 'revokeDevice',
        details: {
          'error': e.toString(),
          'accountId': accountId.toString(),
          'deviceId': deviceId.toString(),
        },
      );
    }
  }

  /// List account devices
  ///
  /// Returns all devices registered to an account with complete metadata.
  /// Includes both active and revoked devices for management purposes.
  ///
  /// Parameters:
  /// - [accountId]: The account to list devices for
  ///
  /// Returns list of AccountDevice objects with metadata.
  /// Returns empty list if no devices are registered.
  ///
  /// Throws AuthenticationException if account does not exist.
  Future<List<AccountDevice>> listDevices(
    Session session,
    int accountId,
  ) async {
    try {
      // Verify account exists
      final account = await AnonAccount.db.findById(session, accountId);
      if (account == null) {
        final exception =
            AnonAccredExceptionFactory.createAuthenticationException(
              code: AnonAccredErrorCodes.authAccountNotFound,
              message: 'Account not found',
              operation: 'listDevices',
              details: {'accountId': accountId.toString()},
            );

        throw exception;
      }

      // Find all devices for the account
      final devices = await AccountDevice.db.find(
        session,
        where: (t) => t.accountId.equals(accountId),
        orderBy: (t) => t.lastActive,
        orderDescending: true, // Most recently active first
      );

      return devices;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      // Log unexpected error

      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to list devices: ${e.toString()}',
        operation: 'listDevices',
        details: {'error': e.toString(), 'accountId': accountId.toString()},
      );
    }
  }
}
