import 'dart:convert';
import 'dart:io';

import 'package:anonaccred_server/src/payments/notification_signature_validator.dart';
import 'package:test/test.dart';

/// A JWT-shaped payload with an ES256 header and a `kid`, just enough to
/// pass validateSignature's early checks and reach the JWKS fetch. The
/// signature segment doesn't need to verify — these tests only observe
/// fetch behavior, not verification outcome.
String _fakeSignedPayload() {
  final header = base64Url
      .encode(utf8.encode(jsonEncode({'alg': 'ES256', 'kid': 'test-kid'})))
      .replaceAll('=', '');
  return '$header.payload.signature';
}

void main() {
  late HttpServer server;
  late int requestCount;

  setUp(() async {
    requestCount = 0;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      requestCount++;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'keys': <dynamic>[]}));
      await request.response.close();
    });
    NotificationSignatureValidator.jwksUri =
        Uri.parse('http://${server.address.address}:${server.port}');
    NotificationSignatureValidator.refreshJWKS();
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('closes the HttpClient after fetching JWKS (no idle connection leak)',
      () async {
    await NotificationSignatureValidator.validateSignature(
      signedPayload: _fakeSignedPayload(),
    );

    // Give connection teardown a moment to propagate to the server side.
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(
      server.connectionsInfo().idle,
      equals(0),
      reason: 'the JWKS HttpClient must be closed after use, not left '
          'idle in the connection pool',
    );
  });

  test(
    'fetches JWKS only once for concurrent validateSignature calls when '
    'cache is expired',
    () async {
      final payload = _fakeSignedPayload();

      await Future.wait(
        List.generate(
          5,
          (_) => NotificationSignatureValidator.validateSignature(
            signedPayload: payload,
          ),
        ),
      );

      expect(requestCount, equals(1));
    },
  );
}
