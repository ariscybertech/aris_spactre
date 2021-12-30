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

class FullscreenLayer extends Layer {
  static SingleArrayMesh _mesh;
  static void _staticInit(GraphicsDevice device) {
    if (_mesh != null) {
      // Already initialized.
      return;
    }
    _mesh = new SingleArrayMesh('FullscreenRenderable', device);
    Float32List vertexData = new Float32List(12);
    // Vertex 0
    vertexData[0] = -1.0;
    vertexData[1] = -1.0;
    vertexData[2] = 0.0;
    vertexData[3] = 0.0;
    // Vertex 1
    vertexData[4] = 3.0;
    vertexData[5] = -1.0;
    vertexData[6] = 2.0;
    vertexData[7] = 0.0;
    // Vertex 2
    vertexData[8] = -1.0;
    vertexData[9] = 3.0;
    vertexData[10] = 0.0;
    vertexData[11] = 2.0;
    _mesh.vertexArray.uploadData(vertexData, UsagePattern.StaticDraw);
    _mesh.attributes['vPosition'] = new SpectreMeshAttribute(
        'vPosition',
        new VertexAttribute(0, 0, 0, 16, DataType.Float32, 2, false));
    _mesh.attributes['vTexCoord'] = new SpectreMeshAttribute(
        'vTexCoord',
        new VertexAttribute(0, 0, 8, 16, DataType.Float32, 2, false));
    _mesh.count = 3;
  }

  set material(Material m) {
    _material = m;
    if (m != null) {
      _inputLayout.shaderProgram = m.shader.shader;
    } else {
      _inputLayout.shaderProgram = null;
    }
  }

  void render(Renderer renderer, List<Renderable> renderables, Camera camera) {
    if (material == null) {
      return;
    }
    GraphicsDevice device = renderer.device;
    GraphicsContext context = device.context;
    material.apply(device);
    material.shader.updateCameraConstants(camera);
    context.setInputLayout(_inputLayout);
    context.setMesh(FullscreenLayer._mesh);
    context.drawMesh(FullscreenLayer._mesh);
  }

  String get type => 'Fullscreen';

  InputLayout _inputLayout;

  FullscreenLayer(String name, Renderer renderer) : super(name, renderer) {
    _staticInit(renderer.device);
    _inputLayout = new InputLayout('FullscreenRenderable', renderer.device);
    _inputLayout.mesh = _mesh;
  }
}