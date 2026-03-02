/// AnonAccred Server Module
///
/// Provides anonymous credential system with privacy-by-design architecture
/// for Serverpod applications. Features include:
///
/// - Ed25519-based cryptographic authentication with account and device management
/// - Challenge-response authentication system for secure device access
/// - Multi-device support with individual subkeys and revocation capability
/// - Zero-PII architecture with encrypted data storage (never decrypted server-side)
/// - Commerce foundation with price registry, order management, and inventory operations
/// - Comprehensive error handling with structured exceptions
/// - Privacy-safe logging integration
///
/// ## Usage
///
/// ### Authentication
///
/// ```dart
/// import 'package:anonaccred_server/anonaccred_server.dart';
///
/// // Create anonymous account
/// final account = await AccountEndpoint().createAccount(
///   session,
///   ultimateSigningPublicKeyHex: 'ecdsa_p256_public_key_hex',
///   encryptedDataKey: 'client_encrypted_sdk',
/// );
///
/// // Register device
/// final device = await DeviceEndpoint().registerDevice(
///   session,
///   accountId: account.id!,
///   deviceSigningPublicKeyHex: 'device_ecdsa_p256_public_key_hex',
///   encryptedDataKey: 'device_encrypted_sdk',
///   label: 'My Device',
/// );
///
/// // Authenticate device
/// final challenge = await DeviceEndpoint().generateAuthChallenge(session);
/// final authResult = await DeviceEndpoint().authenticateDevice(
///   session,
///   deviceSigningPublicKeyHex: 'device_ecdsa_p256_public_key_hex',
///   challenge: challenge,
///   signature: 'client_generated_signature',
/// );
/// ```
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
///   accountId: accountId,
///   rail: PaymentRail.monero,
///   storeProductId: 'api_credits',
/// );
///
/// // Query entitlements
/// final balance = await EntitlementManager.getEntitlementBalance(
///   session,
///   accountId: accountId,
///   tag: 'api_credits',
/// );
///
/// // Consume entitlement atomically
/// final consumeResult = await EntitlementManager.consumeEntitlement(
///   session,
///   accountId: accountId,
///   tag: 'api_credits',
///   quantity: 10.0,
/// );
/// ```

library;

// Authentication handler for Serverpod integration
export 'src/auth_handler.dart';
// Commerce and Entitlement Management
export 'src/commerce_manager.dart';
// Configuration system
export 'src/config/header_config.dart';
// Core cryptographic utilities
export 'src/crypto_auth.dart';
export 'src/crypto_utils.dart';
export 'src/entitlement_manager.dart';
// Exception handling and error classification system
export 'src/error_classification.dart';
export 'src/exception_factory.dart';
// Generated Serverpod protocol classes and endpoints
export 'src/generated/endpoints.dart';
export 'src/generated/protocol.dart';
// Helper utilities for reducing code duplication
export 'src/helpers.dart';
// Payment system foundation - Payment Rails, Manager, and Processor
export 'src/payments/payment_manager.dart';
export 'src/payments/payment_processor.dart';
export 'src/payments/payment_rail_interface.dart';
export 'src/payments/x402_interceptor.dart';
export 'src/payments/x402_payment_rail.dart';
export 'src/price_registry.dart';

// Transaction utilities removed - use Serverpod built-in patterns
