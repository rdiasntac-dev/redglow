import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dump resolved lockfile', () {
    final encoded = base64Encode(File('pubspec.lock').readAsBytesSync());
    // Used only on the temporary dependency-resolution branch.
    // ignore: avoid_print
    print('LOCKFILE_BASE64:$encoded');
  });
}
