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

library rasterizer_state_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'shared/device_child_equality.dart';
import 'shared/mock_graphics_device.dart';

GraphicsDevice _graphicsDevice;

void testConstructor(RasterizerState rasterizerState, int cullMode, int frontFace) {
  expect(rasterizerState.cullMode , cullMode);
  expect(rasterizerState.frontFace, frontFace);

  expect(rasterizerState.depthBias          , 0.0);
  expect(rasterizerState.slopeScaleDepthBias, 0.0);

  expect(rasterizerState.scissorTestEnabled, false);
}

void main() {
  _graphicsDevice = new MockGraphicsDevice.useMock();

  // Construction
  test('construction', () {
    // Default constructor
    RasterizerState defaultState = new RasterizerState();
    testConstructor(defaultState, CullMode.Back, FrontFace.CounterClockwise);

    // RasterizerState.cullClockwise
    RasterizerState cullClockwise = new RasterizerState.cullClockwise();
    testConstructor(cullClockwise, CullMode.Back, FrontFace.CounterClockwise);

    // RasterizerState.cullCounterClockwise
    RasterizerState cullCounterClockwise =
        new RasterizerState.cullCounterClockwise();
    testConstructor(cullCounterClockwise, CullMode.Back, FrontFace.Clockwise);

    // RasterizerState.cullNone
    RasterizerState cullNone = new RasterizerState.cullNone();
    testConstructor(cullNone, CullMode.None, FrontFace.CounterClockwise);
  });

  // Enumeration setters
  test('cullMode', () {
    RasterizerState rasterizerState = new RasterizerState();

    dynamic function = (rasterizerState, value) {
      rasterizerState.cullMode = value;
      return rasterizerState.cullMode;
    };

    // Shouldn't throw
    expect(function(rasterizerState, CullMode.None) , CullMode.None);
    expect(function(rasterizerState, CullMode.Front), CullMode.Front);
    expect(function(rasterizerState, CullMode.Back) , CullMode.Back);

    // Should throw
    expect(() { function(rasterizerState, -1); }, throwsArgumentError);
  });

  test('frontFace', () {
    RasterizerState rasterizerState = new RasterizerState();

    dynamic function = (rasterizerState, value) {
      rasterizerState.frontFace = value;
      return rasterizerState.frontFace;
    };

    // Shouldn't throw
    expect(function(rasterizerState, FrontFace.Clockwise)       , FrontFace.Clockwise);
    expect(function(rasterizerState, FrontFace.CounterClockwise), FrontFace.CounterClockwise);

    // Should throw
    expect(() { function(rasterizerState, -1); }, throwsArgumentError);
  });

  // Equality
  test('equality', () {
    RasterizerState rasterizerState0 = new RasterizerState();
    RasterizerState rasterizerState1 = new RasterizerState();

    // Check identical
    expect(rasterizerStateEqual(rasterizerState0, rasterizerState0), true);
    expect(rasterizerStateEqual(rasterizerState0, rasterizerState1), true);

    // Check inequality
    rasterizerState0.cullMode = CullMode.Front;
    expect(rasterizerStateEqual(rasterizerState0, rasterizerState1), false);
    rasterizerState1.cullMode = rasterizerState0.cullMode;
    expect(rasterizerStateEqual(rasterizerState0, rasterizerState1), true);

    rasterizerState0.frontFace = FrontFace.Clockwise;
    expect(rasterizerStateEqual(rasterizerState0, rasterizerState1), false);
    rasterizerState1.frontFace = rasterizerState0.frontFace;
    expect(rasterizerStateEqual(rasterizerState0, rasterizerState1), true);

    rasterizerState0.depthBias = 1.0;
    expect(rasterizerStateEqual(rasterizerState0, rasterizerState1), false);
    rasterizerState1.depthBias = rasterizerState0.depthBias;
    expect(rasterizerStateEqual(rasterizerState0, rasterizerState1), true);

    rasterizerState0.slopeScaleDepthBias = 1.0;
    expect(rasterizerStateEqual(rasterizerState0, rasterizerState1), false);
    rasterizerState1.slopeScaleDepthBias = rasterizerState0.slopeScaleDepthBias;
    expect(rasterizerStateEqual(rasterizerState0, rasterizerState1), true);

    rasterizerState0.scissorTestEnabled = true;
    expect(rasterizerStateEqual(rasterizerState0, rasterizerState1), false);
    rasterizerState1.scissorTestEnabled = rasterizerState0.scissorTestEnabled;
    expect(rasterizerStateEqual(rasterizerState0, rasterizerState1), true);
  });

  // Serialization
  test('serialization', () {
    RasterizerState original = new RasterizerState();

    RasterizerState copy = new RasterizerState();
    copy.cullMode = CullMode.Front;
    copy.frontFace = FrontFace.Clockwise;
    copy.depthBias = 1.0;
    copy.slopeScaleDepthBias = 1.0;
    copy.scissorTestEnabled = true;

    Map json = original.toJson();
    copy.fromJson(json);

    expect(rasterizerStateEqual(original, copy), true);
  });
}
