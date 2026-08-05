import 'package:anonaccount_client/anonaccount_client.dart' as client;
import 'package:anonaccount_server/src/generated/public_challenge_response.dart'
    as server;
import 'package:test/test.dart';

import 'sdk_test_caller.dart';

void main() {
  test('convertModel round-trips server and client models', () {
    final result = convertModel(
      server.PublicChallengeResponse(
        challenge: 'abc',
        difficulty: 20,
        expiresAt: 12345,
      ),
      client.PublicChallengeResponse.fromJson,
    );
    expect(result.challenge, 'abc');
    expect(result.difficulty, 20);
    expect(result.expiresAt, 12345);
  });
}
