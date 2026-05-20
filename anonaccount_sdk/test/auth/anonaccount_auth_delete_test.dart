import 'package:anonaccount_client/anonaccount_client.dart' as wire;
import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeCaller extends Mock implements wire.Caller {}

void main() {
  test('deleteAccount throws UnimplementedError (server endpoint not landed)', () async {
    final ultimate = await KeyGen.generateUltimateKey();
    final auth = AnonaccountAuth(_FakeCaller());
    await expectLater(
      auth.deleteAccount(ultimateKey: ultimate),
      throwsA(isA<UnimplementedError>()),
    );
  });
}
