import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'generated/protocol.dart';
import 'helpers.dart';

/// Custom authentication handler for configurable device public key header validation
/// Integrates with Serverpod's built-in authentication system
/// 
/// Header name is configurable via ANONACCRED_HEADER_PREFIX environment variable
/// Default format: X-QUANITYA-DEVICE-PUBKEY
class AnonAccredAuthHandler {
  
  /// Serverpod authentication handler callback
  /// 
  /// In Serverpod 3.x, the `token` parameter receives the full Authorization header value
  /// from the client's `authKeyProvider.authHeaderValue`. For Bearer auth, this is
  /// "Bearer <public_key_hex>".
  /// 
  /// Validates device public key (ECDSA P-256, 128 hex chars) by:
  /// 1. Parsing Bearer token from the `token` parameter
  /// 2. Looking up device in database by public key
  /// 3. Returning AuthenticationInfo with account ID and device scope
  static Future<AuthenticationInfo?> handleAuthentication(
    Session session, 
    String token,
  ) async {
    session.log('AnonAccredAuthHandler: handleAuthentication called', level: LogLevel.info);
    session.log('AnonAccredAuthHandler: token length: ${token.length}', level: LogLevel.info);
    session.log('AnonAccredAuthHandler: token prefix: ${token.length > 20 ? token.substring(0, 20) : token}...', level: LogLevel.info);
    
    try {
      String? devicePubKey;
      
      // Parse the token parameter - in Serverpod 3.x this contains the full header value
      // Client sends: "Bearer <128-char-hex-public-key>"
      final trimmedToken = token.trim();
      session.log('AnonAccredAuthHandler: trimmedToken length: ${trimmedToken.length}', level: LogLevel.info);
      
      if (trimmedToken.startsWith('Bearer ')) {
        // Extract public key from Bearer token
        devicePubKey = trimmedToken.substring(7).trim();
        session.log('AnonAccredAuthHandler: Extracted public key from Bearer token, length: ${devicePubKey.length}', level: LogLevel.info);
        session.log('AnonAccredAuthHandler: Device public key prefix: ${devicePubKey.length > 20 ? devicePubKey.substring(0, 20) : devicePubKey}...', level: LogLevel.info);
      } else if (trimmedToken.startsWith('Basic ')) {
        // Basic auth - decode base64 (Serverpod default wrapping)
        // Format after decode: ":<public_key>" or just "<public_key>"
        try {
          final decoded = String.fromCharCodes(
            base64Decode(trimmedToken.substring(6).trim()),
          );
          session.log('AnonAccredAuthHandler: Decoded Basic token: ${decoded.length > 20 ? decoded.substring(0, 20) : decoded}...', level: LogLevel.info);
          // Basic auth format is "username:password", we use empty username
          if (decoded.startsWith(':')) {
            devicePubKey = decoded.substring(1);
          } else {
            devicePubKey = decoded;
          }
          session.log('AnonAccredAuthHandler: Extracted public key from Basic token, length: ${devicePubKey?.length}', level: LogLevel.info);
        } catch (e) {
          session.log('AnonAccredAuthHandler: Failed to decode Basic token: $e', level: LogLevel.error);
        }
      } else if (trimmedToken.length == 128 && _isHexString(trimmedToken)) {
        // Raw 128-char hex public key (direct token parameter)
        devicePubKey = trimmedToken;
        session.log('AnonAccredAuthHandler: Using raw public key from token, length: ${devicePubKey.length}', level: LogLevel.info);
      }
      
      if (devicePubKey == null || devicePubKey.isEmpty) {
        session.log('AnonAccredAuthHandler: ERROR - Could not extract device public key from token', level: LogLevel.error);
        return null;
      }
      
      session.log('AnonAccredAuthHandler: Final device public key length: ${devicePubKey.length}', level: LogLevel.info);
      
      // Validate device public key format
      session.log('AnonAccredAuthHandler: Validating device public key format...', level: LogLevel.info);
      AnonAccredHelpers.validatePublicKey(devicePubKey, 'authentication');
      session.log('AnonAccredAuthHandler: Device public key format is valid', level: LogLevel.info);
      
      // Verify device exists and is active
      session.log('AnonAccredAuthHandler: Looking up device in database...', level: LogLevel.info);
      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.deviceSigningPublicKeyHex.equals(devicePubKey),
      );
      
      if (device == null) {
        session.log('AnonAccredAuthHandler: ERROR - Device not found in database', level: LogLevel.error);
      } else {
        session.log('AnonAccredAuthHandler: Device found, ID: ${device.id}, accountId: ${device.accountId}, isRevoked: ${device.isRevoked}', level: LogLevel.info);
      }
      
      final activeDevice = AnonAccredHelpers.requireActiveDevice(
        device, 
        devicePubKey, 
        'authentication',
      );
      
      session.log('AnonAccredAuthHandler: Device is active, creating AuthenticationInfo...', level: LogLevel.info);
      
      // Return authentication info with account ID as userId
      // Store device public key in scopes for endpoint access
      final authInfo = AuthenticationInfo(
        activeDevice.accountId.toString(),
        {Scope('device:${activeDevice.deviceSigningPublicKeyHex}')},
        authId: activeDevice.deviceSigningPublicKeyHex,
      );
      
      session.log('AnonAccredAuthHandler: Authentication successful, userIdentifier: "${authInfo.userId}", authId: "${authInfo.authId}"', level: LogLevel.info);
      return authInfo;
      
    } on AuthenticationException catch (e) {
      // Authentication exceptions should return null (authentication failed)
      session.log('AnonAccredAuthHandler: Authentication exception: ${e.toString()}', level: LogLevel.error);
      return null;
    } on Exception catch (e) {
      session.log('AnonAccredAuthHandler: Authentication error: ${e.toString()}', level: LogLevel.error);
      return null;
    }
  }
  
  /// Helper to check if a string is valid hexadecimal
  static bool _isHexString(String s) {
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(s);
  }
  
  /// Helper to extract device public key from authenticated session
  /// For use in endpoints that need the device public key
  static String getDevicePublicKey(Session session) {
    if (session.authenticated?.scopes != null) {
      for (final scope in session.authenticated!.scopes) {
        final scopeName = scope.name;
        if (scopeName?.startsWith('device:') ?? false) {
          return scopeName!.substring(7); // Remove 'device:' prefix
        }
      }
    }
    return '';
  }
}