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

class MaterialShader extends Disposable {
  String name;
  final Renderer renderer;
  Material _material;
  Material get material => _material;
  ShaderProgram _shader;
  ShaderProgram get shader => _shader;

  int _serial = 0;

  final List<SpectreTexture> _textures = new List<SpectreTexture>();
  final List<SamplerState> _samplers = new List<SamplerState>();

  void _setupTextureSamplerTable() {
    _textures.length = _shader.samplers.length;
    _samplers.length = _shader.samplers.length;
    for (int i = 0; i < _shader.samplers.length; i++) {
      _textures[i] = null;
      _samplers[i] = null;
    }
  }

  void _link() {
    _setupTextureSamplerTable();
    _serial++;
  }

  void link() {
    _link();
  }

  set vertexShader(String source) {
    _shader.vertexShader.source = source;
    _shader.vertexShader.compile();
    if (_shader.vertexShader.compiled) {
      link();
    } else {
      print('Vertex Shader compile error in $name: '
            '${_shader.vertexShader.compileLog}');
    }
  }
  set fragmentShader(String source) {
    _shader.fragmentShader.source = source;
    _shader.fragmentShader.compile();
    _shader.link();
    if (_shader.fragmentShader.compiled) {
      link();
    } else {
      print('Fragment Shader compile error in $name: '
          '${_shader.vertexShader.compileLog}');
    }

  }

  MaterialShader(this.name, this.renderer) {
    _shader = new ShaderProgram(name, renderer.device);
    _shader.vertexShader = new VertexShader(name, renderer.device);
    _shader.fragmentShader = new FragmentShader(name, renderer.device);
    _material = new Material(name, this, renderer);
    _depthState = new DepthState();
    _blendState = new BlendState();
    _rasterizerState = new RasterizerState();
  }

  DepthState _depthState;
  DepthState get depthState => _depthState;
  RasterizerState _rasterizerState;
  RasterizerState get rasterizerState => _rasterizerState;
  BlendState _blendState;
  BlendState get blendState => _blendState;

  void finalize() {
    if (_shader != null) {
      _shader.vertexShader.dispose();
      _shader.fragmentShader.dispose();
      _shader.dispose();
    }
  }

  void updateCameraConstants(Camera camera) {
    if (camera == null) {
      // TODO(johnmccutchan): Do we have a default camera setup?
    }
    Matrix4 projectionMatrix = camera.projectionMatrix;
    Matrix4 viewMatrix = camera.viewMatrix;
    Matrix4 projectionViewMatrix = camera.projectionMatrix;
    projectionViewMatrix.multiply(viewMatrix);
    Matrix4 viewRotationMatrix = makeViewMatrix(new Vector3.zero(),
                                             camera.frontDirection,
                                             new Vector3(0.0, 1.0, 0.0));
    Matrix4 projectionViewRotationMatrix = camera.projectionMatrix;
    projectionViewRotationMatrix.multiply(viewRotationMatrix);
    ShaderProgramUniform uniform;
    uniform = shader.uniforms['cameraView'];
    if (uniform != null) {
      shader.updateUniform(uniform, viewMatrix.storage);
    }
    uniform = shader.uniforms['cameraProjection'];
    if (uniform != null) {
      shader.updateUniform(uniform, projectionMatrix.storage);
    }
    uniform = shader.uniforms['cameraProjectionView'];
    if (uniform != null) {
      shader.updateUniform(uniform, projectionViewMatrix.storage);
    }
    uniform = shader.uniforms['cameraViewRotation'];
    if (uniform != null) {
      shader.updateUniform(uniform, viewRotationMatrix.storage);
    }
    uniform = shader.uniforms['cameraProjectionViewRotation'];
    if (uniform != null) {
      shader.updateUniform(uniform, projectionViewRotationMatrix.storage);
    }
  }

  void updateObjectTransformConstant(Matrix4 T) {
    ShaderProgramUniform uniform;
    uniform = shader.uniforms['objectTransform'];
    if (uniform != null) {
      shader.updateUniform(uniform, T.storage);
    }
  }

  static final Float32List _viewportStorage = new Float32List(4);
  void updateViewportConstants(Viewport vp) {
    ShaderProgramUniform uniform;
    uniform = shader.uniforms['viewport'];
    if (uniform != null) {
      MaterialShader._viewportStorage[0] = vp.x.toDouble();
      MaterialShader._viewportStorage[1] = vp.y.toDouble();
      MaterialShader._viewportStorage[2] = vp.width.toDouble();
      MaterialShader._viewportStorage[3] = vp.height.toDouble();
      shader.updateUniform(uniform, MaterialShader._viewportStorage);
    }
  }

  MaterialConstant _findConstant(String k, Material one, Material two,
                                 Material three) {
    MaterialConstant constant;
    if (one != null) {
      constant = one.constants[k];
      if (constant != null) {
        return constant;
      }
    }
    if (two != null) {
      constant = two.constants[k];
      if (constant != null) {
        return constant;
      }
    }
    if (three != null) {
      constant = three.constants[k];
      if (constant != null) {
        return constant;
      }
    }
    return constant;
  }

  MaterialTexture _findTexture(String k, Material one, Material two,
                               Material three) {
    MaterialTexture texture;
    if (one != null) {
      texture = one.textures[k];
      if (texture != null) {
        return texture;
      }
    }
    if (two != null) {
      texture = two.textures[k];
      if (texture != null) {
        return texture;
      }
    }
    if (three != null) {
      texture = three.textures[k];
      if (texture != null) {
        return texture;
      }
    }
    return texture;
  }

  void apply(GraphicsDevice device, Material renderableMaterial) {
    device.context.setBlendState(_blendState);
    device.context.setRasterizerState(_rasterizerState);
    device.context.setDepthState(_depthState);
    device.context.setShaderProgram(shader);

    shader.uniforms.forEach((String k, ShaderProgramUniform v) {
      MaterialConstant constant = _findConstant(k, renderableMaterial, material,
                                                null);
      if (constant != null) {
        shader.updateUniform(v, constant.value);
      }
    });

    bool flag = false;
    shader.samplers.forEach((String k, ShaderProgramSampler v) {
      int textureUnit = v.textureUnit;
      MaterialTexture texture = _findTexture(k, renderableMaterial, material,
                                             null);

      if (k == 'source') {
        flag = true;
      }
      if (texture != null) {
        _textures[textureUnit] = texture.texture;
        _samplers[textureUnit] = texture.sampler;
      }
    });
    device.context.setTextures(0, _textures);
    device.context.setSamplers(0, _samplers);
  }

  void _applyConstant(String name, MaterialConstant constant) {
  }

  void _applyTexture(String name, MaterialTexture texture) {
  }

  dynamic toJson() {
    Map json = new Map();
    json['name'] = name;
    json['depthState'] = depthState.toJson();
    json['rasterizerState'] = rasterizerState.toJson();
    json['blendState'] = blendState.toJson();
    json['material'] = _material.toJson();
    json['fragmentShader'] = _shader.fragmentShader.source;
    json['vertexShader'] = _shader.vertexShader.source;
    return json;
  }

  void fromJson(dynamic json) {
    name = json['name'];
    depthState.fromJson(json['depthState']);
    rasterizerState.fromJson(json['rasterizerState']);
    blendState.fromJson(json['blendState']);
    _material.fromJson(json['material']);
    _shader.fragmentShader.source = json['fragmentShader'];
    _shader.vertexShader.source = json['vertexShader'];
  }
}