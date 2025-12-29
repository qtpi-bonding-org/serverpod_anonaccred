import 'package:serverpod/serverpod.dart';
import '../auth_handler.dart';
import '../crypto_auth.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../helpers.dart';

/// Device management endpoints for ECDSA P-256 device registration and authentication
///
/// This endpoint provides device management functionality including:
/// - Device registration with ECDSA P-256 subkeys
/// - Challenge-response authentication
/// - Device revocation and listing
/// - Integration with existing AccountDevice model from Phase 1
class DeviceEndpoint extends Endpoint {
  
  @override
  bool get requireLogin => false; // Methods handle authentication individually
  /// Register new device with account
  ///
  /// Creates a new device registration associated with an account.
  /// The device is identified by its ECDSA P-256 public subkey.
  ///
  /// Parameters:
  /// - [accountId]: The account to associate the device with
  /// - [publicSubKey]: ECDSA P-256 public key for the device (128 hex chars, x||y coordinates)
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
              message: 'Invalid ECDSA P-256 public subkey format',
              operation: 'registerDevice',
              details: {
                'publicSubKeyLength': publicSubKey.length.toString(),
                'expectedLength': '128 or 130',
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
  /// Performs ECDSA P-256 signature verification for device authentication.
  /// Updates the device's last active timestamp on successful authentication.
  /// Authentication already validated by Serverpod - device key extracted from session.
  ///
  /// Parameters:
  /// - [challenge]: The challenge string that was signed
  /// - [signature]: ECDSA P-256 signature of the challenge (128 hex chars, r||s format)
  ///
  /// Returns AuthenticationResult with success/failure information.
  Future<AuthenticationResult> authenticateDevice(
    Session session,
    String challenge,
    String signature,
  ) async {
    try {
      // Check if session is authenticated
      if (session.authenticated == null) {
        throw AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.authMissingKey,
          message: 'Authentication required for device authentication',
          operation: 'authenticateDevice',
          details: {},
        );
      }
      
      // Get device key and account ID from authenticated session
      final publicKey = AnonAccredAuthHandler.getDevicePublicKey(session);
      final accountId = int.parse(session.authenticated!.userIdentifier);
      
      // Validate input parameters using helpers
      AnonAccredHelpers.validateNonEmpty(challenge, 'challenge', 'authenticateDevice');
      AnonAccredHelpers.validateNonEmpty(signature, 'signature', 'authenticateDevice');

      // Find device by public subkey (should exist since authentication passed)
      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.publicSubKey.equals(publicKey),
      );

      // Use helper to ensure device exists and is active
      final activeDevice = AnonAccredHelpers.requireActiveDevice(
        device, 
        publicKey, 
        'authenticateDevice',
      );

      // Verify challenge-response signature
      final verificationResult = await CryptoAuth.verifyChallengeResponse(
        publicKey,
        challenge,
        signature,
      );

      if (verificationResult.success) {
        // Update last active timestamp
        final updatedDevice = await AccountDevice.db.updateRow(
          session,
          activeDevice.copyWith(lastActive: DateTime.now()),
        );

        return AuthenticationResultFactory.success(
          accountId: accountId,
          deviceId: activeDevice.id,
          details: {
            'publicSubKey': publicKey,
            'lastActive': updatedDevice.lastActive.toIso8601String(),
          },
        );
      } else {
        return verificationResult; // Return the failure result from crypto verification
      }
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Authentication failed: ${e.toString()}',
        operation: 'authenticateDevice',
        details: {'error': e.toString()},
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
  /// Account ownership automatically verified through authentication.
  ///
  /// Parameters:
  /// - [deviceId]: The device to revoke
  ///
  /// Returns true if revocation succeeded.
  ///
  /// Throws AuthenticationException if device validation fails or device not found.
  Future<bool> revokeDevice(
    Session session,
    int deviceId,
  ) async {
    try {
      // Check if session is authenticated
      if (session.authenticated == null) {
        throw AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.authMissingKey,
          message: 'Authentication required for device revocation',
          operation: 'revokeDevice',
          details: {},
        );
      }
      
      // Validate deviceId parameter
      if (deviceId <= 0) {
        throw AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.authMissingKey,
          message: 'deviceId is required for revokeDevice',
          operation: 'revokeDevice',
          details: {'deviceId': deviceId.toString()},
        );
      }

      // Get authenticated account ID from session
      final accountId = int.parse(session.authenticated!.userIdentifier);
      
      // Find device and verify it belongs to the authenticated account
      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.id.equals(deviceId) & t.accountId.equals(accountId),
      );

      // Use helper to ensure device exists and belongs to account
      final foundDevice = AnonAccredHelpers.requireDevice(
        device, 
        'deviceId:$deviceId', 
        'revokeDevice',
      );

      // Mark device as revoked
      await AccountDevice.db.updateRow(
        session,
        foundDevice.copyWith(isRevoked: true),
      );

