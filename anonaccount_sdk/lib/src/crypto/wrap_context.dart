import 'dart:convert';
import 'dart:typed_data';

import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:meta/meta.dart';

final _sec1Hex = RegExp(r'^04[0-9a-f]{128}$');
final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);

/// What an HPKE-wrapped secret is for (`info`) and whom it belongs to (`aad`).
///
/// Why: the server stores every wrapped blob and is not trusted with them, so
/// the purpose and the owner are bound into the encryption itself (what that
/// buys is pinned in asymmetric_test.dart). One factory per wrap site, so a
/// wrap and its unwrap are built from the same definition.
@immutable
final class WrapContext {
  const WrapContext._(this._label, this._parts);

  final String _label;
  final List<String> _parts;

  Uint8List get info => Uint8List.fromList(utf8.encode(_label));

  /// The parts joined by `:`; SEC1 hex and UUIDs contain no `:`.
  Uint8List get aad => Uint8List.fromList(utf8.encode(_parts.join(':')));

  factory WrapContext.accountDataKeyForUltimate({
    required String ultimateSigningHex,
  }) => WrapContext._('anonaccount.wrap.account-data-key.ultimate.v1', [
    _hex(ultimateSigningHex, 'ultimateSigningHex'),
  ]);

  factory WrapContext.accountDataKeyForDevice({
    required String deviceSigningHex,
  }) => WrapContext._('anonaccount.wrap.account-data-key.device.v1', [
    _hex(deviceSigningHex, 'deviceSigningHex'),
  ]);

  factory WrapContext.groupDataKeyForGroup({required String groupSigningHex}) =>
      WrapContext._('anonaccount.wrap.group-data-key.group.v1', [
        _hex(groupSigningHex, 'groupSigningHex'),
      ]);

  factory WrapContext.groupDataKeyForMember({
    required String groupSigningHex,
    required String memberSigningHex,
  }) => WrapContext._('anonaccount.wrap.group-data-key.member.v1', [
    _hex(groupSigningHex, 'groupSigningHex'),
    _hex(memberSigningHex, 'memberSigningHex'),
  ]);

  factory WrapContext.groupDataKeyForDevice({
    required UuidValue memberId,
    required String deviceSigningHex,
  }) => WrapContext._('anonaccount.wrap.group-data-key.device.v1', [
    _member(memberId),
    _hex(deviceSigningHex, 'deviceSigningHex'),
  ]);

  factory WrapContext.memberKeyBackup({
    required String groupSigningHex,
    required String memberSigningHex,
  }) => WrapContext._('anonaccount.wrap.member-key-backup.v1', [
    _hex(groupSigningHex, 'groupSigningHex'),
    _hex(memberSigningHex, 'memberSigningHex'),
  ]);

  factory WrapContext.groupOwnerKeyBackup({required String groupSigningHex}) =>
      WrapContext._('anonaccount.wrap.group-owner-key-backup.v1', [
        _hex(groupSigningHex, 'groupSigningHex'),
      ]);
}

// Checked rather than normalised: a wrap and its unwrap must agree byte for
// byte, and a value that needs normalising came from an encoder that should
// be fixed.
String _hex(String value, String name) {
  if (!_sec1Hex.hasMatch(value)) {
    throw ArgumentError.value(
      value,
      name,
      'must be 130 lowercase hex characters starting 04',
    );
  }
  return value;
}

String _member(UuidValue memberId) {
  final s = memberId.toString();
  if (!_uuid.hasMatch(s)) {
    throw ArgumentError.value(s, 'memberId', 'must be a lowercase UUID');
  }
  return s;
}
