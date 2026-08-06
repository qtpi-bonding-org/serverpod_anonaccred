import 'dart:convert';
import 'dart:io';

import 'package:googleapis/androidpublisher/v3.dart' hide RefundEvent;
import 'package:serverpod/serverpod.dart';

import '../../entitlement_manager.dart';
import 'package:anonaccount_server/anonaccount_server.dart';

import '../../protocol_failures.dart';
import '../../exception_factory.dart';
import '../../generated/protocol.dart';
import '../../refund_event.dart';
import '../../refund_manager.dart';
import '../android_publisher_client.dart';
import '../google_auth_client.dart';
import '../google_pubsub_verifier.dart';
import '../payment_rail_interface.dart';
import '../rail_fulfillment_helpers.dart';

/// Google Play In-App Purchase payment rail implementation
///
/// Provides server-side validation of Google Play purchases using the Google Play
/// Developer API. Maintains privacy-first architecture by extracting only
/// transaction IDs and product information without storing PII.
///
/// Requirements 3.1, 3.2, 3.3: Google purchase validation with service account authentication
class GoogleIAPRail implements PaymentRailInterface {
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
  GoogleIAPRail({AndroidPublisherClient? client}) : _client = client;
  final AndroidPublisherClient? _client;

  /// Internal helper to get the client, throws if not initialized
  AndroidPublisherClient get _publisherClient {
    if (_client == null) {
      throw AnonAccountException(
        code: AnonAccredErrorCodes.configurationMissing,
        message:
            'Google IAP rail not initialized. Use GoogleIAPRail.create() or provide a client.',
      );
    }
    return _client;
  }

  /// Factory to create and initialize GoogleIAPRail asynchronously
  ///
  /// Loads credentials and initializes the AndroidPublisherClient.
  /// Throws [AnonAccountException] if initialization fails.
  static Future<GoogleIAPRail> create() async {
    final authClient = await GoogleAuthClient.fromEnvironment();
    final authenticatedClient = await authClient.createAuthenticatedClient();
    final publisherClient = AndroidPublisherClient(authenticatedClient);
    return GoogleIAPRail(client: publisherClient);
  }

  /// The `aud` claim Google's Pub/Sub push OIDC token is expected to carry —
  /// the configured push endpoint URL for this deployment.
  static String get expectedPushAudience =>
      Platform.environment['GOOGLE_PUBSUB_PUSH_AUDIENCE'] ?? '';

