import 'dart:io';

import 'package:http/http.dart' as http;

import '../exception_factory.dart';
import '../generated/protocol.dart';
import 'polar_http_client.dart';

/// Result of a Polar `/v1/license-keys/validate` call.
///
/// Covers the subset of the response the rail consumes. See
/// https://polar.sh/docs/api-reference/license-keys/validate
/// for the full response shape.
class PolarLicenseValidation {
  PolarLicenseValidation({
    required this.id,
    required this.key,
    required this.status,
    required this.organizationId,
    required this.benefitId,
    required this.customerId,
    required this.expiresAt,
    required this.raw,
  });

  /// License-key UUID (`id` on the response).
  final String id;

  /// The licence key string Polar accepted (echoed back).
  final String key;

  /// `granted` | `revoked` | `disabled` per Polar docs.
  final String status;

  /// Polar organization UUID.
  final String organizationId;

  /// Polar benefit UUID. Maps to a `RailProduct.storeProductId`
  /// (rail=polar) at fulfilment time.
  final String benefitId;

  /// Customer UUID (Polar-side identity; never persisted by anonaccred).
  final String customerId;

  /// Subscription expiry, null for one-time purchases.
  final DateTime? expiresAt;

  /// Raw JSON for debugging / forward-compatible field access.
  final Map<String, dynamic> raw;

  bool get isGranted => status == 'granted';

  factory PolarLicenseValidation.fromJson(Map<String, dynamic> json) {
    final expiresAtStr = json['expires_at'] as String?;
    return PolarLicenseValidation(
      id: json['id'] as String,
      key: json['key'] as String,
      status: json['status'] as String,
      organizationId: json['organization_id'] as String,
      benefitId: json['benefit_id'] as String,
      customerId: json['customer_id'] as String,
      expiresAt: expiresAtStr == null ? null : DateTime.parse(expiresAtStr),
      raw: json,
    );
  }
}

/// Polar.sh MoR (Merchant of Record) API client.
///
/// Layered on top of [PolarHttpClient]. The transport handles bearer
/// auth, JSON encoding, and status-code mapping; this class adds Polar-
/// specific request shapes (e.g. `organization_id` is always required)
/// and response parsing.
class PolarClient {
  PolarClient({required this.organizationId, required PolarHttpClient http})
      : _http = http;

  /// Build from env vars: see [PolarHttpClient.fromEnvironment] for
  /// the transport-level vars, plus `POLAR_ORGANIZATION_ID`.
  factory PolarClient.fromEnvironment({http.Client? httpClient}) {
    final org = Platform.environment['POLAR_ORGANIZATION_ID'];
    if (org == null || org.isEmpty) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'POLAR_ORGANIZATION_ID is not configured',
        paymentRail: PaymentRail.polar.name,
      );
    }
    return PolarClient(
      organizationId: org,
      http: PolarHttpClient.fromEnvironment(httpClient: httpClient),
    );
  }

  final String organizationId;
  final PolarHttpClient _http;

  /// Validate a license key against Polar.
  ///
  /// Returns the parsed [PolarLicenseValidation] on `granted` status.
  ///
  /// Throws [PaymentException]:
  ///   * code `polarLicenseRevoked` when Polar returns `revoked`/`disabled`
  ///     (200 OK but unusable)
  ///   * code `polarValidationFailed` on 4xx (key not found, wrong org, etc.)
  ///   * code `polarApiUnavailable` on 5xx / network / parse errors
  ///   * code `configurationMissing` on 401/403 (server-side token problem)
  Future<PolarLicenseValidation> validateLicenseKey({
    required String key,
    String? activationId,
    String? benefitId,
    int? incrementUsage,
  }) async {
    final response = await _http.postJson(
      '/v1/license-keys/validate',
      body: <String, dynamic>{
        'key': key,
        'organization_id': organizationId,
        'activation_id': ?activationId,
        'benefit_id': ?benefitId,
        'increment_usage': ?incrementUsage,
      },
    );

    final PolarLicenseValidation validation;
    try {
      validation = PolarLicenseValidation.fromJson(response.body);
    } catch (e) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.polarApiUnavailable,
        message: 'Failed to parse Polar license validation response',
        paymentRail: PaymentRail.polar.name,
        details: {'error': e.toString()},
      );
    }

    if (!validation.isGranted) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.polarLicenseRevoked,
        message: 'License key status is "${validation.status}", not "granted"',
        paymentRail: PaymentRail.polar.name,
        details: {'status': validation.status, 'licenseKeyId': validation.id},
      );
    }
    return validation;
  }

  /// Fetch a Polar order by its UUID.
  ///
  /// Used at refund time to map a `data.order_id` from a webhook back to
  /// the license-key UUID that [ReceiptHash] is keyed on. Returns the
  /// parsed JSON body verbatim — the caller picks the fields it needs.
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    final response = await _http.getJson('/v1/orders/$orderId');
    return response.body;
  }

  void close() => _http.close();
}
