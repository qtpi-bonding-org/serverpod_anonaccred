import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../payments/payment_manager.dart';
import 'payment_webhook_route.dart';

class GoogleWebhookRoute extends PaymentWebhookRoute {
  @override
  PaymentRail get railType => PaymentRail.google_iap;

  @override
  String get providerName => 'Google';

  @override
  Future<void> initializeRail(Session session) =>
      PaymentManager.initializeGoogleIAPRail(session);

  @override
  Future<Map<String, dynamic>> buildCallbackData(
    Session session,
    Request request,
    String requestBody,
  ) async {
    final webhookData = jsonDecode(requestBody) as Map<String, dynamic>;
    final signature =
        request.headers['x-goog-iam-authority-selector']?.first ??
        request.headers['x-signature']?.first;
    return {
      'session': session,
      'payload': requestBody,
      'signature': signature,
      ...webhookData,
    };
  }
}
