import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod_test/serverpod_test.dart';

class RevocationTestHelper {
  static Future<void> revokeDevice(
    TestSessionBuilder sessionBuilder,
    String deviceSigningPublicKeyHex,
  ) async {
    final session = (sessionBuilder as InternalTestSessionBuilder)
        .internalBuild(endpoint: 'test', method: 'revokeTestDevice');
    try {
      final device = (await AccountDevice.db.findFirstRow(
        session,
        where: (t) =>
            t.deviceSigningPublicKeyHex.equals(deviceSigningPublicKeyHex),
      ))!;
      await AccountDevice.db.updateRow(
        session,
        device.copyWith(isRevoked: true, revokedAt: DateTime.now()),
      );
    } finally {
      await session.close();
    }
  }
}
