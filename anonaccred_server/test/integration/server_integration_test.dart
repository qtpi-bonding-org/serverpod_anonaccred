import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('Server Integration Tests', () {
    test('authentication handler can be registered with Serverpod', () {
      // Test that the authentication handler has the correct signature
      // and can be passed to Serverpod constructor
      expect(AnonAccredAuthHandler.handleAuthentication, isA<Function>());
      
      // Verify the function signature matches Serverpod's expected type
      const handler = AnonAccredAuthHandler.handleAuthentication;
      expect(handler, isA<Future<AuthenticationInfo?> Function(Session, String)>());
    });

    test('authentication handler handles missing token gracefully', () async {
      final mockSession = _MockSession();
      
      final result = await AnonAccredAuthHandler.handleAuthentication(
        mockSession, 
        '',
      );
      
      expect(result, isNull);
    });

    test('authentication handler handles invalid token format gracefully', () async {
      final mockSession = _MockSession();
      
      final result = await AnonAccredAuthHandler.handleAuthentication(
        mockSession, 
        'invalid-key',
      );
      
      expect(result, isNull);
    });

    test('getDevicePublicKey extracts key from authenticated session', () {
      final mockSession = _MockSession();
      const deviceKey = 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890';
      
      mockSession.authenticated = AuthenticationInfo(
        'user123',
        {const Scope('device:$deviceKey')},
        authId: deviceKey,
      );
      
      final result = AnonAccredAuthHandler.getDevicePublicKey(mockSession);
      expect(result, equals(deviceKey));
    });
    
    test('getDevicePublicKey returns empty string for unauthenticated session', () {
      final mockSession = _MockSession();
      
      final result = AnonAccredAuthHandler.getDevicePublicKey(mockSession);
      expect(result, equals(''));
    });
  });
}

// Mock classes for testing
class _MockSession implements Session {
  @override
  AuthenticationInfo? authenticated;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}