  @override
  PaymentRail get railType => PaymentRail.google_iap;

  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String internalTransactionId,
  }) async {
    // For IAP, the payment request provides information for the mobile app
    // The actual payment happens in the mobile app, then purchase token is validated
    return PaymentRequest(
      paymentRef: internalTransactionId,
      amountUSD: amountUSD,
      internalTransactionId: internalTransactionId,
      railDataJson: jsonEncode({
        'payment_rail': 'google_iap',
        'internal_transaction_id': internalTransactionId,
        'amount_usd': amountUSD,
        'validation_endpoint': '/api/iap/google/validate',
        'instructions':
            'Complete purchase in Android app, then submit purchase token for validation',
        'expires_at': DateTime.now()
            .add(const Duration(hours: 24))
            .toIso8601String(),
      }),
    );
  }

  @override
  Future<PaymentResult> processCallback(
    Map<String, dynamic> callbackData,
  ) async {
    // Google delivers Real-time Developer Notifications as a Cloud Pub/Sub
    // push request: an OIDC bearer token over the envelope, not a callback
    // carrying purchase fields directly. Full purchase validation with
    // delivery tracking happens via validatePurchase() when the client
    // submits its purchase token — this handler only verifies authenticity
    // and routes refund/void notifications to RefundManager.
    try {
      final authorizationHeader = callbackData['authorization_header'] as String?;
      final requestBody = callbackData['request_body'] as String?;
      final expectedAudience = callbackData['expected_audience'] as String?;
      final session = callbackData['session'] as Session?;

      if (authorizationHeader == null ||
          requestBody == null ||
          expectedAudience == null ||
          session == null) {
        return PaymentResult(
          success: false,
          errorMessage:
              'Missing authorization_header, request_body, expected_audience, or session',
        );
      }

      GoogleDeveloperNotification notification;
      try {
        notification = await GooglePubSubVerifier.verifyAndDecode(
          authorizationHeader: authorizationHeader,
          requestBody: requestBody,
          expectedAudience: expectedAudience,
        );
      } on AnonAccountException catch (e) {
        if (e.code == AnonAccountErrorCodes.authInvalidSignature) {
          return PaymentResult(
            success: false,
            errorMessage: 'Invalid webhook signature',
          );
        }
        rethrow;
      }

      final voided = notification.voidedPurchaseNotification;
      if (voided != null) {
        final event = extractRefundEvent(voided);
        if (event != null) {
          await RefundManager.processRefund(session, event);
        }
        return PaymentResult(
          success: true,
          internalTransactionId: voided['orderId'] as String?,
        );
      }

      // subscriptionNotification / oneTimeProductNotification / other types
      // carry no refund signal in Google's schema — acknowledge only.
      return PaymentResult(success: true);
    } on AnonAccountException {
      rethrow;
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Google IAP callback processing failed: ${e.runtimeType}',
      );
    }
  }

  @override
  RefundEvent? extractRefundEvent(Map<String, dynamic> notificationData) {
    try {
      final purchaseToken = notificationData['purchaseToken'] as String?;
      final orderId = notificationData['orderId'] as String?;

      if (purchaseToken == null || orderId == null) return null;

      return RefundEvent(
        rail: PaymentRail.google_iap,
        receiptHash: CryptoUtils.sha256Hash(purchaseToken),
        paymentRef: orderId,
        rawData: notificationData,
      );
    } catch (_) {
      return null;
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
  /// - [accountUuid]: Account UUID to deliver consumables to
  ///
  /// Returns: [GooglePurchaseValidationResult] with validation status and delivery details
  ///
  /// Requirements 2.1, 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 4.4, 5.1, 5.2, 5.4, 6.2
  Future<GooglePurchaseValidationResult> validatePurchase({
    required Session session,
    required String packageName,
    required String productId,
    required String purchaseToken,
    required UuidValue accountUuid,
    String? internalTransactionId,
  }) async {
    return tryOperation(
      session,
      'validatePurchase',
      () async {
        // 1. Hash the purchase token for blind idempotency
        final purchaseHash = CryptoUtils.sha256Hash(purchaseToken);

        // 2. Check for existing delivery via hash (idempotency)
        final existingHash = await findExistingReceipt(session, purchaseHash);

        if (existingHash != null) {
          // Already handled - return success with fromCache
          return GooglePurchaseValidationResult(
            purchaseState: 0,
            consumptionState: 1,
            fromCache: true,
          );
        }

        final expectedPackageName = Platform.environment['GOOGLE_PACKAGE_NAME'];
        if (expectedPackageName != null &&
            expectedPackageName.isNotEmpty &&
            packageName != expectedPackageName) {
          throw AnonAccredExceptionFactory.createPaymentException(
            code: AnonAccredErrorCodes.paymentValidationFailed,
            message:
                'packageName "$packageName" does not match the configured '
                'GOOGLE_PACKAGE_NAME',
            details: {'packageName': packageName},
          );
        }

        // 2. Validate with Google API
        final purchase = await _publisherClient.getPurchase(
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

        // 4. Look up RailProduct from DB (replaces old env-var ProductMappingConfig)
        final railProduct = await requireActiveRailProduct(
          session,
          PaymentRail.google_iap,
          productId,
        );

        // 5. Atomic Transaction: Record permanent hash, ephemeral audit, financial record, and inventory credit
        String? deliveredTag;
        double? deliveredQuantity;

        final purchaseTime = DateTime.fromMillisecondsSinceEpoch(
          GooglePurchaseValidationResult._parseIntField(
                purchase.purchaseTimeMillis,
              ) ??
              0,
        );
        final grants = await executeAtomicFulfillment(
          session,
          receiptHash: purchaseHash,
          rail: PaymentRail.google_iap,
          railProduct: railProduct,
          internalTransactionId: internalTransactionId,
          purchaseDate: purchaseTime,
          paymentRef: purchase.orderId ?? '',
          insertBridge: (tx) => EphemeralAccreditation.db.insertRow(
            session,
            EphemeralAccreditation(
              accountUuid: accountUuid,
              transactionTimestamp: purchaseTime,
            ),
            transaction: tx,
          ),
          creditGrant: (grant, tx) => EntitlementManager.grantEntitlementById(
            session,
            accountUuid: accountUuid,
            entitlementId: grant.entitlementId,
            quantity: grant.quantity,
            transaction: tx,
          ),
        );
        final firstGrantEntitlement = grants.isNotEmpty
            ? await Entitlement.db.findById(session, grants.first.entitlementId)
            : null;
        final metadata = firstGrantMetadata(grants, firstGrantEntitlement);
        deliveredTag = metadata.tag;
        deliveredQuantity = metadata.quantity;

        /*
        await session.db.transaction((dbTransaction) async {
          // a. Record the purchase hash permanently (blind idempotency)
          await ReceiptHash.db.insertRow(
            session,
            ReceiptHash(
              hash: purchaseHash,
              paymentRail: PaymentRail.google_iap,
            ),
            transaction: dbTransaction,
          );

          // b. Record the EPHEMERAL accreditation (Bridge account to time for 7-day refund support)
          final purchaseTime = DateTime.fromMillisecondsSinceEpoch(
            GooglePurchaseValidationResult._parseIntField(
                  purchase.purchaseTimeMillis,
                ) ??
                0,
          );

          await EphemeralAccreditation.db.insertRow(
            session,
            EphemeralAccreditation(
              accountUuid: accountUuid,
              transactionTimestamp: purchaseTime,
            ),
            transaction: dbTransaction,
          );

          // c. Create the PERMANENT financial record
          final internalTxId = internalTransactionId ?? const Uuid().v4();

          await TransactionPayment.db.insertRow(
            session,
            TransactionPayment(
              railProductId: railProduct.id!,
              internalTransactionId: internalTxId,
              priceCurrency: Currency.USD,
              price: 0.0,
              paymentRail: PaymentRail.google_iap,
              paymentCurrency: Currency.USD,
              paymentAmount: 0.0,
              paymentRef: purchase.orderId ?? '',
              transactionTimestamp: purchaseTime,
              clientReference: internalTxId,
              status: OrderStatus.paid,
            ),
            transaction: dbTransaction,
          );

          // d. Credit user inventory based on grants
          final grants = await RailProductGrant.db.find(
            session,
            where: (t) => t.railProductId.equals(railProduct.id!),
            transaction: dbTransaction,
          );

          for (final grant in grants) {
            await EntitlementManager.grantEntitlementById(
              session,
              accountUuid: accountUuid,
              entitlementId: grant.entitlementId,
              quantity: grant.quantity,
              transaction: dbTransaction,
            );
          }

          // Capture first grant info for the response
          if (grants.isNotEmpty) {
            final entitlement = await Entitlement.db.findById(
              session,
              grants.first.entitlementId,
              transaction: dbTransaction,
            );
            deliveredTag = entitlement?.tag;
            deliveredQuantity = grants.first.quantity;
          }
        });*/

        // 6. Acknowledge purchase (async, don't block)
        _acknowledgePurchaseAsync(
          session,
          packageName,
          productId,
          purchaseToken,
        );

        // 7. Always consume (all IAP products are consumable)
        _consumePurchaseAsync(session, packageName, productId, purchaseToken);

        final base = GooglePurchaseValidationResult.fromProductPurchase(
          purchase,
        );
        return GooglePurchaseValidationResult(
          consumptionState: base.consumptionState,
          purchaseState: base.purchaseState,
          developerPayload: base.developerPayload,
          internalTransactionId: base.internalTransactionId,
          purchaseTimeMillis: base.purchaseTimeMillis,
          purchaseType: base.purchaseType,
          acknowledgementState: base.acknowledgementState,
          tag: deliveredTag,
          quantity: deliveredQuantity,
        );
      },
      onFailure: paymentFailure,
      code: AnonAccredErrorCodes.paymentValidationFailed,
      extraDetails: {'packageName': packageName, 'productId': productId},
    );
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
    Session session,
    String packageName,
    String productId,
    String purchaseToken,
  ) async {
    try {
      await _publisherClient.acknowledgePurchase(
        packageName: packageName,
        productId: productId,
        purchaseToken: purchaseToken,
      );
    } catch (e) {
      // Log but don't throw (async, non-blocking)
      session.log('Failed to acknowledge purchase: $e', level: LogLevel.error);
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
    Session session,
    String packageName,
    String productId,
    String purchaseToken,
  ) async {
    try {
      await _publisherClient.consumePurchase(
        packageName: packageName,
        productId: productId,
        purchaseToken: purchaseToken,
      );
    } catch (e) {
      // Log but don't throw (async, non-blocking)
      session.log('Failed to consume purchase: $e', level: LogLevel.error);
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
    final result = await tryOperation<bool, PaymentException>(
      null,
      'acknowledgePurchase',
      () async {
        await _publisherClient.acknowledgePurchase(
          packageName: packageName,
          productId: productId,
          purchaseToken: purchaseToken,
        );
        return true;
      },
      onFailure: paymentFailure,
      code: AnonAccredErrorCodes.paymentValidationFailed,
      extraDetails: {'packageName': packageName, 'productId': productId},
    );
    return result;
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
  ) => {
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
  GooglePurchaseValidationResult({
    required this.consumptionState,
    required this.purchaseState,
    this.developerPayload,
    this.internalTransactionId,
    this.purchaseTimeMillis,
    this.purchaseType,
    this.acknowledgementState,
    this.tag,
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
        internalTransactionId:
            json['orderId'] as String? ??
            json['internalTransactionId'] as String?,
        purchaseTimeMillis: json['purchaseTimeMillis'] as int?,
        purchaseType: json['purchaseType'] as int?,
        acknowledgementState: json['acknowledgementState'] as int?,
      );

  /// Create from ProductPurchase object from googleapis
  factory GooglePurchaseValidationResult.fromProductPurchase(
    ProductPurchase productPurchase,
  ) {
    // Extract values, converting types as needed
    var consumptionState = 0;
    var purchaseState = 0;

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
      developerPayload = productPurchase.developerPayload;
    }

    String? orderId;
    if (productPurchase.orderId is String) {
      orderId = productPurchase.orderId;
    }

    return GooglePurchaseValidationResult(
      consumptionState: consumptionState,
      purchaseState: purchaseState,
      developerPayload: developerPayload,
      internalTransactionId: orderId,
      purchaseTimeMillis: _parseIntField(productPurchase.purchaseTimeMillis),
      purchaseType: _parseIntField(productPurchase.purchaseType),
      acknowledgementState: _parseIntField(
        productPurchase.acknowledgementState,
      ),
    );
  }

  final int consumptionState;
  final int purchaseState;
  final String? developerPayload;
  final String? internalTransactionId;
  final int? purchaseTimeMillis;
  final int? purchaseType;
  final int? acknowledgementState;
  final String? tag;
  final double? quantity;
  final bool fromCache;
  final DateTime? deliveredAt;

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
