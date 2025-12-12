import 'generated/protocol.dart';
import 'exception_factory.dart';

/// Error severity levels for classification
enum ErrorSeverity {
  low,      // Recoverable errors, retry recommended
  medium,   // Operational errors, manual intervention may be needed
  high,     // System errors, immediate attention required
}

/// Error categories for classification
enum ErrorCategory {
  authentication,
  payment,
  inventory,
  network,
  database,
}

/// Utility class for analyzing and classifying AnonAccred exceptions
class AnonAccredExceptionUtils {
  /// Determines if an error is retryable based on its code
  static bool isRetryable(String errorCode) {
    switch (errorCode) {
      // Retryable errors
      case AnonAccredErrorCodes.networkTimeout:
      case AnonAccredErrorCodes.databaseError:
        return true;
      
      // Non-retryable errors (cryptographic)
      case AnonAccredErrorCodes.cryptoInvalidPublicKey:
      case AnonAccredErrorCodes.cryptoInvalidSignature:
      case AnonAccredErrorCodes.cryptoInvalidMessage:
      case AnonAccredErrorCodes.cryptoFormatError:
      
      // Non-retryable errors (authentication)
      case AnonAccredErrorCodes.authInvalidSignature:
      case AnonAccredErrorCodes.authExpiredChallenge:
      case AnonAccredErrorCodes.authDeviceNotFound:
      case AnonAccredErrorCodes.authDeviceRevoked:
      case AnonAccredErrorCodes.authAccountNotFound:
      case AnonAccredErrorCodes.authDuplicateDevice:
      case AnonAccredErrorCodes.authChallengeExpired:
      
      // Non-retryable errors (payment/inventory)
      case AnonAccredErrorCodes.paymentInsufficientFunds:
      case AnonAccredErrorCodes.inventoryInsufficientBalance:
      case AnonAccredErrorCodes.inventoryAccountNotFound:
      
      // Non-retryable errors (price registry)
      case AnonAccredErrorCodes.priceRegistryProductNotFound:
      case AnonAccredErrorCodes.priceRegistryInvalidPrice:
      case AnonAccredErrorCodes.priceRegistryInvalidSku:
        return false;
      
      // Potentially retryable cryptographic errors
      case AnonAccredErrorCodes.cryptoVerificationFailed:
      
      // Potentially retryable price registry errors
      case AnonAccredErrorCodes.priceRegistryOperationFailed:
        return true;
      
      // Default to non-retryable for unknown codes
      default:
        return false;
    }
  }

  /// Gets the error severity for an error code
  static ErrorSeverity getErrorSeverity(String errorCode) {
    switch (errorCode) {
      // High severity - system errors
      case AnonAccredErrorCodes.databaseError:
      case AnonAccredErrorCodes.internalError:
      case AnonAccredErrorCodes.cryptoVerificationFailed:
        return ErrorSeverity.high;
      
      // Medium severity - operational errors
      case AnonAccredErrorCodes.paymentFailed:
      case AnonAccredErrorCodes.networkTimeout:
      case AnonAccredErrorCodes.priceRegistryOperationFailed:
        return ErrorSeverity.medium;
      
      // Low severity - user/client errors (cryptographic)
      case AnonAccredErrorCodes.cryptoInvalidPublicKey:
      case AnonAccredErrorCodes.cryptoInvalidSignature:
      case AnonAccredErrorCodes.cryptoInvalidMessage:
      case AnonAccredErrorCodes.cryptoFormatError:
      
      // Low severity - user/client errors (authentication)
      case AnonAccredErrorCodes.authInvalidSignature:
      case AnonAccredErrorCodes.authExpiredChallenge:
      case AnonAccredErrorCodes.authDeviceNotFound:
      case AnonAccredErrorCodes.authDeviceRevoked:
      case AnonAccredErrorCodes.authAccountNotFound:
      case AnonAccredErrorCodes.authDuplicateDevice:
      case AnonAccredErrorCodes.authChallengeExpired:
      
      // Low severity - user/client errors (payment/inventory)
      case AnonAccredErrorCodes.paymentInsufficientFunds:
      case AnonAccredErrorCodes.inventoryInsufficientBalance:
      
      // Low severity - user/client errors (price registry)
      case AnonAccredErrorCodes.priceRegistryProductNotFound:
      case AnonAccredErrorCodes.priceRegistryInvalidPrice:
      case AnonAccredErrorCodes.priceRegistryInvalidSku:
        return ErrorSeverity.low;
      
      // Default to medium for unknown codes
      default:
        return ErrorSeverity.medium;
    }
  }

  /// Gets the error category for an error code
  static ErrorCategory getErrorCategory(String errorCode) {
    if (errorCode.startsWith('AUTH_') || errorCode.startsWith('CRYPTO_')) {
      return ErrorCategory.authentication;
    } else if (errorCode.startsWith('PAYMENT_') || errorCode.startsWith('PRICE_REGISTRY_')) {
      return ErrorCategory.payment;
    } else if (errorCode.startsWith('INVENTORY_')) {
      return ErrorCategory.inventory;
    } else if (errorCode == AnonAccredErrorCodes.networkTimeout) {
      return ErrorCategory.network;
    } else if (errorCode == AnonAccredErrorCodes.databaseError) {
      return ErrorCategory.database;
    }
    
    // Default category
    return ErrorCategory.database;
  }

