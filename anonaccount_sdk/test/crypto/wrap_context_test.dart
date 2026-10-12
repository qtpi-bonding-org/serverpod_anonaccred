import 'dart:convert';

import 'package:anonaccount_client/anonaccount_client.dart' show UuidValue;
import 'package:anonaccount_sdk/src/crypto/wrap_context.dart';
import 'package:test/test.dart';

void main() {
  final a = '04${'a' * 128}';
  final b = '04${'b' * 128}';
  final m1 = UuidValue.fromString('11111111-1111-4111-8111-111111111111');

  String info(WrapContext c) => utf8.decode(c.info);
  String aad(WrapContext c) => utf8.decode(c.aad);

  test('each purpose carries its own label and owner', () {
    final cases = <(WrapContext, String, String)>[
      (WrapContext.accountDataKeyForUltimate(ultimateSigningHex: a),
          'anonaccount.wrap.account-data-key.ultimate.v1', a),
      (WrapContext.accountDataKeyForDevice(deviceSigningHex: a),
          'anonaccount.wrap.account-data-key.device.v1', a),
      (WrapContext.groupDataKeyForGroup(groupSigningHex: a),
          'anonaccount.wrap.group-data-key.group.v1', a),
      (WrapContext.groupDataKeyForMember(groupSigningHex: a, memberSigningHex: b),
          'anonaccount.wrap.group-data-key.member.v1', '$a:$b'),
      (WrapContext.groupDataKeyForDevice(memberId: m1, deviceSigningHex: a),
          'anonaccount.wrap.group-data-key.device.v1',
          '11111111-1111-4111-8111-111111111111:$a'),
      (WrapContext.memberKeyBackup(groupSigningHex: a, memberSigningHex: b),
          'anonaccount.wrap.member-key-backup.v1', '$a:$b'),
      (WrapContext.groupOwnerKeyBackup(groupSigningHex: a),
          'anonaccount.wrap.group-owner-key-backup.v1', a),
    ];
    for (final (c, label, owner) in cases) {
      expect(info(c), label);
      expect(aad(c), owner, reason: label);
    }
    expect(cases.map((c) => c.$2).toSet(), hasLength(7));
  });

  group('rejects a binding value that is not canonical', () {
    test('uppercase hex', () {
      expect(() => WrapContext.groupOwnerKeyBackup(groupSigningHex: a.toUpperCase()),
          throwsArgumentError);
    });
    test('128 hex characters (no 04 tag)', () {
      expect(() => WrapContext.groupOwnerKeyBackup(groupSigningHex: a.substring(2)),
          throwsArgumentError);
    });
    test('a non-hex character', () {
      expect(() => WrapContext.groupOwnerKeyBackup(
              groupSigningHex: a.replaceRange(10, 11, 'g')),
          throwsArgumentError);
    });
    test('the second hex of a pair', () {
      expect(() => WrapContext.memberKeyBackup(
              groupSigningHex: a, memberSigningHex: 'nope'),
          throwsArgumentError);
    });
    test('a member id that is not a UUID', () {
      expect(() => WrapContext.groupDataKeyForDevice(
              memberId: UuidValue.fromString('not-a-uuid'), deviceSigningHex: a),
          throwsArgumentError);
    });
  });
}
