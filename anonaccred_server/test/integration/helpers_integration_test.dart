import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:test/test.dart';

void main() {
  group('AnonAccredHelpers Integration', () {
    test('can be imported from main library', () {
      // Test that helpers are accessible through main library export
      expect(AnonAccredHelpers.validateNonEmpty, isA<Function>());
      expect(AnonAccredHelpers.validatePublicKey, isA<Function>());
      expect(AnonAccredHelpers.requireEntity, isA<Function>());
      expect(AnonAccredHelpers.requireAccount, isA<Function>());
      expect(AnonAccredHelpers.requireDevice, isA<Function>());
      expect(AnonAccredHelpers.requireActiveDevice, isA<Function>());
    });

    test('validation helpers work with existing error codes', () {
      try {
        AnonAccredHelpers.validateNonEmpty(null, 'testField', 'testOp');
        fail('Should have thrown exception');
      } on AuthenticationException catch (e) {
        expect(e.code, equals(AnonAccredErrorCodes.authMissingKey));
        expect(e.operation, equals('testOp'));
        expect(e.details?['testField'], equals('null'));
      }
    });

    test('database helpers work with existing models', () {
      final account = AnonAccount(
        publicMasterKey: 'a' * 128, // ECDSA P-256 format
        encryptedDataKey: 'encrypted',
        ultimatePublicKey: 'b' * 128,
      );

      final result = AnonAccredHelpers.requireAccount(account, 1, 'testOp');
      expect(result, equals(account));
    });

    test('auth handler can be imported from main library', () {
      // Test that auth handler is accessible through main library export
      expect(AnonAccredAuthHandler.handleAuthentication, isA<Function>());
      expect(AnonAccredAuthHandler.getDevicePublicKey, isA<Function>());
    });
  });
}