  /// Generates recovery guidance for different error types
  static String getRecoveryGuidance(String errorCode) {
    switch (errorCode) {
      // Cryptographic error guidance
      case AnonAccredErrorCodes.cryptoInvalidPublicKey:
        return 'Ensure the Ed25519 public key is exactly 64 hexadecimal characters.';
      
      case AnonAccredErrorCodes.cryptoInvalidSignature:
        return 'Ensure the Ed25519 signature is exactly 128 hexadecimal characters.';
      
      case AnonAccredErrorCodes.cryptoInvalidMessage:
        return 'Provide a non-empty message for signature verification.';
      
      case AnonAccredErrorCodes.cryptoFormatError:
        return 'Check that all cryptographic data is properly formatted as hexadecimal.';
      
      case AnonAccredErrorCodes.cryptoVerificationFailed:
        return 'Cryptographic operation failed. Verify inputs and retry.';
      
      // Authentication error guidance
      case AnonAccredErrorCodes.authInvalidSignature:
        return 'Verify the Ed25519 signature is correctly generated and matches the public key.';
      
      case AnonAccredErrorCodes.authExpiredChallenge:
        return 'Request a new authentication challenge and retry the operation.';
      
      case AnonAccredErrorCodes.authMissingKey:
        return 'Ensure the Ed25519 public key is provided in the request.';
      
      case AnonAccredErrorCodes.authDeviceNotFound:
        return 'Verify the device is registered and the public subkey is correct.';
      
      case AnonAccredErrorCodes.authDeviceRevoked:
        return 'This device has been revoked. Use a different device or register a new one.';
      
      case AnonAccredErrorCodes.authAccountNotFound:
        return 'Verify the account exists and the account ID is correct.';
      
      case AnonAccredErrorCodes.authDuplicateDevice:
        return 'This device public key is already registered. Use a different key.';
      
      case AnonAccredErrorCodes.authChallengeExpired:
        return 'Request a new authentication challenge and retry the operation.';
      
      // Payment error guidance
      case AnonAccredErrorCodes.paymentFailed:
        return 'Check payment details and retry. Contact support if the issue persists.';
      
      case AnonAccredErrorCodes.paymentInsufficientFunds:
        return 'Ensure sufficient funds are available in the payment method.';
      
      case AnonAccredErrorCodes.paymentInvalidRail:
        return 'Use a supported payment rail (X402, Monero, or IAP).';
      
      // Inventory error guidance
      case AnonAccredErrorCodes.inventoryInsufficientBalance:
        return 'Purchase additional consumables or check account balance.';
      
      case AnonAccredErrorCodes.inventoryInvalidConsumable:
        return 'Verify the consumable type is valid for this operation.';
      
      case AnonAccredErrorCodes.inventoryAccountNotFound:
        return 'Ensure the account exists and the account ID is correct.';
      
      // Price Registry error guidance
      case AnonAccredErrorCodes.priceRegistryProductNotFound:
        return 'Register the product in the price registry before creating orders.';
      
      case AnonAccredErrorCodes.priceRegistryInvalidPrice:
        return 'Ensure the price is a positive number greater than zero.';
      
      case AnonAccredErrorCodes.priceRegistryInvalidSku:
        return 'Provide a valid, non-empty product SKU identifier.';
      
      case AnonAccredErrorCodes.priceRegistryOperationFailed:
        return 'Price registry operation failed. Please retry or contact support.';
      
      // System error guidance
      case AnonAccredErrorCodes.networkTimeout:
        return 'Check network connectivity and retry the operation.';
      
      case AnonAccredErrorCodes.databaseError:
        return 'Temporary database issue. Please retry in a few moments.';
      
      case AnonAccredErrorCodes.internalError:
        return 'An internal error occurred. Please contact support.';
      
      default:
        return 'An unexpected error occurred. Please retry or contact support.';
    }
  }

  /// Analyzes an AnonAccred exception and provides comprehensive error information
  static Map<String, dynamic> analyzeException(dynamic exception) {
    String code;
    String message;
    
    if (exception is AnonAccredException) {
      code = exception.code;
      message = exception.message;
    } else if (exception is AuthenticationException) {
      code = exception.code;
      message = exception.message;
    } else if (exception is PaymentException) {
      code = exception.code;
      message = exception.message;
    } else if (exception is InventoryException) {
      code = exception.code;
      message = exception.message;
    } else {
      code = AnonAccredErrorCodes.internalError;
      message = exception.toString();
    }
    
    return {
      'code': code,
      'message': message,
      'retryable': isRetryable(code),
      'severity': getErrorSeverity(code).name,
      'category': getErrorCategory(code).name,
      'recoveryGuidance': getRecoveryGuidance(code),
    };
  }
}