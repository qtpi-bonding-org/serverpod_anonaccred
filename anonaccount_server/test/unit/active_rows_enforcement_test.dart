import 'dart:io';
import 'package:test/test.dart';

/// The isRevoked filter is written once, in active_rows.dart. A direct
/// .db.find on a soft-deleted table silently returns revoked rows once the
/// unique indexes go partial.
void main() {
  const softDeleted = [
    'AccountDevice',
    'GroupMember',
    'GroupMemberDevice',
    'GroupOwner',
  ];
  const allowed = 'lib/src/queries/active_rows.dart';

  test('no direct reads of soft-deleted tables outside active_rows.dart', () {
    final offenders = <String>[];

    for (final file in Directory('lib/src')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.contains('/generated/'))
        .where((f) => !f.path.endsWith('active_rows.dart'))) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final model in softDeleted) {
          if (lines[i].contains('$model.db.find')) {
            offenders.add('${file.path}:${i + 1}  ${lines[i].trim()}');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Read these through ActiveRows or AllRows in $allowed:\n'
          '${offenders.join('\n')}',
    );
  });
}
