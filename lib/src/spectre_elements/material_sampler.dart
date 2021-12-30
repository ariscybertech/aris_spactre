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

library spectre_material_sampler_element;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_declarative.dart';
import 'package:spectre/spectre_elements.dart';

@CustomTag('s-material-sampler')
class SpectreMaterialSamplerElement extends SpectreElement {
  @published String textureId = '';
  @published String name = '';
  @published String addressU = 'TextureAddressMode.Wrap';
  @published String addressV = 'TextureAddressMode.Wrap';
  @published String minFilter = 'TextureMinFilter.PointMipLinear';
  @published String magFilter = 'TextureMagFilter.Linear';
  @published SpectreTextureElement texture;
  SamplerState _sampler;
  SamplerState get sampler => _sampler;

  SpectreMaterialSamplerElement.created() : super.created() {
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
    _sampler = new SamplerState('SpectreMaterialConstantElement',
                                declarativeInstance.graphicsDevice);
    _updateSampler();
    _updateTexture();
  }

  void _updateSampler() {
    _sampler.addressU = TextureAddressMode.parse(addressU);
    _sampler.addressV = TextureAddressMode.parse(addressV);
    _sampler.minFilter = TextureMinFilter.parse(minFilter);
    _sampler.magFilter = TextureMagFilter.parse(magFilter);
  }

  void _updateTexture() {
    texture = ownerDocument.querySelector(textureId);
    if (texture != null) {
      texture.init();
    }
  }

  void apply() {
    var currentMaterial = declarativeInstance.root.currentMaterial;
    if (currentMaterial == null) {
      return;
    }
    var sampler = currentMaterial.materialProgram.program.samplers[name];
    if (sampler != null && texture != null) {
      _applySampler(sampler);
    }
  }

  void _applySampler(ShaderProgramSampler sampler) {
    var graphicsContext = declarativeInstance.graphicsContext;
    graphicsContext.setTexture(sampler.textureUnit, texture.texture);
    graphicsContext.setSampler(sampler.textureUnit, _sampler);
  }
}
