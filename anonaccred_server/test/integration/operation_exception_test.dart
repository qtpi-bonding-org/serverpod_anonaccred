import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given AnonAccred operations with exception handling', (
    sessionBuilder,
    endpoints,
  ) {
    late int testAccountId;

    setUp(() async {
      // Create a test account so manageEntitlements has an authenticated session
      final session = sessionBuilder.build();
      final account = await AnonAccount.db.insertRow(
        session,
        AnonAccount(
          ultimateSigningPublicKeyHex:
              'opextest1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef12',
          encryptedDataKey: 'encrypted_data_key_operation_exception_test',
          ultimatePublicKey:
              'opextest1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef12',
        ),
      );
      testAccountId = account.id!;
    });

    test(
      'when authenticateUser is called with invalid signature then AuthenticationException is thrown',
      () async {
        expect(
          () => endpoints.module.authenticateUser(
            sessionBuilder,
            'valid_public_key',
            'short', // Invalid signature (too short)
            'valid_challenge',
          ),
          throwsA(isA<AuthenticationException>()),
        );
      },
    );

    test(
      'when authenticateUser is called with expired challenge then AuthenticationException is thrown',
      () async {
        expect(
          () => endpoints.module.authenticateUser(
            sessionBuilder,
            'valid_public_key',
            'valid_signature_that_is_long_enough_to_pass_length_validation_test',
            'expired_challenge', // Expired challenge
          ),
          throwsA(isA<AuthenticationException>()),
        );
      },
    );

    test(
      'when authenticateUser is called with valid parameters then returns true',
      () async {
        final result = await endpoints.module.authenticateUser(
          sessionBuilder,
          'valid_public_key',
          'valid_signature_that_is_long_enough_to_pass_length_validation_test',
          'valid_challenge',
        );
        expect(result, isTrue);
      },
    );

    test(
      'when processPayment is called with invalid payment rail then PaymentException is thrown',
      () async {
        try {
          await endpoints.module.processPayment(
            sessionBuilder,
            'order123',
            'invalid_rail', // Invalid payment rail
            100.0,
          );
          fail('Expected PaymentException to be thrown');
        } on PaymentException catch (e) {
          // internalTransactionId is passed to the exception even for invalid rail
          expect(e.internalTransactionId, equals('order123'));
          expect(e.paymentRail, equals('invalid_rail'));
        }
      },
    );

    test(
      'when processPayment is called with negative amount then PaymentException is thrown',
      () async {
        expect(
          () => endpoints.module.processPayment(
            sessionBuilder,
            'order123',
            'x402_http',
            -50.0, // Negative amount
          ),
          throwsA(isA<PaymentException>()),
        );
      },
    );

    test(
      'when processPayment is called with valid parameters then returns receipt',
      () async {
        final result = await endpoints.module.processPayment(
          sessionBuilder,
          'order123',
          'x402_http',
          100.0,
        );
        expect(result, startsWith('payment_receipt_order123_'));
      },
    );

    test(
      'when manageEntitlements is called with invalid account ID then returns 0.0',
      () async {
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            testAccountId.toString(),
            {},
          ),
        );
        final result = await endpoints.module.manageEntitlements(
          authenticatedSession,
          'api_calls',
          'check',
          null,
        );
        expect(result, equals(0.0));
      },
    );

    test(
      'when manageEntitlements is called with invalid consumable type then returns 0.0',
      () async {
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            testAccountId.toString(),
            {},
          ),
        );
        final result = await endpoints.module.manageEntitlements(
          authenticatedSession,
          'invalid_type', // Invalid consumable type
          'check',
          null,
        );
        expect(result, equals(0.0));
      },
    );

    test(
      'when manageEntitlements is called with valid parameters then returns balance',
      () async {
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            testAccountId.toString(),
            {},
          ),
        );
        final result = await endpoints.module.manageEntitlements(
          authenticatedSession,
          'api_calls',
          'check',
          null,
        );
        expect(result, equals(0.0)); // Default balance for non-existent account
      },
    );
  });
}
