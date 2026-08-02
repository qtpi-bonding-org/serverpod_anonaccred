import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('tryOperation', (sessionBuilder, endpoints) {
    test('a protocol exception passes through unchanged', () async {
      final session = sessionBuilder.build();
      final original = AuthenticationException(
        code: 'AUTH_DEVICE_REVOKED',
        message: 'device revoked',
      );

      await expectLater(
        tryOperation<void, AuthenticationException>(
          session,
          'op',
          () async => throw original,
          onFailure: authFailure,
          code: AnonAccountErrorCodes.internalError,
        ),
        throwsA(same(original)),
      );
    });

    test('a sibling protocol exception is not rewritten to DATABASE_ERROR',
        () async {
      final session = sessionBuilder.build();
      final original = AnonAccountException(
        code: 'GROUP_OPERATION_NOT_ALLOWED',
        message: 'not an admin',
      );

      await expectLater(
        tryOperation<void, AuthenticationException>(
          session,
          'op',
          () async => throw original,
          onFailure: authFailure,
          code: AnonAccountErrorCodes.databaseError,
        ),
        throwsA(same(original)),
      );
    });

    test('an unexpected exception is wrapped with its type, not its message',
        () async {
      final session = sessionBuilder.build();

      try {
        await tryOperation<void, AuthenticationException>(
          session,
          'createGroup',
          () async => throw StateError('connection to db-host:5432 refused'),
          onFailure: authFailure,
          code: AnonAccountErrorCodes.databaseError,
        );
        fail('expected a throw');
      } on AuthenticationException catch (e) {
        expect(e.message, 'createGroup failed: StateError');
        expect(e.message, isNot(contains('db-host')));
        expect(e.operation, 'createGroup');
        expect(e.code, AnonAccountErrorCodes.databaseError);
      }
    });

    test('details carries the session ref and no exception text', () async {
      final session = sessionBuilder.build();

      try {
        await tryOperation<void, AuthenticationException>(
          session,
          'createGroup',
          () async => throw StateError('secret-host-name'),
          onFailure: authFailure,
          code: AnonAccountErrorCodes.databaseError,
        );
        fail('expected a throw');
      } on AuthenticationException catch (e) {
        expect(e.details!['ref'], session.sessionId.toString());
        expect(e.details!.values, everyElement(isNot(contains('secret-host'))));
      }
    });

    test('extraDetails are merged and cannot overwrite ref', () async {
      final session = sessionBuilder.build();

      try {
        await tryOperation<void, AuthenticationException>(
          session,
          'op',
          () async => throw StateError('x'),
          onFailure: authFailure,
          code: AnonAccountErrorCodes.databaseError,
          extraDetails: {'railType': 'polar', 'ref': 'forged'},
        );
        fail('expected a throw');
      } on AuthenticationException catch (e) {
        expect(e.details!['railType'], 'polar');
        expect(e.details!['ref'], session.sessionId.toString());
      }
    });

    test('the original stack trace survives wrapping', () async {
      final session = sessionBuilder.build();

      Never thrower() => throw StateError('boom');

      try {
        await tryOperation<void, AuthenticationException>(
          session,
          'op',
          () async => thrower(),
          onFailure: authFailure,
          code: AnonAccountErrorCodes.databaseError,
        );
        fail('expected a throw');
      } catch (_, stackTrace) {
        expect(stackTrace.toString(), contains('thrower'));
      }
    });

    test('the return value passes through when nothing throws', () async {
      final session = sessionBuilder.build();

      final result = await tryOperation<int, AuthenticationException>(
        session,
        'op',
        () async => 42,
        onFailure: authFailure,
        code: AnonAccountErrorCodes.internalError,
      );

      expect(result, 42);
    });
  });

  group('without a session', () {
    test('a null session still sanitizes, and omits ref', () async {
      try {
        await tryOperation<void, AnonAccountException>(
          null,
          'getAccessToken',
          () async => throw StateError('token endpoint 500 at auth.host'),
          onFailure: accountFailure,
          code: AnonAccountErrorCodes.internalError,
        );
        fail('expected a throw');
      } on AnonAccountException catch (e) {
        expect(e.message, 'getAccessToken failed: StateError');
        expect(e.message, isNot(contains('auth.host')));
        expect(e.details!.containsKey('ref'), isFalse);
      }
    });

    test('a null session still passes a protocol exception through', () async {
      final original = AnonAccountException(code: 'X', message: 'y');
      await expectLater(
        tryOperation<void, AnonAccountException>(
          null,
          'op',
          () async => throw original,
          onFailure: accountFailure,
          code: AnonAccountErrorCodes.internalError,
        ),
        throwsA(same(original)),
      );
    });
  });

  group('crypto helpers do not leak library internals', () {
    test('verifySignature reports the type, not the pointycastle message',
        () async {
      try {
        await CryptoUtils.verifySignature(
          // parameter names per crypto_utils.dart:59
          message: 'm',
          signature: 'not-hex',
          publicKey: 'also-not-hex',
        );
        fail('expected a throw');
      } on AuthenticationException catch (e) {
        expect(e.message, isNot(contains('pointycastle')));
        expect(e.details?['pointyCastleError'], isNull);
      }
    });
  });
}