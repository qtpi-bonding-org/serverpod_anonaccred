// Reusable test harness for flow-level commerce integration tests.
//
// Creates a real DB-backed anon account + device, registers mock payment
// rail clients with PaymentManager, and exposes high-level buy/redeem/
// consume/query actions driven through the real endpoints via an
// AuthenticationOverride-backed session.
import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/mock_android_publisher_client.dart';
import 'package:anonaccred_server/src/payments/mock_app_store_server_client.dart';
import 'package:anonaccred_server/src/payments/mock_polar_client.dart';
import 'package:anonaccred_server/src/payments/payment_manager.dart';
import 'package:anonaccred_server/src/payments/rails/apple_iap_rail.dart';
import 'package:anonaccred_server/src/payments/rails/google_iap_rail.dart';
import 'package:anonaccred_server/src/payments/rails/polar_rail.dart';
import 'package:serverpod/serverpod.dart';
import 'package:uuid/uuid.dart';

import 'serverpod_test_tools.dart';

/// Drives real endpoints (IAP, Polar, Commerce, GroupCommerce) against a
/// freshly created anon account + device, with mock payment-rail clients
/// registered so purchases can be fulfilled without live provider APIs.
class CommerceTestHarness {
  CommerceTestHarness._({
    required this.authenticatedSessionBuilder,
    required this.accountUuid,
    required String deviceKeyHex,
    required TestSessionBuilder sessionBuilder,
    required this.endpoints,
  }) : _deviceKeyHex = deviceKeyHex,
       _sessionBuilder = sessionBuilder;

  final TestSessionBuilder authenticatedSessionBuilder;
  final UuidValue accountUuid;
  final String _deviceKeyHex;
  final TestSessionBuilder _sessionBuilder;
  final TestEndpoints endpoints;

  /// Resolved through [PaymentManager.getRail] at access time rather than
  /// stored at harness-creation time — [PaymentManager.registerRail]
  /// overwrites by key globally, so a field captured at construction would
  /// go stale the moment a later harness registers its own mocks.
  MockAppStoreServerClient get appleMock =>
      (PaymentManager.getRail(PaymentRail.apple_iap) as AppleIAPRail).client
          as MockAppStoreServerClient;

  MockAndroidPublisherClient get googleMock =>
      (PaymentManager.getRail(PaymentRail.google_iap) as GoogleIAPRail).client
          as MockAndroidPublisherClient;

  MockPolarClient get polarMock =>
      (PaymentManager.getRail(PaymentRail.polar) as PolarRail).client
          as MockPolarClient;

