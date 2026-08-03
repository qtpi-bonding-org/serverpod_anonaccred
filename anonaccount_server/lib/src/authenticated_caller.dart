import 'package:serverpod/serverpod.dart';

import 'generated/protocol.dart';

/// A caller device that has been resolved and confirmed active.
class AuthenticatedCaller {
  final AccountDevice device;

  AuthenticatedCaller(this.device) {
    if (device.isRevoked) {
      throw StateError(
        'AuthenticatedCaller must wrap an active device; got revoked device '
        '${device.id}.',
      );
    }
  }

  UuidValue get accountId => device.anonAccountId;

  String get signingPublicKeyHex => device.deviceSigningPublicKeyHex;
}
