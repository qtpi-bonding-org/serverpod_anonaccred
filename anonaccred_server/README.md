# AnonAccred Server Module

Anonymous credential system with privacy-by-design architecture for Serverpod applications.

## 🎉 Phase 3 Complete

**Status: Production Ready** ✅

Phase 3 provides complete commerce foundation with:
- ✅ Ed25519-based account creation and management
- ✅ Multi-device registration with public subkeys
- ✅ Challenge-response authentication system
- ✅ Device revocation and management
- ✅ Zero-PII architecture with encrypted data storage
- ✅ **Commerce foundation with price registry, order management, and inventory operations**
- ✅ **Atomic inventory utilities for parent applications**
- ✅ **Commerce endpoints with authentication integration**
- ✅ Comprehensive error handling and privacy-safe logging
- ✅ All tests passing with property-based validation

**Ready for Phase 4+ Payment Rail Integration**

## Features

### Authentication & Identity
- **Ed25519 Cryptographic Authentication**: Complete account and device management with public key identity
- **Challenge-Response Authentication**: Secure device authentication using Ed25519 signatures
- **Multi-Device Support**: Register and manage multiple devices per account with individual subkeys
- **Device Revocation**: Secure device access control with immediate revocation capability
- **Zero-PII Architecture**: No personally identifiable information stored, client-side key management
- **Encrypted Data Storage**: Server stores encrypted data but never decrypts it

### Commerce Foundation
- **Price Registry**: Singleton service for product definitions and pricing management
- **Order Management**: Create and fulfill purchase orders with automatic pricing calculation
- **Inventory Management**: Account-based consumable balance tracking and operations
- **Atomic Utilities**: Optional consumption operations with race condition protection
- **Commerce Endpoints**: RESTful API for all commerce operations with authentication
- **Payment Rail Agnostic**: Foundation ready for multiple payment method integration

### System Quality
- **Comprehensive Error Handling**: Structured exceptions with classification and recovery guidance
- **Privacy-Safe Logging**: Operational visibility without exposing sensitive data
- **Property-Based Testing**: Validated correctness across random input spaces
- **Lightweight Design**: Minimal dependencies, leverages Serverpod infrastructure

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  anonaccred_server: ^0.1.0
```

## Usage

### Basic Setup

```dart
import 'package:anonaccred_server/anonaccred_server.dart';
```

### Account Management

```dart
// Create anonymous account with Ed25519 public key
final account = await AccountEndpoint().createAccount(
  session,
  publicMasterKey: 'ed25519_public_key_hex', // 64 hex chars
  encryptedDataKey: 'client_encrypted_sdk',   // Never decrypted server-side
);

// Lookup account by public key
final existingAccount = await AccountEndpoint().getAccountByPublicKey(
  session,
  publicMasterKey: 'ed25519_public_key_hex',
);
```

### Device Management

```dart
// Register device with account
final device = await DeviceEndpoint().registerDevice(
  session,
  accountId: account.id!,
  publicSubKey: 'device_ed25519_public_key_hex', // 64 hex chars
  encryptedDataKey: 'device_encrypted_sdk',      // Never decrypted server-side
  label: 'My iPhone',
);

// Generate authentication challenge
final challenge = await DeviceEndpoint().generateAuthChallenge(session);

// Authenticate device with challenge-response
final authResult = await DeviceEndpoint().authenticateDevice(
  session,
  publicSubKey: 'device_ed25519_public_key_hex',
  challenge: challenge,
  signature: 'ed25519_signature_of_challenge', // Client-generated
);

if (authResult.success) {
  print('Device authenticated: Account ${authResult.accountId}, Device ${authResult.deviceId}');
} else {
  print('Authentication failed: ${authResult.errorMessage}');
}

// List all devices for account
final devices = await DeviceEndpoint().listDevices(session, accountId);

// Revoke device access
final revoked = await DeviceEndpoint().revokeDevice(session, accountId, deviceId);
```

### Cryptographic Operations

```dart
// Validate Ed25519 public keys
final isValid = CryptoAuth.isValidPublicKey(publicKeyHex);

