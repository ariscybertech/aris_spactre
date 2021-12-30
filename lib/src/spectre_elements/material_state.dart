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

library spectre_material_state_element;

import 'dart:convert';

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_declarative.dart';
import 'package:spectre/spectre_elements.dart';

@CustomTag('s-material-state')
class SpectreMaterialStateElement extends SpectreElement {
  @published String name = '';
  @published String value = '';
  var parsedValue;

  SpectreMaterialStateElement.created() : super.created() {
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
    _update();
  }

  dynamic apply() {
    _update();
    if (_isRasterizerConstant(name)) {
      return _applyRasterizerConstant(name);
    } else if (_isDepthConstant(name)) {
      return _applyDepthConstant(name);
    } else if (_isBlendConstant(name)) {
      return _applyBlendConstant(name);
    }
  }

  void _update() {
    assert(inited);
    if (name == null) {
      name = attributes['name'];
    }
    if (name == null) {
      return;
    }
    var currentMaterial = declarativeInstance.root.currentMaterial;
    if (currentMaterial == null) {
      return;
    }
    if (_isRasterizerConstant(name)) {
      _updateRasterizerConstant(name);
    } else if (_isDepthConstant(name)) {
      _updateDepthConstant(name);
    } else if (_isBlendConstant(name)) {
      _updateBlendConstant(name);
    }
  }


  dynamic _applyRasterizerConstant(String name) {
    assert(inited);
    assert(_isRasterizerConstant(name));
    if (parsedValue == null) {
      // No value set.
      return null;
    }
    var currentMaterial = declarativeInstance.root.currentMaterial;
    if (currentMaterial == null) {
      return null;
    }
    var graphicsContext = declarativeInstance.graphicsContext;
    var old;
    switch (name) {
      case 'cullMode':
        old = currentMaterial.rasterizerState.cullMode;
        currentMaterial.rasterizerState.cullMode = parsedValue;
        break;
      case 'frontFace':
        old = currentMaterial.rasterizerState.frontFace;
        currentMaterial.rasterizerState.frontFace = parsedValue;
        break;
      case 'depthBias':
        old = currentMaterial.rasterizerState.depthBias;
        currentMaterial.rasterizerState.depthBias = parsedValue;
        break;
      case 'slopeScaleDepthBias':
        old = currentMaterial.rasterizerState.slopeScaleDepthBias;
        currentMaterial.rasterizerState.slopeScaleDepthBias = parsedValue;
        break;
      case 'scissorTestEnabled':
        old = currentMaterial.rasterizerState.scissorTestEnabled;
        currentMaterial.rasterizerState.scissorTestEnabled = parsedValue;
        break;
    }
    graphicsContext.setRasterizerState(currentMaterial.rasterizerState);
    return old;
  }

  void _updateRasterizerConstant(String name) {
    assert(inited);
    assert(_isRasterizerConstant(name));
    switch (name) {
      case 'cullMode':
        parsedValue = CullMode.parse(value);
        break;
      case 'frontFace':
        parsedValue = FrontFace.parse(value);
        break;
      case 'depthBias':
      case 'slopeScaleDepthBias':
        parsedValue = parseDouble(value, 0.0);
        break;
      case 'scissorTestEnabled':
        parsedValue = parseBool(value, false);
        break;
    }
  }

  dynamic _applyDepthConstant(String name) {
    assert(inited);
    assert(_isDepthConstant(name));
    if (parsedValue == null) {
      // No value set.
      return null;
    }
    var currentMaterial = declarativeInstance.root.currentMaterial;
    if (currentMaterial == null) {
      return null;
    }
    var graphicsContext = declarativeInstance.graphicsContext;
    var old;
    switch (name) {
      case 'depthBufferEnabled':
        old = currentMaterial.depthState.depthBufferEnabled;
        currentMaterial.depthState.depthBufferEnabled = parsedValue;
        break;
      case 'depthBufferWriteEnabled':
        old = currentMaterial.depthState.depthBufferWriteEnabled;
        currentMaterial.depthState.depthBufferWriteEnabled = parsedValue;
        break;
      case 'depthBufferFunction':
        old = currentMaterial.depthState.depthBufferFunction;
        currentMaterial.depthState.depthBufferFunction = parsedValue;
        break;
    }
    graphicsContext.setDepthState(currentMaterial.depthState);
    return old;
  }

  void _updateDepthConstant(String name) {
    assert(inited);
    assert(_isDepthConstant(name));
    switch (name) {
      case 'depthBufferEnabled':
        parsedValue = parseBool(value, true);
        break;
      case 'depthBufferWriteEnabled':
        parsedValue = parseBool(value, true);
        break;
      case 'depthBufferFunction':
        parsedValue = CompareFunction.parse(value);
        break;
    }
  }

