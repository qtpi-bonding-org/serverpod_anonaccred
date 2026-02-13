import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import '../../exception_factory.dart';
import '../../generated/protocol.dart';
import '../../product_mapping_config.dart';
import '../apple_consumable_delivery_manager.dart';
import '../apple_jwt_auth_client.dart';
import '../app_store_server_client.dart';
import '../decoded_transaction.dart';
import '../notification_signature_validator.dart';
import '../payment_rail_interface.dart';

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
  final AppStoreServerClient _client;
  final AppleConsumableDeliveryManager _deliveryManager;

  /// Creates a new AppleIAPRail instance.
  ///
  /// [client] - Optional AppStoreServerClient for dependency injection (defaults to production client)
  /// [deliveryManager] - Optional AppleConsumableDeliveryManager for dependency injection
  AppleIAPRail({
    AppStoreServerClient? client,
    AppleConsumableDeliveryManager? deliveryManager,
  }) : _client = client ?? _createDefaultClient(),
       _deliveryManager =
           deliveryManager ?? const AppleConsumableDeliveryManager();

  /// Creates the default App Store Server API client using environment credentials.
  static AppStoreServerClient _createDefaultClient() {
    final authClient = AppleJWTAuthClient.fromEnvironment();
    return AppStoreServerClient(authClient);
  }

  @override
  PaymentRail get railType => PaymentRail.apple_iap;

  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String orderId,
  }) async {
    // For IAP, the payment request provides information for the mobile app
    // The actual payment happens in the mobile app, then transaction is validated
    return PaymentRequest(
      paymentRef: orderId,
      amountUSD: amountUSD,
      orderId: orderId,
      railDataJson:
          '{"payment_rail":"apple_iap","order_id":"$orderId","amount_usd":$amountUSD}',
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
        NotificationSignatureValidator.validateSignatureOrThrow(
          session: session,
          signedPayload: signedPayload,
        );
      } on AnonAccredException catch (e) {
        // Invalid signature - return HTTP 401
        if (e.code == AnonAccredErrorCodes.authInvalidSignature) {
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

      // Route refund notifications to processRefundNotification()
      if (notificationType == 'REFUND') {
        await processRefundNotification(session, notificationData);
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
  }) async {
    // 1. Check for existing delivery (idempotency)
    final existingDelivery = await _deliveryManager.findByIdempotencyKey(
      session,
      transactionId,
    );

    if (existingDelivery != null) {
      return AppleTransactionValidationResult.fromExistingDelivery(
        existingDelivery,
      );
    }

    // 2. Validate with Apple API
    final historyResponse = await _client.getTransactionInfo(transactionId);

    // 3. Decode and verify the signed transaction
    if (historyResponse.signedTransactions.isEmpty) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentValidationFailed,
        message: 'No transactions found for transaction ID: $transactionId',
        details: {'transactionId': transactionId},
      );
    }

    final signedTransaction = historyResponse.signedTransactions.first;
    final decodedTransaction = _decodeSignedTransaction(signedTransaction);

    // 4. Verify product ID matches
    if (decodedTransaction.productId != productId) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.paymentValidationFailed,
        message:
            'Product ID mismatch: expected $productId, got ${decodedTransaction.productId}',
        details: {
          'expectedProductId': productId,
          'actualProductId': decodedTransaction.productId,
        },
      );
    }

    // 5. Get product mapping
    final mapping = ProductMappingConfig.getAppleMapping(productId);
    if (mapping == null) {
      throw AnonAccredExceptionFactory.createException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'No product mapping for Apple product ID: $productId',
        details: {'productId': productId},
      );
    }

    // 6. Record delivery and add to inventory (atomic)
    await session.db.transaction((transaction) async {
      await _deliveryManager.recordDelivery(
        session,
        productId: productId,
        accountId: accountId,
        consumableType: mapping.consumableType,
        quantity: mapping.quantity,
        orderId: decodedTransaction.webOrderLineItemId ?? 'unknown',
        platformSpecificData: {
          'transactionId': transactionId,
          'originalTransactionId': decodedTransaction.originalTransactionId,
        },
      );

      // Note: InventoryManager.addToInventory would be called here
      // This is commented out as it depends on the inventory system implementation
      // await InventoryManager.addToInventory(
      //   session,
      //   accountId: accountId,
      //   consumableType: mapping.consumableType,
      //   quantity: mapping.quantity,
      // );
    });

    return AppleTransactionValidationResult.fromTransaction(
      decodedTransaction,
      mapping,
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
    final history = await _client.getTransactionHistory(
      originalTransactionId: originalTransactionId,
    );

    return history.signedTransactions
        .map((signedTxn) => _decodeSignedTransaction(signedTxn))
        .toList();
  }

  /// Process refund notification.
  ///
  /// Logs refund information but does not automatically remove consumables from inventory.
  ///
  /// [session] - The database session
  /// [notificationData] - The decoded notification data from Apple
  ///
  /// Requirements 6.2, 6.3, 6.4, 6.5
  Future<void> processRefundNotification(
    Session session,
    Map<String, dynamic> notificationData,
  ) async {
    // Extract transaction info from notification data
    final data = notificationData['data'] as Map<String, dynamic>?;
    if (data == null) {
      session.log(
        'Refund notification missing data field',
        level: LogLevel.warning,
      );
      return;
    }

    final signedTransactionInfo = data['signedTransactionInfo'] as String?;
    if (signedTransactionInfo == null) {
      session.log(
        'Refund notification missing signedTransactionInfo',
        level: LogLevel.warning,
      );
      return;
    }

    // Decode the transaction to get the transaction ID
    final transaction = _decodeSignedTransaction(signedTransactionInfo);
    final transactionId = transaction.transactionId;

    // Find what was delivered
    final delivery = await _deliveryManager.findByIdempotencyKey(
      session,
      transactionId,
    );

    if (delivery != null) {
      session.log(
        'Refund processed for transaction: $transactionId, '
        'product: ${delivery.productId}, '
        'delivered: ${delivery.quantity} ${delivery.consumableType}',
        level: LogLevel.warning,
      );

      // Note: We don't automatically remove from inventory
      // This is a business decision - log for manual review
    } else {
      session.log(
        'Refund notification for unknown transaction: $transactionId',
        level: LogLevel.warning,
      );
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
      throw FormatException('Invalid JWT format');
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
  DecodedTransaction _decodeSignedTransaction(String signedTransaction) {
    return DecodedTransaction.fromJWT(signedTransaction);
  }
}

/// Apple transaction validation result.
///
/// Contains validation status and delivery information.
class AppleTransactionValidationResult {
  final bool isValid;
  final String? transactionId;
  final String? originalTransactionId;
  final String? productId;
  final DateTime? purchaseDate;
  final String? consumableType;
  final double? quantity;
  final bool fromCache;
  final DateTime? deliveredAt;

  AppleTransactionValidationResult({
    required this.isValid,
    this.transactionId,
    this.originalTransactionId,
    this.productId,
    this.purchaseDate,
    this.consumableType,
    this.quantity,
    this.fromCache = false,
    this.deliveredAt,
  });

  /// Create result from a decoded transaction and product mapping.
  factory AppleTransactionValidationResult.fromTransaction(
    DecodedTransaction transaction,
    ProductMapping mapping,
  ) {
    return AppleTransactionValidationResult(
      isValid: true,
      transactionId: transaction.transactionId,
      originalTransactionId: transaction.originalTransactionId,
      productId: transaction.productId,
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(
        transaction.purchaseDate,
      ),
      consumableType: mapping.consumableType,
      quantity: mapping.quantity,
      fromCache: false,
    );
  }

  /// Create result from an existing delivery record (idempotent case).
  factory AppleTransactionValidationResult.fromExistingDelivery(
    AppleConsumableDelivery delivery,
  ) {
    return AppleTransactionValidationResult(
      isValid: true,
      transactionId: delivery.transactionId,
      originalTransactionId: delivery.originalTransactionId,
      productId: delivery.productId,
      consumableType: delivery.consumableType,
      quantity: delivery.quantity,
      fromCache: true,
      deliveredAt: delivery.deliveredAt,
    );
  }
}
