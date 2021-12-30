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

library spectre_geometry_element;

import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_declarative.dart';
import 'spectre_element.dart';

@CustomTag('s-geometry')
class SpectreGeometryElement extends SpectreElement {
  @published String src = '';
  SingleArrayIndexedMesh mesh;

  bool get indexed => (mesh is SingleArrayIndexedMesh);

  void srcChanged(oldValue) {
    init();
    if (!inited) {
      return;
    }
    _load();
  }

  void _load() {
    assert(inited);
    HttpRequest.getString(src).then((r) {
      var json = JSON.decode(r);
      _updateBuffers(json);
      _updateAttributes(json);
    }).catchError((e) {
      SpectreElement.log.shout('Failed to load geometry from $src');
    });
  }

  void _updateBuffers(Map json) {
    var vertexArray = new Float32List.fromList(json['vertices']);
    var indexArray = new Uint16List.fromList(json['indices']);
    mesh.vertexArray.uploadData(vertexArray, UsagePattern.StaticDraw);
    mesh.indexArray.uploadData(indexArray, UsagePattern.StaticDraw);
    mesh.count = indexArray.length;
  }

  void _updateAttributes(Map json) {
    List attributes = json['attributes'];
    attributes.forEach((v) {
      String name = v['name'];
      int offset = v['offset'];
      int stride = v['stride'];
      int count = 1;
      switch (v['format']) {
        case 'float2': count = 2; break;
        case 'float3': count = 3; break;
        case 'float4': count = 4; break;
      }
      SpectreMeshAttribute attribute = new SpectreMeshAttribute(
          name,
          new VertexAttribute(0, 0, offset, stride, DataType.Float32, count,
                              false));
      mesh.attributes[name] = attribute;
    });
  }

  SpectreGeometryElement.created() : super.created() {
    init();
  }

  void init() {
    if (inited) {
      // Already initialized.
      return;
    }
    if (!declarativeInstance.inited) {
      // Not ready to initialize.
      return;
    }
    // Initialize.
    super.init();
    _create();
    _load();
  }

  void _create() {
    assert(inited);
    var device = declarativeInstance.graphicsDevice;
    mesh = new SingleArrayIndexedMesh('SpectreGeometryElement', device);
    SpectreElement.log.info('Created SingleArrayIndexedMesh for $id');
  }

  void _destroy() {
    if (mesh != null) {
      mesh.dispose();
      mesh = null;
    }
  }
}
