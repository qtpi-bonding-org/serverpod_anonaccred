/// AnonAccred Server Module
///
/// Provides anonymous credential commerce system with privacy-by-design architecture
/// for Serverpod applications. Features include:
///
/// - Commerce foundation with price registry, order management, and inventory operations
/// - Multi-rail payment processing (Apple IAP, Google IAP, X402, Monero)
/// - Entitlement management with consumables, subscriptions, and one-time perks
/// - Ephemeral bridge pattern for privacy-preserving transaction linking
/// - Comprehensive error handling with structured exceptions
///
/// Identity and authentication are provided by the `anonaccount` module,
/// which is re-exported here for convenience.
///
/// ## Usage
///
/// ### Commerce Operations
///
/// ```dart
/// // Initialize Price Registry (singleton)
/// final registry = PriceRegistry();
/// registry.registerProduct('api_credits', 0.01);
/// registry.registerProduct('storage_gb', 5.99);
///
/// // Initiate payment
/// final result = await CommerceEndpoint().initiatePayment(
///   session,
///   publicKey: publicKey,
///   signature: signature,
///   accountUuid: accountUuid,
///   rail: PaymentRail.monero,
///   storeProductId: 'api_credits',
/// );
///
/// // Query entitlements
/// final balance = await EntitlementManager.getEntitlementBalance(
///   session,
///   accountUuid: accountUuid,
///   tag: 'api_credits',
/// );
///
/// // Consume entitlement atomically
/// final consumeResult = await EntitlementManager.consumeEntitlement(
///   session,
///   accountUuid: accountUuid,
///   tag: 'api_credits',
///   quantity: 10.0,
/// );
/// ```

library;

// Re-export anonaccount identity types (hide generated classes that conflict)
export 'package:anonaccount_server/anonaccount_server.dart'
    hide Protocol, Endpoints;
// Privacy scrub job — delete ephemeral bridge rows older than retention window
export 'src/privacy_scrub_config.dart';
export 'src/privacy_scrub_future_call.dart';
// Commerce and Entitlement Management
export 'src/commerce_manager.dart';
export 'src/post_fulfillment_context.dart';
export 'src/group_post_fulfillment_context.dart';
export 'src/entitlement_manager.dart';
export 'src/group_entitlement_manager.dart';
export 'src/group_entitlement_utils.dart';
export 'src/entitlement_core.dart';
// Exception handling and error classification system
export 'src/error_classification.dart';
export 'src/exception_factory.dart';
// Generated Serverpod protocol classes and endpoints
export 'src/generated/endpoints.dart';
export 'src/generated/protocol.dart';
// Payment system foundation - Payment Rails, Manager, and Processor
export 'src/payments/payment_manager.dart';
export 'src/payments/payment_processor.dart';
export 'src/payments/payment_rail_interface.dart';
export 'src/payments/polar_client.dart';
export 'src/payments/polar_http_client.dart';
export 'src/payments/polar_signature_validator.dart';
export 'src/payments/rails/polar_rail.dart';
export 'src/payments/redemption_target.dart';
export 'src/payments/x402_interceptor.dart';
export 'src/payments/x402_payment_rail.dart';
export 'src/price_registry.dart';
// Refund system
export 'src/refund_event.dart';
export 'src/refund_manager.dart';
// Webhook routes for Apple, Google, and Polar server-to-server notifications
export 'src/webhooks/apple_webhook_route.dart';
export 'src/webhooks/google_webhook_route.dart';
export 'src/webhooks/polar_webhook_route.dart';