// Generate secure challenge for authentication
final challenge = CryptoAuth.generateChallenge();

// Verify challenge-response signature
final result = await CryptoAuth.verifyChallengeResponse(
  publicKeyHex: 'device_public_key',
  challenge: 'generated_challenge',
  signatureHex: 'client_signature',
);
```

### Exception Handling

```dart
// Create structured exceptions with factory methods
throw AnonAccredExceptionFactory.createAuthenticationException(
  code: AnonAccredErrorCodes.authInvalidSignature,
  message: 'Invalid signature format',
  operation: 'authenticateDevice',
  details: {'signatureLength': '32', 'expectedLength': '64'},
);

// Analyze exceptions for comprehensive error information
final analysis = AnonAccredExceptionUtils.analyzeException(exception);
print('Retryable: ${analysis['retryable']}');
print('Severity: ${analysis['severity']}');
print('Recovery: ${analysis['recoveryGuidance']}');
```

### Commerce Operations

#### Price Registry Initialization

The Price Registry uses a singleton pattern and should be initialized at application startup:

```dart
// Initialize price registry (typically in main() or server startup)
final registry = PriceRegistry();

// Register products with USD prices
registry.registerProduct('api_credits', 0.01);      // $0.01 per credit
registry.registerProduct('storage_gb', 5.99);       // $5.99 per GB
registry.registerProduct('premium_features', 9.99); // $9.99 per month

// Query registered products
final catalog = registry.getProductCatalog();
final price = registry.getPrice('api_credits'); // Returns 0.01 or null
```

#### Order Management

```dart
// Create order with automatic pricing
final transaction = await OrderManager.createOrder(
  session,
  accountId: accountId,
  items: {
    'api_credits': 100.0,    // 100 credits
    'storage_gb': 1.0,       // 1 GB storage
  },
  priceCurrency: Currency.USD,
  paymentRail: PaymentRail.monero, // or PaymentRail.iap, PaymentRail.x402
);

// Order total automatically calculated: (100 * 0.01) + (1 * 5.99) = $6.99
print('Order total: \$${transaction.totalAmountUSD}');
print('Transaction ID: ${transaction.externalId}');

// Fulfill order after successful payment
await OrderManager.fulfillOrder(session, transaction);
// This adds all items to account inventory atomically
```

#### Inventory Management

```dart
// Query account inventory
final inventory = await InventoryManager.getInventory(session, accountId);
for (final item in inventory) {
  print('${item.consumableType}: ${item.quantity}');
}

// Check specific balance
final creditBalance = await InventoryManager.getBalance(
  session,
  accountId: accountId,
  consumableType: 'api_credits',
);

// Add inventory directly (for testing or admin operations)
await InventoryManager.addToInventory(
  session,
  accountId: accountId,
  consumableType: 'bonus_credits',
  quantity: 50.0,
);
```

#### Optional Inventory Utilities

AnonAccred provides optional atomic consumption utilities that parent applications can choose to use:

```dart
// Attempt to consume inventory atomically
final result = await InventoryUtils.tryConsume(
  session,
  accountId: accountId,
  consumableType: 'api_credits',
  quantity: 10.0,
);

if (result.success) {
  print('Consumed 10 credits successfully');
  print('Remaining balance: ${result.availableBalance}');
  // Proceed with API operation
} else {
  print('Insufficient credits: ${result.availableBalance} available');
  print('Error: ${result.errorMessage}');
  // Handle insufficient balance
}
```

#### Commerce Endpoints

All commerce operations are available through RESTful endpoints with authentication:

```dart
// Register products (requires authentication)
final products = await CommerceEndpoint().registerProducts(
  session,
  publicKey: 'ed25519_public_key_hex',
  signature: 'request_signature',
  products: {
    'new_feature': 2.99,
    'extra_storage': 1.99,
  },
);

// Get product catalog (public endpoint)
final catalog = await CommerceEndpoint().getProductCatalog(session);

