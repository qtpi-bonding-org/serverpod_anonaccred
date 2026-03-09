import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:test/test.dart';

void main() {
  group('AnonAccountHelpers Integration', () {
    test('can be imported from main library', () {
      // Test that helpers are accessible through main library export
      expect(AnonAccountHelpers.validateNonEmpty, isA<Function>());
      expect(AnonAccountHelpers.validatePublicKey, isA<Function>());
      expect(AnonAccountHelpers.requireEntity, isA<Function>());
      expect(AnonAccountHelpers.requireAccount, isA<Function>());
      expect(AnonAccountHelpers.requireDevice, isA<Function>());
      expect(AnonAccountHelpers.requireActiveDevice, isA<Function>());
    });

    test('validation helpers work with existing error codes', () {
      try {
        AnonAccountHelpers.validateNonEmpty(null, 'testField', 'testOp');
        fail('Should have thrown exception');
      } on AuthenticationException catch (e) {
        expect(e.code, equals(AnonAccountErrorCodes.authMissingKey));
        expect(e.operation, equals('testOp'));
        expect(e.details?['testField'], equals('null'));
      }
    });

    test('database helpers work with existing models', () {
      final account = AnonAccount(
        ultimateSigningPublicKeyHex: 'a' * 128, // ECDSA P-256 format
        encryptedDataKey: 'encrypted',
        ultimatePublicKey: 'b' * 128,
      );

      final result = AnonAccountHelpers.requireAccount(account, 1, 'testOp');
      expect(result, equals(account));
    });

    test('auth handler can be imported from main library', () {
      // Test that auth handler is accessible through main library export
      expect(AnonAccountAuthHandler.handleAuthentication, isA<Function>());
      expect(AnonAccountAuthHandler.getDevicePublicKey, isA<Function>());
    });
  });
}
