import 'dart:io';

import 'package:test/test.dart';

// Runs with cwd = anonaccount_sdk (dart test's default).
void main() {
  test('the SDK neither depends on nor imports webcrypto', () {
    final offenders = <String>[
      if (File('pubspec.yaml').readAsStringSync().contains('webcrypto'))
        'pubspec.yaml',
      for (final f in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')))
        if (f.readAsStringSync().contains('webcrypto')) f.path,
    ];
    expect(offenders, isEmpty);
  });
}