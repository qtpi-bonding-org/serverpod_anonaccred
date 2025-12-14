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
///   publicMasterKey: 'ed25519_public_key_hex',
///   encryptedDataKey: 'client_encrypted_sdk',
/// );
///
/// // Register device
/// final device = await DeviceEndpoint().registerDevice(
///   session,
///   accountId: account.id!,
///   publicSubKey: 'device_ed25519_public_key_hex',
///   encryptedDataKey: 'device_encrypted_sdk',
///   label: 'My Device',
/// );
///
/// // Authenticate device
/// final challenge = await DeviceEndpoint().generateAuthChallenge(session);
/// final authResult = await DeviceEndpoint().authenticateDevice(
///   session,
///   publicSubKey: 'device_ed25519_public_key_hex',
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
/// // Create order
/// final transaction = await OrderManager.createOrder(
///   session,
///   accountId: accountId,
///   items: {'api_credits': 100.0, 'storage_gb': 1.0},
///   priceCurrency: Currency.USD,
/// );
///
/// // Fulfill order (after payment)
/// await OrderManager.fulfillOrder(session, transaction);
///
/// // Query inventory
/// final inventory = await InventoryManager.getInventory(session, accountId);
/// final balance = await InventoryManager.getBalance(
///   session,
///   accountId: accountId,
///   consumableType: 'api_credits',
/// );
///
/// // Optional: Consume inventory atomically
/// final result = await InventoryUtils.tryConsume(
///   session,
///   accountId: accountId,
///   consumableType: 'api_credits',
///   quantity: 10.0,
/// );
/// ```
///
/// ### Payment System
///
/// ```dart
/// // Initialize X402 payment rail (simple registration)
/// PaymentManager.initializeX402Rail(session);
///
/// // Create X402 HTTP payment
/// final paymentRequest = await PaymentManager.createPayment(
///   session: session,
///   railType: PaymentRail.x402_http,
///   amountUSD: 10.00,
///   orderId: 'order_123',
/// );
///
/// // Process payment callback (X402 verification)
/// final rail = PaymentManager.getRail(PaymentRail.x402_http);
/// final result = await rail?.processCallback(callbackData);
/// ```

// Authentication handler for Serverpod integration
export 'src/auth_handler.dart';

// Core cryptographic utilities
export 'src/crypto_auth.dart';
export 'src/crypto_utils.dart';

// Exception handling and error classification system
export 'src/error_classification.dart';
export 'src/exception_factory.dart';

// Helper utilities for reducing code duplication
export 'src/helpers.dart';

// Generated Serverpod protocol classes and endpoints
export 'src/generated/endpoints.dart';
export 'src/generated/protocol.dart';

// Commerce foundation - Price Registry, Order Management, and Inventory Management
export 'src/inventory_manager.dart';
export 'src/inventory_utils.dart';
export 'src/order_manager.dart';
export 'src/price_registry.dart';

// Payment system foundation - Payment Rails, Manager, and Processor
export 'src/payments/payment_manager.dart';
export 'src/payments/payment_processor.dart';
export 'src/payments/payment_rail_interface.dart';
export 'src/payments/x402_payment_rail.dart';

// Transaction utilities removed - use Serverpod built-in patterns
