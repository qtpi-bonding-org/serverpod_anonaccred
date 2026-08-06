import 'package:relic_core/relic_core.dart';

/// Builds a relic_core Request without a live HTTP server, using the
/// RequestInternal extension relic_core's own test suite uses for the
/// same purpose (Request's only public constructor path otherwise runs
/// through a real IO adapter). `RequestInternal` lives in a `part` file
/// of `src/context/result.dart`, which the public barrel does export —
/// so this currently resolves via the plain `package:relic_core/relic_core.dart`
/// import rather than a deep `src/...` import. relic_core could still move
/// or hide the extension without a deprecation cycle; if this import breaks
/// on a relic_core upgrade, that's why.
class FakeWebhookRequest {
  static Request build({required String body, required Map<String, String> headers}) => RequestInternal.create(
        Method.post,
        Uri.parse('http://localhost/webhook'),
        Object(),
        headers: Headers.fromMap(headers.map((key, value) => MapEntry(key, [value]))),
        body: Body.fromString(body),
      );
}
