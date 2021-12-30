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

library spectre_spectre_element;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_declarative.dart';
import 'package:spectre/spectre_elements.dart';

@CustomTag('s-spectre')
class SpectreSpectreElement extends SpectreElement {
  final Matrix4 I = new Matrix4.identity();
  final Camera C = new Camera();
  final List<Matrix4> _transformStack = new List<Matrix4>();
  final List<Camera> _cameraStack = new List<Camera>();
  final List<SpectreMaterialElement> _materialStack =
      new List<SpectreMaterialElement>();

  void toggleFullscreen(Event e, var detail, Node target) {
    declarativeInstance.example.toggleFullscreen();
  }

  SpectreSpectreElement.created() : super.created() {
    init();
    ButtonElement b = shadowRoot.querySelector('#fsbutton');
    b.onClick.listen((E) => toggleFullscreen(E, '', b));
  }

  CanvasElement get canvas {
    var canvas = $['backBuffer'];
    return canvas;
  }

  void ready() {
    super.ready();

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
  }

  update() {
    super.update();
    updateChildren();
  }

  render() {
    super.render();
    renderChildren();
  }

  void _applyMaterial(SpectreMaterialElement material) {
    if (material == null) {
      return;
    }
    var graphicsContext = declarativeInstance.graphicsContext;
    var shaderProgram = material.materialProgram.program;
    if (shaderProgram != null) {
      graphicsContext.setShaderProgram(shaderProgram);
      graphicsContext.setDepthState(material.depthState);
      graphicsContext.setRasterizerState(material.rasterizerState);
      graphicsContext.setBlendState(material.blendState);
    }
  }

  void pushMaterial(SpectreMaterialElement material) {
    _materialStack.add(material);
    material.apply();
    material.applyStates();
    material.applySamplers();
    material.applyUniforms();
  }

  void popMaterial() {
    assert(_materialStack.length > 0);
    // Cleanup.
    var previous = _materialStack.last;
    previous.unapplyUniforms();
    previous.unapplySamplers();
    previous.unapplyStates();
    // Pop.
    _materialStack.removeLast();
    if (_materialStack.length == 0) {
      return;
    }
    // Reapply previous material.
    var m = _materialStack.last;
    m.apply();
  }

  SpectreMaterialElement get currentMaterial {
    if (_materialStack.length == 0) {
      // TODO(johnmccutchan): Provide a default material.
      return null;
    }
    return _materialStack.last;
  }

  void pushCamera(Camera C) {
    _cameraStack.add(C);
  }

  void popCamera() {
    assert(_cameraStack.length > 0);
    _cameraStack.removeLast();
  }

  Camera get currentCamera {
    if (_cameraStack.length == 0) {
      return C;
    }
    return _cameraStack.last;
  }

  void pushTransform(Matrix4 M) {
    var T;
    if (_transformStack.length == 0) {
      T = M.clone();
    } else {
      var currentTransform = _transformStack.last;
      T = currentTransform * M;
    }
    _transformStack.add(T);
  }

  void popTransform() {
    assert(_transformStack.length > 0);
    _transformStack.removeLast();
  }

  Matrix4 get currentTransform {
    if (_transformStack.length == 0) {
      return I;
    }
    var currentTransform = _transformStack.last;
    return currentTransform;
  }
}
