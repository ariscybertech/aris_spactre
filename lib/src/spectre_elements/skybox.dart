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

library spectre_skybox_element;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_declarative.dart';
import 'package:spectre/spectre_elements.dart';

@CustomTag('s-skybox')
class SpectreSkyboxElement extends SpectreElement {
  @published String textureId = '';
  SpectreTextureElement textureElement;
  VertexShader _vertexShader;
  FragmentShader _fragmentShader;
  ShaderProgram _shaderProgram;
  SamplerState _sampler;
  RasterizerState _rasterizerState;
  DepthState _depthState;
  InputLayout _inputLayout;
  SingleArrayIndexedMesh get skyboxMesh =>
      declarativeInstance.example.skyboxMesh;

  SpectreSkyboxElement.created() : super.created();

  textureIdChanged(oldValue) {
    _updateTexture();
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
    _initShader();
    _initSampler();
    _initStates();
    _initLayout();
    _updateTexture();
  }

  void _initShader() {
    _vertexShader = new VertexShader('', declarativeInstance.graphicsDevice);
    _vertexShader.source = '''
      attribute vec3 POSITION;
      attribute vec3 TEXCOORD0;
      uniform mat4 cameraProjectionViewRotation;
      uniform mat4 cameraViewRotation;
      varying vec3 samplePoint;

      void main(void)
      {
        vec4 vPosition4 = vec4(POSITION.x*512.0,
                               POSITION.y*512.0,
                               POSITION.z*512.0,
                               1.0);
        gl_Position = cameraProjectionViewRotation*vPosition4;
        samplePoint = TEXCOORD0;
      }
''';
    _fragmentShader = new FragmentShader('', declarativeInstance.graphicsDevice);
    _fragmentShader.source = '''
      precision highp float;
      varying vec3 samplePoint;
      uniform samplerCube skyMap;
      
      void main(void)
      {
        vec4 color = textureCube(skyMap, samplePoint);
        gl_FragColor = vec4(color.xyz, 1.0);
      }
''';
    _shaderProgram = new ShaderProgram('', declarativeInstance.graphicsDevice);
    _shaderProgram.vertexShader = _vertexShader;
    _shaderProgram.fragmentShader = _fragmentShader;
    _shaderProgram.link();
    assert(_shaderProgram.linked);
  }

  void _initSampler() {
    _sampler = new SamplerState('SpectreMaterialConstantElement',
                                declarativeInstance.graphicsDevice);
    _sampler.minFilter = TextureMinFilter.Linear;
    _sampler.magFilter = TextureMagFilter.Linear;
  }

  void _initLayout() {
    _inputLayout = new InputLayout('', declarativeInstance.graphicsDevice);
    _inputLayout.mesh = skyboxMesh;
    _inputLayout.shaderProgram = _shaderProgram;
    assert(_inputLayout.ready);
  }

  void _initStates() {
    _rasterizerState = new RasterizerState();
    _rasterizerState.cullMode = CullMode.None;
    _depthState = new DepthState();
    _depthState.depthBufferWriteEnabled = false;
    _depthState.depthBufferFunction = CompareFunction.Always;
  }

  void _updateTexture() {
    textureElement = ownerDocument.querySelector(textureId);
    if (textureElement != null) {
      textureElement.init();
    }
  }

  void render() {
    super.render();
    var graphicsContext = declarativeInstance.graphicsContext;
    var camera = declarativeInstance.root.currentCamera;
    graphicsContext.setShaderProgram(_shaderProgram);
    graphicsContext.setIndexedMesh(skyboxMesh);
    graphicsContext.setInputLayout(_inputLayout);
    Matrix4 projectionMatrix = camera.projectionMatrix;
    Matrix4 viewRotationMatrix = makeViewMatrix(new Vector3.zero(),
                                             camera.frontDirection,
                                             new Vector3(0.0, 1.0, 0.0));
    Matrix4 projectionViewRotationMatrix = camera.projectionMatrix;
    projectionViewRotationMatrix.multiply(viewRotationMatrix);
    ShaderProgram shader = graphicsContext.shaderProgram;
    ShaderProgramUniform uniform;
    uniform = shader.uniforms['cameraViewRotation'];
    if (uniform != null) {
      shader.updateUniform(uniform, viewRotationMatrix.storage);
    }
    uniform = shader.uniforms['cameraProjectionViewRotation'];
    if (uniform != null) {
      shader.updateUniform(uniform, projectionViewRotationMatrix.storage);
    }
    graphicsContext.setDepthState(_depthState);
    graphicsContext.setRasterizerState(_rasterizerState);
    if (textureElement != null) {
      graphicsContext.setTexture(0, textureElement.texture);
    } else {
      graphicsContext.setTexture(0, null);
    }
    graphicsContext.setSampler(0, _sampler);
    graphicsContext.drawIndexedMesh(skyboxMesh);
  }
}
