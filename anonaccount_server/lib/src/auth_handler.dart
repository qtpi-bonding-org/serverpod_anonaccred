import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'generated/protocol.dart';
import 'helpers.dart';

/// Custom authentication handler for configurable device public key header validation
/// Integrates with Serverpod's built-in authentication system
class AnonAccountAuthHandler {
  /// Serverpod authentication handler callback
  static Future<AuthenticationInfo?> handleAuthentication(
    Session session,
    String token,
  ) async {
    session.log(
      'AnonAccountAuthHandler: handleAuthentication called',
      level: LogLevel.info,
    );
    session.log(
      'AnonAccountAuthHandler: token length: ${token.length}',
      level: LogLevel.info,
    );
    session.log(
      'AnonAccountAuthHandler: token prefix: ${token.length > 20 ? token.substring(0, 20) : token}...',
      level: LogLevel.info,
    );

    try {
      String? devicePubKey;

      final trimmedToken = token.trim();
      session.log(
        'AnonAccountAuthHandler: trimmedToken length: ${trimmedToken.length}',
        level: LogLevel.info,
      );

      if (trimmedToken.startsWith('Bearer ')) {
        devicePubKey = trimmedToken.substring(7).trim();
        session.log(
          'AnonAccountAuthHandler: Extracted public key from Bearer token, length: ${devicePubKey.length}',
          level: LogLevel.info,
        );
        session.log(
          'AnonAccountAuthHandler: Device public key prefix: ${devicePubKey.length > 20 ? devicePubKey.substring(0, 20) : devicePubKey}...',
          level: LogLevel.info,
        );
      } else if (trimmedToken.startsWith('Basic ')) {
        try {
          final decoded = String.fromCharCodes(
            base64Decode(trimmedToken.substring(6).trim()),
          );
          session.log(
            'AnonAccountAuthHandler: Decoded Basic token: ${decoded.length > 20 ? decoded.substring(0, 20) : decoded}...',
            level: LogLevel.info,
          );
          if (decoded.startsWith(':')) {
            devicePubKey = decoded.substring(1);
          } else {
            devicePubKey = decoded;
          }
          session.log(
            'AnonAccountAuthHandler: Extracted public key from Basic token, length: ${devicePubKey.length}',
            level: LogLevel.info,
          );
        } catch (e) {
          session.log(
            'AnonAccountAuthHandler: Failed to decode Basic token: $e',
            level: LogLevel.error,
          );
        }
      } else if (trimmedToken.length == 128 && _isHexString(trimmedToken)) {
        devicePubKey = trimmedToken;
        session.log(
          'AnonAccountAuthHandler: Using raw public key from token, length: ${devicePubKey.length}',
          level: LogLevel.info,
        );
      }

      if (devicePubKey == null || devicePubKey.isEmpty) {
        session.log(
          'AnonAccountAuthHandler: ERROR - Could not extract device public key from token',
          level: LogLevel.error,
        );
        return null;
      }

      session.log(
        'AnonAccountAuthHandler: Final device public key length: ${devicePubKey.length}',
        level: LogLevel.info,
      );

      session.log(
        'AnonAccountAuthHandler: Validating device public key format...',
        level: LogLevel.info,
      );
      AnonAccountHelpers.validatePublicKey(devicePubKey, 'authentication');
      session.log(
        'AnonAccountAuthHandler: Device public key format is valid',
        level: LogLevel.info,
      );

      session.log(
        'AnonAccountAuthHandler: Looking up device in database...',
        level: LogLevel.info,
      );
      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.deviceSigningPublicKeyHex.equals(devicePubKey),
      );

      if (device == null) {
        session.log(
          'AnonAccountAuthHandler: ERROR - Device not found in database',
          level: LogLevel.error,
        );
      } else {
        session.log(
          'AnonAccountAuthHandler: Device found, ID: ${device.id}, accountId: ${device.accountId}, isRevoked: ${device.isRevoked}',
          level: LogLevel.info,
        );
      }

      final activeDevice = AnonAccountHelpers.requireActiveDevice(
        device,
        devicePubKey,
        'authentication',
      );

      session.log(
        'AnonAccountAuthHandler: Device is active, creating AuthenticationInfo...',
        level: LogLevel.info,
      );

      final authInfo = AuthenticationInfo(
        activeDevice.accountId.toString(),
        {Scope('device:${activeDevice.deviceSigningPublicKeyHex}')},
        authId: activeDevice.deviceSigningPublicKeyHex,
      );

      session.log(
        'AnonAccountAuthHandler: Authentication successful, authId: "${authInfo.authId}"',
        level: LogLevel.info,
      );
      return authInfo;
    } on AuthenticationException catch (e) {
      session.log(
        'AnonAccountAuthHandler: Authentication exception: ${e.toString()}',
        level: LogLevel.error,
      );
      return null;
    } on Exception catch (e) {
      session.log(
        'AnonAccountAuthHandler: Authentication error: ${e.toString()}',
        level: LogLevel.error,
      );
      return null;
    }
  }

  static bool _isHexString(String s) => RegExp(r'^[0-9a-fA-F]+$').hasMatch(s);

  /// Helper to extract device public key from authenticated session
  static String getDevicePublicKey(Session session) {
    if (session.authenticated?.scopes != null) {
      for (final scope in session.authenticated!.scopes) {
        final scopeName = scope.name;
        if (scopeName?.startsWith('device:') ?? false) {
          return scopeName!.substring(7);
        }
      }
    }
    return '';
  }
}
