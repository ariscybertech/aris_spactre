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

class SkyboxRenderable extends Renderable {
  static SingleArrayIndexedMesh _mesh;
  static void _staticSkyboxInit(GraphicsDevice device) {
    if (_mesh != null) {
      // Already initialized.
      return;
    }
    _mesh = new SingleArrayIndexedMesh('SkyboxRenderable', device);
    Float32List vertexData = new Float32List.fromList([
        -1.0, -1.0, -1.0, -1.0, -1.0, -1.0,
        -1.0, 1.0, -1.0, -1.0, 1.0, -1.0,
        1.0, 1.0, -1.0, 1.0, 1.0, -1.0,
        1.0, -1.0, -1.0, 1.0, -1.0, -1.0,
        -1.0, -1.0, 1.0, -1.0, -1.0, 1.0,
        -1.0, 1.0, 1.0, -1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, -1.0, 1.0, 1.0, -1.0, 1.0,
        -1.0, -1.0, -1.0, -1.0, -1.0, -1.0,
        -1.0, -1.0, 1.0, -1.0, -1.0, 1.0,
        1.0, -1.0, 1.0, 1.0, -1.0, 1.0,
        1.0, -1.0, -1.0, 1.0, -1.0, -1.0,
        -1.0, 1.0, -1.0, -1.0, 1.0, -1.0,
        -1.0, 1.0, 1.0, -1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, -1.0, 1.0, 1.0, -1.0,
        -1.0, -1.0, -1.0, -1.0, -1.0, -1.0,
        -1.0, -1.0, 1.0, -1.0, -1.0, 1.0,
        -1.0, 1.0, 1.0, -1.0, 1.0, 1.0,
        -1.0, 1.0, -1.0, -1.0, 1.0, -1.0,
        1.0, -1.0, -1.0, 1.0, -1.0, -1.0,
        1.0, -1.0, 1.0, 1.0, -1.0, 1.0,
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, -1.0, 1.0, 1.0, -1.0]);
    _mesh.vertexArray.uploadData(vertexData, UsagePattern.StaticDraw);
    Uint16List indexData = new Uint16List.fromList([
        0, 1, 2,
        0, 2, 3,
        4, 5, 6,
        4, 6, 7,
        8, 9, 10,
        8, 10, 11,
        12, 13, 14,
        12, 14, 15,
        16, 17, 18,
        16, 18, 19,
        20, 21, 22,
        20, 22, 23]);
    _mesh.indexArray.uploadData(indexData, UsagePattern.StaticDraw);
    _mesh.attributes['POSITION'] = new SpectreMeshAttribute(
        'vPosition',
        new VertexAttribute(0, 0, 0, 24, DataType.Float32, 3, false));
    _mesh.attributes['TEXCOORD0'] = new SpectreMeshAttribute(
        'vTexCoord',
        new VertexAttribute(0, 0, 12, 24, DataType.Float32, 3, false));
    _mesh.count = indexData.length;
  }

  /// Path to material asset.
  String get materialPath => _materialPath;
  set materialPath(String o) {
    _materialPath = o;
    material = renderer.assetManager[_materialPath];
  }
  String _materialPath;

  InputLayout get inputLayout => _inputLayout;
  InputLayout _inputLayout;
  // Bounding Box.

  SkyboxRenderable(String name, Renderer renderer)
      : super(name, renderer) {
    _staticSkyboxInit(renderer.device);
    _inputLayout = new InputLayout(name, renderer.device);
    _link();
  }

  SkyboxRenderable.json(Map json, Renderer renderer)
      : super.json(json, renderer) {
    _staticSkyboxInit(renderer.device);
    _inputLayout = new InputLayout(name, renderer.device);
    fromJson(json);
    _link();
  }

  Material get material => _material;
  set material(Material m) {
    _material = m;
    _link();
  }
  Material _material;

  void _link() {
    _inputLayout.mesh = _mesh;
    if (_material != null) {
      _inputLayout.shaderProgram = _material.shader.shader;
    } else {
      _inputLayout.shaderProgram = null;
    }
  }

  void render(Layer layer, Camera camera) {
    if (_material == null) {
      _spectreLog.shout('Cannot render $name it has no material.');
      return;
    }
    if (_inputLayout.ready == false) {
      _spectreLog.shout('Cannot render $name inputs are invalid.');
      return;
    }
    _material.apply(renderer.device);
    _material.shader.updateCameraConstants(camera);
    renderer.device.context.setInputLayout(_inputLayout);
    renderer.device.context.setIndexedMesh(SkyboxRenderable._mesh);
    renderer.device.context.drawIndexedMesh(SkyboxRenderable._mesh);
  }

  void fromJson(Map json) {
    super.fromJson(json);
    materialPath = json['materialPath'];
  }

  dynamic toJson() {
    Map map = super.toJson();
    map['materialPath'] = materialPath;
    return map;
  }
}