  dynamic _applyBlendConstant(String name) {
    assert(inited);
    assert(_isBlendConstant(name));
    if (parsedValue == null) {
      // No value set.
      return null;
    }
    var currentMaterial = declarativeInstance.root.currentMaterial;
    if (currentMaterial == null) {
      return null;
    }
    var graphicsContext = declarativeInstance.graphicsContext;
    var old;
    switch (name) {
      case 'enabled':
        old = currentMaterial.blendState.enabled;
        currentMaterial.blendState.enabled = parsedValue;
        break;
      case 'blendFactorRed':
        old = currentMaterial.blendState.blendFactorRed;
        currentMaterial.blendState.blendFactorRed = parsedValue;
        break;
      case 'blendFactorGreen':
        old = currentMaterial.blendState.blendFactorGreen;
        currentMaterial.blendState.blendFactorGreen = parsedValue;
        break;
      case 'blendFactorBlue':
        old = currentMaterial.blendState.blendFactorBlue;
        currentMaterial.blendState.blendFactorBlue = parsedValue;
        break;
      case 'blendFactorAlpha':
        old = currentMaterial.blendState.blendFactorAlpha;
        currentMaterial.blendState.blendFactorAlpha = parsedValue;
        break;
      case 'alphaBlendOperation':
        old = currentMaterial.blendState.alphaBlendOperation;
        currentMaterial.blendState.alphaBlendOperation = parsedValue;
        break;
      case 'alphaDestinationBlend':
        old = currentMaterial.blendState.alphaDestinationBlend;
        currentMaterial.blendState.alphaDestinationBlend = parsedValue;
        break;
      case 'alphaSourceBlend':
        old = currentMaterial.blendState.alphaSourceBlend;
        currentMaterial.blendState.alphaSourceBlend = parsedValue;
        break;
      case 'colorBlendOperation':
        old = currentMaterial.blendState.colorBlendOperation;
        currentMaterial.blendState.colorBlendOperation = parsedValue;
        break;
      case 'colorDestinationBlend':
        old = currentMaterial.blendState.colorDestinationBlend;
        currentMaterial.blendState.colorDestinationBlend = parsedValue;
        break;
      case 'colorSourceBlend':
        old = currentMaterial.blendState.colorSourceBlend;
        currentMaterial.blendState.colorSourceBlend = parsedValue;
        break;
      case 'writeRenderTargetRed':
        old = currentMaterial.blendState.writeRenderTargetRed;
        currentMaterial.blendState.writeRenderTargetRed = parsedValue;
        break;
      case 'writeRenderTargetGreen':
        old = currentMaterial.blendState.writeRenderTargetGreen;
        currentMaterial.blendState.writeRenderTargetGreen = parsedValue;
        break;
      case 'writeRenderTargetBlue':
        old = currentMaterial.blendState.writeRenderTargetBlue;
        currentMaterial.blendState.writeRenderTargetBlue = parsedValue;
        break;
      case 'writeRenderTargetAlpha':
        old = currentMaterial.blendState.writeRenderTargetAlpha;
        currentMaterial.blendState.writeRenderTargetAlpha = value;
        break;
    }
    graphicsContext.setBlendState(currentMaterial.blendState);
    return old;
  }

  void _updateBlendConstant(String name) {
    assert(inited);
    assert(_isBlendConstant(name));
    switch (name) {
      case 'enabled':
        parsedValue = parseBool('value', true);
        break;
      case 'blendFactorRed':
      case 'blendFactorGreen':
      case 'blendFactorBlue':
      case 'blendFactorAlpha':
        parsedValue = parseDouble('value', 1.0);
        break;
      case 'alphaBlendOperation':
        parsedValue = BlendOperation.parse(value);
        break;
      case 'alphaDestinationBlend':
        parsedValue = Blend.parse(value);
        break;
      case 'alphaSourceBlend':
        parsedValue = Blend.parse(value);
        break;
      case 'colorBlendOperation':
        parsedValue = BlendOperation.parse(value);
        break;
      case 'colorDestinationBlend':
        parsedValue = Blend.parse(value);
        break;
      case 'colorSourceBlend':
        parsedValue = Blend.parse(value);
        break;
      case 'writeRenderTargetRed':
      case 'writeRenderTargetGreen':
      case 'writeRenderTargetBlue':
      case 'writeRenderTargetAlpha':
        parsedValue = parseBool('value', true);
        break;
    }
  }

  static bool _isRasterizerConstant(String name) {
    List<String> rasterizerConstants = ['cullMode', 'frontFace', 'depthBias',
                                        'slopeScaleDepthBias',
                                        'scissorTestEnabled'];
    for (var i = 0; i < rasterizerConstants.length; i++) {
      if (name == rasterizerConstants[i]) {
        return true;
      }
    }
    return false;
  }

  static bool _isDepthConstant(String name) {
    List<String> depthConstants = ['depthBufferEnabled',
                                   'depthBufferWriteEnabled',
                                   'depthBufferFunction'];
    for (var i = 0; i < depthConstants.length; i++) {
      if (name == depthConstants[i]) {
        return true;
      }
    }
    return false;
  }

  static bool _isBlendConstant(String name) {
    List<String> blendConstant = ['enabled',
                                  'blendFactorRed',
                                  'blendFactorGreen',
                                  'blendFactorBlue',
                                  'blendFactorAlpha',
                                  'alphaBlendOperation',
                                  'alphaDestinationBlend',
                                  'alphaSourceBlend',
                                  'colorBlendOperation',
                                  'colorDestinationBlend',
                                  'colorSourceBlend',
                                  'writeRenderTargetRed',
                                  'writeRenderTargetGreen',
                                  'writeRenderTargetBlue',
                                  'writeRenderTargetAlpha'];
    for (var i = 0; i < blendConstant.length; i++) {
      if (name == blendConstant[i]) {
        return true;
      }
    }
    return false;
  }

  double parseDouble(String a, double d) {
    var l;
    try {
      l = double.parse(a);
    } catch (e) {
      return d;
    }
    return l;
  }

  bool parseBool(String a, bool b) {
    bool l;
    try {
      l = JSON.decode(a);
    } catch (e) {
      return b;
    }
    return l;
  }
}