  static Future<CommerceTestHarness> create(
    TestSessionBuilder sessionBuilder,
    TestEndpoints endpoints, {
    required String label,
  }) async {
    final ultimateHex = _hexKey('u-$label');
    final deviceHex = _hexKey('d-$label');

    final account = await AnonAccount.db.insertRow(
      sessionBuilder.build(),
      AnonAccount(
        id: UuidValue.fromString(const Uuid().v4()),
        ultimateSigningPublicKeyHex: ultimateHex,
        ultimateEncryptionPublicKeyHex: ultimateHex,
        encryptedDataKey: 'test-data-key-$label',
      ),
    );

    await AccountDevice.db.insertRow(
      sessionBuilder.build(),
      AccountDevice(
        anonAccountId: account.id!,
        deviceSigningPublicKeyHex: deviceHex,
        deviceEncryptionPublicKeyHex: deviceHex,
        addedByAttestorPublicKeyHex: ultimateHex,
        addedByAttestation: 'test-attestation-$label',
        encryptedDataKey: 'test-device-data-key-$label',
        label: 'device-$label',
      ),
    );

    final appleMock = MockAppStoreServerClient();
    final googleMock = MockAndroidPublisherClient();
    final polarMock = MockPolarClient();
    PaymentManager.registerRail(AppleIAPRail(client: appleMock));
    PaymentManager.registerRail(GoogleIAPRail(client: googleMock));
    PaymentManager.registerRail(PolarRail(client: polarMock));

    final authenticatedSessionBuilder = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        account.id.toString(),
        {Scope('device:$deviceHex')},
        authId: deviceHex,
      ),
    );

    return CommerceTestHarness._(
      authenticatedSessionBuilder: authenticatedSessionBuilder,
      accountUuid: account.id!,
      deviceKeyHex: deviceHex,
      sessionBuilder: sessionBuilder,
      endpoints: endpoints,
    );
  }

  Future<IapValidationResponse> buyApple({
    required String transactionId,
    required String productId,
  }) => endpoints.iAP.validateAppleTransaction(
    authenticatedSessionBuilder,
    transactionId,
    productId,
  );

  Future<IapValidationResponse> buyGoogle({
    required String packageName,
    required String productId,
    required String purchaseToken,
  }) => endpoints.iAP.validateGooglePurchase(
    authenticatedSessionBuilder,
    packageName,
    productId,
    purchaseToken,
  );

  Future<IapValidationResponse> redeemPolar({required String licenseKey}) =>
      endpoints.polar.redeemLicenseKey(authenticatedSessionBuilder, licenseKey);

  Future<IapValidationResponse> redeemPolarForGroup({
    required String licenseKey,
    required UuidValue shareGroupUuid,
  }) => endpoints.polar.redeemLicenseKey(
    authenticatedSessionBuilder,
    licenseKey,
    shareGroupUuid: shareGroupUuid,
  );

  Future<List<AccountEntitlement>> getEntitlements() =>
      endpoints.commerce.getEntitlements(authenticatedSessionBuilder);

  Future<double> getBalance(String tag) => endpoints.commerce
      .getEntitlementBalance(authenticatedSessionBuilder, tag);

  Future<ConsumeResult> consume(String tag, double quantity) => endpoints
      .commerce
      .consumeEntitlement(authenticatedSessionBuilder, tag, quantity);

  Future<ConsumeResult> consumeGroup(
    UuidValue shareGroupUuid,
    String tag,
    double quantity,
  ) => endpoints.groupCommerce.consumeGroupEntitlement(
    authenticatedSessionBuilder,
    shareGroupUuid,
    tag,
    quantity,
  );

  Future<void> revokeDevice() async {
    final session = _sessionBuilder.build();
    try {
      final device = (await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.deviceSigningPublicKeyHex.equals(_deviceKeyHex),
      ))!;
      await AccountDevice.db.updateRow(
        session,
        device.copyWith(isRevoked: true),
      );
    } finally {
      await session.close();
    }
  }

  static String _hexKey(String seed) {
    final base = seed.hashCode.toRadixString(16).padLeft(8, '0');
    return List.filled(16, base).join().substring(0, 128);
  }
}

/// Seeds an [Entitlement] (if not already present, keyed by [tag]) plus a
/// [RailProduct] + [RailProductGrant] mapping [storeProductId] on [rail] to
/// [quantity] units of that tag. Shared by every flow test that needs a
/// rail to recognize a product id and know what it grants — mirrors the
/// inline seeding already used in `commerce_endpoint_test.dart` and
/// `group_fulfillment_test.dart`.
Future<void> seedRailProduct(
  Session session, {
  required PaymentRail rail,
  required String storeProductId,
  required String tag,
  required double quantity,
  EntitlementType type = EntitlementType.consumable,
}) async {
  var entitlement = await Entitlement.db.findFirstRow(
    session,
    where: (t) => t.tag.equals(tag),
  );
  entitlement ??= await Entitlement.db.insertRow(
    session,
    Entitlement(name: tag, tag: tag, type: type, serverValidated: true),
  );

  final railProduct = await RailProduct.db.insertRow(
    session,
    RailProduct(rail: rail, storeProductId: storeProductId, isActive: true),
  );

  await RailProductGrant.db.insertRow(
    session,
    RailProductGrant(
      railProductId: railProduct.id!,
      entitlementId: entitlement.id!,
      quantity: quantity,
    ),
  );
}
