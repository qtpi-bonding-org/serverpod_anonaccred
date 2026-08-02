import 'dart:io';
import 'package:test/test.dart';

/// A wrapped copy of a rotatable secret is useless without knowing which
/// generation it holds. This scans the model definitions rather than the
/// generated code, so it fails at the source of truth.
void main() {
  test('every model with a wrapped-copy field declares keyEpoch', () {
    final missing = <String>[];

    for (final file in Directory('lib/src/models')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.spy.yaml'))) {
      final text = file.readAsStringSync();
      if (!text.contains('table:')) continue;

      final holdsWrappedCopy = RegExp(r'^\s{2}encrypted\w*Key:', multiLine: true)
          .hasMatch(text);
      if (!holdsWrappedCopy) continue;

      if (!RegExp(r'^\s{2}keyEpoch:', multiLine: true).hasMatch(text)) {
        missing.add(file.path);
      }
    }

    expect(missing, isEmpty,
        reason: 'These tables hold a wrapped copy but do not record its '
            'generation:\n${missing.join('\n')}');
  });
}
