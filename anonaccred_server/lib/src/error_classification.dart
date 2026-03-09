import 'package:anonaccount_server/anonaccount_server.dart';

import 'exception_factory.dart';
import 'generated/protocol.dart';

/// Lightweight utility class for basic error analysis
class AnonAccountExceptionUtils {
  /// Determines if an error is retryable based on its code
  static bool isRetryable(String errorCode) {
    switch (errorCode) {
      // Retryable errors
      case AnonAccountErrorCodes.networkTimeout:
      case AnonAccountErrorCodes.databaseError:
        return true;

      // Non-retryable errors (cryptographic)
      case AnonAccountErrorCodes.cryptoInvalidPublicKey:
      case AnonAccountErrorCodes.cryptoInvalidSignature:
      case AnonAccountErrorCodes.cryptoInvalidMessage:
      case AnonAccountErrorCodes.cryptoFormatError:

      // Non-retryable errors (authentication)
      case AnonAccountErrorCodes.authInvalidSignature:
      case AnonAccountErrorCodes.authExpiredChallenge:
      case AnonAccountErrorCodes.authDeviceNotFound:
      case AnonAccountErrorCodes.authDeviceRevoked:
      case AnonAccountErrorCodes.authAccountNotFound:
      case AnonAccountErrorCodes.authDuplicateDevice:
      case AnonAccountErrorCodes.authChallengeExpired:

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
      case AnonAccountErrorCodes.cryptoVerificationFailed:

      // Potentially retryable price registry errors
      case AnonAccredErrorCodes.priceRegistryOperationFailed:
        return true;

      // X402-specific retryable errors
      case AnonAccredErrorCodes.x402FacilitatorUnavailable:
        return true;

      // X402-specific non-retryable errors
      case AnonAccredErrorCodes.x402InvalidPaymentPayload:
      case AnonAccredErrorCodes.x402ConfigurationMissing:
      case AnonAccredErrorCodes.x402VerificationFailed:
        return false;

      // Default to non-retryable for unknown codes
      default:
        return false;
    }
  }

  /// Basic error analysis - returns code, message, retryability, severity, and category
  static Map<String, dynamic> analyzeException(Object exception) {
    String code;
    String message;

    if (exception is AnonAccountException) {
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
      code = AnonAccountErrorCodes.internalError;
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
      case AnonAccountErrorCodes.databaseError:
      case AnonAccountErrorCodes.internalError:
        return 'high';
      
      // Medium severity - operational errors
      case AnonAccountErrorCodes.networkTimeout:
      case AnonAccountErrorCodes.cryptoVerificationFailed:
      case AnonAccredErrorCodes.priceRegistryOperationFailed:
      case AnonAccredErrorCodes.x402FacilitatorUnavailable:
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
    } else if (errorCode.startsWith('PAYMENT_') || errorCode.startsWith('PRICE_REGISTRY_') || errorCode.startsWith('X402_')) {
      return 'payment';
    } else if (errorCode.startsWith('INVENTORY_')) {
      return 'inventory';
    } else if (errorCode == AnonAccountErrorCodes.networkTimeout) {
      return 'network';
    } else if (errorCode == AnonAccountErrorCodes.databaseError) {
      return 'database';
    } else {
      return 'system';
    }
  }

  /// Get recovery guidance for error code
  static String _getRecoveryGuidance(String errorCode) {
    switch (errorCode) {
      // Authentication errors
      case AnonAccountErrorCodes.authInvalidSignature:
      case AnonAccountErrorCodes.cryptoInvalidSignature:
        return 'Verify signature format and regenerate if necessary';
      case AnonAccountErrorCodes.authExpiredChallenge:
      case AnonAccountErrorCodes.authChallengeExpired:
        return 'Request a new authentication challenge';
      case AnonAccountErrorCodes.authDeviceRevoked:
        return 'Device has been revoked, register a new device';
      case AnonAccountErrorCodes.authDeviceNotFound:
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
      case AnonAccountErrorCodes.networkTimeout:
        return 'Retry the operation after a brief delay';
      case AnonAccountErrorCodes.databaseError:
        return 'Contact support if problem persists';
      
      // X402-specific errors
      case AnonAccredErrorCodes.x402FacilitatorUnavailable:
        return 'Facilitator service is unavailable, retry after a brief delay';
      case AnonAccredErrorCodes.x402InvalidPaymentPayload:
        return 'Verify X-PAYMENT header format and regenerate payment proof';
      case AnonAccredErrorCodes.x402ConfigurationMissing:
        return 'Configure X402_FACILITATOR_URL and X402_DESTINATION_ADDRESS environment variables';
      case AnonAccredErrorCodes.x402VerificationFailed:
        return 'Payment verification failed, ensure payment is valid and complete';
      
      default:
        return 'Review error details and retry if appropriate';
    }
  }
}
