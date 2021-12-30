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

library line_primitive_main;

import 'dart:async';
import 'dart:html';
import 'dart:math' as Math;
import 'package:polymer/polymer.dart';
import 'package:spectre/spectre_declarative.dart' as declarative;
import 'package:spectre/spectre_elements.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  initPolymer();
  declarative.startup('#backBuffer', '#spectre').then((_) {
    SpectreTransformElement masterT = querySelector('#masterT');
    SpectreLineArcElement arc = querySelector('#arc');
    SpectreLinePlaneElement plane = querySelector('#plane');
    SpectreSceneElement scene = querySelector('#scene');
    SpectreLinePlaneElement plane2 = document.createElement('s-line-plane');
    plane2.color = new Vector4(0.0, 0.0, 1.0, 1.0);
    scene.children.add(plane2);
    double radians = 0.01;
    Matrix3 R = new Matrix3.rotationZ(radians);
    Vector3 baseOrigin = new Vector3.copy(masterT.origin);
    Stopwatch timeSource = new Stopwatch()..start();
    new Timer.periodic(new Duration(milliseconds: 16), (t) {
      arc.startAngle += 0.05;
      arc.stopAngle += 0.05;
      R.transform(plane.normal);
      baseOrigin.copyInto(masterT.origin);
      masterT.origin.y += Math.sin(timeSource.elapsedMilliseconds / 1000.0) * 3.0;
      masterT.updateTransform();
    });
  });
}