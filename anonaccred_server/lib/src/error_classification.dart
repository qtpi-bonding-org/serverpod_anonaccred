import 'exception_factory.dart';
import 'generated/protocol.dart';

/// Lightweight utility class for basic error analysis
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

  /// Basic error analysis - returns code, message, retryability, severity, and category
  static Map<String, dynamic> analyzeException(Object exception) {
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
      'severity': _getSeverity(code),
      'category': _getCategory(code),
      'recoveryGuidance': _getRecoveryGuidance(code),
    };
  }

  /// Get severity level for error code
  static String _getSeverity(String errorCode) {
    switch (errorCode) {
      // High severity - system errors
      case AnonAccredErrorCodes.databaseError:
      case AnonAccredErrorCodes.internalError:
        return 'high';
      
      // Medium severity - operational errors
      case AnonAccredErrorCodes.networkTimeout:
      case AnonAccredErrorCodes.cryptoVerificationFailed:
      case AnonAccredErrorCodes.priceRegistryOperationFailed:
        return 'medium';
      
      // Low severity - client errors
      default:
        return 'low';
    }
  }

  /// Get category for error code
  static String _getCategory(String errorCode) {
    if (errorCode.startsWith('AUTH_') || errorCode.startsWith('CRYPTO_')) {
      return 'authentication';
    } else if (errorCode.startsWith('PAYMENT_') || errorCode.startsWith('PRICE_REGISTRY_')) {
      return 'payment';
    } else if (errorCode.startsWith('INVENTORY_')) {
      return 'inventory';
    } else if (errorCode == AnonAccredErrorCodes.networkTimeout) {
      return 'network';
    } else if (errorCode == AnonAccredErrorCodes.databaseError) {
      return 'database';
    } else {
      return 'system';
    }
  }

  /// Get recovery guidance for error code
  static String _getRecoveryGuidance(String errorCode) {
    switch (errorCode) {
      // Authentication errors
      case AnonAccredErrorCodes.authInvalidSignature:
      case AnonAccredErrorCodes.cryptoInvalidSignature:
        return 'Verify signature format and regenerate if necessary';
      case AnonAccredErrorCodes.authExpiredChallenge:
      case AnonAccredErrorCodes.authChallengeExpired:
        return 'Request a new authentication challenge';
      case AnonAccredErrorCodes.authDeviceRevoked:
        return 'Device has been revoked, register a new device';
      case AnonAccredErrorCodes.authDeviceNotFound:
        return 'Register device with account first';
      
      // Payment errors
      case AnonAccredErrorCodes.paymentInsufficientFunds:
        return 'Add funds to account or reduce payment amount';
      case AnonAccredErrorCodes.paymentInvalidRail:
        return 'Use a supported payment method';
      
      // Inventory errors
      case AnonAccredErrorCodes.inventoryInsufficientBalance:
        return 'Purchase more consumables or reduce usage';
      case AnonAccredErrorCodes.inventoryInvalidConsumable:
        return 'Use a valid consumable type';
      
      // System errors
      case AnonAccredErrorCodes.networkTimeout:
        return 'Retry the operation after a brief delay';
      case AnonAccredErrorCodes.databaseError:
        return 'Contact support if problem persists';
      
      default:
        return 'Review error details and retry if appropriate';
    }
  }
}
