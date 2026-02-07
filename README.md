# AnonAccred - Anonymous Credential System for Serverpod

AnonAccred is a privacy-by-design anonymous credential system module for Serverpod that provides Ed25519-based identity, multi-rail payment processing, and encrypted data storage without storing any personally identifiable information (PII).

## Overview

AnonAccred implements a zero-PII architecture where:
- Account identity is based on Ed25519 public keys (not PII)
- All user data is encrypted with client-controlled keys
- The server never decrypts user data or handles private keys
- Payment processing supports multiple rails (X402, Monero, Apple IAP, Google IAP)
- Comprehensive error handling with structured exceptions and recovery guidance

## Phase 1: Core Foundation & Error Infrastructure

This phase establishes the foundational data layer and error handling infrastructure that will support all subsequent authentication, payment, and inventory management features.

### Key Features

- **Privacy-by-Design Architecture**: No PII storage, encrypted data only
- **Ed25519 Cryptographic Identity**: Public key-based account system
- **Multi-Rail Payment Support**: X402, Monero, Apple IAP, Google IAP
- **Comprehensive Error Handling**: Structured exceptions with classification and recovery guidance
- **Agnostic Commerce Foundation**: Flexible consumable types and inventory management
- **Serverpod Integration**: Native module following Serverpod conventions

### Architecture Principles

1. **Zero Server-Side Decryption**: Server stores encrypted data keys but never decrypts them
2. **Public Key Identity**: Account identity based on Ed25519 public keys (not PII)
3. **Client-Side Key Management**: All private keys generated and managed on client devices
4. **Encrypted Data Storage**: All user data encrypted with client-controlled keys
5. **Privacy-Safe Logging**: Logs never contain private keys, encrypted data, or PII

## Module Structure

```
serverpod_anonaccred/
├── anonaccred_server/          # Server-side module
│   ├── lib/src/
│   │   ├── models/             # .spy.yaml data model definitions
│   │   ├── endpoints/          # Serverpod endpoint implementations
│   │   ├── exception_factory.dart    # Exception creation patterns
│   │   └── error_classification.dart # Error analysis utilities
│   ├── config/                 # Environment configurations
│   ├── migrations/             # Database schema migrations
│   └── test/                   # Unit and integration tests
└── anonaccred_client/          # Client-side protocol classes
    └── lib/                    # Generated Dart classes for client use
```

## Installation

Add AnonAccred as a dependency in your Serverpod project:

### Server Module (pubspec.yaml)
```yaml
dependencies:
  anonaccred_server:
    git:
      url: https://github.com/your-org/serverpod_anonaccred.git
      path: anonaccred_server
      ref: main
```

### Client Module (pubspec.yaml)
```yaml
dependencies:
  anonaccred_client:
    git:
      url: https://github.com/your-org/serverpod_anonaccred.git
      path: anonaccred_client
      ref: main
```

## Configuration

### Database Setup

AnonAccred requires PostgreSQL for data persistence. Add the following to your Serverpod configuration:

```yaml
# config/development.yaml
database:
  host: localhost
  port: 5432
  name: your_app_dev
  user: postgres
```

### Module Configuration

AnonAccred-specific settings can be added to your configuration files:

```yaml
# Optional AnonAccred configuration
anonaccred:
  pbt_iterations: 5  # Property-based test iterations (5 for dev, 100+ for prod)
  error_classification:
    enabled: true
    include_stack_traces: true  # false in production
  privacy_logging:
    enabled: true
    log_public_keys: true
    log_order_ids: true
    log_account_ids: true
```

## Usage

### Code Generation

After adding the dependency, run Serverpod code generation:

```bash
serverpod generate
```

This generates:
- Server-side Dart classes from .spy.yaml models
- Client-side protocol classes for external consumption
- Database migrations for PostgreSQL schema

### Basic Integration

```dart
// Import the module in your Serverpod server
import 'package:anonaccred_server/anonaccred_server.dart';

// Use generated client classes
import 'package:anonaccred_client/anonaccred_client.dart';
```

## Data Models

### Core Models

- **AnonAccount**: Immutable identity root with Master Public Key
- **AccountDevice**: Ephemeral device access with Subkey Public Key
- **AccountInventory**: Balance tracking for any consumable type
- **TransactionPayment**: Payment receipt with rail and status information
- **TransactionConsumable**: Line items for purchased consumables

### Exception Models

- **AnonAccredException**: Base exception with structured error codes
- **AuthenticationException**: Authentication-specific context
- **PaymentException**: Payment-specific context (order ID, payment rail)
- **InventoryException**: Inventory-specific context (account ID, consumable type)

## Error Handling

AnonAccred provides comprehensive error handling with:

### Exception Factory Pattern
```dart
AnonAccredExceptionFactory.createAuthenticationException(
  code: AnonAccredErrorCodes.authInvalidSignature,
  message: 'Invalid signature format',
  operation: 'authenticateUser',
  details: {'signatureLength': '32', 'expectedMinLength': '64'},
);
```

### Error Classification
```dart
final analysis = AnonAccredExceptionUtils.analyzeException(exception);
// Returns: code, message, retryable, severity, category, recoveryGuidance
```

### Error Categories
- **Authentication**: Signature verification, challenge validation, key management
- **Payment**: Transaction processing, payment rail communication, receipt generation
- **Inventory**: Balance management, consumable operations, account lookups
- **Network**: External API communication, timeout handling
- **Database**: Data persistence, query execution, constraint violations

## Development

### Running Tests

```bash
# Run all tests
dart test

# Run specific test suites
dart test test/unit/
dart test test/integration/
```

### Property-Based Testing

AnonAccred uses property-based testing for comprehensive validation:
- Development: 5 iterations for fast feedback
- Production: 100+ iterations for thorough coverage

### Database Migrations

Generate and apply migrations:

```bash
# Generate migration after model changes
serverpod create-migration

# Apply migrations
serverpod migrate
```

## Module Boundaries

### What AnonAccred Does
- Accept and verify payments through multiple rails
- Store encrypted data (never decrypt on server)
- Verify Ed25519 signatures (no key generation)
- Increment inventory balances after successful payment
- Provide payment receipts and transaction records
- Maintain anonymous account/device relationships

### What AnonAccred Does NOT Do
- Generate or handle private keys (client-side only)
- Decrypt any client data (E2EE architecture)
- Decide how consumables are used or consumed
- Generate JWTs for services (parent project responsibility)
- Decrement inventory (consumption is parent project's domain)
- Make business logic decisions about access control

## Interface Boundary
```
Client (Key Gen, Encryption) -> AnonAccred (Payment, Storage) -> Parent Project (Business Logic, JWT, Consumption)
```

## Contributing

1. Follow Serverpod module conventions
2. Maintain privacy-by-design principles
3. Use lightweight development approach (avoid over-engineering)
4. Write property-based tests for universal properties
5. Follow established error handling patterns

## License

[Add your license information here]

## Support

- **Issues**: [GitHub Issues](https://github.com/your-org/serverpod_anonaccred/issues)
- **Documentation**: [Project Wiki](https://github.com/your-org/serverpod_anonaccred/wiki)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/serverpod_anonaccred/discussions)