import 'package:anonaccount_server/src/endpoints/account_endpoint.dart';
import 'package:anonaccount_server/src/generated/protocol.dart';
import 'package:serverpod_test/serverpod_test.dart';

/// Concrete AccountEndpoint for testing (no spam prevention).
class TestAccountEndpoint extends AccountEndpoint {}

/// Helper to create test accounts via direct DB insert.
///
/// Use this in tests that need an account to exist but aren't testing
/// account creation itself.
Future<AnonAccount> createTestAccount(
  TestSessionBuilder sessionBuilder, {
  required String ultimateSigningPublicKeyHex,
  String encryptedDataKey = 'test-encrypted-data-key',
  String? ultimatePublicKey,
}) async {
  final session =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: 'createTestAccount',
  );
  try {
    final account = AnonAccount(
      ultimateSigningPublicKeyHex: ultimateSigningPublicKeyHex,
      encryptedDataKey: encryptedDataKey,
      ultimatePublicKey: ultimatePublicKey ?? ultimateSigningPublicKeyHex,
      createdAt: DateTime.now(),
    );
    return await AnonAccount.db.insertRow(session, account);
  } finally {
    await session.close();
  }
}
