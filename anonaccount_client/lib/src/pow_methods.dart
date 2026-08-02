import 'protocol/public_key_duo.dart';

/// Method name constants for PoW payload construction.
///
/// Both client and server must agree on the method name embedded in the
/// signed payload (`'$challenge:$methodName:$publicKeyHex'`).
/// Using these constants instead of raw strings prevents silent auth
/// failures when a method is renamed on one side but not the other.
abstract final class AccountMethods {
  static const createAccount = 'createAccount';
}

abstract final class DeviceMethods {
  static const registerDevice = 'registerDevice';
  static const signIn = 'signIn';
  static const monitorRegistration = 'monitorRegistration';
}

abstract final class DataKeyMethods {
  static const retrieveEncryptedDataKey = 'retrieveEncryptedDataKey';
  static const recoverEncryptedDataKey = 'recoverEncryptedDataKey';
}

abstract final class AccountInnerPayloads {
  /// The ultimate key attests to a new device's key pair.
  /// Used identically by createAccount and registerDevice.
  ///
  /// Covers BOTH halves: the encryption key becomes a wrap target, so it must
  /// be inside the signature rather than beside it, or it can be substituted.
  static String registerDevice(PublicKeyDuo deviceKeys) =>
      'registerDevice:${deviceKeys.signingPublicKeyHex}'
      ':${deviceKeys.encryptionPublicKeyHex}';

  /// An existing paired device attests to a newly paired device's key pair.
  static String pairDevice(PublicKeyDuo newDeviceKeys) =>
      'pairDevice:${newDeviceKeys.signingPublicKeyHex}'
      ':${newDeviceKeys.encryptionPublicKeyHex}';
}