      return true;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to revoke device: ${e.toString()}',
        operation: 'revokeDevice',
        details: {
          'error': e.toString(),
          'deviceId': deviceId.toString(),
        },
      );
    }
  }

  /// List account devices
  ///
  /// Returns all devices registered to the authenticated account with complete metadata.
  /// Includes both active and revoked devices for management purposes.
  /// Account ownership automatically verified through authentication.
  ///
  /// Returns list of AccountDevice objects with metadata.
  /// Returns empty list if no devices are registered.
  Future<List<AccountDevice>> listDevices(Session session) async {
    try {
      // Check if session is authenticated
      if (session.authenticated == null) {
        throw AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.authMissingKey,
          message: 'Authentication required for listing devices',
          operation: 'listDevices',
          details: {},
        );
      }
      
      final accountId = int.parse(session.authenticated!.userIdentifier);
      
      // Find all devices for the authenticated account
      final devices = await AccountDevice.db.find(
        session,
        where: (t) => t.accountId.equals(accountId),
        orderBy: (t) => t.lastActive,
        orderDescending: true, // Most recently active first
      );

      return devices;
    } catch (e) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to list devices: ${e.toString()}',
        operation: 'listDevices',
        details: {'error': e.toString()},
      );
    }
  }

  /// Register a new device for the caller's account (QR code pairing flow).
  /// 
  /// Device A (authenticated) calls this to register Device B.
  /// Server derives accountId from Device A's authenticated session.
  /// 
  /// SECURITY: Caller must be authenticated with an active (non-revoked) device.
  /// The auth handler already enforces this via requireActiveDevice().
  /// 
  /// Parameters:
  /// - [newDeviceSigningPublicKeyHex]: Device B's ECDSA P-256 signing public key (128 hex)
  /// - [newDeviceEncryptedDataKey]: SDK encrypted with Device B's RSA public key
  /// - [label]: Human-readable device name
  /// 
  /// Returns the created AccountDevice.
  /// 
  /// Throws AuthenticationException if:
  /// - Caller is not authenticated
  /// - Caller's device not found
  /// - New device public key format is invalid
  /// - New device public key already registered
  Future<AccountDevice> registerDeviceForAccount(
    Session session,
    String newDeviceSigningPublicKeyHex,
    String newDeviceEncryptedDataKey,
    String label,
  ) async {
    try {
      // Require authentication (revoked devices already blocked by auth handler)
      if (session.authenticated == null) {
        throw AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.authMissingKey,
          message: 'Authentication required to register new device',
          operation: 'registerDeviceForAccount',
          details: {},
        );
      }
      
      // Get caller's device → derive accountId
      final callerDeviceKey = AnonAccredAuthHandler.getDevicePublicKey(session);
      final callerDevice = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.publicSubKey.equals(callerDeviceKey),
      );
      
      if (callerDevice == null) {
        throw AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.authDeviceNotFound,
          message: 'Caller device not found',
          operation: 'registerDeviceForAccount',
          details: {'callerDeviceKey': callerDeviceKey},
        );
      }
      
      // Validate new device key format
      AnonAccredHelpers.validatePublicKey(newDeviceSigningPublicKeyHex, 'registerDeviceForAccount');
      AnonAccredHelpers.validateNonEmpty(newDeviceEncryptedDataKey, 'newDeviceEncryptedDataKey', 'registerDeviceForAccount');
      AnonAccredHelpers.validateNonEmpty(label, 'label', 'registerDeviceForAccount');
      
      // Check for duplicate
      final existing = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.publicSubKey.equals(newDeviceSigningPublicKeyHex),
      );
      if (existing != null) {
        throw AnonAccredExceptionFactory.createAuthenticationException(
          code: AnonAccredErrorCodes.authDuplicateDevice,
          message: 'Device already registered',
          operation: 'registerDeviceForAccount',
          details: {'newDeviceSigningPublicKeyHex': newDeviceSigningPublicKeyHex},
        );
      }
      
      // Register new device under same account
      final newDevice = AccountDevice(
        accountId: callerDevice.accountId,  // Derived from caller's session
        publicSubKey: newDeviceSigningPublicKeyHex,
        encryptedDataKey: newDeviceEncryptedDataKey,
        label: label,
        lastActive: DateTime.now(),
        isRevoked: false,
      );
      
      return await AccountDevice.db.insertRow(session, newDevice);
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to register device for account: ${e.toString()}',
        operation: 'registerDeviceForAccount',
        details: {'error': e.toString()},
      );
    }
  }

  /// Get device info by signing public key (for pairing completion).
  /// 
  /// UNAUTHENTICATED - Device B doesn't have credentials yet.
  /// Only returns the encrypted blob needed to complete pairing.
  /// 
  /// SECURITY: 
  /// - Only returns encryptedDataKey (useless without Device B's private key)
  /// - No account identifiers exposed
  /// - 128-hex key is not enumerable (2^512 possibilities)
  /// 
  /// Parameters:
  /// - [signingPublicKeyHex]: Device's ECDSA P-256 signing public key (128 hex)
  /// 
  /// Returns DevicePairingInfo if device is registered, null otherwise.
  Future<DevicePairingInfo?> getDeviceBySigningKey(
    Session session,
    String signingPublicKeyHex,
  ) async {
    try {
      // Validate key format
      AnonAccredHelpers.validatePublicKey(signingPublicKeyHex, 'getDeviceBySigningKey');
      
      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.publicSubKey.equals(signingPublicKeyHex),
      );
      
      if (device == null) return null;
      
      // Return only what Device B needs - no account identifiers
      return DevicePairingInfo(
        encryptedDataKey: device.encryptedDataKey,
      );
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createAuthenticationException(
        code: AnonAccredErrorCodes.databaseError,
        message: 'Failed to get device by signing key: ${e.toString()}',
        operation: 'getDeviceBySigningKey',
        details: {'error': e.toString()},
      );
    }
  }
}
