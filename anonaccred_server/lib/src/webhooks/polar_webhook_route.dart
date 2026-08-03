import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../payments/payment_manager.dart';
import 'payment_webhook_route.dart';

class PolarWebhookRoute extends PaymentWebhookRoute {
  @override
  PaymentRail get railType => PaymentRail.polar;

  @override
  String get providerName => 'Polar';

  @override
  Future<void> initializeRail(Session session) async {
    PaymentManager.initializePolarRail(session);
  }

  @override
  Future<Map<String, dynamic>> buildCallbackData(
    Session session,
    Request request,
    String requestBody,
  ) async {
    final headers = <String, String>{};
    request.headers.forEach((key, values) {
      if (values.isNotEmpty) headers[key.toLowerCase()] = values.first;
    });
    return {
      'session': session,
      'request_body': requestBody,
      'headers': headers,
    };
  }
}
