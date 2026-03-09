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
// Configuration system
export 'src/config/header_config.dart';
// Core cryptographic utilities
export 'src/crypto_auth.dart';
export 'src/crypto_utils.dart';
// Challenge storage
export 'src/challenge_storage.dart';
// Exception handling
export 'src/exception_factory.dart';
// Generated Serverpod protocol classes and endpoints
export 'src/generated/endpoints.dart';
export 'src/generated/protocol.dart';
// Helper utilities
export 'src/helpers.dart';
