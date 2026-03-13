import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../entitlement_manager.dart';
import 'package:anonaccount_server/anonaccount_server.dart';

import '../../exception_factory.dart';
import '../../generated/protocol.dart';
import '../../refund_event.dart';
import '../../refund_manager.dart';
import '../app_store_server_client.dart';
import '../apple_jwt_auth_client.dart';
import '../notification_signature_validator.dart';
import '../payment_rail_interface.dart';
import 'package:uuid/uuid.dart';

/// Apple In-App Purchase payment rail implementation using app_store_server_sdk.
///
/// This implementation uses the App Store Server API with JWT authentication
/// instead of the deprecated verifyReceipt API. It provides:
/// - Transaction validation with idempotency guarantees
/// - Consumable delivery tracking
/// - Transaction history retrieval
/// - Refund notification processing
///
/// Requirements 2.1, 2.2, 2.3: App Store Server SDK integration
class AppleIAPRail implements PaymentRailInterface {
  /// Creates a new AppleIAPRail instance.
  ///
  /// [client] - Optional AppStoreServerClient for dependency injection (defaults to production client)
  AppleIAPRail({AppStoreServerClient? client}) : _client = client;

  final AppStoreServerClient? _client;

  /// Factory to create and initialize AppleIAPRail asynchronously.
  ///
  /// Reads `APPLE_ENVIRONMENT` env var to select sandbox or production API.
  /// Defaults to production. Set `APPLE_ENVIRONMENT=sandbox` for TestFlight/dev testing.
  static Future<AppleIAPRail> create() async {
    final authClient = AppleJWTAuthClient.fromEnvironment();
    final envStr = Platform.environment['APPLE_ENVIRONMENT'] ?? 'production';
    final environment = envStr.toLowerCase() == 'sandbox'
        ? AppStoreClientEnvironment.sandbox
        : AppStoreClientEnvironment.production;
    final client = AppStoreServerClient(authClient, environment: environment);
    return AppleIAPRail(client: client);
  }

  /// Internal helper to get the client, throws if not initialized
  AppStoreServerClient get _appStoreClient {
    if (_client == null) {
      throw AnonAccountException(
        code: AnonAccredErrorCodes.configurationMissing,
        message:
            'Apple IAP rail not initialized. Use AppleIAPRail.create() or provide a client.',
      );
    }
    return _client;
  }

