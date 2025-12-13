import 'package:serverpod/serverpod.dart';
import 'generated/protocol.dart';
import 'helpers.dart';

/// Custom authentication handler for x-anonaccred-device-key header validation
/// Integrates with Serverpod's built-in authentication system
class AnonAccredAuthHandler {
  
  /// Serverpod authentication handler callback
  /// Validates device key from token parameter and returns AuthenticationInfo
  static Future<AuthenticationInfo?> handleAuthentication(
    Session session, 
    String token,
  ) async {
    try {
      // Use token parameter as device key (Serverpod extracts this from Authorization header)
      final deviceKey = token.trim();
      
      if (deviceKey.isEmpty) {
        session.log('Authentication failed: Missing or empty token');
        return null;
      }
      
      // Validate device key format
      AnonAccredHelpers.validatePublicKey(deviceKey, 'authentication');
      
      // Verify device exists and is active
      final device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.publicSubKey.equals(deviceKey),
      );
      
      final activeDevice = AnonAccredHelpers.requireActiveDevice(
        device, 
        deviceKey, 
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
    } catch (e) {
      session.log('Authentication error: ${e.toString()}');
      return null;
    }
  }
  
  /// Extract device key from custom header (for future use)
  /// Currently not used - device key is passed via Authorization header/token
  static String _extractDeviceKeyFromHeader(Session session) {
    // TODO: Implement custom header extraction when Serverpod API is available
    // For now, device key should be passed via Authorization header
    return '';
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