import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given AnonAccred operations with exception handling', (
    sessionBuilder,
    endpoints,
  ) {
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
        expect(
          () => endpoints.module.processPayment(
            sessionBuilder,
            'order123',
            'invalid_rail', // Invalid payment rail
            100.0,
          ),
          throwsA(isA<PaymentException>()),
        );
      },
    );

    test(
      'when processPayment is called with negative amount then PaymentException is thrown',
      () async {
        expect(
          () => endpoints.module.processPayment(
            sessionBuilder,
            'order123',
            'x402',
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
          'x402',
          100.0,
        );
        expect(result, startsWith('payment_receipt_order123_'));
      },
    );

    test(
      'when manageInventory is called with invalid account ID then InventoryException is thrown',
      () async {
        expect(
          () => endpoints.module.manageInventory(
            sessionBuilder,
            404, // Account not found
            'api_calls',
            'check',
            null,
          ),
          throwsA(isA<InventoryException>()),
        );
      },
    );

    test(
      'when manageInventory is called with invalid consumable type then InventoryException is thrown',
      () async {
        expect(
          () => endpoints.module.manageInventory(
            sessionBuilder,
            123,
            'invalid_type', // Invalid consumable type
            'check',
            null,
          ),
          throwsA(isA<InventoryException>()),
        );
      },
    );

    test(
      'when manageInventory is called with valid parameters then returns balance',
      () async {
        final result = await endpoints.module.manageInventory(
          sessionBuilder,
          123,
          'api_calls',
          'check',
          null,
        );
        expect(result, equals(100)); // Mock balance
      },
    );
  });
}
