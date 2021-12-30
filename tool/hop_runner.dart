library hop_runner;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import '../test/test_dump_render_tree.dart' as test_runner;

void main(List<String> args) {
  //
  // Analyzer
  //
  addTask('analyze_lib', createAnalyzerTask(_getLibs));
  addTask('analyze_test', createAnalyzerTask(['test/test_runner.dart']));

  addTask('docs', createDartDocTask(_getLibs));

  addTask('test', createUnitTestTask(test_runner.testCore));

  runHop(args);
}

Future<List<String>> _getLibs() {
  return new Directory('lib').list()
      .where((FileSystemEntity fse) => fse is File)
      .map((File file) => file.path)
      .toList();
}
