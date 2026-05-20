import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../payments/payment_manager.dart';
import '../payments/payment_rail_interface.dart';

/// Route for receiving Polar.sh webhook notifications.
///
/// Register in your server's `run()` method:
/// ```dart
/// pod.webServer.addRoute(PolarWebhookRoute(), '/hooks/polar');
/// ```
///
/// Polar sends Standard Webhooks signed deliveries. Signature
/// validation happens inside [PolarRail.processCallback] (matches the
/// Apple pattern of doing rail-specific validation in the rail itself,
/// not the route).
class PolarWebhookRoute extends Route {
  PolarWebhookRoute({super.host}) : super(methods: {Method.post}, path: '/');

  @override
  FutureOr<Result> handleCall(Session session, Request request) async {
    try {
      session.log('Polar webhook received', level: LogLevel.info);

      final body = await request.readAsString();
      if (body.isEmpty) {
        return Response.badRequest(
          body: Body.fromString('Empty request body'),
        );
      }

      final rail = PaymentManager.getRail(PaymentRail.polar);
      if (rail == null) {
        PaymentManager.initializePolarRail(session);
        final retryRail = PaymentManager.getRail(PaymentRail.polar);
        if (retryRail == null) {
          session.log('Polar rail not available', level: LogLevel.error);
          return Response.internalServerError(
            body: Body.fromString('Polar rail not available'),
          );
        }
        return _process(session, retryRail, body, request);
      }
      return _process(session, rail, body, request);
    } catch (e) {
      session.log('Polar webhook error: $e', level: LogLevel.error);
      return Response.internalServerError(
        body: Body.fromString('Internal error'),
      );
    }
  }

  Future<Response> _process(
    Session session,
    PaymentRailInterface rail,
    String requestBody,
    Request request,
  ) async {
    final headers = <String, String>{};
    request.headers.forEach((k, v) {
      if (v.isNotEmpty) headers[k.toLowerCase()] = v.first;
    });

    final callbackData = <String, dynamic>{
      'session': session,
      'request_body': requestBody,
      'headers': headers,
    };

    final result = await rail.processCallback(callbackData);

    if (result.success) {
      return Response.ok(body: Body.fromString('OK'));
    } else {
      return Response.unauthorized(
        body: Body.fromString(result.errorMessage ?? 'Verification failed'),
      );
    }
  }
}
