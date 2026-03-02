import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../payments/payment_manager.dart';
import '../payments/payment_rail_interface.dart';

/// IAP webhook endpoint for Apple and Google notifications.
///
/// Uses PaymentManager.getRail() to get initialized rail instances,
/// injects the session into callbackData so rails can access the database.
class IAPWebhookEndpoint extends Endpoint {
  /// Handle Apple App Store Server Notifications
  Future<String> handleAppleWebhook(
    Session session,
    Map<String, dynamic> webhookData,
  ) async {
    try {
      session.log('Apple webhook received', level: LogLevel.info);

      final rail = PaymentManager.getRail(PaymentRail.apple_iap);
      if (rail == null) {
        // Lazy init: try to initialize now
        await PaymentManager.initializeAppleIAPRail(session);
        final retryRail = PaymentManager.getRail(PaymentRail.apple_iap);
        if (retryRail == null) {
          session.log(
            'Apple IAP rail not available',
            level: LogLevel.error,
          );
          return 'ERROR';
        }
        return _processApple(session, retryRail, webhookData);
      }

      return _processApple(session, rail, webhookData);
    } catch (e) {
      session.log(
        'Apple webhook error: ${e.toString()}',
        level: LogLevel.error,
      );
      return 'ERROR';
    }
  }

  Future<String> _processApple(
    Session session,
    PaymentRailInterface rail,
    Map<String, dynamic> webhookData,
  ) async {
    // Construct callbackData with session and request_body
    final callbackData = <String, dynamic>{
      'session': session,
      ...webhookData,
    };

    // Apple processCallback expects 'request_body' — construct from webhookData if absent
    if (!callbackData.containsKey('request_body') && webhookData.isNotEmpty) {
      callbackData['request_body'] = jsonEncode(webhookData);
    }

    final result = await rail.processCallback(callbackData);

    if (result.success) {
      session.log(
        'Apple webhook processed successfully: ${result.internalTransactionId}',
        level: LogLevel.info,
      );
      return 'OK';
    } else {
      session.log(
        'Apple webhook processing failed: ${result.errorMessage}',
        level: LogLevel.warning,
      );
      return 'ERROR';
    }
  }

  /// Handle Google Play Real-time Developer Notifications
  Future<String> handleGoogleWebhook(
    Session session,
    Map<String, dynamic> webhookData,
  ) async {
    try {
      session.log('Google webhook received', level: LogLevel.info);

      final rail = PaymentManager.getRail(PaymentRail.google_iap);
      if (rail == null) {
        // Lazy init
        await PaymentManager.initializeGoogleIAPRail(session);
        final retryRail = PaymentManager.getRail(PaymentRail.google_iap);
        if (retryRail == null) {
          session.log(
            'Google IAP rail not available',
            level: LogLevel.error,
          );
          return 'ERROR';
        }
        return _processGoogle(session, retryRail, webhookData);
      }

      return _processGoogle(session, rail, webhookData);
    } catch (e) {
      session.log(
        'Google webhook error: ${e.toString()}',
        level: LogLevel.error,
      );
      return 'ERROR';
    }
  }

  Future<String> _processGoogle(
    Session session,
    PaymentRailInterface rail,
    Map<String, dynamic> webhookData,
  ) async {
    // Inject session into callbackData
    final callbackData = <String, dynamic>{
      'session': session,
      ...webhookData,
    };

    final result = await rail.processCallback(callbackData);

    if (result.success) {
      session.log(
        'Google webhook processed successfully: ${result.internalTransactionId}',
        level: LogLevel.info,
      );
      return 'OK';
    } else {
      session.log(
        'Google webhook processing failed: ${result.errorMessage}',
        level: LogLevel.warning,
      );
      return 'ERROR';
    }
  }
}
