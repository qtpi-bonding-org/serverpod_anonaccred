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
  /// Validates device public key from token parameter or custom header
  /// Supports both Authorization header and configurable device public key header
  static Future<AuthenticationInfo?> handleAuthentication(
    Session session, 
    String token,
  ) async {
    try {
      String? devicePubKey;
      
      // First try to get device public key from custom header
      devicePubKey = extractDevicePubKeyFromHeader(session);
      
      // Fall back to token parameter if header not present
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
  
  /// Extract device public key from custom header
  /// Uses configurable header name (default: X-QUANITYA-DEVICE-PUBKEY)
  /// Falls back to Authorization header if custom header not present
  /// 
  /// Note: Direct header access is limited in Serverpod 3.x
  /// This method is prepared for future Serverpod versions that expose HTTP headers
  static String? extractDevicePubKeyFromHeader(Session session) {
    // TODO: Implement header extraction when Serverpod exposes HTTP request headers
    // For now, this method returns null and authentication falls back to token-based auth
    // 
    // Future implementation would look like:
    // try {
    //   final methodCallSession = session as MethodCallSession;
    //   final httpRequest = methodCallSession.httpRequest;
    //   
    //   final devicePubKey = AnonAccredHeaderConfig.getHeaderValue(
    //     httpRequest.headers,
    //     AnonAccredHeaderConfig.devicePubKeyHeaderVariations,
    //   );
    //   
    //   if (devicePubKey != null && devicePubKey.isNotEmpty) {
    //     return devicePubKey;
    //   }
    //   
    //   return null;
    // } catch (e) {
    //   return null;
    // }
    
    return null; // Header extraction not available in current Serverpod version
  }
  
  /// Helper to extract device public key from authenticated session
  /// For use in endpoints that need the device public key
  static String getDevicePublicKey(Session session) {
    if (session.authenticated?.scopes != null) {
      for (final scope in session.authenticated!.scopes) {
        final scopeName = scope.name;
        if (scopeName?.startsWith('device:') == true) {
          return scopeName!.substring(7); // Remove 'device:' prefix
        }
      }
    }
    return '';
  }
}