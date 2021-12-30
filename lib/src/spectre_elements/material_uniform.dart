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

library spectre_material_uniform_element;

import 'dart:typed_data';

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre_declarative.dart';
import 'package:spectre/spectre_elements.dart';

@CustomTag('s-material-uniform')
class SpectreMaterialUniformElement extends SpectreElement {
  @published String name = '';
  @published List value = toObservable([]);
  static final Float32List _value = new Float32List(16);
  SpectreMaterialUniformElement.created() : super.created() {
    init();
  }

  void valueChanged(oldValue) {
    _updateValue();
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
    _updateValue();
  }

  void _updateValue() {
    int length = value.length > _value.length ? _value.length : value.length;
    for (int i = 0; i < length; i++) {
      _value[i] = value[i];
    }
  }

  void apply() {
    var currentMaterial = declarativeInstance.root.currentMaterial;
    if (currentMaterial == null) {
      return;
    }
    var graphicsContext = declarativeInstance.graphicsContext;
    graphicsContext.setConstant(name, value);
  }
}
