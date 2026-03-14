import 'dart:async';
import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../payments/payment_manager.dart';
import '../payments/payment_rail_interface.dart';

/// Route for receiving Google Play Real-time Developer Notifications.
///
/// Register in your server's `run()` method:
/// ```dart
/// pod.webServer.addRoute(GoogleWebhookRoute(), '/hooks/google');
/// ```
///
/// Google sends signed Pub/Sub notifications to this URL. The signature
/// is validated inside [GoogleIAPRail.processCallback] via
/// [WebhookSignatureValidator].
class GoogleWebhookRoute extends Route {
  /// Creates a Google webhook route that accepts POST requests.
  GoogleWebhookRoute({super.host})
      : super(methods: {Method.post}, path: '/');

  @override
  FutureOr<Result> handleCall(Session session, Request request) async {
    try {
      session.log('Google webhook received', level: LogLevel.info);

      final body = await request.readAsString();
      if (body.isEmpty) {
        return Response.badRequest(
          body: Body.fromString('Empty request body'),
        );
      }

      final Map<String, dynamic> webhookData;
      try {
        webhookData = jsonDecode(body) as Map<String, dynamic>;
      } on FormatException {
        return Response.badRequest(
          body: Body.fromString('Invalid JSON'),
        );
      }

      // Extract signature from headers for verification
      final signature =
          request.headers['x-goog-iam-authority-selector']?.first
          ?? request.headers['x-signature']?.first;

      final rail = PaymentManager.getRail(PaymentRail.google_iap);
      if (rail == null) {
        await PaymentManager.initializeGoogleIAPRail(session);
        final retryRail = PaymentManager.getRail(PaymentRail.google_iap);
        if (retryRail == null) {
          session.log(
            'Google IAP rail not available',
            level: LogLevel.error,
          );
          return Response.internalServerError(
            body: Body.fromString('Google IAP rail not available'),
          );
        }
        return _process(session, retryRail, webhookData, body, signature);
      }

      return _process(session, rail, webhookData, body, signature);
    } catch (e) {
      session.log(
        'Google webhook error: ${e.toString()}',
        level: LogLevel.error,
      );
      return Response.internalServerError(
        body: Body.fromString('Internal error'),
      );
    }
  }

  Future<Response> _process(
    Session session,
    PaymentRailInterface rail,
    Map<String, dynamic> webhookData,
    String rawPayload,
    String? signature,
  ) async {
    final callbackData = <String, dynamic>{
      'session': session,
      'payload': rawPayload,
      'signature': signature,
      ...webhookData,
    };

    final result = await rail.processCallback(callbackData);

    if (result.success) {
      session.log(
        'Google webhook processed: ${result.internalTransactionId}',
        level: LogLevel.info,
      );
      return Response.ok(body: Body.fromString('OK'));
    } else {
      session.log(
        'Google webhook failed: ${result.errorMessage}',
        level: LogLevel.warning,
      );
      return Response.unauthorized(
        body: Body.fromString(result.errorMessage ?? 'Verification failed'),
      );
    }
  }
}
