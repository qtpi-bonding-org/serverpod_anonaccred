import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../exception_factory.dart';
import '../../generated/protocol.dart';
import '../payment_rail_interface.dart';

/// Google Play In-App Purchase payment rail implementation
///
/// Provides server-side validation of Google Play purchases using the Google Play
/// Developer API. Maintains privacy-first architecture by extracting only
/// transaction IDs and product information without storing PII.
///
/// Requirements 3.1, 3.2, 3.3: Google purchase validation with service account authentication
class GoogleIAPRail implements PaymentRailInterface {
  @override
  PaymentRail get railType => PaymentRail.google_iap;

  /// Google Play Developer API base URL
  static const String _baseUrl = 'https://androidpublisher.googleapis.com/androidpublisher/v3';

  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String orderId,
  }) async {
    // For IAP, the payment request provides information for the mobile app
    // The actual payment happens in the mobile app, then purchase token is validated
    return PaymentRequest(
      paymentRef: orderId,
      amountUSD: amountUSD,
      orderId: orderId,
      railDataJson: jsonEncode({
        'payment_rail': 'google_iap',
        'order_id': orderId,
        'amount_usd': amountUSD,
        'validation_endpoint': '/api/iap/google/validate',
        'instructions': 'Complete purchase in Android app, then submit purchase token for validation',
        'expires_at': DateTime.now().add(Duration(hours: 24)).toIso8601String(),
      }),
    );
  }

  @override
  Future<PaymentResult> processCallback(Map<String, dynamic> callbackData) async {
    // Google IAP uses purchase token validation rather than callbacks
    // This method handles Real-time Developer Notifications if configured
    try {
      final packageName = callbackData['package_name'] as String?;
      final productId = callbackData['product_id'] as String?;
      final purchaseToken = callbackData['purchase_token'] as String?;
      final orderId = callbackData['order_id'] as String?;

      if (packageName == null || productId == null || purchaseToken == null || orderId == null) {
        return PaymentResult(
          success: false,
          errorMessage: 'Missing required fields in Google IAP callback',
        );
      }

      final validationResult = await validatePurchase(
        packageName: packageName,
        productId: productId,
        purchaseToken: purchaseToken,
      );
      
      if (validationResult.isValid) {
        // Acknowledge the purchase (required by Google)
        await acknowledgePurchase(
          packageName: packageName,
          productId: productId,
          purchaseToken: purchaseToken,
        );
      }

      return PaymentResult(
        success: validationResult.isValid,
        orderId: orderId,
        transactionHash: validationResult.orderId,
        errorMessage: validationResult.isValid ? null : 'Purchase validation failed',
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Google IAP callback processing failed: ${e.toString()}',
      );
    }
  }

  /// Validate Google Play purchase using Developer API
  ///
  /// Validates purchase token with Google Play Developer API and returns
  /// structured validation result. Requires service account authentication.
  ///
  /// Parameters:
  /// - [packageName]: Android app package name
  /// - [productId]: In-app product ID (SKU)
  /// - [purchaseToken]: Purchase token from Android app
  ///
  /// Returns: [GooglePurchaseValidationResult] with validation status and purchase details
  ///
  /// Requirements 3.1: Validate using Google Play Developer API
  /// Requirements 3.2: Use service account authentication
  Future<GooglePurchaseValidationResult> validatePurchase({
    required String packageName,
    required String productId,
    required String purchaseToken,
  }) async {
    final accessToken = await GoogleIAPConfig.getAccessToken();
    if (accessToken == null) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'Google service account not configured',
        details: {'requiredConfig': 'GOOGLE_SERVICE_ACCOUNT_JSON or GOOGLE_SERVICE_ACCOUNT_PATH'},
      );
    }

    try {
      final url = '$_baseUrl/applications/$packageName/purchases/products/$productId/tokens/$purchaseToken';
      
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      
      request.headers.set('Authorization', 'Bearer $accessToken');
      request.headers.set('Content-Type', 'application/json');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      client.close();
      
      if (response.statusCode != 200) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentValidationFailed,
          message: 'Google purchase validation failed: HTTP ${response.statusCode}',
          details: {
            'httpStatus': response.statusCode.toString(),
            'responseBody': responseBody,
            'packageName': packageName,
            'productId': productId,
          },
        );
      }
      
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;
      
      return GooglePurchaseValidationResult.fromJson(responseData);
    } catch (e) {
      if (e is PaymentException) rethrow;
      
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentValidationFailed,
        message: 'Google purchase validation network error: ${e.toString()}',
        details: {
          'packageName': packageName,
          'productId': productId,
          'error': e.toString(),
        },
      );
    }
  }

  /// Acknowledge Google Play purchase (required)
  ///
  /// Google requires purchases to be acknowledged within 3 days or they will
  /// be automatically refunded. This method sends the acknowledgment.
  ///
  /// Parameters:
  /// - [packageName]: Android app package name
  /// - [productId]: In-app product ID (SKU)
  /// - [purchaseToken]: Purchase token from Android app
  ///
  /// Returns: true if acknowledgment was successful
  ///
  /// Requirements 3.3: Acknowledge purchases properly
  Future<bool> acknowledgePurchase({
    required String packageName,
    required String productId,
    required String purchaseToken,
  }) async {
    final accessToken = await GoogleIAPConfig.getAccessToken();
    if (accessToken == null) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'Google service account not configured for acknowledgment',
        details: {'requiredConfig': 'GOOGLE_SERVICE_ACCOUNT_JSON or GOOGLE_SERVICE_ACCOUNT_PATH'},
      );
    }

    try {
      final url = '$_baseUrl/applications/$packageName/purchases/products/$productId/tokens/$purchaseToken:acknowledge';
      
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(url));
      
      request.headers.set('Authorization', 'Bearer $accessToken');
      request.headers.set('Content-Type', 'application/json');
      
      // Empty JSON body for acknowledgment
      request.write('{}');
      
      final response = await request.close();
      await response.drain(); // Consume response
      
      client.close();
      
      return response.statusCode == 200;
    } catch (e) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentValidationFailed,
        message: 'Google purchase acknowledgment failed: ${e.toString()}',
        details: {
          'packageName': packageName,
          'productId': productId,
          'error': e.toString(),
        },
      );
    }
  }

  /// Extract transaction information from validated Google purchase
  ///
  /// Parses Google purchase data to extract essential transaction details
  /// without storing any PII. Only extracts transaction IDs and product information.
  ///
  /// Parameters:
  /// - [purchaseData]: Validated purchase data from Google
  ///
  /// Returns: Map containing transaction details (order_id, product_id, etc.)
  ///
  /// Requirements 1.3: Extract transaction details without storing PII
  /// Requirements 6.1: Extract only transaction IDs and product information
  static Map<String, dynamic> extractTransactionData(Map<String, dynamic> purchaseData) {
    return {
      'order_id': purchaseData['orderId'] as String?,
      'product_id': purchaseData['productId'] as String?,
      'purchase_time_millis': purchaseData['purchaseTimeMillis'] as int?,
      'purchase_state': purchaseData['purchaseState'] as int?,
      'consumption_state': purchaseData['consumptionState'] as int?,
      'developer_payload': purchaseData['developerPayload'] as String?,
      'purchase_type': purchaseData['purchaseType'] as int?,
      'acknowledgement_state': purchaseData['acknowledgementState'] as int?,
    };
  }
}

