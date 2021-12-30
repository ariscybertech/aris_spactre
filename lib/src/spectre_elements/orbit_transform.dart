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

library spectre_orbit_transform_element;

import 'dart:math' as Math;
import 'package:polymer/polymer.dart';
import 'package:spectre/spectre_declarative.dart';
import 'package:spectre/spectre_elements.dart';

@CustomTag('s-orbit-transform')
class SpectreOrbitTransformElement extends SpectreRenderableElement {
  @published double radius = 1.0;
  @published double height = 0.0;
  @published double period = 1.0;
  double _orbitAngle = 0.0;
  double _angle = 0.0;

  void radiusChanged(oldValue) {
    updateTransform();
  }

  void periodChanged(oldValue) {
    updateTransform();
  }

  SpectreOrbitTransformElement.created() : super.created();

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

  void pushTransform() {
    var spectre = declarativeInstance.root;
    spectre.pushTransform(transform);
  }

  void popTransform() {
    var spectre = declarativeInstance.root;
    spectre.popTransform();
  }

  double _calculateSpeed(double period) {
    if (period == 0.0) {
      return 0.0;
    } else {
      return 1 / (60.0 * 24.0 * 2 * period);
    }
  }

  update() {
    super.update();
    updateTransform();
    updateChildren();
  }

  render() {
    super.render();
    pushTransform();
    renderChildren();
    popTransform();
  }

  void updateTransform() {
    double speed = _calculateSpeed(period);
    _orbitAngle = declarativeInstance.time * speed;
    _angle += 0.002;
    double x = radius * Math.cos(_orbitAngle);
    double z = radius * Math.sin(_orbitAngle);
    transform.setIdentity();
    transform.rotateY(_angle);
    transform.translate(x, height, z);
  }
}
