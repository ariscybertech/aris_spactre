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

library declarative_test_main;

import 'dart:html';
import 'package:spectre/spectre_declarative.dart' as declarative;
import 'package:spectre/spectre_elements.dart';

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

void testShaders() {
  SpectreVertexShaderElement vsGood = query('#vertexShaderGood').xtag;
  SpectreFragmentShaderElement fsGood = query('#fragmentShaderGood').xtag;
  SpectreVertexShaderElement vsBad = query('#vertexShaderBad').xtag;
  SpectreFragmentShaderElement fsBad = query('#fragmentShaderBad').xtag;
  test('Shaders compiled', () {
    expect(vsGood.shader.compiled, true);
    expect(fsGood.shader.compiled, true);
  });
  test('Shaders failed to compile', () {
    expect(vsBad.shader.compiled, false);
    expect(fsBad.shader.compiled, false);
  });
  test('ShaderProgram linked', () {
    SpectreMaterialProgramElement mpe1 =
        query('#materialProgramInnerTags').xtag;
    SpectreMaterialProgramElement mpe2 =
        query('#materialProgramReference').xtag;
    SpectreMaterialProgramElement mpe3 =
        query('#materialProgramReferenceOne').xtag;
    expect(mpe1.program.linked, true);
    expect(mpe2.program.linked, true);
    expect(mpe3.program.linked, true);
  });
}

void main() {
  useHtmlEnhancedConfiguration();
  declarative.startup('#backBuffer', '#scene').then((_) {
    group('Shader tests', testShaders);
  });
}