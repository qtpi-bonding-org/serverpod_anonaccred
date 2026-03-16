import 'package:anonaccount_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:serverpod_test/serverpod_test.dart';

/// Helper to create test accounts via direct DB insert.
///
/// Use this in tests that need an account to exist but aren't testing
/// account creation itself (bypasses PoW verification).
///
/// Creates a Serverpod AuthUser first (mirroring what the real
/// AccountEndpoint.createAccount does), then inserts the AnonAccount
/// row with the AuthUser's UUID as its id.
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
    // Create AuthUser so signIn's issueToken can find the user
    final authUser = await AuthServices.instance.authUsers.create(session);

    final account = AnonAccount(
      id: authUser.id,
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