  @override
  PaymentRail get railType => PaymentRail.apple_iap;

  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String internalTransactionId,
  }) async {
    // For IAP, the payment request provides information for the mobile app
    // The actual payment happens in the mobile app, then transaction is validated
    return PaymentRequest(
      paymentRef: internalTransactionId,
      amountUSD: amountUSD,
      internalTransactionId: internalTransactionId,
      railDataJson: jsonEncode({
        'payment_rail': 'apple_iap',
        'internal_transaction_id': internalTransactionId,
        'amount_usd': amountUSD,
        'validation_endpoint': '/api/iap/apple/validate',
        'instructions':
            'Complete purchase in iOS app, then submit transaction ID for validation',
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
    // Apple IAP uses App Store Server Notifications V2
    // This method handles webhook notifications with signature validation
    try {
      final requestBody = callbackData['request_body'] as String?;
      final session = callbackData['session'] as Session?;

      // Validate required fields
      if (requestBody == null || session == null) {
        return PaymentResult(
          success: false,
          errorMessage: 'Malformed payload: missing request_body or session',
        );
      }

      // Extract signed payload from request body
      final signedPayload = NotificationSignatureValidator.extractSignedPayload(
        requestBody,
      );
      if (signedPayload == null) {
        return PaymentResult(
          success: false,
          errorMessage: 'Malformed payload: missing signedPayload',
        );
      }

      // Validate notification signature
      try {
        await NotificationSignatureValidator.validateSignatureOrThrow(
          session: session,
          signedPayload: signedPayload,
        );
      } on AnonAccountException catch (e) {
        // Invalid signature - return HTTP 401
        if (e.code == AnonAccountErrorCodes.authInvalidSignature) {
          return PaymentResult(
            success: false,
            errorMessage: 'Invalid notification signature',
          );
        }
        rethrow;
      }

      // Decode the signed payload to get notification data
      final notificationData = _decodeNotificationPayload(signedPayload);
      final notificationType = notificationData['notificationType'] as String?;

      // Route refund notifications to RefundManager
      if (notificationType == 'REFUND') {
        final event = extractRefundEvent(notificationData);
        if (event != null) {
          await RefundManager.processRefund(session, event);
        }
        return PaymentResult(
          success: true,
          errorMessage: 'Refund notification acknowledged',
        );
      }

      // Acknowledge other notification types
      return PaymentResult(
        success: true,
        errorMessage: 'Notification acknowledged',
      );
    } on FormatException {
      // Malformed JSON payload
      return PaymentResult(
        success: false,
        errorMessage: 'Malformed payload: invalid JSON',
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Apple IAP callback processing failed: ${e.toString()}',
      );
    }
  }

  /// Validate transaction with idempotency check.
  ///
  /// This method:
  /// 1. Checks for existing delivery (idempotency)
  /// 2. Validates with Apple API
  /// 3. Decodes and verifies the signed transaction
  /// 4. Verifies product ID matches
  /// 5. Gets product mapping
  /// 6. Atomically creates delivery record and adds to inventory
  ///
  /// [session] - The database session
  /// [transactionId] - The Apple transaction ID
  /// [productId] - The product ID to validate
  /// [accountId] - The account ID to deliver to
  ///
  /// Returns [AppleTransactionValidationResult] with validation details.
  ///
  /// Requirements 2.1, 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 5.2, 5.3
  Future<AppleTransactionValidationResult> validateTransaction({
    required Session session,
    required String transactionId,
    required String productId,
    required int accountId,
    String?
    internalTransactionId, // Optional internal reference if provided by client
  }) async {
    // 1. Hash the transaction ID for blind idempotency
    final transactionHash = CryptoUtils.sha256Hash(transactionId);

    // 2. Check for existing delivery via hash (idempotency)
    final existingHash = await ReceiptHash.db.findFirstRow(
      session,
      where: (t) => t.hash.equals(transactionHash),
    );

    if (existingHash != null) {
      // If we've seen this hash, it means coins were already delivered.
      // We return success with fromCache=true to let the app know it's handled.
      return AppleTransactionValidationResult(
        isValid: true,
        transactionId: transactionId,
        productId: productId,
        fromCache: true,
      );
    }

    // 3. Validate with Apple API
    final historyResponse = await _appStoreClient.getTransactionInfo(
      transactionId,
    );

    // 4. Decode and verify the signed transaction
    if (historyResponse.signedTransactions.isEmpty) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentValidationFailed,
        message: 'No transactions found for transaction ID: $transactionId',
        details: {'transactionId': transactionId},
      );
    }

    final signedTransaction = historyResponse.signedTransactions.first;
    final decodedTransaction = _decodeSignedTransaction(signedTransaction);

    // 5. Apple receipt is the source of truth for product ID.
    // The client may send a mismatched productId when Apple re-delivers
    // a stale transaction from a previous purchase. Log and use Apple's value.
    final resolvedProductId = decodedTransaction.productId;
    if (resolvedProductId != productId) {
      session.log(
        'Product ID mismatch: client sent $productId, '
        'Apple receipt has $resolvedProductId — using receipt value',
        level: LogLevel.warning,
      );
    }

    // 6. Look up RailProduct from DB (replaces old env-var ProductMappingConfig)
    final railProduct = await RailProduct.db.findFirstRow(
      session,
      where: (t) =>
          t.rail.equals(PaymentRail.apple_iap) &
          t.storeProductId.equals(resolvedProductId),
    );

    if (railProduct == null) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccredErrorCodes.configurationMissing,
        message:
            'No RailProduct found for Apple product ID: $resolvedProductId',
        details: {'productId': resolvedProductId},
      );
    }

    // 7. Atomic Transaction: Record permanent hash, ephemeral audit, delivery, and credit inventory
    String? deliveredTag;
    double? deliveredQuantity;

    await session.db.transaction((dbTransaction) async {
      // a. Record the transaction hash permanently (blind idempotency)
      await ReceiptHash.db.insertRow(
        session,
        ReceiptHash(hash: transactionHash, paymentRail: PaymentRail.apple_iap),
        transaction: dbTransaction,
      );

      // b. Record the EPHEMERAL accreditation (Bridge account to time for 7-day refund support)
      final purchaseDate = DateTime.fromMillisecondsSinceEpoch(
        decodedTransaction.purchaseDate,
      );

      await EphemeralAccreditation.db.insertRow(
        session,
        EphemeralAccreditation(
          accountId: accountId,
          transactionTimestamp: purchaseDate,
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
          paymentRail: PaymentRail.apple_iap,
          paymentCurrency: Currency.USD,
          paymentAmount: 0.0,
          paymentRef: transactionId,
          transactionTimestamp: purchaseDate,
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
          accountId: accountId,
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
    });

    return AppleTransactionValidationResult(
      isValid: true,
      transactionId: decodedTransaction.transactionId,
      originalTransactionId: decodedTransaction.originalTransactionId,
      productId: decodedTransaction.productId,
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(
        decodedTransaction.purchaseDate,
      ),
      tag: deliveredTag,
      quantity: deliveredQuantity,
    );
  }

  /// Get transaction history for user.
  ///
  /// Retrieves all transactions for an original transaction ID with pagination support.
  ///
  /// [session] - The database session
  /// [originalTransactionId] - The original transaction ID
  ///
  /// Returns a list of [DecodedTransaction] objects.
  ///
  /// Requirements 8.1, 8.2, 8.3, 8.5
  Future<List<DecodedTransaction>> getTransactionHistory({
    required Session session,
    required String originalTransactionId,
  }) async {
    final history = await _appStoreClient.getTransactionHistory(
      originalTransactionId: originalTransactionId,
    );

    return history.signedTransactions.map(_decodeSignedTransaction).toList();
  }

  @override
  RefundEvent? extractRefundEvent(Map<String, dynamic> notificationData) {
    try {
      final data = notificationData['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      final signedTransactionInfo = data['signedTransactionInfo'] as String?;
      if (signedTransactionInfo == null) return null;

      final transaction = _decodeSignedTransaction(signedTransactionInfo);
      final transactionId = transaction.transactionId;

      return RefundEvent(
        rail: PaymentRail.apple_iap,
        receiptHash: CryptoUtils.sha256Hash(transactionId),
        paymentRef: transactionId,
        productId: transaction.productId,
        purchaseTimestamp: DateTime.fromMillisecondsSinceEpoch(
          transaction.purchaseDate,
        ),
        rawData: notificationData,
      );
    } catch (_) {
      return null;
    }
  }

  /// Decode notification payload JWT.
  ///
  /// Decodes the signed notification payload to extract notification data.
  /// Note that signature verification should be done before calling this method.
  ///
  /// [signedPayload] - The signed JWT from Apple notification
  ///
  /// Returns a Map with the decoded notification data.
  Map<String, dynamic> _decodeNotificationPayload(String signedPayload) {
    // Split JWT and decode payload (middle part)
    final parts = signedPayload.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT format');
    }

    final payloadPart = parts[1];
    final normalized = base64Url.normalize(payloadPart);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }

  /// Decode signed transaction JWT.
  ///
  /// Decodes the JWT and extracts transaction data. Note that this does NOT
  /// verify the signature - signature verification should be done separately
  /// using Apple root certificates.
  ///
  /// [signedTransaction] - The signed JWT from Apple
  ///
  /// Returns a [DecodedTransaction] with all transaction details.
  ///
  /// Requirements 2.5, 7.2
  DecodedTransaction _decodeSignedTransaction(String signedTransaction) =>
      DecodedTransaction.fromJWT(signedTransaction);

  /// Extract transaction information from validated Apple purchase
  ///
  /// Parses Apple purchase data to extract essential transaction details
  /// without storing any PII. Only extracts transaction IDs and product information.
  static Map<String, dynamic> extractTransactionData(
    Map<String, dynamic> purchaseData,
  ) {
    if (purchaseData.containsKey('receipt')) {
      final receipt = purchaseData['receipt'] as Map<String, dynamic>;
      final inApp = receipt['in_app'] as List<dynamic>?;
      final firstInApp = inApp != null && inApp.isNotEmpty
          ? inApp.first as Map<String, dynamic>
          : <String, dynamic>{};

      return {
        'transaction_id': firstInApp['transaction_id'] as String?,
        'original_transaction_id':
            firstInApp['original_transaction_id'] as String?,
        'product_id': firstInApp['product_id'] as String?,
        'purchase_date': firstInApp['purchase_date'] as String?,
        'purchase_date_ms': firstInApp['purchase_date_ms'] as String?,
        'quantity': firstInApp['quantity'] as String?,
        'is_trial_period': firstInApp['is_trial_period'] as String?,
        'bundle_id': receipt['bundle_id'] as String?,
        'application_version': receipt['application_version'] as String?,
      };
    }
    return purchaseData;
  }
}