// Create order (requires authentication)
final order = await CommerceEndpoint().createOrder(
  session,
  publicKey: 'ed25519_public_key_hex',
  signature: 'request_signature',
  accountId: accountId,
  items: {'new_feature': 1.0},
  paymentRail: PaymentRail.monero,
);

// Query inventory (requires authentication)
final inventory = await CommerceEndpoint().getInventory(
  session,
  publicKey: 'ed25519_public_key_hex',
  signature: 'request_signature',
  accountId: accountId,
);

// Check balance (requires authentication)
final balance = await CommerceEndpoint().getBalance(
  session,
  publicKey: 'ed25519_public_key_hex',
  signature: 'request_signature',
  accountId: accountId,
  consumableType: 'api_credits',
);

// Consume inventory (requires authentication, optional utility)
final consumeResult = await CommerceEndpoint().consumeInventory(
  session,
  publicKey: 'ed25519_public_key_hex',
  signature: 'request_signature',
  accountId: accountId,
  consumableType: 'api_credits',
  quantity: 5.0,
);
```

### Privacy-Safe Logging

```dart
// Log authentication events (public keys safe, private keys excluded)
PrivacyLogger.logAuthentication(session,
  operation: 'authenticateDevice',
  success: true,
  publicKey: publicKey,
);

// Log cryptographic operations
PrivacyLogger.logCryptographic(session,
  operation: 'signature_verification',
  success: true,
  algorithm: 'Ed25519',
  keyType: 'public',
);

// Log commerce operations
PrivacyLogger.logOperation(session,
  operation: 'createOrder',
  success: true,
  category: 'commerce',
  safeData: {
    'accountId': accountId.toString(),
    'itemCount': '2',
    'totalUSD': '6.99',
  },
);
```

## Architecture

AnonAccred follows privacy-by-design principles with clear module boundaries:

### Privacy-by-Design
- **Zero PII Storage**: No personally identifiable information stored on server
- **Client-Side Key Management**: All private keys generated and managed on client devices
- **Encrypted Data Storage**: Server stores encrypted data but never decrypts it
- **Public Key Identity**: Account identity based on Ed25519 public keys

### Module Boundaries

**What AnonAccred Provides (Tools):**
- Payment verification and processing
- Encrypted data storage (never decrypted server-side)
- Ed25519 signature verification (no key generation)
- Inventory balance increments after successful payments
- Atomic consumption utilities (optional)
- Price registry and order management
- Payment receipts and transaction records
- Anonymous account/device relationships

**What AnonAccred Does NOT Do (Parent Project Decisions):**
- Generate or handle private keys (client-side only)
- Decrypt any client data (E2EE architecture)
- Decide how consumables are used or consumed
- Generate JWTs for services (parent project responsibility)
- Make business logic decisions about access control
- Automatically decrement inventory (consumption is optional)

**Integration Boundary:**
```
Client (Key Gen, Encryption) -> AnonAccred (Payment, Storage) -> Parent Project (Business Logic, JWT, Consumption)
```

## Integration Examples

### Basic Integration Pattern

```dart
// 1. Initialize AnonAccred in your Serverpod server
import 'package:anonaccred_server/anonaccred_server.dart';

// 2. Set up price registry at startup
void initializeCommerce() {
  final registry = PriceRegistry();
  registry.registerProduct('premium_subscription', 9.99);
  registry.registerProduct('api_calls_1000', 4.99);
  registry.registerProduct('storage_10gb', 2.99);
}

// 3. Create orders through your business logic
Future<String> createSubscriptionOrder(Session session, int accountId) async {
  final transaction = await OrderManager.createOrder(
    session,
    accountId: accountId,
    items: {'premium_subscription': 1.0},
    priceCurrency: Currency.USD,
  );
  
  // Return payment URL or transaction ID to client
  return transaction.externalId;
}

// 4. Fulfill orders after payment confirmation
Future<void> handlePaymentSuccess(Session session, String transactionId) async {
  // Find transaction by external ID
  final transaction = await TransactionPayment.db.findFirstWhere(
    session,
    where: (t) => t.externalId.equals(transactionId),
  );
  
  if (transaction != null) {
    // Fulfill order - adds items to inventory
    await OrderManager.fulfillOrder(session, transaction);
  }
}

