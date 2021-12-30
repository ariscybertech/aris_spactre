/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

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

library spectre_renderer;

import 'dart:html';
import 'dart:async';
import 'dart:typed_data';

import 'package:asset_pack/asset_pack.dart';
import 'package:logging/logging.dart';
import 'package:spectre/disposable.dart';
import 'package:spectre/spectre.dart';

part 'src/spectre_renderer/asset_pack.dart';
part 'src/spectre_renderer/builtin_material_shaders.dart';
part 'src/spectre_renderer/debugdraw_layer.dart';
part 'src/spectre_renderer/fullscreen_layer.dart';
part 'src/spectre_renderer/layer.dart';
part 'src/spectre_renderer/light.dart';
part 'src/spectre_renderer/material.dart';
part 'src/spectre_renderer/material_constant.dart';
part 'src/spectre_renderer/material_shader.dart';
part 'src/spectre_renderer/material_texture.dart';
part 'src/spectre_renderer/mesh_renderable.dart';
part 'src/spectre_renderer/renderable.dart';
part 'src/spectre_renderer/renderer.dart';
part 'src/spectre_renderer/scene_layer.dart';
part 'src/spectre_renderer/skybox_renderable.dart';

// The global logger for spectre
final Logger _spectreLog = new Logger('Spectre Renderer');
