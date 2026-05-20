import 'dart:convert';

import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart';

import '../../entitlement_manager.dart';
import '../../exception_factory.dart';
import '../../generated/protocol.dart';
import '../../group_entitlement_manager.dart';
import '../../refund_event.dart';
import '../payment_rail_interface.dart';
import '../polar_client.dart';
import '../redemption_target.dart';

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
  PolarRail({required this.client});

  /// Build from env vars: `POLAR_ACCESS_TOKEN`, `POLAR_ORGANIZATION_ID`,
  /// `POLAR_ENVIRONMENT`.
  factory PolarRail.fromEnvironment() {
    return PolarRail(client: PolarClient.fromEnvironment());
  }

  final PolarClient client;

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
    final existing = await ReceiptHash.db.findFirstRow(
      session,
      where: (t) => t.hash.equals(licenseHash),
    );
    if (existing != null) {
      return PolarValidationResult(
        isValid: true,
        licenseKeyId: validation.id,
        benefitId: validation.benefitId,
        fromCache: true,
      );
    }

    // 2. Look up RailProduct (storeProductId=benefit_id, rail=polar)
    final railProduct = await RailProduct.db.findFirstRow(
      session,
      where: (t) =>
          t.rail.equals(PaymentRail.polar) &
          t.storeProductId.equals(validation.benefitId) &
          t.isActive.equals(true),
    );

    if (railProduct == null) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.polarBenefitUnmapped,
        message:
            'No active RailProduct found for Polar benefit ${validation.benefitId}',
        paymentRail: PaymentRail.polar.name,
        details: {
          'benefitId': validation.benefitId,
          'licenseKeyId': validation.id,
        },
      );
    }

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
    final productIsGroup =
        firstGrantEntitlement?.tag.startsWith('group_') ?? false;
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
    final internalTxId = internalTransactionId ?? const Uuid().v4();

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
      deliveredTag = firstGrantEntitlement?.tag;
      deliveredQuantity = grantList.first.quantity;
    });

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
      Map<String, dynamic> callbackData) async {
    // TODO(polar-webhook-refund-resolution): wire Polar order_id →
    // license_key_id via `client.getOrder(orderId)`, then forward the
    // resulting RefundEvent to RefundManager.processRefund. For now we
    // acknowledge deliveries without action so Polar stops retrying.
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
      final timestamp =
          createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

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
