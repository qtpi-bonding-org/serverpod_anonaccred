import 'package:serverpod/serverpod.dart';
import '../config/header_config.dart';
import '../exception_factory.dart';
import '../generated/protocol.dart';
import 'x402_payment_processor.dart';

/// X402 Request Interceptor for payment requirement handling
///
/// Provides middleware functionality to intercept requests and handle
/// X402 payment requirements. Can be used by any endpoint to add
/// X402 payment integration.
///
/// Requirements 5.1, 5.2, 5.3: Request interception for payment requirements
class X402Interceptor {
  /// Intercept request and handle X402 payment flow
  ///
  /// This method implements the standard X402 client-server communication flow:
  /// 1. Check if X-PAYMENT header is present
  /// 2. If no payment, return HTTP 402 with payment requirements
  /// 3. If payment present, verify through facilitator
  /// 4. If verification fails, return HTTP 402
  /// 5. If verification succeeds, allow request to proceed
  ///
  /// Parameters:
  /// - [session]: Serverpod session for logging
  /// - [headers]: HTTP headers from the request
  /// - [resourceId]: Identifier for the resource being requested
  /// - [amount]: Payment amount required for the resource
  /// - [onPaymentRequired]: Callback to generate payment requirements
  /// - [onPaymentVerified]: Callback to execute when payment is verified
  ///
  /// Returns: Either payment requirement response or the result from onPaymentVerified
  ///
  /// Requirements 5.1: Standard client-server communication flow
  /// Requirements 5.2: HTTP 402 response when payment required  
  /// Requirements 5.3: Verify payment and provide resource
  static Future<Map<String, dynamic>> interceptRequest({
    required Session session,
    required Map<String, String> headers,
    required String resourceId,
    required double amount,
    required Future<Map<String, dynamic>> Function() onPaymentRequired,
    required Future<Map<String, dynamic>> Function() onPaymentVerified,
  }) async {
    try {
      // Check if X-PAYMENT header is provided
      final hasPayment = AnonAccredHeaderConfig.hasHeader(
        headers.map((key, value) => MapEntry(key, [value])),
        AnonAccredHeaderConfig.paymentHeaderVariations,
      );

      if (!hasPayment) {
        // No payment provided - return HTTP 402 with payment requirements
        session.log(
          'X402 interceptor: No payment header found for resource: $resourceId',
          level: LogLevel.info,
        );
        
        return await onPaymentRequired();
      }

      // Payment provided - verify it
      final paymentVerified = await X402PaymentProcessor.verifyPayment(headers);
      
      if (!paymentVerified) {
        // Payment verification failed - return HTTP 402 with payment requirements
        session.log(
          'X402 interceptor: Payment verification failed for resource: $resourceId',
          level: LogLevel.warning,
        );
        
        return await onPaymentRequired();
      }

      // Payment verified - proceed with request
      session.log(
        'X402 interceptor: Payment verified for resource: $resourceId',
        level: LogLevel.info,
      );
      
      return await onPaymentVerified();

    } on Exception catch (e) {
      // Log error and return payment required as fallback
      session.log(
        'X402 interceptor error for resource $resourceId: ${e.toString()}',
        level: LogLevel.error,
      );
      
      // Return payment required as safe fallback
      return onPaymentRequired();
    }
  }

  /// Generate standard X402 payment required response
  ///
  /// Creates a standardized HTTP 402 response with X402 protocol compliant
  /// payment requirements. This can be used by any endpoint that needs
  /// to request payment.
  ///
  /// Parameters:
  /// - [session]: Serverpod session for logging
  /// - [resourceId]: Identifier for the resource requiring payment
  /// - [amount]: Payment amount required
  /// - [description]: Optional description of what is being purchased
  ///
  /// Returns: HTTP 402 response with payment requirements
  ///
  /// Requirements 1.2, 1.4: HTTP 402 response with payment requirements
  static Future<Map<String, dynamic>> generatePaymentRequired({
    required Session session,
    required String resourceId,
    required double amount,
    String? description,
  }) async {
    try {
      // Generate unique order ID for this payment request
      final orderId = 'x402_${resourceId}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Generate X402 payment response
      final paymentResponse = X402PaymentProcessor.generatePaymentRequired(
        amount: amount,
        orderId: orderId,
      );

      session.log(
        'Generated X402 payment requirement for resource: $resourceId, amount: \$${amount.toStringAsFixed(2)}, order: $orderId',
        level: LogLevel.info,
      );

      // Return standardized HTTP 402 response
      return {
        'httpStatus': 402,
        'message': 'Payment Required',
        'resource': resourceId,
        'description': description ?? 'Access to $resourceId',
        'paymentRequired': paymentResponse.toJson(),
      };

    } catch (e) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.x402VerificationFailed,
        message: 'Failed to generate X402 payment requirements: ${e.toString()}',
        paymentRail: 'x402_http',
        details: {
          'resourceId': resourceId,
          'amount': amount.toString(),
          'error': e.toString(),
        },
      );
    }
  }

  /// Check if request has X402 payment header
  ///
  /// Utility method to check if a request contains an X-PAYMENT header
  /// in any of the common case variations.
  ///
  /// Parameters:
  /// - [headers]: HTTP headers from the request
  ///
  /// Returns: true if X-PAYMENT header is present, false otherwise
  static bool hasPaymentHeader(Map<String, String> headers) => 
      AnonAccredHeaderConfig.hasHeader(
        headers.map((key, value) => MapEntry(key, [value])),
        AnonAccredHeaderConfig.paymentHeaderVariations,
      );

  /// Extract X-PAYMENT header value
  ///
  /// Utility method to extract the X-PAYMENT header value from request headers,
  /// handling case-insensitive header names.
  ///
  /// Parameters:
  /// - [headers]: HTTP headers from the request
  ///
  /// Returns: X-PAYMENT header value or null if not present
  static String? getPaymentHeader(Map<String, String> headers) => 
      AnonAccredHeaderConfig.getHeaderValue(
        headers.map((key, value) => MapEntry(key, [value])),
        AnonAccredHeaderConfig.paymentHeaderVariations,
      );

  /// Validate X402 configuration
  ///
  /// Checks if the required X402 environment variables are configured.
  /// This should be called during application startup to ensure proper configuration.
  ///
  /// Throws:
  /// - [PaymentException] if configuration is missing or invalid
  static void validateConfiguration() {
    const facilitatorUrl = String.fromEnvironment('X402_FACILITATOR_URL');
    
    const destinationAddress = String.fromEnvironment('X402_DESTINATION_ADDRESS');

    if (facilitatorUrl.isEmpty) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.x402ConfigurationMissing,
        message: 'X402_FACILITATOR_URL environment variable not set',
        paymentRail: 'x402_http',
        details: {
          'missingVariable': 'X402_FACILITATOR_URL',
          'required': 'true',
        },
      );
    }

    if (destinationAddress.isEmpty) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.x402ConfigurationMissing,
        message: 'X402_DESTINATION_ADDRESS environment variable not set',
        paymentRail: 'x402_http',
        details: {
          'missingVariable': 'X402_DESTINATION_ADDRESS',
          'required': 'true',
        },
      );
    }
  }
}