/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

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

part of spectre_renderer;

void _registerBuiltinMaterialShaders(Renderer renderer) {
  // Fullscreen blit shader.
  MaterialShader blit = new MaterialShader('blit', renderer);
  blit.vertexShader = '''
precision highp float;
attribute vec2 vPosition;
attribute vec2 vTexCoord;
varying vec2 samplePoint;

uniform float time;
uniform vec2 cursor;
uniform vec2 renderTargetResolution;

void main() {
vec4 vPosition4 = vec4(vPosition.x, vPosition.y, 1.0, 1.0);
gl_Position = vPosition4;
samplePoint = vTexCoord;
}
''';
  blit.fragmentShader = '''
precision mediump float;

uniform float time;
uniform vec2 cursor;
uniform vec2 renderTargetResolution;

varying vec2 samplePoint;
uniform sampler2D source;

void main() {
gl_FragColor = texture2D(source, samplePoint);
}
''';
  var asset = renderer._materialShaderPack.registerAsset('blit',
                                                         'materialShader',
                                                         '',
                                                         {},
                                                         {});
  asset.imported = blit;
  renderer.materialShaders['blit'] = blit;

  // Skybox cube map shader.
  MaterialShader skyBox = new MaterialShader('skyBox', renderer);
  skyBox.vertexShader = '''
attribute vec3 POSITION;
attribute vec3 TEXCOORD0;
uniform mat4 cameraProjectionViewRotation;
uniform vec3 skyboxScale;
varying vec3 samplePoint;

void main(void)
{
  vec4 vPosition4 = vec4(POSITION*skyboxScale, 1.0);
  gl_Position = cameraProjectionViewRotation*vPosition4;
  samplePoint = TEXCOORD0;
}
''';
  skyBox.fragmentShader = '''
precision highp float;
varying vec3 samplePoint;
uniform samplerCube skyMap;

void main(void)
{
  vec4 color = textureCube(skyMap, samplePoint);
  //gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
  gl_FragColor = vec4(color.xyz, 1.0);
}
''';
  skyBox.rasterizerState.cullMode = CullMode.None;
  skyBox.blendState.enabled = false;
  skyBox.material.addConstant('skyboxScale', 'vec3');
  List value = skyBox.material.constants['skyboxScale'].value;
  for (int i = 0; i < value.length; i++) {
    value[i] = 512.0;
  }
  renderer._materialShaderPack.registerAsset('skyBox',
      'materialShader',
      '',
      {},
      {});
  asset.imported = skyBox;
  renderer.materialShaders['skyBox'] = skyBox;
  MaterialShader coloredLight = new MaterialShader('coloredLight', renderer);
}
