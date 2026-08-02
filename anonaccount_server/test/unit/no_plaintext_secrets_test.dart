import 'dart:io';

import 'package:test/test.dart';

/// The server holds ciphertext and public keys. Never plaintext key material.
///
/// A model field is the point where that stops being a convention: once a
/// column exists, it is persisted, serialized to every client that reads the
/// row, and printed by generated `toString`s. This scans the model
/// definitions, which is where such a field would first appear.
void main() {
  /// Field-name fragments that mean plaintext key material.
  ///
  /// `Jwk` is included because a JWK is a serialized key, and the private
  /// form is indistinguishable from the public one by field name alone.
  /// No server model has ever needed one.
  const forbidden = ['private', 'secret', 'seed', 'jwk', 'passphrase'];

  /// Field-name fragments that are safe and would otherwise trip the scan.
  const allowed = ['encrypted', 'publickey'];

  Iterable<File> modelFiles(String package) =>
      Directory('$package/lib/src/models')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.spy.yaml'));

  for (final package in ['.', '../anonaccred_server']) {
    test('no model in $package declares a plaintext secret field', () {
      final offenders = <String>[];

      for (final file in modelFiles(package)) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final match =
              RegExp(r'^\s{2}([a-zA-Z][a-zA-Z0-9]*):').firstMatch(lines[i]);
          if (match == null) continue;

          final field = match.group(1)!.toLowerCase();
          if (allowed.any(field.contains)) continue;
          if (forbidden.any(field.contains)) {
            offenders.add('${file.path}:${i + 1}  ${lines[i].trim()}');
          }
        }
      }

      expect(offenders, isEmpty,
          reason: 'Plaintext key material must not be a column. If one of '
              'these is genuinely ciphertext, name it `encrypted...`:\n'
              '${offenders.join('\n')}');
    });
  }

  test('the scan actually reads model files', () {
    // A scan pointed at an empty directory passes forever.
    expect(modelFiles('.').length, greaterThan(5));
    expect(modelFiles('../anonaccred_server').length, greaterThan(5));
  });

  test('the forbidden-name pattern would catch a plaintext key field', () {
    // Proves the matcher works, without adding a real offending column.
    const sample = '  ultimatePrivateKeyJwk: String';
    final field = RegExp(r'^\s{2}([a-zA-Z][a-zA-Z0-9]*):')
        .firstMatch(sample)!
        .group(1)!
        .toLowerCase();
    expect(forbidden.any(field.contains), isTrue);
  });
}
