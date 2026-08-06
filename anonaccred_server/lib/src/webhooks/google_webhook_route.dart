import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../payments/payment_manager.dart';
import '../payments/rails/google_iap_rail.dart';
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
  ) async => {
    'session': session,
    'authorization_header': request.headers['authorization']?.first ?? '',
    'request_body': requestBody,
    'expected_audience': GoogleIAPRail.expectedPushAudience,
  };
}