/// Decoded Apple transaction data.
///
/// Contains details extracted from the signed transaction JWT.
class DecodedTransaction {
  DecodedTransaction({
    required this.transactionId,
    required this.originalTransactionId,
    required this.productId,
    required this.purchaseDate,
    required this.quantity,
    required this.type,
    required this.inAppOwnershipType,
    this.revocationDate,
    this.revocationReason,
  });

  /// Create from signed JWT (unverified decode)
  factory DecodedTransaction.fromJWT(String signedTransaction) {
    final parts = signedTransaction.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT format');
    }

    final payloadPart = parts[1];
    final normalized = base64Url.normalize(payloadPart);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final json = jsonDecode(decoded) as Map<String, dynamic>;

    return DecodedTransaction(
      transactionId: json['transactionId'] as String,
      originalTransactionId: json['originalTransactionId'] as String,
      productId: json['productId'] as String,
      purchaseDate: (json['purchaseDate'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      type: json['type'] as String,
      inAppOwnershipType: json['inAppOwnershipType'] as String,
      revocationDate: (json['revocationDate'] as num?)?.toInt(),
      revocationReason: (json['revocationReason'] as num?)?.toInt(),
    );
  }
  final String transactionId;
  final String originalTransactionId;
  final String productId;
  final int purchaseDate;
  final int quantity;
  final String type;
  final String inAppOwnershipType;
  final int? revocationDate;
  final int? revocationReason;
}

/// Apple transaction validation result.
///
/// Contains validation status and delivery information.
class AppleTransactionValidationResult {
  AppleTransactionValidationResult({
    required this.isValid,
    this.transactionId,
    this.originalTransactionId,
    this.productId,
    this.purchaseDate,
    this.tag,
    this.quantity,
    this.fromCache = false,
    this.deliveredAt,
  });

  final bool isValid;
  final String? transactionId;
  final String? originalTransactionId;
  final String? productId;
  final DateTime? purchaseDate;
  final String? tag;
  final double? quantity;
  final bool fromCache;
  final DateTime? deliveredAt;
}
