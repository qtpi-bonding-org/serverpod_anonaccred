import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../exception_factory.dart';
import '../../generated/protocol.dart';
import '../payment_rail_interface.dart';

/// Apple In-App Purchase payment rail implementation
///
/// Provides server-side validation of Apple App Store receipts using Apple's
/// verifyReceipt API. Maintains privacy-first architecture by extracting only
/// transaction IDs and product information without storing PII.
///
/// Requirements 2.1, 2.2, 2.3: Apple receipt validation with shared secret authentication
class AppleIAPRail implements PaymentRailInterface {
  @override
  PaymentRail get railType => PaymentRail.apple_iap;

  /// Apple's receipt validation endpoints
  static const String _productionUrl =
      'https://buy.itunes.apple.com/verifyReceipt';
  static const String _sandboxUrl =
      'https://sandbox.itunes.apple.com/verifyReceipt';

  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String orderId,
  }) async {
    // For IAP, the payment request provides information for the mobile app
    // The actual payment happens in the mobile app, then receipt is validated
    return PaymentRequest(
      paymentRef: orderId,
      amountUSD: amountUSD,
      orderId: orderId,
      railDataJson: jsonEncode({
        'payment_rail': 'apple_iap',
        'order_id': orderId,
        'amount_usd': amountUSD,
        'validation_endpoint': '/api/iap/apple/validate',
        'instructions':
            'Complete purchase in iOS app, then submit receipt for validation',
        'expires_at': DateTime.now().add(Duration(hours: 24)).toIso8601String(),
      }),
    );
  }

  @override
  Future<PaymentResult> processCallback(
    Map<String, dynamic> callbackData,
  ) async {
    // Apple IAP uses receipt validation rather than callbacks
    // This method handles webhook notifications if configured
    try {
      final receiptData = callbackData['receipt_data'] as String?;
      final orderId = callbackData['order_id'] as String?;

      if (receiptData == null || orderId == null) {
        return PaymentResult(
          success: false,
          errorMessage: 'Missing receipt_data or order_id in callback',
        );
      }

      final validationResult = await validateReceipt(receiptData);

      return PaymentResult(
        success: validationResult.isValid,
        orderId: orderId,
        transactionTimestamp: validationResult.purchaseDate,
        errorMessage: validationResult.isValid
            ? null
            : 'Receipt validation failed',
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Apple IAP callback processing failed: ${e.toString()}',
      );
    }
  }

  /// Validate Apple App Store receipt using verifyReceipt API
  ///
  /// Sends receipt data to Apple's validation service and returns structured
  /// validation result. Handles both production and sandbox environments.
  ///
  /// Parameters:
  /// - [receiptData]: Base64-encoded receipt from iOS app
  ///
  /// Returns: [AppleReceiptValidationResult] with validation status and transaction details
  ///
  /// Requirements 2.1: POST to Apple's verifyReceipt endpoint
  /// Requirements 2.2: Use app-specific shared secret for authentication
  /// Requirements 2.5: Support both production and sandbox environments
  Future<AppleReceiptValidationResult> validateReceipt(
    String receiptData,
  ) async {
    final sharedSecret = AppleIAPConfig.sharedSecret;
    if (sharedSecret == null) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'Apple shared secret not configured',
        details: {'requiredConfig': 'APPLE_SHARED_SECRET'},
      );
    }

    // Try production first, then sandbox if needed
    var result = await _validateReceiptWithEndpoint(
      receiptData,
      sharedSecret,
      _productionUrl,
    );

    // If production returns sandbox error (21007), try sandbox
    if (result.status == 21007) {
      result = await _validateReceiptWithEndpoint(
        receiptData,
        sharedSecret,
        _sandboxUrl,
      );
    }

    return result;
  }

  /// Validate receipt with specific Apple endpoint
  ///
  /// Internal method that handles the actual HTTP request to Apple's validation service.
  /// Parses response and creates structured validation result.
  Future<AppleReceiptValidationResult> _validateReceiptWithEndpoint(
    String receiptData,
    String sharedSecret,
    String endpoint,
  ) async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(endpoint));

      request.headers.contentType = ContentType.json;

      final requestBody = {
        'receipt-data': receiptData,
        'password': sharedSecret,
        'exclude-old-transactions': true,
      };

      request.write(jsonEncode(requestBody));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      client.close();

      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      return AppleReceiptValidationResult.fromJson(responseData);
    } catch (e) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentValidationFailed,
        message: 'Apple receipt validation network error: ${e.toString()}',
        details: {'endpoint': endpoint, 'error': e.toString()},
      );
    }
  }

  /// Extract transaction information from validated Apple receipt
  ///
  /// Parses Apple receipt data to extract essential transaction details
  /// without storing any PII. Only extracts transaction IDs and product information.
  ///
  /// Parameters:
  /// - [receiptData]: Validated receipt data from Apple
  ///
  /// Returns: Map containing transaction details (transaction_id, product_id, etc.)
  ///
  /// Requirements 1.3: Extract transaction details without storing PII
  /// Requirements 6.1: Extract only transaction IDs and product information
  static Map<String, dynamic> extractTransactionData(
    Map<String, dynamic> receiptData,
  ) {
    final receipt = receiptData['receipt'] as Map<String, dynamic>?;
    if (receipt == null) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentValidationFailed,
        message: 'No receipt data found in Apple response',
        details: {'responseKeys': receiptData.keys.join(', ')},
      );
    }

    final inAppPurchases = receipt['in_app'] as List<dynamic>? ?? [];
    if (inAppPurchases.isEmpty) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentValidationFailed,
        message: 'No in-app purchases found in receipt',
        details: {'receiptKeys': receipt.keys.join(', ')},
      );
    }

    // Get the most recent purchase
    final latestPurchase = inAppPurchases.last as Map<String, dynamic>;

    return {
      'transaction_id': latestPurchase['transaction_id'] as String?,
      'original_transaction_id':
          latestPurchase['original_transaction_id'] as String?,
      'product_id': latestPurchase['product_id'] as String?,
      'purchase_date': latestPurchase['purchase_date'] as String?,
      'purchase_date_ms': latestPurchase['purchase_date_ms'] as String?,
      'quantity': latestPurchase['quantity'] as String? ?? '1',
      'is_trial_period':
          latestPurchase['is_trial_period'] as String? ?? 'false',
      'bundle_id': receipt['bundle_id'] as String?,
      'application_version': receipt['application_version'] as String?,
    };
  }
}

