import 'package:serverpod/serverpod.dart';

/// Privacy-aware logging utilities that extend Serverpod's session logging
/// while ensuring no PII, private keys, or encrypted data is ever logged
class PrivacyLogger {
  /// Logs authentication events with privacy-safe information
  /// 
  /// Logs: public keys, operation types, success status
  /// Never logs: private keys, encrypted data, PII
  static void logAuthentication(
    Session session, {
    required String operation,
    required bool success,
    String? publicKey,
    String? errorCode,
  }) {
    final logData = <String, dynamic>{
      'event_type': 'authentication',
      'operation': operation,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Add public key if provided (safe to log)
    if (publicKey != null && publicKey.isNotEmpty) {
      logData['public_key'] = publicKey;
    }

    // Add error code if provided
    if (errorCode != null && errorCode.isNotEmpty) {
      logData['error_code'] = errorCode;
    }

    // Use Serverpod's built-in session logging
    session
      ..log(
        'Authentication event: $operation ${success ? 'succeeded' : 'failed'}',
        level: success ? LogLevel.info : LogLevel.warning,
      )
      // Log structured data for operational monitoring
      ..log(
        'Auth data: ${_formatLogData(logData)}',
        level: LogLevel.debug,
      );
  }

  /// Logs payment events with privacy-safe information
  /// 
  /// Logs: order IDs, payment rails, transaction references, amounts
  /// Never logs: payment credentials, PII, sensitive payment data
  static void logPayment(
    Session session, {
    required String operation,
    required String orderId,
    required String paymentRail,
    String? status,
    double? amountUSD,
    String? errorCode,
    String? transactionRef,
  }) {
    final logData = <String, dynamic>{
      'event_type': 'payment',
      'operation': operation,
      'order_id': orderId,
      'payment_rail': paymentRail,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Add optional fields if provided
    if (status != null && status.isNotEmpty) {
      logData['status'] = status;
    }

    if (amountUSD != null) {
      logData['amount_usd'] = amountUSD;
    }

    if (errorCode != null && errorCode.isNotEmpty) {
      logData['error_code'] = errorCode;
    }

    if (transactionRef != null && transactionRef.isNotEmpty) {
      logData['transaction_ref'] = transactionRef;
    }

    // Use Serverpod's built-in session logging
    final isSuccess = status == 'paid' || status == 'completed';
    session
      ..log(
        'Payment event: $operation for order $orderId via $paymentRail ${isSuccess ? 'succeeded' : 'failed'}',
        level: isSuccess ? LogLevel.info : LogLevel.warning,
      )
      // Log structured data for operational monitoring
      ..log(
        'Payment data: ${_formatLogData(logData)}',
        level: LogLevel.debug,
      );
  }

  /// Logs inventory events with privacy-safe information
  /// 
  /// Logs: account IDs, consumable types, quantities, operations
  /// Never logs: encrypted user data, PII, sensitive account information
  static void logInventory(
    Session session, {
    required String operation,
    required int accountId,
    required String consumableType,
    int? quantity,
    int? newBalance,
    String? errorCode,
  }) {
    final logData = <String, dynamic>{
      'event_type': 'inventory',
      'operation': operation,
      'account_id': accountId,
      'consumable_type': consumableType,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Add optional fields if provided
    if (quantity != null) {
      logData['quantity'] = quantity;
    }

    if (newBalance != null) {
      logData['new_balance'] = newBalance;
    }

    if (errorCode != null && errorCode.isNotEmpty) {
      logData['error_code'] = errorCode;
    }

    // Use Serverpod's built-in session logging
    final isSuccess = errorCode == null || errorCode.isEmpty;
    session
      ..log(
        'Inventory event: $operation for account $accountId, consumable $consumableType ${isSuccess ? 'succeeded' : 'failed'}',
        level: isSuccess ? LogLevel.info : LogLevel.warning,
      )
      // Log structured data for operational monitoring
      ..log(
        'Inventory data: ${_formatLogData(logData)}',
        level: LogLevel.debug,
      );
  }

  /// Logs cryptographic operations with privacy-safe information
  /// 
  /// Logs: operation types, success status, algorithm information
  /// Never logs: key material, encrypted content, private keys, signatures
  static void logCryptographic(
    Session session, {
    required String operation,
    required bool success,
    String? algorithm,
    String? keyType,
    String? errorCode,
  }) {
    final logData = <String, dynamic>{
      'event_type': 'cryptographic',
      'operation': operation,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Add optional fields if provided
    if (algorithm != null && algorithm.isNotEmpty) {
      logData['algorithm'] = algorithm;
    }

    if (keyType != null && keyType.isNotEmpty) {
      logData['key_type'] = keyType;
    }

    if (errorCode != null && errorCode.isNotEmpty) {
      logData['error_code'] = errorCode;
    }

    // Use Serverpod's built-in session logging
    session
      ..log(
        'Cryptographic event: $operation ${success ? 'succeeded' : 'failed'}',
        level: success ? LogLevel.info : LogLevel.warning,
      )
      // Log structured data for operational monitoring
      ..log(
        'Crypto data: ${_formatLogData(logData)}',
        level: LogLevel.debug,
      );
  }

  /// Logs general operational events with privacy-safe information
  /// 
  /// This is a general-purpose logging method for events that don't fit
  /// into the specific categories above but still need privacy-safe logging
  static void logOperation(
    Session session, {
    required String operation,
    required bool success,
    String? category,
    Map<String, dynamic>? safeData,
    String? errorCode,
  }) {
    final logData = <String, dynamic>{
      'event_type': 'operation',
      'operation': operation,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Add optional fields if provided
    if (category != null && category.isNotEmpty) {
      logData['category'] = category;
    }

    if (errorCode != null && errorCode.isNotEmpty) {
      logData['error_code'] = errorCode;
    }

    // Add safe data if provided (caller is responsible for ensuring privacy)
    if (safeData != null && safeData.isNotEmpty) {
      logData['data'] = safeData;
    }

    // Use Serverpod's built-in session logging
    session
      ..log(
        'Operation event: $operation ${success ? 'succeeded' : 'failed'}',
        level: success ? LogLevel.info : LogLevel.warning,
      )
      // Log structured data for operational monitoring
      ..log(
        'Operation data: ${_formatLogData(logData)}',
        level: LogLevel.debug,
      );
  }

  /// Formats log data as a JSON-like string for structured logging
  /// 
  /// This helper method ensures consistent formatting of structured log data
  /// while maintaining readability in log files
  static String _formatLogData(Map<String, dynamic> data) {
    final buffer = StringBuffer()..write('{');
    
    final entries = data.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('"${entry.key}": ');
      
      if (entry.value is String) {
        buffer.write('"${entry.value}"');
      } else {
        buffer.write('${entry.value}');
      }
      
      if (i < entries.length - 1) {
        buffer.write(', ');
      }
    }
    
    buffer.write('}');
    return buffer.toString();
  }
}