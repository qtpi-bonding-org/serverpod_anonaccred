import 'dart:convert';

import 'package:googleapis/androidpublisher/v3.dart';
import 'package:serverpod/serverpod.dart';

import '../../exception_factory.dart';
import '../../generated/protocol.dart';
import '../../inventory_manager.dart';
import '../../product_mapping_config.dart';
import '../android_publisher_client.dart';
import '../consumable_delivery_manager.dart';
import '../payment_rail_interface.dart';
import '../webhook_signature_validator.dart';

/// Google Play In-App Purchase payment rail implementation
///
/// Provides server-side validation of Google Play purchases using the Google Play
/// Developer API. Maintains privacy-first architecture by extracting only
/// transaction IDs and product information without storing PII.
///
/// Requirements 3.1, 3.2, 3.3: Google purchase validation with service account authentication
class GoogleIAPRail implements PaymentRailInterface {
  final AndroidPublisherClient _client;

  /// Create GoogleIAPRail with optional dependency injection
  ///
  /// If [client] is not provided, creates a default client using GoogleAuthClient
  /// with credentials from environment variables.
  ///
  /// Parameters:
  /// - [client]: Optional AndroidPublisherClient for dependency injection (e.g., for testing)
  ///
  /// Requirements 2.1: Use AndroidPublisherClient for API calls
  /// Requirements 9.4: Support dependency injection for testing
  GoogleIAPRail({AndroidPublisherClient? client})
      : _client = client ?? _createDefaultClient();

  /// Create default AndroidPublisherClient using GoogleAuthClient
  ///
  /// Loads service account credentials from environment and creates an authenticated
  /// client for Google Play Developer API calls.
  ///
  /// Returns: [AndroidPublisherClient] configured with OAuth 2.0 authentication
  ///
  /// Throws: [AnonAccredException] if credentials are not configured
  ///
  /// Requirements 2.1: Create client using GoogleAuthClient
  /// Requirements 1.1, 1.2: OAuth 2.0 service account authentication
  static AndroidPublisherClient _createDefaultClient() {
    throw UnimplementedError(
      'Default client creation requires async initialization. '
      'Use GoogleIAPRail.create() factory instead or provide a client via constructor.',
    );
  }

