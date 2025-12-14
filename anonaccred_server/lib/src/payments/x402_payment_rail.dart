import '../exception_factory.dart';
import '../generated/payment_rail.dart';
import '../generated/payment_request.dart';
import '../generated/payment_result.dart';
import '../generated/protocol.dart';
import 'payment_rail_interface.dart';

/// X402 HTTP Payment Rail implementation
/// 
/// Implements the x402 protocol for frictionless, API-native payments using
/// HTTP 402 "Payment Required" status codes.
class X402PaymentRail implements PaymentRailInterface {
  // Use environment variables directly - no custom config class needed
  static const String _facilitatorUrl = String.fromEnvironment(
    'X402_FACILITATOR_URL',
    defaultValue: 'http://localhost:8090/verify',
  );
  
  static const String _destinationAddress = String.fromEnvironment(
    'X402_DESTINATION_ADDRESS',
    defaultValue: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
  );
  
  @override
  PaymentRail get railType => PaymentRail.x402_http;
  
  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String orderId,
  }) async {
    // Generate unique payment reference for X402
    final paymentRef = 'x402_${orderId}_${DateTime.now().millisecondsSinceEpoch}';
    
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
          'environmentVariables': 'X402_FACILITATOR_URL, X402_DESTINATION_ADDRESS',
        },
      );
    }
    
    // Create X402-specific payment data
    final railData = {
      'facilitatorUrl': _facilitatorUrl,
      'destinationAddress': _destinationAddress,
      'amount': amountUSD.toString(),
      'currency': 'USD',
      'orderId': orderId,
      'timestamp': DateTime.now().toIso8601String(),
      'protocol': 'x402',
    };
    
    return PaymentRequestExtension.withRailData(
      paymentRef: paymentRef,
      amountUSD: amountUSD,
      orderId: orderId,
      railData: railData,
    );
  }
  
  @override
  Future<PaymentResult> processCallback(Map<String, dynamic> callbackData) async {
    try {
      // For X402, the callback would typically be the X-PAYMENT header verification
      // This is a placeholder implementation - actual verification will be implemented
      // in task 3 (X-PAYMENT header verification)
      
      final paymentRef = callbackData['paymentRef'] as String?;
      final orderId = callbackData['orderId'] as String?;
      final success = callbackData['success'] as bool? ?? false;
      
      if (paymentRef == null || orderId == null) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentFailed,
          message: 'Invalid X402 callback data: missing paymentRef or orderId',
          orderId: orderId,
          paymentRail: railType.toString(),
          details: {
            'error': 'missing_required_fields',
            'receivedFields': callbackData.keys.join(', '),
          },
        );
      }
      
      return PaymentResult(
        success: success,
        orderId: orderId,
        transactionHash: success ? 'x402_tx_${DateTime.now().millisecondsSinceEpoch}' : null,
        errorMessage: success ? null : 'X402 payment verification failed',
      );
    } on AnonAccredException {
      // Re-throw AnonAccred exceptions as-is
      rethrow;
    } on PaymentException {
      // Re-throw Payment exceptions as-is
      rethrow;
    } catch (e) {
      // Wrap unexpected errors in PaymentException
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentFailed,
        message: 'X402 callback processing failed: ${e.toString()}',
        paymentRail: railType.toString(),
        details: {
          'error': e.toString(),
          'callbackData': callbackData.toString(),
        },
      );
    }
  }
}