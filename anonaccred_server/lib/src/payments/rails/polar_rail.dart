import 'dart:convert';
import 'dart:io';

import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart';

import '../../entitlement_manager.dart';
import '../../exception_factory.dart';
import '../../generated/protocol.dart';
import '../../group_entitlement_manager.dart';
import '../../refund_event.dart';
import '../../refund_manager.dart';
import '../payment_rail_interface.dart';
import '../polar_client.dart';
import '../redemption_target.dart';
import '../polar_signature_validator.dart';
import '../rail_fulfillment_helpers.dart';

/// Polar.sh license-key payment rail.
///
/// Mirrors [AppleIAPRail]'s shape. Where Apple validates a transaction
/// via the App Store Server API and credits an account via
/// [RailProduct] + [RailProductGrant], Polar validates a license key
/// via Polar's API and credits **either an account or a group** via
/// the same DB tables.
///
/// Scope dispatch is driven by the entitlement tag prefix of the
/// product's first grant:
///   * tag starts with `group_` → group product (requires [GroupTarget])
///   * otherwise → account product (requires [AccountTarget])
///
/// Mismatched target/product scope throws
/// [AnonAccredErrorCodes.polarScopeMismatch].
class PolarRail implements PaymentRailInterface {
  PolarRail({required this.client, this.signatureValidator});

  /// Build from env vars: `POLAR_ACCESS_TOKEN`, `POLAR_ORGANIZATION_ID`,
  /// `POLAR_ENVIRONMENT`, and `POLAR_WEBHOOK_SECRET`.
  factory PolarRail.fromEnvironment() {
    final secret = Platform.environment['POLAR_WEBHOOK_SECRET'];
    return PolarRail(
      client: PolarClient.fromEnvironment(),
      signatureValidator: secret == null || secret.isEmpty
          ? null
          : PolarSignatureValidator(secret: secret),
    );
  }

  final PolarClient client;

  /// Null when the webhook secret is not configured; callbacks are rejected
  /// in that case rather than processed without authentication.
  final PolarSignatureValidator? signatureValidator;

  @override
  PaymentRail get railType => PaymentRail.polar;

  @override
  Future<PaymentRequest> createPayment({
    required double amountUSD,
    required String internalTransactionId,
  }) async {
    // Polar checkout happens in a browser; this PaymentRequest just
    // instructs the client to open the checkout flow. Actual fulfilment
    // runs server-side when the user pastes the license key into the
    // redeem endpoint.
    return PaymentRequest(
      paymentRef: internalTransactionId,
      amountUSD: amountUSD,
      internalTransactionId: internalTransactionId,
      railDataJson: jsonEncode({
        'payment_rail': PaymentRail.polar.name,
        'internal_transaction_id': internalTransactionId,
        'amount_usd': amountUSD,
        'flow': 'license_key',
        'instructions':
            'Complete checkout in browser; paste the license key into '
            'redeemLicenseKey to fulfil.',
      }),
    );
  }

