import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}

void main() {
  test('deleteAccount throws UnimplementedError (server endpoint not landed)', () async {
    // Generate a seed account and extract its ultimate key
    final seedStore = InMemoryAccountKeyStore();
    await seedStore.generateAccountKeys();
    final seedUltimateJwk = (await seedStore.getUltimateKeyJwkOnce())!;

    // Create auth with a fresh store
    final authStore = InMemoryAccountKeyStore();
    final auth = AnonaccountAuth(_FakeCaller(), authStore);

    await expectLater(
      auth.deleteAccount(ultimateBackupJwk: seedUltimateJwk),
      throwsA(isA<UnimplementedError>()),
    );
  });
}
