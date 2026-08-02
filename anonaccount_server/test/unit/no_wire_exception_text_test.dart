import 'dart:io';

import 'package:test/test.dart';

/// Why the token and not the context: a context-sensitive pattern has to know
/// whether an `e.toString()` sits inside an exception constructor or a log
/// call, and `dart format` splits `message:` from its value across lines. Two
/// earlier drafts of this guard matched on one physical line and were blind to
/// exactly that shape. Banning the token outright cannot be evaded by
/// formatting, and after this refactor nothing in either package needs it:
/// `tryOperation` owns the wire text, and log calls interpolate `$e`.
void main() {
  Iterable<File> sourceFiles(String package) => Directory('$package/lib/src')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.contains('/generated/'));

  final banned = RegExp(r'\be\.toString\(\)');

  for (final package in ['.', '../anonaccred_server']) {
    test('$package contains no e.toString()', () {
      final offenders = <String>[];

      for (final file in sourceFiles(package)) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (banned.hasMatch(lines[i])) {
            offenders.add('${file.path}:${i + 1}  ${lines[i].trim()}');
          }
        }
      }

      expect(offenders, isEmpty,
          reason: 'Route the failure through tryOperation. For a log line, '
              r'interpolate $e instead:' '\n${offenders.join('\n')}');
    });
  }

  test('the scan reads both packages', () {
    // A scan pointed at an empty directory passes forever.
    expect(sourceFiles('.').length, greaterThan(10));
    expect(sourceFiles('../anonaccred_server').length, greaterThan(10));
  });

  test('the pattern catches a call split across lines by the formatter', () {
    // The shape that defeated the previous two drafts.
    const wrapped = "            'Failed to generate: \${e.toString()}',";
    expect(banned.hasMatch(wrapped), isTrue);
    expect(banned.hasMatch("      details: {'error': e.toString()},"), isTrue);
    expect(banned.hasMatch("      details: {'groupId': groupId.toString()},"),
        isFalse);
  });
}
