import 'dart:convert';
import 'dart:io';

import 'package:anonaccount_sdk/anonaccount_sdk.dart';
import 'package:dart_jwk_duo/dart_jwk_duo.dart' show KeyDuoSerializer;
import 'package:test/test.dart';
import 'package:webcrypto/webcrypto.dart';

/// Every model that can hold key material, checked against its own material.
///
/// The AES-256 data key once reached logs through a generated `toString`
/// nobody wrote or reviewed. The crypto was correct; the codegen leaked it.
/// These tests cover the class of bug rather than the one instance.
void main() {
  group('per-model redaction', () {
    test('AccountKeys hides the symmetric key', () async {
      final keys = await KeyGen.generateAccountKeys();
      final k = (jsonDecode(keys.symmetricKeyJwk) as Map<String, dynamic>)['k']
          as String;

      expect(k, isNotEmpty);
      expect(keys.toString(), isNot(contains(k)));
      expect(keys.toString(), isNot(contains(keys.symmetricKeyJwk)));
      expect(keys.toString(), contains('AccountKeys'));
    });

    test('AccountKeys hides private components of both key pairs', () async {
      final keys = await KeyGen.generateAccountKeys();

      for (final duo in [keys.ultimateKey, keys.deviceKey]) {
        final jwk = await const KeyDuoSerializer().exportKeyDuoJwk(duo);
        final entries =
            (jsonDecode(jwk) as Map<String, dynamic>)['keys'] as List<dynamic>;
        for (final key in entries.cast<Map<String, dynamic>>()) {
          final d = key['d'] as String?;
          if (d == null) continue;
          expect(keys.toString(), isNot(contains(d)),
              reason: 'a private key component reached toString');
        }
      }
    });

    test('CreatedGroup hides the group data key and the member key', () async {
      final dataKey = await AesGcmSecretKey.generateKey(256);
      final raw = base64Url.encode(await dataKey.exportRawKey());
      final memberKey = await KeyGen.generateDeviceKey();
      final memberJwk =
          await const KeyDuoSerializer().exportKeyDuoJwk(memberKey);

      final created = CreatedGroup(
        groupId: 'g',
        displayName: 'g',
        groupDataKey: dataKey,
        memberKey: memberKey,
        createdAt: DateTime.utc(2026, 8, 2),
      );

      expect(created.toString(), isNot(contains(raw.replaceAll('=', ''))));
      final memberEntries = (jsonDecode(memberJwk) as Map<String, dynamic>)
          ['keys'] as List<dynamic>;
      for (final key in memberEntries.cast<Map<String, dynamic>>()) {
        final d = key['d'] as String?;
        if (d == null) continue;
        expect(created.toString(), isNot(contains(d)));
      }
    });
  });

  group('structural guard', () {
    // A model gaining a raw secret field is how this happens again. Names
    // that have meant "raw secret material" in this SDK so far.
    const secretish = ['symmetricKey', 'privateKey', 'secret', 'seed'];

    test('a model holding a raw secret field defines its own toString', () {
      final offenders = <String>[];

      for (final file in Directory('lib/src/models')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.endsWith('.freezed.dart'))
          .where((f) => !f.path.endsWith('.g.dart'))) {
        final text = file.readAsStringSync();

        final holdsSecret = secretish.any(
          (needle) => RegExp('(required |final )[A-Za-z<>?]+ *\\w*$needle\\w*',
                  caseSensitive: false)
              .hasMatch(text),
        );
        if (!holdsSecret) continue;

        if (!text.contains('String toString()')) {
          offenders.add(file.path);
        }
      }

      expect(offenders, isEmpty,
          reason: 'These hold raw secret material and inherit a generated '
              'toString that prints every field:\n${offenders.join('\n')}');
    });

    test('the guard actually detects a model that holds a secret', () {
      // A guard that matches nothing passes forever. account_keys.dart holds
      // symmetricKeyJwk, so it must be in the set the guard examines.
      final text =
          File('lib/src/models/account_keys.dart').readAsStringSync();
      expect(
        RegExp('(required |final )[A-Za-z<>?]+ *\\w*symmetricKey\\w*',
                caseSensitive: false)
            .hasMatch(text),
        isTrue,
        reason: 'the secret-field pattern no longer matches a known secret '
            'field — the structural guard has gone blind',
      );
    });
  });
}
