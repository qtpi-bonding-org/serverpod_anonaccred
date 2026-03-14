/// AnonAccount Server Module
///
/// Provides anonymous identity system with privacy-by-design architecture
/// for Serverpod applications. Features include:
///
/// - ECDSA P-256-based cryptographic authentication with account and device management
/// - Challenge-response authentication system for secure device access
/// - Multi-device support with individual subkeys and revocation capability
/// - Zero-PII architecture with encrypted data storage (never decrypted server-side)
library;

// Authentication handler for Serverpod integration
export 'src/auth_handler.dart';
// Token issuer callback for host-configured JWT/token issuance
export 'src/token_issuer.dart';
// Configuration system
export 'src/config/header_config.dart';
// Core cryptographic utilities
export 'src/crypto_auth.dart';
export 'src/crypto_utils.dart';
// Challenge storage
export 'src/challenge_storage.dart';
// Exception handling
export 'src/exception_factory.dart';
// Account query service (not an endpoint — consuming projects decide how to expose)
export 'src/account_query_service.dart';
// PoW spam prevention services
export 'src/services/public_challenge_service.dart';
export 'src/services/rate_limit_service.dart';
// Abstract base classes for consuming projects
export 'src/endpoints/pow_endpoint.dart';
export 'src/endpoints/signed_pow_endpoint.dart';
export 'src/endpoints/jwt_endpoint.dart';
// Legacy exports (deprecated, use PowEndpoint/SignedPowEndpoint/JwtEndpoint)
export 'src/endpoints/pow_protected_endpoint.dart';
export 'src/endpoints/authenticated_endpoint.dart';
// Endpoints (concrete with built-in PoW spam prevention)
export 'src/endpoints/entrypoint_endpoint.dart';
export 'src/endpoints/account_endpoint.dart';
export 'src/endpoints/device_endpoint.dart';
export 'src/endpoints/device_management_endpoint.dart';
// Generated Serverpod protocol classes and endpoints
export 'src/generated/endpoints.dart';
export 'src/generated/protocol.dart';
// Helper utilities
export 'src/helpers.dart';
