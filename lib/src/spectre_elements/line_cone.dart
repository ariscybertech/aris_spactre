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

library s_line_cone;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre_declarative.dart';
import 'package:spectre/spectre_elements.dart';
import 'package:vector_math/vector_math.dart';

@CustomTag('s-line-cone')
class SpectreLineConeElement extends SpectreLinePrimitiveElement {
  @published Vector3 apex = new Vector3.zero();
  @published Vector3 direction = new Vector3(1.0, 0.0, 0.0);
  @published double height = 1.0;
  @published double angle = 0.78;
  static final Vector3 _apex = new Vector3.zero();
  static final Vector3 _direction = new Vector3.zero();

  SpectreLineConeElement.created() : super.created() {
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
    update();
  }

  void render() {
    apex.copyInto(_apex);
    direction.copyInto(_direction);
    pushTransform();
    var transform = declarativeInstance.root.currentTransform;
    transform.transform3(_apex);
    transform.rotate3(_direction);
    popTransform();
    declarativeInstance.debugDrawManager.addCone(_apex, _direction, height,
                                                 angle, color);
  }

  void update() {
  }
}