/// Apple IAP configuration management
///
/// Handles Apple-specific configuration using environment variables.
/// Provides validation and environment detection.
///
/// Requirements 5.1: Use environment variables for shared secret
/// Requirements 5.3: Support sandbox/production configuration
class AppleIAPConfig {
  /// Apple shared secret for receipt validation
  static String? get sharedSecret =>
      Platform.environment['APPLE_SHARED_SECRET'];

  /// Whether to use sandbox environment for testing
  static bool get useSandbox =>
      Platform.environment['APPLE_USE_SANDBOX'] == 'true';

  /// Check if Apple IAP is properly configured
  static bool get isConfigured => sharedSecret != null;

  /// Validate Apple IAP configuration
  ///
  /// Throws configuration exception if required settings are missing.
  ///
  /// Requirements 5.4: Graceful handling of missing configuration
  /// Requirements 5.5: Clear error messages for invalid configuration
  static void validateConfiguration() {
    if (!isConfigured) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'Apple IAP configuration missing',
        details: {
          'requiredConfig': 'APPLE_SHARED_SECRET',
          'optionalConfig': 'APPLE_USE_SANDBOX',
        },
      );
    }
  }
}

/// Apple receipt validation result
///
/// Structured representation of Apple's verifyReceipt API response.
/// Provides convenient access to validation status and transaction details.
class AppleReceiptValidationResult {
  final int status;
  final String? environment;
  final Map<String, dynamic>? receipt;
  final List<Map<String, dynamic>>? latestReceiptInfo;

  AppleReceiptValidationResult({
    required this.status,
    this.environment,
    this.receipt,
    this.latestReceiptInfo,
  });

  /// Create from Apple API JSON response
  factory AppleReceiptValidationResult.fromJson(Map<String, dynamic> json) {
    return AppleReceiptValidationResult(
      status: json['status'] as int,
      environment: json['environment'] as String?,
      receipt: json['receipt'] as Map<String, dynamic>?,
      latestReceiptInfo: (json['latest_receipt_info'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>(),
    );
  }

  /// Whether the receipt validation was successful
  bool get isValid => status == 0;

  /// Whether this is a sandbox receipt
  bool get isSandbox => environment == 'Sandbox';

  /// Get purchase date from receipt (for refund matching)
  DateTime? get purchaseDate {
    if (receipt == null) return null;

    final inApp = receipt!['in_app'] as List<dynamic>?;
    if (inApp == null || inApp.isEmpty) return null;

    final latestPurchase = inApp.last as Map<String, dynamic>;
    final purchaseDateMs = latestPurchase['purchase_date_ms'] as String?;
    if (purchaseDateMs == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(int.parse(purchaseDateMs));
  }

  /// Get human-readable error message for status code
  ///
  /// Maps Apple's status codes to descriptive error messages.
  ///
  /// Requirements 7.1: Return specific error codes (21000-21010)
  String get errorMessage {
    switch (status) {
      case 0:
        return 'Receipt validation successful';
      case 21000:
        return 'App Store cannot read the JSON object';
      case 21002:
        return 'Receipt data property malformed or missing';
      case 21003:
        return 'Receipt could not be authenticated';
      case 21004:
        return 'Shared secret does not match';
      case 21005:
        return 'Receipt server temporarily unavailable';
      case 21006:
        return 'Receipt valid but subscription expired';
      case 21007:
        return 'Receipt from sandbox but sent to production';
      case 21008:
        return 'Receipt from production but sent to sandbox';
      case 21010:
        return 'Account not found or deleted';
      default:
        return 'Unknown receipt validation error: $status';
    }
  }
}
