import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../payments/payment_manager.dart';
import '../payments/payment_rail_interface.dart';

/// Route for receiving Apple App Store Server Notifications.
///
/// Register in your server's `run()` method:
/// ```dart
/// pod.webServer.addRoute(AppleWebhookRoute(), '/hooks/apple');
/// ```
///
/// Apple sends JWS-signed notifications to this URL. The signature is
/// validated inside [AppleIAPRail.processCallback] via
/// [NotificationSignatureValidator].
class AppleWebhookRoute extends Route {
  /// Creates an Apple webhook route that accepts POST requests.
  AppleWebhookRoute({super.host})
      : super(methods: {Method.post}, path: '/');

  @override
  FutureOr<Result> handleCall(Session session, Request request) async {
    try {
      session.log('Apple webhook received', level: LogLevel.info);

      final body = await request.readAsString();
      if (body.isEmpty) {
        return Response.badRequest(
          body: Body.fromString('Empty request body'),
        );
      }

      final rail = PaymentManager.getRail(PaymentRail.apple_iap);
      if (rail == null) {
        await PaymentManager.initializeAppleIAPRail(session);
        final retryRail = PaymentManager.getRail(PaymentRail.apple_iap);
        if (retryRail == null) {
          session.log(
            'Apple IAP rail not available',
            level: LogLevel.error,
          );
          return Response.internalServerError(
            body: Body.fromString('Apple IAP rail not available'),
          );
        }
        return _process(session, retryRail, body);
      }

      return _process(session, rail, body);
    } catch (e) {
      session.log(
        'Apple webhook error: ${e.toString()}',
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
    String requestBody,
  ) async {
    final callbackData = <String, dynamic>{
      'session': session,
      'request_body': requestBody,
    };

    final result = await rail.processCallback(callbackData);

    if (result.success) {
      session.log(
        'Apple webhook processed: ${result.internalTransactionId}',
        level: LogLevel.info,
      );
      return Response.ok(body: Body.fromString('OK'));
    } else {
      session.log(
        'Apple webhook failed: ${result.errorMessage}',
        level: LogLevel.warning,
      );
      return Response.unauthorized(
        body: Body.fromString(result.errorMessage ?? 'Verification failed'),
      );
    }
  }
}
