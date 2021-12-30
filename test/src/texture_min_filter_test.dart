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

library texture_min_filter_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'dart:web_gl' as WebGL;

void main() {
  test('values', () {
    expect(TextureMinFilter.Linear, WebGL.LINEAR);
    expect(TextureMinFilter.Point , WebGL.NEAREST);
    expect(TextureMinFilter.PointMipPoint  , WebGL.NEAREST_MIPMAP_NEAREST);
    expect(TextureMinFilter.PointMipLinear , WebGL.NEAREST_MIPMAP_LINEAR);
    expect(TextureMinFilter.LinearMipPoint , WebGL.LINEAR_MIPMAP_NEAREST);
    expect(TextureMinFilter.LinearMipLinear, WebGL.LINEAR_MIPMAP_LINEAR);

  });

  test('stringify', () {
    expect(TextureMinFilter.stringify(TextureMinFilter.Linear), 'TextureMinFilter.Linear');
    expect(TextureMinFilter.stringify(TextureMinFilter.Point) , 'TextureMinFilter.Point');
    expect(TextureMinFilter.stringify(TextureMinFilter.PointMipPoint)  , 'TextureMinFilter.PointMipPoint');
    expect(TextureMinFilter.stringify(TextureMinFilter.PointMipLinear) , 'TextureMinFilter.PointMipLinear');
    expect(TextureMinFilter.stringify(TextureMinFilter.LinearMipPoint) , 'TextureMinFilter.LinearMipPoint');
    expect(TextureMinFilter.stringify(TextureMinFilter.LinearMipLinear), 'TextureMinFilter.LinearMipLinear');

    expect(() { TextureMinFilter.stringify(-1); }, throwsA(new isInstanceOf<ArgumentError>()));
  });

  test('parse', () {
    expect(TextureMinFilter.parse('TextureMinFilter.Linear'), TextureMinFilter.Linear);
    expect(TextureMinFilter.parse('TextureMinFilter.Point') , TextureMinFilter.Point);
    expect(TextureMinFilter.parse('TextureMinFilter.PointMipPoint')  , TextureMinFilter.PointMipPoint);
    expect(TextureMinFilter.parse('TextureMinFilter.PointMipLinear') , TextureMinFilter.PointMipLinear);
    expect(TextureMinFilter.parse('TextureMinFilter.LinearMipPoint') , TextureMinFilter.LinearMipPoint);
    expect(TextureMinFilter.parse('TextureMinFilter.LinearMipLinear'), TextureMinFilter.LinearMipLinear);

    expect(TextureMinFilter.parse('NotValid'), TextureMinFilter.Default);
  });

  test('isValid', () {
    expect(TextureMinFilter.isValid(TextureMinFilter.Linear), true);
    expect(TextureMinFilter.isValid(TextureMinFilter.Point) , true);
    expect(TextureMinFilter.isValid(TextureMinFilter.PointMipPoint)  , true);
    expect(TextureMinFilter.isValid(TextureMinFilter.PointMipLinear) , true);
    expect(TextureMinFilter.isValid(TextureMinFilter.LinearMipPoint) , true);
    expect(TextureMinFilter.isValid(TextureMinFilter.LinearMipLinear), true);

    expect(TextureMinFilter.isValid(-1), false);
  });
}
