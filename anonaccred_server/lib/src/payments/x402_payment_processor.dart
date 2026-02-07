import 'dart:convert';
import 'package:http/http.dart' as http;
import '../exception_factory.dart';
import '../generated/protocol.dart';

/// X402 Payment Processor for HTTP 402 response generation and payment verification
/// 
/// Implements the x402 protocol for generating HTTP 402 "Payment Required" responses
/// and verifying X-PAYMENT headers for stateless, API-native payments.
class X402PaymentProcessor {
  // Use environment variables directly - no custom config class needed
  static const String _facilitatorUrl = String.fromEnvironment(
    'X402_FACILITATOR_URL',
    defaultValue: 'http://localhost:8090/verify',
  );
  
  static const String _destinationAddress = String.fromEnvironment(
    'X402_DESTINATION_ADDRESS',
    defaultValue: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
  );

  /// Generate HTTP 402 response data with payment requirements
  /// 
  /// Creates payment requirement data following the x402 protocol.
  /// The response includes all necessary information for programmatic payment completion.
  /// 
  /// Requirements 1.2, 1.4: Include payment amount, currency, destination address, and order ID
  static X402PaymentResponse generatePaymentRequired({
    required double amount,
    required String orderId,
  }) {
    // Validate configuration
    if (_facilitatorUrl.isEmpty || _destinationAddress.isEmpty) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.x402ConfigurationMissing,
        message: 'X402 configuration missing: facilitator URL or destination address not set',
        paymentRail: 'x402_http',
        orderId: orderId,
        details: {
          'facilitatorUrl': _facilitatorUrl.isEmpty ? 'missing' : 'configured',
          'destinationAddress': _destinationAddress.isEmpty ? 'missing' : 'configured',
        },
      );
    }

    // Create x402 protocol compliant response data
    return X402PaymentResponse(
      amount: amount,
      currency: 'USD',
      destination: _destinationAddress,
      orderId: orderId,
      facilitator: _facilitatorUrl,
      protocol: 'x402',
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  /// Extract X-PAYMENT header and verify through facilitator
  /// 
  /// Extracts the X-PAYMENT header from incoming requests and verifies the payment
  /// payload through the configured facilitator service.
  /// 
  /// Returns false for any verification failure (missing payment, invalid payload, 
  /// facilitator unavailable, etc.). For detailed error information, use verifyPaymentWithDetails.
  /// 
  /// Requirements 2.1, 2.2: Extract X-PAYMENT header and verify through facilitator
  static Future<bool> verifyPayment(Map<String, String> headers) async {
    try {
      return await _verifyPaymentInternal(headers);
    } on AnonAccredException {
      // Log the error but return false for backward compatibility
      return false;
    } on PaymentException {
      // Log the error but return false for backward compatibility
      return false;
    } catch (e) {
      // Log unexpected errors but return false for backward compatibility
      return false;
    }
  }

  /// Extract X-PAYMENT header and verify through facilitator with detailed error information
  /// 
  /// Same as verifyPayment but throws detailed exceptions for different failure scenarios.
  /// Use this method when you need to distinguish between different types of failures.
  /// 
  /// Requirements 2.1, 2.2: Extract X-PAYMENT header and verify through facilitator
  static Future<bool> verifyPaymentWithDetails(Map<String, String> headers) async {
    return await _verifyPaymentInternal(headers);
  }

  /// Internal payment verification logic with proper error handling
  static Future<bool> _verifyPaymentInternal(Map<String, String> headers) async {
    try {
      // Extract X-PAYMENT header (case-insensitive)
      final xPaymentHeader = headers['X-PAYMENT'] ?? 
                            headers['x-payment'] ??
                            headers['X-Payment'];
      
      // Missing or empty X-PAYMENT header means no payment provided (not an error)
      if (xPaymentHeader == null || xPaymentHeader.isEmpty) {
        return false;
      }

      // Validate configuration
      if (_facilitatorUrl.isEmpty) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.x402ConfigurationMissing,
          message: 'X402 facilitator URL not configured',
          paymentRail: 'x402_http',
          details: {
            'facilitatorUrl': 'missing',
            'environmentVariable': 'X402_FACILITATOR_URL',
          },
        );
      }

      // Prepare facilitator verification request
      final verificationRequest = {
        'payment_payload': xPaymentHeader,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Send verification request to facilitator
      final response = await http.post(
        Uri.parse(_facilitatorUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(verificationRequest),
      );

      // Check if facilitator confirms payment
      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          final verified = responseData['verified'] as bool? ?? false;
          return verified;
        } on FormatException catch (e) {
          // Invalid JSON response from facilitator
          throw AnonAccredExceptionFactory.createPaymentException(
            code: AnonAccredErrorCodes.x402VerificationFailed,
            message: 'Facilitator returned invalid JSON response',
            paymentRail: 'x402_http',
            details: {
              'facilitatorUrl': _facilitatorUrl,
              'responseBody': response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body,
              'parseError': e.toString(),
            },
          );
        }
      }

      // Handle specific HTTP error codes from facilitator
      if (response.statusCode >= 500) {
        // Server errors are retryable
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.x402FacilitatorUnavailable,
          message: 'Facilitator service unavailable (HTTP ${response.statusCode})',
          paymentRail: 'x402_http',
          details: {
            'facilitatorUrl': _facilitatorUrl,
            'statusCode': response.statusCode.toString(),
            'responseBody': response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body,
          },
        );
      } else {
        // Client errors (4xx) indicate payment verification failed
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.x402VerificationFailed,
          message: 'Payment verification failed (HTTP ${response.statusCode})',
          paymentRail: 'x402_http',
          details: {
            'facilitatorUrl': _facilitatorUrl,
            'statusCode': response.statusCode.toString(),
            'responseBody': response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body,
          },
        );
      }
      
    } on AnonAccredException {
      // Re-throw AnonAccred exceptions as-is
      rethrow;
    } on PaymentException {
      // Re-throw Payment exceptions as-is
      rethrow;
    } on http.ClientException catch (e) {
      // Network connectivity issues
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.x402FacilitatorUnavailable,
        message: 'Failed to connect to facilitator service',
        paymentRail: 'x402_http',
        details: {
          'facilitatorUrl': _facilitatorUrl,
          'networkError': e.toString(),
        },
      );
    } catch (e) {
      // Wrap any other unexpected errors
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.x402VerificationFailed,
        message: 'Unexpected error during payment verification: ${e.toString()}',
        paymentRail: 'x402_http',
        details: {
          'facilitatorUrl': _facilitatorUrl,
          'error': e.toString(),
        },
      );
    }
  }
}

/// X402 Payment Response data structure
/// 
/// Contains all necessary information for programmatic payment completion
/// following the x402 protocol specification.
class X402PaymentResponse {
  final double amount;
  final String currency;
  final String destination;
  final String orderId;
  final String facilitator;
  final String protocol;
  final String timestamp;

  const X402PaymentResponse({
    required this.amount,
    required this.currency,
    required this.destination,
    required this.orderId,
    required this.facilitator,
    required this.protocol,
    required this.timestamp,
  });

  /// Convert to JSON map for HTTP response body
  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency': currency,
    'destination': destination,
    'orderId': orderId,
    'facilitator': facilitator,
    'protocol': protocol,
    'timestamp': timestamp,
  };

  /// Create from JSON map
  factory X402PaymentResponse.fromJson(Map<String, dynamic> json) => X402PaymentResponse(
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String,
    destination: json['destination'] as String,
    orderId: json['orderId'] as String,
    facilitator: json['facilitator'] as String,
    protocol: json['protocol'] as String,
    timestamp: json['timestamp'] as String,
  );
}