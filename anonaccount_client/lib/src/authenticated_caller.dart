// Client representation of the active caller returned by endpoint guards.
// The server owns the validation; clients only need the wire shape.
import 'protocol/account_device.dart';

class AuthenticatedCaller {
  AuthenticatedCaller({required this.device});

  final AccountDevice device;

  String get accountId => device.anonAccountId.toString();

  String get signingPublicKeyHex => device.deviceSigningPublicKeyHex;
}
