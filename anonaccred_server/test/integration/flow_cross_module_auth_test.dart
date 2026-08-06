import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:test/test.dart';
import 'test_tools/commerce_test_harness.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Cross-module auth chaining', (sessionBuilder, endpoints) {
    test('a revoked device is rejected by every commerce entrypoint, not just one', () async {
      final harness = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'revoke1');
      await harness.revokeDevice();

      await expectLater(harness.getEntitlements(), throwsA(isA<AuthenticationException>()));
      await expectLater(harness.getBalance('coins'), throwsA(isA<AuthenticationException>()));
      await expectLater(harness.consume('coins', 1), throwsA(isA<AuthenticationException>()));
      await expectLater(
        harness.buyApple(transactionId: 't', productId: 'p'),
        throwsA(isA<AuthenticationException>()),
      );
      await expectLater(
        harness.buyGoogle(packageName: 'pkg', productId: 'p', purchaseToken: 'tok'),
        throwsA(isA<AuthenticationException>()),
      );
      await expectLater(harness.redeemPolar(licenseKey: 'x'), throwsA(isA<AuthenticationException>()));
    });
  });
}