/// Google IAP configuration management
///
/// Handles Google-specific configuration using environment variables or service account files.
/// Provides OAuth 2.0 token management for API authentication.
///
/// Requirements 5.2: Use service account JSON file or environment variables
/// Requirements 5.3: Support sandbox/production configuration
class GoogleIAPConfig {
  /// Service account JSON configuration
  static String? get serviceAccountJson => Platform.environment['GOOGLE_SERVICE_ACCOUNT_JSON'];
  
  /// Service account file path
  static String? get serviceAccountPath => Platform.environment['GOOGLE_SERVICE_ACCOUNT_PATH'];
  
  /// Check if Google IAP is properly configured
  static bool get isConfigured => serviceAccountJson != null || serviceAccountPath != null;
  
  /// Validate Google IAP configuration
  ///
  /// Throws configuration exception if required settings are missing.
  ///
  /// Requirements 5.4: Graceful handling of missing configuration
  /// Requirements 5.5: Clear error messages for invalid configuration
  static void validateConfiguration() {
    if (!isConfigured) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'Google IAP configuration missing',
        details: {
          'requiredConfig': 'GOOGLE_SERVICE_ACCOUNT_JSON or GOOGLE_SERVICE_ACCOUNT_PATH',
        },
      );
    }
  }

  /// Get OAuth 2.0 access token for Google Play Developer API
  ///
  /// This is a simplified implementation. In production, you would:
  /// 1. Parse the service account JSON
  /// 2. Create a JWT signed with the private key
  /// 3. Exchange JWT for access token
  /// 4. Cache tokens and handle refresh
  ///
  /// For now, returns null to indicate configuration needed.
  static Future<String?> getAccessToken() async {
    // TODO: Implement proper OAuth 2.0 flow with service account
    // This would require JWT creation and token exchange
    // For development, this returns null to indicate missing implementation
    return null;
  }
}

/// Google purchase validation result
///
/// Structured representation of Google Play Developer API response.
/// Provides convenient access to validation status and purchase details.
class GooglePurchaseValidationResult {
  final int consumptionState;
  final int purchaseState;
  final String? developerPayload;
  final String? orderId;
  final int? purchaseTimeMillis;
  final int? purchaseType;
  final int? acknowledgementState;

  GooglePurchaseValidationResult({
    required this.consumptionState,
    required this.purchaseState,
    this.developerPayload,
    this.orderId,
    this.purchaseTimeMillis,
    this.purchaseType,
    this.acknowledgementState,
  });

  /// Create from Google API JSON response
  factory GooglePurchaseValidationResult.fromJson(Map<String, dynamic> json) {
    return GooglePurchaseValidationResult(
      consumptionState: json['consumptionState'] as int? ?? 0,
      purchaseState: json['purchaseState'] as int? ?? 0,
      developerPayload: json['developerPayload'] as String?,
      orderId: json['orderId'] as String?,
      purchaseTimeMillis: json['purchaseTimeMillis'] as int?,
      purchaseType: json['purchaseType'] as int?,
      acknowledgementState: json['acknowledgementState'] as int?,
    );
  }

  /// Whether the purchase validation was successful
  /// purchaseState: 0 = Purchased, 1 = Canceled, 2 = Pending
  bool get isValid => purchaseState == 0;

  /// Whether the purchase has been consumed
  /// consumptionState: 0 = Yet to be consumed, 1 = Consumed
  bool get isConsumed => consumptionState == 1;

  /// Whether the purchase has been acknowledged
  /// acknowledgementState: 0 = Yet to be acknowledged, 1 = Acknowledged
  bool get isAcknowledged => acknowledgementState == 1;

  /// Get human-readable error message for purchase state
  ///
  /// Maps Google's purchase states to descriptive messages.
  ///
  /// Requirements 7.2: Return appropriate HTTP status codes and messages
  String get errorMessage {
    switch (purchaseState) {
      case 0:
        return 'Purchase successful';
      case 1:
        return 'Purchase was canceled';
      case 2:
        return 'Purchase is pending';
      default:
        return 'Unknown purchase state: $purchaseState';
    }
  }
}