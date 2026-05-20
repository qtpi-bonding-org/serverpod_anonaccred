/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

enum PaymentRail implements _i1.SerializableModel {
  apple_iap,
  google_iap,
  monero,
  manual,
  stripe,
  x402_http,
  polar;

  static PaymentRail fromJson(String name) {
    switch (name) {
      case 'apple_iap':
        return PaymentRail.apple_iap;
      case 'google_iap':
        return PaymentRail.google_iap;
      case 'monero':
        return PaymentRail.monero;
      case 'manual':
        return PaymentRail.manual;
      case 'stripe':
        return PaymentRail.stripe;
      case 'x402_http':
        return PaymentRail.x402_http;
      case 'polar':
        return PaymentRail.polar;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "PaymentRail"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
