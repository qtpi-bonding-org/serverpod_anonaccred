import 'package:serverpod/serverpod.dart';
import 'config/header_config.dart';
import 'generated/protocol.dart';
import 'helpers.dart';

/// Custom authentication handler for configurable device public key header validation
/// Integrates with Serverpod's built-in authentication system
/// 
/// Header name is configurable via ANONACCRED_HEADER_PREFIX environment variable
/// Default format: X-QUANITYA-DEVICE-PUBKEY
class AnonAccredAuthHandler {
  
  /// Serverpod authentication handler callback
  /// Validates device public key with priority: 1) Authorization Bearer, 2) Custom header, 3) Token parameter
  /// Supports Authorization header (Bearer token), configurable device public key header, and token fallback
  static Future<AuthenticationInfo?> handleAuthentication(
    Session session, 
    String token,
  ) async {
    try {
      String? devicePubKey;
      
      // Priority 1: Try Authorization header with Bearer token format
      devicePubKey = extractDevicePubKeyFromAuthorizationHeader(session);
      
      // Priority 2: Try custom header (X-QUANITYA-DEVICE-PUBKEY)
      if (devicePubKey == null || devicePubKey.isEmpty) {
        devicePubKey = extractDevicePubKeyFromHeader(session);
      }
      
      // Priority 3: Fall back to token parameter
      if (devicePubKey == null || devicePubKey.isEmpty) {
        devicePubKey = token.trim();
      }
      
      if (devicePubKey.isEmpty) {
        session.log('Authentication failed: Missing device public key in both header (${AnonAccredHeaderConfig.devicePubKeyHeader}) and token');
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
  
  /// Extract device public key from Authorization header (Bearer token)
  /// Supports format: Authorization: Bearer `device_public_key`
  /// 
  /// Note: Direct header access is limited in Serverpod 3.x
  /// This method is prepared for future Serverpod versions that expose HTTP headers
  static String? extractDevicePubKeyFromAuthorizationHeader(Session session) =>
      null; // Header extraction not available in current Serverpod version
  
  /// Extract device public key from custom header
  /// Uses configurable header name (default: X-QUANITYA-DEVICE-PUBKEY)
  /// 
  /// Note: Direct header access is limited in Serverpod 3.x
  /// This method is prepared for future Serverpod versions that expose HTTP headers
  static String? extractDevicePubKeyFromHeader(Session session) =>
      null; // Header extraction not available in current Serverpod version
  
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