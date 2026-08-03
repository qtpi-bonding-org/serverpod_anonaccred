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

    test('CreatedGroup hides the group data key', () async {
      final dataKey = await AesGcmSecretKey.generateKey(256);
      final raw = base64Url.encode(await dataKey.exportRawKey());

      final created = CreatedGroup(
        groupId: 'g',
        displayName: 'g',
        groupDataKey: dataKey,
        createdAt: DateTime.utc(2026, 8, 2),
      );

      expect(created.toString(), isNot(contains(raw.replaceAll('=', ''))));
    });
  });

  group('structural guard', () {
    // Field names that have meant raw secret material in this SDK.
    const secretish = [
      'symmetricKey',
      'privateKey',
      'secret',
      'seed',
      'KeyJwk',
    ];

    bool holdsSecret(String text) => secretish.any((needle) =>
        RegExp('(required |final )[A-Za-z<>?]+ *\\w*$needle\\w*',
                caseSensitive: false)
            .hasMatch(text));

    Iterable<File> sourceFiles() => Directory('lib/src')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.endsWith('.freezed.dart'))
        .where((f) => !f.path.endsWith('.g.dart'));

    test('a codegen class holding secret material defines its own toString',
        () {
      // Only codegen-annotated classes are at risk: a plain class inherits
      // Object.toString, which prints no fields.
      final offenders = <String>[];

      for (final file in sourceFiles()) {
        final text = file.readAsStringSync();
        final generated =
            text.contains('@freezed') || text.contains('@JsonSerializable');
        if (!generated || !holdsSecret(text)) continue;
        if (!text.contains('String toString()')) offenders.add(file.path);
      }

      expect(offenders, isEmpty,
          reason: 'These hold secret material and inherit a generated '
              'toString that prints every field:\n${offenders.join('\n')}');
    });

    test('nothing holding secret material is JSON-serializable', () {
      // toJson is the worse half of this: toString leaks to logs, toJson
      // leaks to whatever the caller transmits or persists.
      final offenders = <String>[];

      for (final file in sourceFiles()) {
        final text = file.readAsStringSync();
        if (!holdsSecret(text)) continue;
        if (text.contains('@JsonSerializable') ||
            text.contains('fromJson(Map<String, dynamic>')) {
          offenders.add(file.path);
        }
      }

      expect(offenders, isEmpty,
          reason: 'Secret material must not have a JSON encoding:\n'
              '${offenders.join('\n')}');
    });

    test('the guard actually detects a model that holds a secret', () {
      // A guard that matches nothing passes forever.
      expect(
        holdsSecret(File('lib/src/models/account_keys.dart').readAsStringSync()),
        isTrue,
        reason: 'the secret-field pattern no longer matches a known secret '
            'field \u2014 the structural guard has gone blind',
      );
    });

    test('the guard scans more than the models directory', () {
      // in_memory_account_key_store.dart holds raw key material and lives
      // outside lib/src/models; a scan that misses it is scoped too narrowly.
      expect(
        sourceFiles().map((f) => f.path),
        contains(contains('in_memory_account_key_store.dart')),
      );
    });
  });
}
