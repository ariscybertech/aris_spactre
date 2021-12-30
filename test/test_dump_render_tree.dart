library test_dump_render_tree;

import 'package:bot_test/dump_render_tree.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

void main() {
  testCore(new VMConfiguration());
}

void testCore(Configuration config) {
  testDumpRenderTree(['test/test_runner.html']);
}