  /// Validate a Polar license key and credit the target.
  ///
  /// Mirrors [AppleIAPRail.validateTransaction]:
  /// 1. Validate with Polar API
  /// 2. Hash `license_key_id`, check [ReceiptHash] for idempotency
  /// 3. Look up [RailProduct] (rail=polar, storeProductId=benefit_id)
  /// 4. Derive product scope from grants → validate target scope matches
  /// 5. Atomic transaction: [ReceiptHash] + bridge row +
  ///    [TransactionPayment] + grants (account or group)
  Future<PolarValidationResult> validateLicenseKey({
    required Session session,
    required String licenseKey,
    required RedemptionTarget target,
    String? internalTransactionId,
  }) async {
    if (licenseKey.isEmpty) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.polarValidationFailed,
        message: 'License key is empty',
        paymentRail: PaymentRail.polar.name,
      );
    }

    final validation = await client.validateLicenseKey(key: licenseKey);

    // 1. Idempotency via ReceiptHash (hash of license_key UUID)
    final licenseHash = CryptoUtils.sha256Hash(validation.id);
    final existing = await findExistingReceipt(session, licenseHash);
    if (existing != null) {
      return PolarValidationResult(
        isValid: true,
        licenseKeyId: validation.id,
        benefitId: validation.benefitId,
        fromCache: true,
      );
    }

    // 2. Look up RailProduct (storeProductId=benefit_id, rail=polar)
    final railProduct = await requireActiveRailProduct(
      session,
      PaymentRail.polar,
      validation.benefitId,
    );

    // 3. Determine product scope by inspecting the first grant's tag.
    //    Tag prefix `group_` → group-scope (matches groups-extension
    //    doc §7.1). Empty grants → misconfiguration.
    final grantList = await RailProductGrant.db.find(
      session,
      where: (t) => t.railProductId.equals(railProduct.id!),
    );
    if (grantList.isEmpty) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.polarBenefitUnmapped,
        message: 'RailProduct ${railProduct.id} has no grants configured',
        paymentRail: PaymentRail.polar.name,
      );
    }
    final firstGrantEntitlement = await Entitlement.db.findById(
      session,
      grantList.first.entitlementId,
    );
    // RailProductGrant.entitlementId is an FK with ON DELETE NO ACTION.
    final productIsGroup = firstGrantEntitlement!.tag.startsWith('group_');
    final targetIsGroup = target is GroupTarget;
    if (productIsGroup != targetIsGroup) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.polarScopeMismatch,
        message:
            'Polar benefit ${validation.benefitId} is '
            '${productIsGroup ? "group" : "account"}-scoped but redemption '
            'targets ${targetIsGroup ? "a group" : "an account"}',
        paymentRail: PaymentRail.polar.name,
        details: {
          'benefitId': validation.benefitId,
          'productScope': productIsGroup ? 'group' : 'account',
          'targetScope': targetIsGroup ? 'group' : 'account',
        },
      );
    }

    // 4. Atomic transaction
    String? deliveredTag;
    double? deliveredQuantity;
    final purchaseDate = DateTime.now().toUtc();

    final grants = await executeAtomicFulfillment(
      session,
      receiptHash: licenseHash,
      rail: PaymentRail.polar,
      railProduct: railProduct,
      internalTransactionId: internalTransactionId,
      purchaseDate: purchaseDate,
      paymentRef: validation.id,
      insertBridge: (tx) => switch (target) {
        AccountTarget(:final accountUuid) =>
          EphemeralAccreditation.db.insertRow(
            session,
            EphemeralAccreditation(
              accountUuid: accountUuid,
              transactionTimestamp: purchaseDate,
            ),
            transaction: tx,
          ),
        GroupTarget(:final shareGroupUuid, :final buyerAccountUuid) =>
          EphemeralAccreditationGroup.db.insertRow(
            session,
            EphemeralAccreditationGroup(
              accountUuid: buyerAccountUuid,
              shareGroupUuid: shareGroupUuid,
              transactionTimestamp: purchaseDate,
            ),
            transaction: tx,
          ),
      },
      creditGrant: (grant, tx) => switch (target) {
        AccountTarget(:final accountUuid) =>
          EntitlementManager.grantEntitlementById(
            session,
            accountUuid: accountUuid,
            entitlementId: grant.entitlementId,
            quantity: grant.quantity,
            transaction: tx,
          ),
        GroupTarget(:final shareGroupUuid) =>
          GroupEntitlementManager.grantGroupEntitlementById(
            session,
            shareGroupUuid: shareGroupUuid,
            entitlementId: grant.entitlementId,
            quantity: grant.quantity,
            transaction: tx,
          ),
      },
    );
    final metadata = firstGrantMetadata(grants, firstGrantEntitlement);
    deliveredTag = metadata.tag;
    deliveredQuantity = metadata.quantity;

    /*
    await session.db.transaction((dbTransaction) async {
      // a. ReceiptHash for blind idempotency
      await ReceiptHash.db.insertRow(
        session,
        ReceiptHash(hash: licenseHash, paymentRail: PaymentRail.polar),
        transaction: dbTransaction,
      );

      // b. Bridge row — account or group flavor
      switch (target) {
        case AccountTarget(:final accountUuid):
          await EphemeralAccreditation.db.insertRow(
            session,
            EphemeralAccreditation(
              accountUuid: accountUuid,
              transactionTimestamp: purchaseDate,
            ),
            transaction: dbTransaction,
          );
        case GroupTarget(:final shareGroupUuid, :final buyerAccountUuid):
          await EphemeralAccreditationGroup.db.insertRow(
            session,
            EphemeralAccreditationGroup(
              accountUuid: buyerAccountUuid,
              shareGroupUuid: shareGroupUuid,
              transactionTimestamp: purchaseDate,
            ),
            transaction: dbTransaction,
          );
      }

      // c. Permanent financial record
      await TransactionPayment.db.insertRow(
        session,
        TransactionPayment(
          railProductId: railProduct.id!,
          internalTransactionId: internalTxId,
          priceCurrency: Currency.USD,
          price: 0.0,
          paymentRail: PaymentRail.polar,
          paymentCurrency: Currency.USD,
          paymentAmount: 0.0,
          paymentRef: validation.id, // license_key_id
          transactionTimestamp: purchaseDate,
          clientReference: internalTxId,
          status: OrderStatus.paid,
        ),
        transaction: dbTransaction,
      );

      // d. Credit inventory — account or group flavor
      for (final grant in grantList) {
        switch (target) {
          case AccountTarget(:final accountUuid):
            await EntitlementManager.grantEntitlementById(
              session,
              accountUuid: accountUuid,
              entitlementId: grant.entitlementId,
              quantity: grant.quantity,
              transaction: dbTransaction,
            );
          case GroupTarget(:final shareGroupUuid):
            await GroupEntitlementManager.grantGroupEntitlementById(
              session,
              shareGroupUuid: shareGroupUuid,
              entitlementId: grant.entitlementId,
              quantity: grant.quantity,
              transaction: dbTransaction,
            );
        }
      }

      // Capture first grant info for the response
      deliveredTag = firstGrantEntitlement.tag;
      deliveredQuantity = grantList.first.quantity;
    });*/

    return PolarValidationResult(
      isValid: true,
      licenseKeyId: validation.id,
      benefitId: validation.benefitId,
      tag: deliveredTag,
      quantity: deliveredQuantity,
      expiresAt: validation.expiresAt,
    );
  }

  @override
  Future<PaymentResult> processCallback(
    Map<String, dynamic> callbackData,
  ) async {
    final session = callbackData['session'] as Session?;
    final requestBody = callbackData['request_body'] as String?;
    final headers =
        (callbackData['headers'] as Map<String, dynamic>?) ?? const {};

    if (session == null || requestBody == null) {
      return PaymentResult(
        success: false,
        errorMessage: 'Malformed payload: missing session or request_body',
      );
    }

    final validator = signatureValidator;
    if (validator == null) {
      session.log(
        'Polar webhook rejected: POLAR_WEBHOOK_SECRET not configured',
        level: LogLevel.error,
      );
      return PaymentResult(
        success: false,
        errorMessage: 'Webhook signature validation not configured',
      );
    }

    final valid = validator.verify(
      id: headers['webhook-id'] as String? ?? '',
      timestamp: headers['webhook-timestamp'] as String? ?? '',
      signatureHeader: headers['webhook-signature'] as String? ?? '',
      rawBody: requestBody,
    );
    if (!valid) {
      session.log('Polar webhook signature invalid', level: LogLevel.warning);
      return PaymentResult(
        success: false,
        errorMessage: 'Invalid webhook signature',
      );
    }

    final Map<String, dynamic> notificationData;
    try {
      notificationData = jsonDecode(requestBody) as Map<String, dynamic>;
    } on FormatException {
      return PaymentResult(
        success: false,
        errorMessage: 'Malformed payload: invalid JSON',
      );
    }

    final preliminary = extractRefundEvent(notificationData);
    if (preliminary != null) {
      final data = notificationData['data'] as Map<String, dynamic>?;
      final orderId = data?['order_id'] as String?;
      final resolved = orderId == null
          ? null
          : await resolveRefundEvent(orderId, preliminary);
      if (resolved != null) {
        await RefundManager.processRefund(session, resolved);
      } else {
        session.log(
          'Polar refund could not be resolved to a license key for '
          'order_id=$orderId; acknowledging without action',
          level: LogLevel.warning,
        );
      }
    }

    return PaymentResult(success: true);
  }

  @override
  RefundEvent? extractRefundEvent(Map<String, dynamic> notificationData) {
    try {
      final type = notificationData['type'] as String?;
      if (type != 'refund.created' && type != 'refund.updated') return null;

      final data = notificationData['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      final orderId = data['order_id'] as String?;
      if (orderId == null) return null;

      final createdAtStr = data['created_at'] as String?;
      final timestamp = createdAtStr != null
          ? DateTime.tryParse(createdAtStr)
          : null;

      return RefundEvent(
        rail: PaymentRail.polar,
        receiptHash: CryptoUtils.sha256Hash(orderId),
        paymentRef: orderId,
        productId: data['product_id'] as String?,
        purchaseTimestamp: timestamp,
        rawData: notificationData,
      );
    } catch (_) {
      return null;
    }
  }

  /// Resolves the webhook order identifier to the license-key identifier used
  /// when the purchase was recorded.
  Future<RefundEvent?> resolveRefundEvent(
    String orderId,
    RefundEvent preliminary,
  ) async {
    final Map<String, dynamic> orderJson;
    try {
      orderJson = await client.getOrder(orderId);
    } catch (_) {
      return null;
    }

    final licenseKeyId = orderJson['license_key_id'] as String?;
    if (licenseKeyId == null) return null;

    return RefundEvent(
      rail: preliminary.rail,
      receiptHash: CryptoUtils.sha256Hash(licenseKeyId),
      paymentRef: licenseKeyId,
      productId: preliminary.productId,
      purchaseTimestamp: preliminary.purchaseTimestamp,
      rawData: preliminary.rawData,
    );
  }
}

/// Outcome of a Polar license-key validation + redemption.
class PolarValidationResult {
  PolarValidationResult({
    required this.isValid,
    this.licenseKeyId,
    this.benefitId,
    this.tag,
    this.quantity,
    this.expiresAt,
    this.fromCache = false,
  });

  final bool isValid;
  final String? licenseKeyId;
  final String? benefitId;
  final String? tag;
  final double? quantity;
  final DateTime? expiresAt;
  final bool fromCache;
}
