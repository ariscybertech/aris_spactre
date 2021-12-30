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

library spectre_mesh_element;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_declarative.dart';
import 'package:spectre/spectre_elements.dart';

@CustomTag('s-mesh')
class SpectreMeshElement extends SpectreElement {
  @published String geometryId = '';
  @published String materialId = '';

  SpectreGeometryElement geometry;
  SpectreMaterialElement material;

  void geometryIdChanged(oldValue) {
    if (!inited) {
      return;
    }
    geometry = ownerDocument.querySelector(geometryId);
    if (geometry != null) {
      geometry.init();
      _inputLayout.mesh = geometry.mesh;
    } else {
      _inputLayout.mesh = null;
    }
  }

  void materialIdChanged(oldValue) {
    if (!inited) {
      return;
    }
    material = ownerDocument.querySelector(materialId);
    if (material != null && material.materialProgram != null) {
      material.init();
      _inputLayout.shaderProgram = material.materialProgram.program;
    } else {
      _inputLayout.shaderProgram = null;
    }
  }

  InputLayout _inputLayout;

  SpectreMeshElement.created() : super.created() {
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
    _inputLayout = new InputLayout('SpectreMeshElement',
                                   declarativeInstance.graphicsDevice);
    geometryIdChanged('');
    materialIdChanged('');
  }

  void render() {
    super.render();
    if (!_inputLayout.ready || (_inputLayout.attributes.length == 0)) {
      // TODO(johnmccutchan): Send event when material or geometry change.
      geometryIdChanged('');
      materialIdChanged('');
    }
    if (!_inputLayout.ready || (_inputLayout.attributes.length == 0)) {
      print('Unnable to render $id because input layout is bad.');
      return;
    }
    var spectre = declarativeInstance.root;
    spectre.pushMaterial(material);
    // Render self.
    var graphicsContext = declarativeInstance.graphicsContext;
    graphicsContext.setInputLayout(_inputLayout);
    _updateObjectTransformConstant(declarativeInstance.root.currentTransform);
    if (geometry.indexed) {
      graphicsContext.setIndexedMesh(geometry.mesh);
      graphicsContext.drawIndexedMesh(geometry.mesh);
    } else {
      graphicsContext.setMesh(geometry.mesh);
      graphicsContext.drawMesh(geometry.mesh);
    }
    spectre.popMaterial();
  }

  void _updateObjectTransformConstant(Matrix4 T) {
    var graphicsContext = declarativeInstance.graphicsContext;
    ShaderProgram shader = graphicsContext.shaderProgram;
    ShaderProgramUniform uniform;
    uniform = shader.uniforms['objectTransform'];
    if (uniform != null) {
      shader.updateUniform(uniform, T.storage);
    }
  }
}