// 5. Check access in your business logic
Future<bool> hasAccess(Session session, int accountId, String feature) async {
  final balance = await InventoryManager.getBalance(
    session,
    accountId: accountId,
    consumableType: feature,
  );
  
  return balance > 0;
}

// 6. Optional: Use atomic consumption
Future<bool> consumeApiCall(Session session, int accountId) async {
  final result = await InventoryUtils.tryConsume(
    session,
    accountId: accountId,
    consumableType: 'api_calls_1000',
    quantity: 1.0,
  );
  
  return result.success;
}
```

### Parent Project JWT Generation

AnonAccred provides authentication but parent projects generate their own service JWTs:

```dart
// Parent project endpoint
class MyServiceEndpoint extends Endpoint {
  Future<String> getServiceToken(Session session, int accountId, String service) async {
    // 1. Verify account has access to service
    final hasAccess = await InventoryManager.getBalance(
      session,
      accountId: accountId,
      consumableType: service,
    ) > 0;
    
    if (!hasAccess) {
      throw Exception('Insufficient balance for service: $service');
    }
    
    // 2. Generate your own JWT with service-specific claims
    final jwt = JWT({
      'accountId': accountId,
      'service': service,
      'exp': DateTime.now().add(Duration(minutes: 60)).millisecondsSinceEpoch ~/ 1000,
    });
    
    return jwt.sign(SecretKey('your-service-secret'));
  }
}
```

## Data Models

The module provides Serverpod data models for:

### Authentication Models
- `AnonAccount`: Anonymous identity root with Ed25519 Master Public Key and encrypted data storage
- `AccountDevice`: Device registration with Ed25519 Subkey Public Key, revocation status, and metadata
- `AuthenticationResult`: Challenge-response authentication results with success/failure information

### Commerce Models
- `AccountInventory`: Balance tracking for consumable items with timestamps
- `TransactionPayment`: Payment receipts with rail information, status, and pricing
- `TransactionConsumable`: Line items for purchased consumables with quantities
- `ConsumeResult`: Atomic consumption operation results with success/failure information

### Supporting Models
- `PaymentRail`: Enum for payment methods (Monero, IAP, X402)
- `Currency`: Enum for pricing currencies (USD, EUR, etc.)
- `OrderStatus`: Enum for transaction states (pending, completed, failed)

## Error Handling

Comprehensive exception hierarchy with structured error codes and recovery guidance:

### Exception Types
- `AnonAccredException`: Base exception with structured error codes and analysis
- `AuthenticationException`: Authentication-specific context (operation, public key validation)
- `PaymentException`: Payment and order-specific context (order ID, payment rail, pricing)
- `InventoryException`: Inventory-specific context (account ID, consumable type, quantities)

### Error Classification
All exceptions include automatic classification for:
- **Retryability**: Whether the operation can be safely retried
- **Severity**: High (system), Medium (operational), Low (client error)
- **Category**: Authentication, Payment, Inventory, Network, Database
- **Recovery Guidance**: Actionable steps for error resolution

### Usage Examples
```dart
try {
  await OrderManager.createOrder(session, /* ... */);
} on PaymentException catch (e) {
  final analysis = AnonAccredExceptionUtils.analyzeException(e);
  
  if (analysis['retryable'] == true) {
    // Retry the operation
    await Future.delayed(Duration(seconds: 1));
    // ... retry logic
  } else {
    // Handle client error
    return ErrorResponse(
      code: e.code,
      message: e.message,
      guidance: analysis['recoveryGuidance'],
    );
  }
} on InventoryException catch (e) {
  // Handle insufficient balance, invalid consumable type, etc.
  print('Inventory error: ${e.message}');
  print('Account: ${e.accountId}, Type: ${e.consumableType}');
}
```

## Requirements

- Dart SDK: `>=3.8.0`
- Serverpod: `^3.0.1`

## License

This project is licensed under the MIT License.
