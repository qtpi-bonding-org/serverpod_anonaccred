import 'package:serverpod/serverpod.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import '../helpers.dart';
import '../pow_methods.dart';
import 'signed_pow_endpoint.dart';

/// PoW-protected endpoint for fetching a device's encrypted data key.
///
/// Two paths:
/// - [retrieveEncryptedDataKey]: device proves ownership → returns
///   [AccountDevice.encryptedDataKey]. Fails if device is revoked.
/// - [recoverEncryptedDataKey]: ultimate key proves ownership → returns
///   [AnonAccount.encryptedDataKey]. Used for account recovery when all
///   devices are lost.
///
/// `signIn` intentionally does NOT return the key — this endpoint is called
/// only when the in-memory key is unavailable (fresh install, memory cleared).
class DataKeyEndpoint extends SignedPowEndpoint {
  @override
  String get endpointType => 'dataKey';

  @override
  int get rateLimitPerHour => 5;

  /// Retrieve encrypted data key for a registered, non-revoked device.
  Future<EncryptedDataKeyResponse> retrieveEncryptedDataKey(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String deviceSigningPublicKeyHex,
  }) async {
    try {
      final payload =
          '$challenge:${DataKeyMethods.retrieveEncryptedDataKey}:$deviceSigningPublicKeyHex';
      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        deviceSigningPublicKeyHex,
        signature,
        payload,
      );

      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.deviceSigningPublicKeyHex.equals(deviceSigningPublicKeyHex),
      );

      final activeDevice = AnonAccountHelpers.requireActiveDevice(
        device,
        deviceSigningPublicKeyHex,
        'retrieveEncryptedDataKey',
      );

      return EncryptedDataKeyResponse(
        encryptedDataKey: activeDevice.encryptedDataKey,
      );
    } on AuthenticationException {
      rethrow;
    } catch (e, stackTrace) {
      session.log(
        'DataKeyEndpoint: retrieveEncryptedDataKey error: $e\n$stackTrace',
        level: LogLevel.error,
      );
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'retrieveEncryptedDataKey failed: ${e.toString()}',
        operation: 'retrieveEncryptedDataKey',
        details: {'error': e.toString()},
      );
    }
  }

  /// Recover encrypted data key using the account's ultimate signing key.
  Future<EncryptedDataKeyResponse> recoverEncryptedDataKey(
    Session session, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String ultimateSigningPublicKeyHex,
  }) async {
    try {
      final payload =
          '$challenge:${DataKeyMethods.recoverEncryptedDataKey}:$ultimateSigningPublicKeyHex';
      await verifySignedPow(
        session,
        challenge,
        proofOfWork,
        ultimateSigningPublicKeyHex,
        signature,
        payload,
      );

      final account = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimateSigningPublicKeyHex
            .equals(ultimateSigningPublicKeyHex),
      );

      if (account == null) {
        throw AnonAccountExceptionFactory.createAuthenticationException(
          code: AnonAccountErrorCodes.authAccountNotFound,
          message: 'Account not found for ultimate signing key',
          operation: 'recoverEncryptedDataKey',
          details: {
            'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
          },
        );
      }

      return EncryptedDataKeyResponse(
        encryptedDataKey: account.encryptedDataKey,
      );
    } on AuthenticationException {
      rethrow;
    } catch (e, stackTrace) {
      session.log(
        'DataKeyEndpoint: recoverEncryptedDataKey error: $e\n$stackTrace',
        level: LogLevel.error,
      );
      throw AnonAccountExceptionFactory.createAuthenticationException(
        code: AnonAccountErrorCodes.databaseError,
        message: 'recoverEncryptedDataKey failed: ${e.toString()}',
        operation: 'recoverEncryptedDataKey',
        details: {'error': e.toString()},
      );
    }
  }
}
