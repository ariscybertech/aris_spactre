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

library texture_2d_main;

import 'dart:html';

import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_elements.dart';
import 'package:spectre/spectre_declarative.dart' as declarative;

void _drawSquare(CanvasRenderingContext2D context2d, int x, int y, int w,
                 int h) {
  context2d.save();
  context2d.beginPath();
  context2d.translate(x, y);
  context2d.fillStyle = "#656565";
  context2d.fillRect(0, 0, w, h);
  context2d.restore();
}

void _drawGrid(CanvasRenderingContext2D context2d, int width, int height,
               int horizSlices, int vertSlices) {
  int sliceWidth = width ~/ horizSlices;
  int sliceHeight = height ~/ vertSlices;
  int sliceHalfWidth = sliceWidth ~/ 2;
  for (int i = 0; i < horizSlices; i++) {
    for (int j = 0; j < vertSlices; j++) {
      if (j % 2 == 0) {
        _drawSquare(context2d, i * sliceWidth, j * sliceHeight,
            sliceHalfWidth, sliceHeight);
      } else {
        _drawSquare(context2d, i * sliceWidth + sliceHalfWidth,
            j * sliceHeight, sliceHalfWidth, sliceHeight);
      }
    }
  }
}

void main() {
  declarative.startup('#backBuffer', '#spectre').then((_) {
    SpectreTextureElement ste = query('#program-filled').xtag;
    ste.init();
    CanvasElement canvas = new CanvasElement();
    canvas.width = 512;
    canvas.height = 512;
    CanvasRenderingContext2D context2d = canvas.getContext('2d');
    _drawGrid(context2d, 512, 512, 8, 8);
    (ste.texture as Texture2D).uploadElement(canvas);
  });
}