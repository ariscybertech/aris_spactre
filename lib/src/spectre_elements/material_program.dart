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

library spectre_material_program_element;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_declarative.dart';
import 'package:spectre/spectre_elements.dart';

@CustomTag('s-material-program')
class SpectreMaterialProgramElement extends SpectreElement {
  @published String vertexShaderId = '';
  @published String fragmentShaderId = '';

  SpectreVertexShaderElement _vertexShader;
  SpectreVertexShaderElement get vertexShader => _vertexShader;

  SpectreFragmentShaderElement _fragmentShader;
  SpectreFragmentShaderElement get fragmentShader => _fragmentShader;

  ShaderProgram _program;
  ShaderProgram get program => _program;

  SpectreMaterialProgramElement.created() : super.created() {
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
    _findVertexShader();
    _findFragmentShader();
    _linkShaders();
  }

  void _create() {
    assert(inited);
    var device = declarativeInstance.graphicsDevice;
    _program = new ShaderProgram('SpectreMaterialProgramElement', device);
    SpectreElement.log.info('Created ShaderProgram for $id');
  }

  void _findVertexShader() {
    _vertexShader = null;
    String id = vertexShaderId;
    try {
      _vertexShader = ownerDocument.querySelector(id);
    } catch (_) {}
    if (_vertexShader == null) {
      _vertexShader = querySelector('s-vertex-shader');
    }
    if (_vertexShader != null) {
      _vertexShader.init();
    }
  }

  void _findFragmentShader() {
    _fragmentShader = null;
    String id = fragmentShaderId;
    try {
      _fragmentShader = ownerDocument.querySelector(id);
    } catch (_) {}
    if (_fragmentShader == null) {
      _fragmentShader = querySelector('s-fragment-shader');
    }
    if (_fragmentShader != null) {
      _fragmentShader.init();
    }
  }

  void _linkShaders() {
    assert(inited);
    _program.vertexShader = _vertexShader != null ?
        _vertexShader.shader : null;
    _program.fragmentShader = _fragmentShader != null ?
        _fragmentShader.shader : null;
    _program.link();
    SpectreElement.log.info('ShaderProgram $id linked ${_program.linked}');
    if (!_program.linked) {
      SpectreElement.log.info('link log: ${_program.linkLog}');
    }
  }

  void _destroy() {
    assert(inited);
    _program.dispose();
  }
}
