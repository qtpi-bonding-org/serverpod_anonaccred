import 'package:test/test.dart';
import 'package:anonaccred_server/anonaccred_server.dart';
import 'dart:math';

/// **Feature: anonaccred-phase1-5, Property 1: Exception Structure Consistency**
/// **Validates: Requirements 1.1, 1.2**

void main() {
  group('Exception Structure Consistency Property Tests', () {
    test(
      'Property 1: Exception Structure Consistency - All AnonAccred exceptions should have consistent structure',
      () {
        // Run 5 iterations during development (can be increased to 100+ for production)
        for (int i = 0; i < 5; i++) {
          // Generate random exception data
          final code = _generateRandomErrorCode();
          final message = _generateRandomMessage();
          final details = _generateRandomDetails();

          // Test base AnonAccred exception
          final baseException = AnonAccredExceptionFactory.createException(
            code: code,
            message: message,
            details: details,
          );

          _verifyExceptionStructure(baseException, code, message, details);

          // Test authentication exception
          final operation = _generateRandomOperation();
          final authException =
              AnonAccredExceptionFactory.createAuthenticationException(
                code: code,
                message: message,
                operation: operation,
                details: details,
              );

          _verifyAuthenticationExceptionStructure(
            authException,
            code,
            message,
            operation,
            details,
          );

          // Test payment exception
          final orderId = _generateRandomOrderId();
          final paymentRail = _generateRandomPaymentRail();
          final paymentException =
              AnonAccredExceptionFactory.createPaymentException(
                code: code,
                message: message,
                orderId: orderId,
                paymentRail: paymentRail,
                details: details,
              );

          _verifyPaymentExceptionStructure(
            paymentException,
            code,
            message,
            orderId,
            paymentRail,
            details,
          );

          // Test inventory exception
          final accountId = _generateRandomAccountId();
          final consumableType = _generateRandomConsumableType();
          final inventoryException =
              AnonAccredExceptionFactory.createInventoryException(
                code: code,
                message: message,
                accountId: accountId,
                consumableType: consumableType,
                details: details,
              );

          _verifyInventoryExceptionStructure(
            inventoryException,
            code,
            message,
            accountId,
            consumableType,
            details,
          );
        }
      },
    );

    test('Property 1: Exception serialization consistency', () {
      // Run 5 iterations during development
      for (int i = 0; i < 5; i++) {
        final code = _generateRandomErrorCode();
        final message = _generateRandomMessage();
        final details = _generateRandomDetails();

        // Test that all exceptions can be serialized and deserialized
        final baseException = AnonAccredExceptionFactory.createException(
          code: code,
          message: message,
          details: details,
        );

        // Verify serialization works
        final json = baseException.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['code'], equals(code));
        expect(json['message'], equals(message));

        // Verify protocol serialization works
        final protocolJson = baseException.toJsonForProtocol();
        expect(protocolJson, isA<Map<String, dynamic>>());
        expect(protocolJson['code'], equals(code));
        expect(protocolJson['message'], equals(message));
      }
    });
  });
}

void _verifyExceptionStructure(
  AnonAccredException exception,
  String expectedCode,
  String expectedMessage,
  Map<String, String>? expectedDetails,
) {
  expect(exception.code, equals(expectedCode));
  expect(exception.message, equals(expectedMessage));
  expect(exception.details, equals(expectedDetails));
  expect(exception.toString(), contains(expectedCode));
  expect(exception.toString(), contains(expectedMessage));
}

void _verifyAuthenticationExceptionStructure(
  AuthenticationException exception,
  String expectedCode,
  String expectedMessage,
  String? expectedOperation,
  Map<String, String>? expectedDetails,
) {
  expect(exception.code, equals(expectedCode));
  expect(exception.message, equals(expectedMessage));
  expect(exception.operation, equals(expectedOperation));
  expect(exception.details, equals(expectedDetails));
  expect(exception.toString(), contains(expectedCode));
  expect(exception.toString(), contains(expectedMessage));
}

void _verifyPaymentExceptionStructure(
  PaymentException exception,
  String expectedCode,
  String expectedMessage,
  String? expectedOrderId,
  String? expectedPaymentRail,
  Map<String, String>? expectedDetails,
) {
  expect(exception.code, equals(expectedCode));
  expect(exception.message, equals(expectedMessage));
  expect(exception.orderId, equals(expectedOrderId));
  expect(exception.paymentRail, equals(expectedPaymentRail));
  expect(exception.details, equals(expectedDetails));
  expect(exception.toString(), contains(expectedCode));
  expect(exception.toString(), contains(expectedMessage));
}

void _verifyInventoryExceptionStructure(
  InventoryException exception,
  String expectedCode,
  String expectedMessage,
  int? expectedAccountId,
  String? expectedConsumableType,
  Map<String, String>? expectedDetails,
) {
  expect(exception.code, equals(expectedCode));
  expect(exception.message, equals(expectedMessage));
  expect(exception.accountId, equals(expectedAccountId));
  expect(exception.consumableType, equals(expectedConsumableType));
  expect(exception.details, equals(expectedDetails));
  expect(exception.toString(), contains(expectedCode));
  expect(exception.toString(), contains(expectedMessage));
}

// Test data generators
String _generateRandomErrorCode() {
  final codes = [
    AnonAccredErrorCodes.authInvalidSignature,
    AnonAccredErrorCodes.authExpiredChallenge,
    AnonAccredErrorCodes.paymentFailed,
    AnonAccredErrorCodes.paymentInsufficientFunds,
    AnonAccredErrorCodes.inventoryInsufficientBalance,
    AnonAccredErrorCodes.inventoryAccountNotFound,
    AnonAccredErrorCodes.networkTimeout,
    AnonAccredErrorCodes.databaseError,
  ];
  return codes[Random().nextInt(codes.length)];
}

String _generateRandomMessage() {
  final messages = [
    'Authentication failed',
    'Payment processing error',
    'Inventory operation failed',
    'Network connection timeout',
    'Database operation failed',
  ];
  return messages[Random().nextInt(messages.length)];
}

Map<String, String>? _generateRandomDetails() {
  if (Random().nextBool()) {
    return null; // Sometimes no details
  }

  return {
    'timestamp': DateTime.now().toIso8601String(),
    'requestId': 'req_${Random().nextInt(10000)}',
    'context': 'test_operation',
  };
}

String? _generateRandomOperation() {
  if (Random().nextBool()) {
    return null; // Sometimes no operation
  }

  final operations = ['authenticate', 'verify_signature', 'challenge_response'];
  return operations[Random().nextInt(operations.length)];
}

String? _generateRandomOrderId() {
  if (Random().nextBool()) {
    return null; // Sometimes no order ID
  }

  return 'order_${Random().nextInt(100000)}';
}

String? _generateRandomPaymentRail() {
  if (Random().nextBool()) {
    return null; // Sometimes no payment rail
  }

  final rails = ['x402', 'monero', 'iap'];
  return rails[Random().nextInt(rails.length)];
}

int? _generateRandomAccountId() {
  if (Random().nextBool()) {
    return null; // Sometimes no account ID
  }

  return Random().nextInt(10000) + 1;
}

String? _generateRandomConsumableType() {
  if (Random().nextBool()) {
    return null; // Sometimes no consumable type
  }

  final types = ['analysis_credit', 'storage_quota', 'api_call'];
  return types[Random().nextInt(types.length)];
}