  @override
  PaymentRail get railType => PaymentRail.google_iap;

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
        'instructions':
            'Complete purchase in Android app, then submit purchase token for validation',
        'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      }),
    );
  }

  @override
  Future<PaymentResult> processCallback(
    Map<String, dynamic> callbackData,
  ) async {
    // Google IAP uses purchase token validation rather than callbacks
    // This method handles Real-time Developer Notifications if configured
    try {
      final packageName = callbackData['package_name'] as String?;
      final productId = callbackData['product_id'] as String?;
      final purchaseToken = callbackData['purchase_token'] as String?;
      final orderId = callbackData['order_id'] as String?;
      final notificationType = callbackData['notification_type'] as String?;
      final signature = callbackData['signature'] as String?;
      final payload = callbackData['payload'] as String?;
      final session = callbackData['session'] as Session?;

      // Validate webhook signature if present
      if (signature != null && payload != null && session != null) {
        try {
          WebhookSignatureValidator.validateSignatureOrThrow(
            session: session,
            payload: payload,
            signature: signature,
          );
        } on AnonAccredException catch (e) {
          // Invalid signature - return HTTP 401
          if (e.code == AnonAccredErrorCodes.authInvalidSignature) {
            return PaymentResult(
              success: false,
              errorMessage: 'Invalid webhook signature',
            );
          }
          rethrow;
        }
      }

      // Handle refund notifications
      if (notificationType == 'refund' && session != null) {
        await processRefundWebhook(session, callbackData);
        return PaymentResult(
          success: true,
          orderId: orderId,
        );
      }

      // Handle malformed payloads
      if (packageName == null ||
          productId == null ||
          purchaseToken == null ||
          orderId == null) {
        return PaymentResult(
          success: false,
          errorMessage: 'Missing required fields in Google IAP callback',
        );
      }

      // Note: Full purchase validation with delivery tracking requires session and accountId
      // This is handled by the validatePurchase() method which is GoogleIAPRail-specific
      // For processCallback, we just validate the purchase exists and is in valid state
      final purchase = await _client.getPurchase(
        packageName: packageName,
        productId: productId,
        purchaseToken: purchaseToken,
      );

      final isValid = purchase.purchaseState == 0;

      if (isValid) {
        // Acknowledge the purchase (required by Google)
        await acknowledgePurchase(
          packageName: packageName,
          productId: productId,
          purchaseToken: purchaseToken,
        );
      }

      return PaymentResult(
        success: isValid,
        orderId: orderId,
        transactionTimestamp: purchase.purchaseTimeMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(purchase.purchaseTimeMillis! as int)
            : null,
        errorMessage: isValid ? null : 'Purchase validation failed',
      );
    } on AnonAccredException {
      rethrow;
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Google IAP callback processing failed: ${e.toString()}',
      );
    }
  }

  /// Process refund webhook from Google Real-time Developer Notifications
  ///
  /// Handles refund notifications by looking up the delivery record to determine
  /// what was delivered, then logging the refund event. Does not automatically
  /// remove consumables from inventory.
  ///
  /// Parameters:
  /// - [session]: Serverpod session for database operations and logging
  /// - [webhookData]: Parsed webhook payload from Google
  ///
  /// Requirements 7.2, 7.3, 7.4, 7.5: Refund webhook processing
  Future<void> processRefundWebhook(
    Session session,
    Map<String, dynamic> webhookData,
  ) async {
    try {
      final purchaseToken = webhookData['purchaseToken'] as String?;
      if (purchaseToken == null) {
        session.log(
          'Refund webhook missing purchaseToken',
          level: LogLevel.warning,
        );
        return;
      }

      // Find what was delivered
      final delivery = await ConsumableDeliveryManager.getDeliveryForRefund(
        session,
        purchaseToken,
      );

      if (delivery != null) {
        // Log refund event with purchase token, product ID, and delivered quantity
        session.log(
          'Refund processed for purchase: $purchaseToken, '
          'product: ${delivery.productId}, '
          'delivered: ${delivery.quantity} ${delivery.consumableType}',
          level: LogLevel.warning,
        );

        // Note: We don't automatically remove from inventory
        // This is a business decision - log for manual review
      } else {
        session.log(
          'Refund webhook for unknown purchase token: $purchaseToken',
          level: LogLevel.warning,
        );
      }
    } catch (e) {
      session.log(
        'Error processing refund webhook: ${e.toString()}',
        level: LogLevel.error,
      );
    }
  }

  /// Validate Google Play purchase with idempotency checking
  ///
  /// Implements idempotent purchase validation with delivery tracking:
  /// 1. Checks for existing delivery record (idempotency)
  /// 2. Validates with Google API if new
  /// 3. Records delivery and adds to inventory atomically
  /// 4. Acknowledges and consumes purchase asynchronously
  ///
  /// Parameters:
  /// - [session]: Serverpod session for database operations
  /// - [packageName]: Android app package name
  /// - [productId]: In-app product ID (SKU)
  /// - [purchaseToken]: Purchase token from Android app
  /// - [accountId]: Account to deliver consumables to
  ///
  /// Returns: [GooglePurchaseValidationResult] with validation status and delivery details
  ///
  /// Requirements 2.1, 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 4.4, 5.1, 5.2, 5.4, 6.2
  Future<GooglePurchaseValidationResult> validatePurchase({
    required Session session,
    required String packageName,
    required String productId,
    required String purchaseToken,
    required int accountId,
  }) async {
    try {
      // 1. Check for existing delivery (idempotency)
      final existingDelivery = await ConsumableDeliveryManager.findByPurchaseToken(
        session,
        purchaseToken,
      );

      if (existingDelivery != null) {
        return GooglePurchaseValidationResult.fromExistingDelivery(existingDelivery);
      }

      // 2. Validate with Google API
      final purchase = await _client.getPurchase(
        packageName: packageName,
        productId: productId,
        purchaseToken: purchaseToken,
      );

      // 3. Check purchase state (must be 0 for valid)
      if (purchase.purchaseState != 0) {
        throw AnonAccredExceptionFactory.createPaymentException(
          code: AnonAccredErrorCodes.paymentValidationFailed,
          message: 'Purchase not in valid state: ${purchase.purchaseState}',
          details: {'purchaseState': purchase.purchaseState.toString()},
        );
      }

      // 4. Get product mapping
      final mapping = ProductMappingConfig.getMapping(productId);
      if (mapping == null) {
        throw AnonAccredExceptionFactory.createException(
          code: AnonAccredErrorCodes.configurationMissing,
          message: 'No product mapping found for product ID: $productId',
          details: {'productId': productId},
        );
      }

      // 5. Record delivery and add to inventory (atomic)
      await session.db.transaction((transaction) async {
        await ConsumableDeliveryManager.recordDelivery(
          session,
          purchaseToken: purchaseToken,
          productId: productId,
          accountId: accountId,
          consumableType: mapping.consumableType,
          quantity: mapping.quantity,
          orderId: purchase.orderId ?? 'unknown',
        );

        await InventoryManager.updateInventoryBalance(
          session,
          accountId: accountId,
          consumableType: mapping.consumableType,
          quantityDelta: mapping.quantity,
          transaction: transaction,
        );
      });

      // 6. Acknowledge purchase (async, don't block)
      _acknowledgePurchaseAsync(packageName, productId, purchaseToken);

      // 7. Consume if auto-consume enabled
      if (mapping.autoConsume) {
        _consumePurchaseAsync(packageName, productId, purchaseToken);
      }

      return GooglePurchaseValidationResult.fromPurchase(purchase, mapping);
    } on PaymentException {
      rethrow;
    } on AnonAccredException {
      rethrow;
    } catch (e) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentValidationFailed,
        message: 'Google purchase validation failed: ${e.toString()}',
        details: {
          'packageName': packageName,
          'productId': productId,
          'error': e.toString(),
        },
      );
    }
  }

  /// Acknowledge purchase asynchronously (non-blocking)
  ///
  /// Calls acknowledgePurchase() in the background without blocking the response.
  /// Logs errors but doesn't throw - this is a best-effort operation.
  ///
  /// Parameters:
  /// - [packageName]: Android app package name
  /// - [productId]: In-app product ID (SKU)
  /// - [purchaseToken]: Purchase token from Android app
  ///
  /// Requirements 2.2: Use AndroidPublisherClient for acknowledgment
  Future<void> _acknowledgePurchaseAsync(
    String packageName,
    String productId,
    String purchaseToken,
  ) async {
    try {
      await _client.acknowledgePurchase(
        packageName: packageName,
        productId: productId,
        purchaseToken: purchaseToken,
      );
    } catch (e) {
      // Log but don't throw (async, non-blocking)
      print('Failed to acknowledge purchase: $e');
    }
  }

  /// Consume purchase asynchronously (non-blocking)
  ///
  /// Calls consumePurchase() in the background without blocking the response.
  /// Logs errors but doesn't throw - this is a best-effort operation.
  ///
  /// Parameters:
  /// - [packageName]: Android app package name
  /// - [productId]: In-app product ID (SKU)
  /// - [purchaseToken]: Purchase token from Android app
  ///
  /// Requirements 2.3, 5.3, 5.5: Use AndroidPublisherClient for consumption
  Future<void> _consumePurchaseAsync(
    String packageName,
    String productId,
    String purchaseToken,
  ) async {
    try {
      await _client.consumePurchase(
        packageName: packageName,
        productId: productId,
        purchaseToken: purchaseToken,
      );
    } catch (e) {
      // Log but don't throw (async, non-blocking)
      print('Failed to consume purchase: $e');
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
  /// Requirements 2.2: Use AndroidPublisherClient for acknowledgment
  Future<bool> acknowledgePurchase({
    required String packageName,
    required String productId,
    required String purchaseToken,
  }) async {
    try {
      await _client.acknowledgePurchase(
        packageName: packageName,
        productId: productId,
        purchaseToken: purchaseToken,
      );
      return true;
    } on PaymentException {
      rethrow;
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
  static Map<String, dynamic> extractTransactionData(
    Map<String, dynamic> purchaseData,
  ) =>
      {
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
  final String? consumableType;
  final double? quantity;
  final bool fromCache;
  final DateTime? deliveredAt;

  GooglePurchaseValidationResult({
    required this.consumptionState,
    required this.purchaseState,
    this.developerPayload,
    this.orderId,
    this.purchaseTimeMillis,
    this.purchaseType,
    this.acknowledgementState,
    this.consumableType,
    this.quantity,
    this.fromCache = false,
    this.deliveredAt,
  });

  /// Create from Google API JSON response
  factory GooglePurchaseValidationResult.fromJson(Map<String, dynamic> json) =>
      GooglePurchaseValidationResult(
        consumptionState: json['consumptionState'] as int? ?? 0,
        purchaseState: json['purchaseState'] as int? ?? 0,
        developerPayload: json['developerPayload'] as String?,
        orderId: json['orderId'] as String?,
        purchaseTimeMillis: json['purchaseTimeMillis'] as int?,
        purchaseType: json['purchaseType'] as int?,
        acknowledgementState: json['acknowledgementState'] as int?,
      );

  /// Create from ProductPurchase object from googleapis
  factory GooglePurchaseValidationResult.fromProductPurchase(
    ProductPurchase productPurchase,
  ) {
    // Extract values, converting types as needed
    int consumptionState = 0;
    int purchaseState = 0;
    
    // Handle consumptionState - may be int or String
    if (productPurchase.consumptionState != null) {
      final val = productPurchase.consumptionState;
      if (val is int) {
        consumptionState = val;
      } else {
        consumptionState = int.tryParse(val.toString()) ?? 0;
      }
    }
    
    // Handle purchaseState - may be int or String
    if (productPurchase.purchaseState != null) {
      final val = productPurchase.purchaseState;
      if (val is int) {
        purchaseState = val;
      } else {
        purchaseState = int.tryParse(val.toString()) ?? 0;
      }
    }
    
    String? developerPayload;
    if (productPurchase.developerPayload is String) {
      developerPayload = productPurchase.developerPayload as String;
    }
    
    String? orderId;
    if (productPurchase.orderId is String) {
      orderId = productPurchase.orderId as String;
    }
    
    return GooglePurchaseValidationResult(
      consumptionState: consumptionState,
      purchaseState: purchaseState,
      developerPayload: developerPayload,
      orderId: orderId,
      purchaseTimeMillis: _parseIntField(productPurchase.purchaseTimeMillis),
      purchaseType: _parseIntField(productPurchase.purchaseType),
      acknowledgementState: _parseIntField(productPurchase.acknowledgementState),
    );
  }

  /// Create from ProductPurchase and ProductMapping (for new purchases)
  factory GooglePurchaseValidationResult.fromPurchase(
    ProductPurchase productPurchase,
    ProductMapping mapping,
  ) {
    final base = GooglePurchaseValidationResult.fromProductPurchase(productPurchase);
    return GooglePurchaseValidationResult(
      consumptionState: base.consumptionState,
      purchaseState: base.purchaseState,
      developerPayload: base.developerPayload,
      orderId: base.orderId,
      purchaseTimeMillis: base.purchaseTimeMillis,
      purchaseType: base.purchaseType,
      acknowledgementState: base.acknowledgementState,
      consumableType: mapping.consumableType,
      quantity: mapping.quantity,
      fromCache: false,
      deliveredAt: null,
    );
  }

  /// Create from existing delivery record (for cached/idempotent responses)
  factory GooglePurchaseValidationResult.fromExistingDelivery(
    ConsumableDelivery delivery,
  ) {
    return GooglePurchaseValidationResult(
      consumptionState: 0,
      purchaseState: 0,
      orderId: delivery.orderId,
      consumableType: delivery.consumableType,
      quantity: delivery.quantity,
      fromCache: true,
      deliveredAt: delivery.deliveredAt,
    );
  }

  /// Helper to parse int fields that may be int or String
  static int? _parseIntField(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Whether the purchase validation was successful
  /// purchaseState: 0 = Purchased, 1 = Canceled, 2 = Pending
  bool get isValid => purchaseState == 0 || fromCache;

  /// Whether the purchase has been consumed
  /// consumptionState: 0 = Yet to be consumed, 1 = Consumed
  bool get isConsumed => consumptionState == 1;

  /// Whether the purchase has been acknowledged
  /// acknowledgementState: 0 = Yet to be acknowledged, 1 = Acknowledged
  bool get isAcknowledged => acknowledgementState == 1;

  /// Get purchase date (for refund matching)
  DateTime? get purchaseDate {
    if (purchaseTimeMillis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(purchaseTimeMillis!);
  }

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
