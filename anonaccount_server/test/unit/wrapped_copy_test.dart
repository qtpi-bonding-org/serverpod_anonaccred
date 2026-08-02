import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccount_server/src/queries/wrapped_copy.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import '../test_helpers/test_account_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

String _uniqueHex() {
  final tag = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  return tag.padRight(128, '0').substring(0, 128);
}

Future<AccountDevice> _insertDeviceWith(
  TestSessionBuilder sessionBuilder,
  WrappedCopy copy, {
  required UuidValue accountId,
}) async {
  final session =
      (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_insertDeviceWith',
  );
  try {
    return await AccountDevice.db.insertRow(
      session,
      AccountDevice(
        anonAccountId: accountId,
        deviceSigningPublicKeyHex: _uniqueHex(),
        deviceEncryptionPublicKeyHex: _uniqueHex(),
        encryptedDataKey: copy.ciphertext,
        keyEpoch: copy.keyEpoch,
        label: 'test-device',
        addedByAttestorPublicKeyHex: _uniqueHex(),
        addedByAttestation: 'attestation',
        lastActive: DateTime.now(),
        isRevoked: false,
      ),
    );
  } finally {
    await session.close();
  }
}

void main() {
  setUpAll(initializeTestAuthServices);

  test('WrappedCopy carries both halves', () {
    const copy = WrappedCopy(ciphertext: 'CT', keyEpoch: 3);
    expect(copy.ciphertext, 'CT');
    expect(copy.keyEpoch, 3);
  });

  withServerpod('WrappedCopy persistence', (sessionBuilder, endpoints) {
    test(
      'a row written through WrappedCopy persists both halves together',
      () async {
        // The type exists so the pair cannot be separated on the way to
        // the database. Asserting the constructor alone would not show
        // that.
        final account = await createTestAccount(
          sessionBuilder,
          ultimateSigningPublicKeyHex: _uniqueHex(),
        );
        final device = await _insertDeviceWith(
          sessionBuilder,
          const WrappedCopy(ciphertext: 'WRAPPED', keyEpoch: 7),
          accountId: account.id!,
        );

        final session = sessionBuilder.build();
        try {
          final reread = await AccountDevice.db.findById(session, device.id!);
          expect(reread!.encryptedDataKey, 'WRAPPED');
          expect(reread.keyEpoch, 7);
        } finally {
          await session.close();
        }
      },
    );
  });
}
