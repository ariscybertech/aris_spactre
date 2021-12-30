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

library spectre_camera_element;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_declarative.dart';
import 'spectre_element.dart';

/**
 * <s-camera id="mainCamera"></s-camera>
 */
@CustomTag('s-camera')
class SpectreCameraElement extends SpectreElement {
  @published double fieldOfViewY = 0.785398163;
  @published Vector3 position = new Vector3(1.0, 1.0, 1.0);
  @published Vector3 upDirection = new Vector3(0.0, 1.0, 0.0);
  @published Vector3 viewDirection = new Vector3(-0.33333, -0.33333, -0.33333);
  @published double zNear = 0.5;
  @published double zFar = 1000.0;

  final Camera camera = new Camera();

  void fieldOfViewYChanged(oldValue) {
    camera.FOV = fieldOfViewY;
  }

  void positionChanged(oldValue) {
    camera.position = position;
  }

  void upDirectionChanged(oldValue) {
    camera.upDirection = upDirection;
  }

  void viewDirectionChanged(oldValue) {
    camera.focusPosition = position + viewDirection;
  }

  void zNearChanged(oldValue) {
    camera.zNear = zNear;
  }

  void zFarChanged(oldValue) {
    camera.zFar = zFar;
  }

  SpectreCameraElement.created() : super.created();

  void enteredView() {
    super.enteredView();
  }

  void leftView() {
    super.leftView();

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
}
