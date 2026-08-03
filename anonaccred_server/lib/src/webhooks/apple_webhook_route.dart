import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../payments/payment_manager.dart';
import 'payment_webhook_route.dart';

class AppleWebhookRoute extends PaymentWebhookRoute {
  @override
  PaymentRail get railType => PaymentRail.apple_iap;

  @override
  String get providerName => 'Apple';

  @override
  Future<void> initializeRail(Session session) =>
      PaymentManager.initializeAppleIAPRail(session);

  @override
  Future<Map<String, dynamic>> buildCallbackData(
    Session session,
    Request request,
    String requestBody,
  ) async => {'session': session, 'request_body': requestBody};
}
