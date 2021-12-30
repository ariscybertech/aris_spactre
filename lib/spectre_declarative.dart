/*
  Copyright (C) 2013 John McCutchan

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

library spectre_declarative;

import 'dart:html';
import 'dart:async';

import 'package:asset_pack/asset_pack.dart';
import 'package:game_loop/game_loop_html.dart';
import 'package:logging/logging.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_example_ui.dart';
import 'package:spectre/spectre_elements.dart';

part 'src/spectre_declarative/declarative_instance.dart';
part 'src/spectre_declarative/example.dart';

Future startup(String backBufferId, String sceneId) {
  var spectre = querySelector('#spectre');
  var canvas = spectre.canvas;
  var example = new DeclarativeExample(canvas, sceneId);
  example.gameLoop.pointerLock.lockOnClick = true;
  SpectreElement.log.level = Level.ALL;
  return example.initialize()
      .then((_) => example.load())
      .then((_) => example.start())
      .catchError((e) {
        print('Could not run ${example.name}: $e');
        print(e.stackTrace);
        window.alert('Could not run ${example.name}: $e. See console.');
      });
}
