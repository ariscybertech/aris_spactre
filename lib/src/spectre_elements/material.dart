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

library spectre_material_element;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_declarative.dart';
import 'package:spectre/spectre_elements.dart';

@CustomTag('s-material')
class SpectreMaterialElement extends SpectreElement {
  @published String materialProgramId = '';
  SpectreMaterialProgramElement materialProgram;

  final DepthState depthState = new DepthState();
  final RasterizerState rasterizerState = new RasterizerState();
  final BlendState blendState = new BlendState.alphaBlend();
  final Map<String, List<SpectreMaterialSamplerElement>> _samplerStack = new
      Map<String, List<SpectreMaterialSamplerElement>>();
  final Map<String, List<SpectreMaterialStateElement>> _stateStack = new
      Map<String, List<SpectreMaterialStateElement>>();

  SpectreMaterialElement.created() : super.created() {
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
    materialProgramIdChanged('');
  }

  void apply() {
    var graphicsContext = declarativeInstance.graphicsContext;
    if (materialProgram != null) {
      graphicsContext.setShaderProgram(materialProgram.program);
    } else {
      graphicsContext.setShaderProgram(null);
    }
    graphicsContext.setDepthState(depthState);
    graphicsContext.setRasterizerState(rasterizerState);
    graphicsContext.setBlendState(blendState);
  }

  void applyState(SpectreMaterialStateElement state,
                  bool updateStack) {
    String name = state.name;
    if (name == null) {
      return;
    }
    var old = state.apply();
    if (updateStack) {
      var l = _stateStack[name];
      if (l == null) {
        l = new List<SpectreMaterialStateElement>();
        _stateStack[name] = l;
      }
      if (l.length == 0 && old != null) {
        SpectreMaterialStateElement reset =
            ownerDocument.createElement('S-MATERIAL-STATE');
        reset.init();
        reset.name = name;
        reset.parsedValue = old;
        l.add(reset);
      }
      l.add(state);
    }
  }

  void unapplyState(SpectreMaterialStateElement state) {
    String name = state.name;
    if (name == null) {
      return;
    }
    var stack = _stateStack[name];
    assert(stack != null);
    assert(stack.length > 0);
    assert(state.name == stack.last.name);
    stack.removeLast();
    if (stack.length == 0) {
      return;
    }
    var o = stack.last;
    if (o != null) {
      // Set to old value, do not update stack.
      applyState(o, false);
    }
  }

  void applyStates() {
    var spectre = declarativeInstance.root;
    var l = findAllTagChildren('S-MATERIAL-STATE');
    l.forEach((e) {
      applyState(e, true);
    });
  }

  void unapplyStates() {
    var l = findAllTagChildren('S-MATERIAL-STATE').reversed;
    l.forEach((e) {
      unapplyState(e);
    });
  }

  void applySampler(SpectreMaterialSamplerElement sampler, bool updateStack) {
    String name = sampler.name;
    if (name == null) {
      return;
    }
    var old = sampler.apply();
    if (updateStack) {
      var l = _samplerStack[name];
      if (l == null) {
        l = new List<SpectreMaterialSamplerElement>();
        _samplerStack[name] = l;
      }
      if (l.length == 0 && old != null) {
        var samplerElement = ownerDocument.createElement('S-MATERIAL-SAMPLER');
        samplerElement.init();
        samplerElement.name = name;
        l.add(samplerElement);
      }
      l.add(sampler);
    }
  }

  void unapplySampler(SpectreMaterialSamplerElement sampler) {
    String name = sampler.name;
    if (name == null) {
      return;
    }
    var stack = _samplerStack[name];
    assert(stack != null);
    assert(stack.length > 0);
    assert(sampler.name == stack.last.name);
    stack.removeLast();
    if (stack.length == 0) {
      return;
    }
    var o = stack.last;
    if (o != null) {
      // Set to old value, do not update stack.
      applySampler(o, false);
    }
  }

  void applySamplers() {
    var spectre = declarativeInstance.root;
    var l = findAllTagChildren('S-MATERIAL-SAMPLER');
    // Apply all constants, update stack.
    l.forEach((e) {
      applySampler(e, true);
    });
  }

  void unapplySamplers() {
    var l = findAllTagChildren('S-MATERIAL-SAMPLER').reversed;
    // Apply all constants, update stack.
    l.forEach((e) {
      unapplySampler(e);
    });
  }

  void applyUniform(SpectreMaterialUniformElement e, bool updateStack) {
    e.apply();
  }

  void unapplyUniform(SpectreMaterialUniformElement e) {
  }

  void applyUniforms() {
    var spectre = declarativeInstance.root;
    _updateCameraConstants(spectre.currentCamera);
    var l = findAllTagChildren('S-MATERIAL-UNIFORM');
    l.forEach((SpectreMaterialUniformElement e) {
      applyUniform(e, true);
    });
  }

  void unapplyUniforms() {
    var l = findAllTagChildren('S-MATERIAL-UNIFORM').reversed;
    l.forEach((SpectreMaterialUniformElement e) {
      unapplyUniform(e);
    });
  }

  void _updateCameraConstants(Camera camera) {
    var graphicsContext = declarativeInstance.graphicsContext;
    Matrix4 projectionMatrix = camera.projectionMatrix;
    Matrix4 viewMatrix = camera.viewMatrix;
    Matrix4 projectionViewMatrix = camera.projectionMatrix;
    projectionViewMatrix.multiply(viewMatrix);
    Matrix4 viewRotationMatrix = makeViewMatrix(new Vector3.zero(),
                                             camera.frontDirection,
                                             new Vector3(0.0, 1.0, 0.0));
    Matrix4 projectionViewRotationMatrix = camera.projectionMatrix;
    projectionViewRotationMatrix.multiply(viewRotationMatrix);
    ShaderProgram shader = graphicsContext.shaderProgram;
    ShaderProgramUniform uniform;
    uniform = shader.uniforms['cameraView'];
    if (uniform != null) {
      shader.updateUniform(uniform, viewMatrix.storage);
    }
    uniform = shader.uniforms['cameraProjection'];
    if (uniform != null) {
      shader.updateUniform(uniform, projectionMatrix.storage);
    }
    uniform = shader.uniforms['cameraProjectionView'];
    if (uniform != null) {
      shader.updateUniform(uniform, projectionViewMatrix.storage);
    }
    uniform = shader.uniforms['cameraViewRotation'];
    if (uniform != null) {
      shader.updateUniform(uniform, viewRotationMatrix.storage);
    }
    uniform = shader.uniforms['cameraProjectionViewRotation'];
    if (uniform != null) {
      shader.updateUniform(uniform, projectionViewRotationMatrix.storage);
    }
  }

  void materialProgramIdChanged(oldValue) {
    materialProgram = ownerDocument.querySelector(materialProgramId);
  }
}
