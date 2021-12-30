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

library multiple_textures_main;

import 'dart:async';
import 'dart:html';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_example_ui.dart';

class MultipleTexturesExample extends Example {
  MultipleTexturesExample(CanvasElement element)
      : super('MultipleTextures', element);

  FpsFlyCameraController cameraController;

  Future initialize() {
    return super.initialize().then((_) {
      cameraController = new FpsFlyCameraController();
    });
  }

  Future load() {
    return super.load().then((_) {
    });
  }

  double _radians = 0.1;
  onUpdate() {
    updateCameraController(cameraController);
    _radians += gameLoop.updateTimeStep * 3.14159;
  }

  onRender() {
    // Set the viewport (2D area of render target to render on to).
    graphicsContext.setViewport(viewport);
    // Clear it.
    graphicsContext.clearColorBuffer(0.97, 0.97, 0.97, 1.0);
    graphicsContext.clearDepthBuffer(1.0);

    var T = new Matrix4.rotationX(_radians).scale(8.0);

    debugDrawManager.addAABB(new Vector3(1.0, 1.0, 1.0),
                             new Vector3(20.0, 20.0, 20.0),
                             DebugDrawManager.ColorRed);

    debugDrawManager.addCone(new Vector3(1.0, 0.0, 0.0),
                             T.transform3(new Vector3(0.0, 0.0, 1.0)),
                             4.0,
                             degrees2radians * 45.0,
                             DebugDrawManager.ColorBlue);

    debugDrawManager.addArc(new Vector3(5.0, 5.0, 5.0),
                            new Vector3(0.0, 1.0, 0.0),
                            3.0,
                            _radians,
                            _radians + (degrees2radians * 45.0),
                            DebugDrawManager.ColorGreen);

    debugDrawManager.addPlane(T.transform3(new Vector3(0.0, 0.0, 1.0)),
                              new Vector3(-5.0, -5.0, -5.0),
                              10.0,
                              DebugDrawManager.ColorBlue);

    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);
  }
}

main() {
  var example = new MultipleTexturesExample(query('#backBuffer'));
  example.gameLoop.pointerLock.lockOnClick = true;
  runExample(example);
}
