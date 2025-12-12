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
      
      // Non-retryable errors
      case AnonAccredErrorCodes.authInvalidSignature:
      case AnonAccredErrorCodes.authExpiredChallenge:
      case AnonAccredErrorCodes.paymentInsufficientFunds:
      case AnonAccredErrorCodes.inventoryInsufficientBalance:
      case AnonAccredErrorCodes.inventoryAccountNotFound:
        return false;
      
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
        return ErrorSeverity.high;
      
      // Medium severity - operational errors
      case AnonAccredErrorCodes.paymentFailed:
      case AnonAccredErrorCodes.networkTimeout:
        return ErrorSeverity.medium;
      
      // Low severity - user/client errors
      case AnonAccredErrorCodes.authInvalidSignature:
      case AnonAccredErrorCodes.authExpiredChallenge:
      case AnonAccredErrorCodes.paymentInsufficientFunds:
      case AnonAccredErrorCodes.inventoryInsufficientBalance:
        return ErrorSeverity.low;
      
      // Default to medium for unknown codes
      default:
        return ErrorSeverity.medium;
    }
  }

  /// Gets the error category for an error code
  static ErrorCategory getErrorCategory(String errorCode) {
    if (errorCode.startsWith('AUTH_')) {
      return ErrorCategory.authentication;
    } else if (errorCode.startsWith('PAYMENT_')) {
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
      case AnonAccredErrorCodes.authInvalidSignature:
        return 'Verify the Ed25519 signature is correctly generated and matches the public key.';
      
      case AnonAccredErrorCodes.authExpiredChallenge:
        return 'Request a new authentication challenge and retry the operation.';
      
      case AnonAccredErrorCodes.authMissingKey:
        return 'Ensure the Ed25519 public key is provided in the request.';
      
      case AnonAccredErrorCodes.paymentFailed:
        return 'Check payment details and retry. Contact support if the issue persists.';
      
      case AnonAccredErrorCodes.paymentInsufficientFunds:
        return 'Ensure sufficient funds are available in the payment method.';
      
      case AnonAccredErrorCodes.paymentInvalidRail:
        return 'Use a supported payment rail (X402, Monero, or IAP).';
      
      case AnonAccredErrorCodes.inventoryInsufficientBalance:
        return 'Purchase additional consumables or check account balance.';
      
      case AnonAccredErrorCodes.inventoryInvalidConsumable:
        return 'Verify the consumable type is valid for this operation.';
      
      case AnonAccredErrorCodes.inventoryAccountNotFound:
        return 'Ensure the account exists and the account ID is correct.';
      
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