import 'package:anonaccount_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:serverpod_test/serverpod_test.dart';
import 'package:uuid/uuid.dart';

/// Helper to create test accounts via direct DB insert.
///
/// Use this in tests that need an account to exist but aren't testing
/// account creation itself (bypasses PoW verification).
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
      id: UuidValue.fromString(const Uuid().v4()),
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
