import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../payments/payment_manager.dart';

abstract class PaymentWebhookRoute extends Route {
  PaymentWebhookRoute({super.host}) : super(methods: {Method.post}, path: '/');

  PaymentRail get railType;
  String get providerName;
  Future<void> initializeRail(Session session);
  Future<Map<String, dynamic>> buildCallbackData(
    Session session,
    Request request,
    String requestBody,
  );

  @override
  FutureOr<Result> handleCall(Session session, Request request) async {
    try {
      session.log('$providerName webhook received', level: LogLevel.info);
      final body = await request.readAsString();
      if (body.isEmpty) {
        return Response.badRequest(body: Body.fromString('Empty request body'));
      }
      var rail = PaymentManager.getRail(railType);
      if (rail == null) {
        await initializeRail(session);
        rail = PaymentManager.getRail(railType);
        if (rail == null) {
          session.log(
            '$providerName rail not available',
            level: LogLevel.error,
          );
          return Response.internalServerError(
            body: Body.fromString('$providerName rail not available'),
          );
        }
      }
      final result = await rail.processCallback(
        await buildCallbackData(session, request, body),
      );
      if (result.success) {
        session.log('$providerName webhook processed', level: LogLevel.info);
        return Response.ok(body: Body.fromString('OK'));
      }
      session.log(
        '$providerName webhook failed: ${result.errorMessage}',
        level: LogLevel.warning,
      );
      return Response.unauthorized(
        body: Body.fromString(result.errorMessage ?? 'Verification failed'),
      );
    } catch (e) {
      session.log('$providerName webhook error: $e', level: LogLevel.error);
      return Response.internalServerError(
        body: Body.fromString('Internal error'),
      );
    }
  }
}
