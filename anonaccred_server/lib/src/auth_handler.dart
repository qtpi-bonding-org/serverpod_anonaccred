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
    try {
      String? devicePubKey;
      
      // Parse the token parameter - in Serverpod 3.x this contains the full header value
      // Client sends: "Bearer <128-char-hex-public-key>"
      final trimmedToken = token.trim();
      
      if (trimmedToken.startsWith('Bearer ')) {
        // Extract public key from Bearer token
        devicePubKey = trimmedToken.substring(7).trim();
        session.log('Auth: Extracted public key from Bearer token');
      } else if (trimmedToken.startsWith('Basic ')) {
        // Basic auth - decode base64 (Serverpod default wrapping)
        // Format after decode: ":<public_key>" or just "<public_key>"
        try {
          final decoded = String.fromCharCodes(
            base64Decode(trimmedToken.substring(6).trim()),
          );
          // Basic auth format is "username:password", we use empty username
          if (decoded.startsWith(':')) {
            devicePubKey = decoded.substring(1);
          } else {
            devicePubKey = decoded;
          }
          session.log('Auth: Extracted public key from Basic token');
        } catch (e) {
          session.log('Auth: Failed to decode Basic token: $e');
        }
      } else if (trimmedToken.length == 128 && _isHexString(trimmedToken)) {
        // Raw 128-char hex public key (direct token parameter)
        devicePubKey = trimmedToken;
        session.log('Auth: Using raw public key from token');
      }
      
      if (devicePubKey == null || devicePubKey.isEmpty) {
        session.log('Authentication failed: Could not extract device public key from token');
        return null;
      }
      
      // Validate device public key format
      AnonAccredHelpers.validatePublicKey(devicePubKey, 'authentication');
      
      // Verify device exists and is active
      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.publicSubKey.equals(devicePubKey),
      );
      
      final activeDevice = AnonAccredHelpers.requireActiveDevice(
        device, 
        devicePubKey, 
        'authentication',
      );
      
      // Return authentication info with account ID as userId
      // Store device public key in scopes for endpoint access
      return AuthenticationInfo(
        activeDevice.accountId.toString(),
        {Scope('device:${activeDevice.publicSubKey}')},
        authId: activeDevice.publicSubKey,
      );
      
    } on AuthenticationException catch (e) {
      // Authentication exceptions should return null (authentication failed)
      session.log('Authentication failed: ${e.toString()}');
      return null;
    } on Exception catch (e) {
      session.log('Authentication error: ${e.toString()}');
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