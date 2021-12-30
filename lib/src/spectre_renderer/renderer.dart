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

/** Spectre Renderer. The renderer holds global GPU resources such as
 * depth buffers, color buffers, and the canvas front buffer. A renderer
 * draws the world a layer at a time. A [Layer] can render all renderables or
 * do a full screen scene pass.
 */
class Renderer {
  final GraphicsDevice device;
  final DebugDrawManager debugDrawManager;
  final CanvasElement frontBuffer;
  final AssetManager assetManager;
  AssetPack _rendererPack;
  AssetPack _materialShaderPack;
  final Map<String, Texture2D> colorBuffers = new Map<String, Texture2D>();
  final Map<String, RenderBuffer> depthBuffers =
      new Map<String, RenderBuffer>();
  final Map<String, RenderTarget> renderTargets =
      new Map<String, RenderTarget>();
  final Map<String, MaterialShader> materialShaders =
      new Map<String, MaterialShader>();

  SamplerState _renderTargetSampler;
  SamplerState get renderTargetSampler => _renderTargetSampler;
  Viewport _frontBufferViewport;
  Viewport get frontBufferViewport => _frontBufferViewport;

  double time = 0.0;

  void _dispose() {
    _rendererPack.clear();
    colorBuffers.forEach((_, t) {
      t.dispose();
    });
    colorBuffers.clear();
    depthBuffers.forEach((_, t) {
      t.dispose();
    });
    depthBuffers.clear();
    renderTargets.forEach((_, t) {
      t.dispose();
    });
    renderTargets.clear();
  }

  void _makeColorBuffer(Map target) {
    String name = target['name'];
    int width = target['width'];
    int height = target['height'];
    if (name == null || width == null || height == null) {
      throw new ArgumentError('Invalid target description.');
    }
    Texture2D buffer = new Texture2D(name, device);
    buffer.uploadPixelArray(width, height, null);
    colorBuffers[name] = buffer;
    var asset =
        _rendererPack.registerAsset(name, 'ColorBuffer', '', {}, {});
    asset.imported = buffer;
  }

  void _makeDepthBuffer(Map target) {
    String name = target['name'];
    int width = target['width'];
    int height = target['height'];
    if (name == null || width == null || height == null) {
      throw new ArgumentError('Invalid target description.');
    }
    RenderBuffer buffer = new RenderBuffer(name, device);
    buffer.allocateStorage(width, height, RenderBuffer.FormatDepth);
    depthBuffers[name] = buffer;
    var asset =
        _rendererPack.registerAsset(name, 'DepthBuffer', '',  {}, {});
    asset.imported = buffer;
  }

  void _makeRenderTarget(Map target) {
    // TODO: Support stencil buffers.
    var name = target['name'];
    if (name == null) {
      throw new ArgumentError('Render target requires a name.');
    }
    var colorBufferName = target['colorBuffer'];
    var depthBufferName = target['depthBuffer'];
    var stencilBufferName = target['stencilBuffer'];
    var colorBuffer = colorBuffers[colorBufferName];
    var depthBuffer = depthBuffers[depthBufferName];
    //XXX var stencilBuffer = stencilBuffers[stencilTarget];
    if (colorBuffer == null && depthBuffer == null) {
      throw new ArgumentError('Render target needs a color or a depth buffer.');
    }
    RenderTarget renderTarget = new RenderTarget(name, device);
    renderTarget.setColorTarget(0, colorBuffer);
    renderTarget.setDepthTarget(depthBuffer);
    if (renderTarget.isRenderable == false) {
      throw new ArgumentError('Render target is not renderable.');
    }
    renderTargets[name]= renderTarget;
    var asset = _rendererPack.registerAsset(name, 'RenderTarget', '', {},
                                            {});
    asset.imported = renderTarget;
  }

  void _configureFrontBuffer(Map target) {
    int width = target['width'];
    int height = target['height'];
    if (width == null || height == null) {
      throw new ArgumentError('Invalid front buffer description.');
    }
    frontBuffer.width = width;
    frontBuffer.height = height;
    _frontBufferViewport.width = frontBuffer.width;
    _frontBufferViewport.height = frontBuffer.height;
    renderTargets['frontBuffer'] = RenderTarget.systemRenderTarget;
    if (_rendererPack['frontBuffer'] == null) {
      var asset = _rendererPack.registerAsset('frontBuffer', 'RenderTarget',
                                              '', {}, {});
      asset.imported =  RenderTarget.systemRenderTarget;
    }
  }

  Layer layerFactory(Map layerDescription) {
    String type = layerDescription['type'];
    if (type == null) {
      throw new FormatException('Layer has no type.');
    }
    String name = layerDescription['name'];
    if (name == null) {
      throw new FormatException('Layer has no name.');
    }
    Layer layer;
    switch (type) {
      case 'Fullscreen':
        layer = new FullscreenLayer(name, this);
      break;
      case 'DebugDraw':
        layer = new DebugDrawLayer(name, this);
      break;
      case 'Scene':
        layer = new SceneLayer(name, this);
      break;
      default:
        throw new UnimplementedError('Unknown layer type: $type');
    }
    layer.fromJson(layerDescription);
    return layer;
  }

  /// Clear render targets.
  void clear() {
    _dispose();
  }

  void fromJson(Map config) {
    clear();
    List<Map> buffers = config['buffers'];
    List<Map> targets = config['targets'];
    if (buffers != null) {
      buffers.forEach((bufferDescription) {
        if (bufferDescription['type'] == 'color') {
          _makeColorBuffer(bufferDescription);
        } else if (bufferDescription['type'] == 'depth') {
          _makeDepthBuffer(bufferDescription);
        }
      });
    }
    if (targets != null) {
      targets.forEach((target) {
        if (target['name'] == 'frontBuffer') {
          _configureFrontBuffer(target);
        } else {
          _makeRenderTarget(target);
        }
      });
    }
  }

  dynamic toJson() {

  }

  List<Renderable> _determineVisibleSet(List<Renderable> renderables,
                                        Camera camera) {
    if (renderables == null) {
      return null;
    }
    List<Renderable> visibleSet = new List<Renderable>();
    int numRenderables = renderables.length;
    for (int i = 0; i < numRenderables; i++) {
      Renderable renderable = renderables[i];
      bool visible = true; // drawable.visibleTo(camera);
      if (!visible)
        continue;
      visibleSet.add(renderable);
    }
    return visibleSet;
  }

  void _sortDrawables(List<Renderable> visibleSet, int sortMode) {
  }

  void _renderLayer(Layer layer, List<Renderable> renderables, Camera camera) {
    RenderTarget renderTarget = _rendererPack[layer.renderTarget];
    if (renderTarget == null) {
      print('Render target ${layer.renderTarget} cannot be found...');
      print('... skipping ${layer.name}');
      return;
    }
    device.context.setRenderTarget(renderTarget);
    layer.clear();
    layer.render(this, renderables, camera);
  }

  void render(List<Layer> layers, List<Renderable> renderables, Camera camera) {
    frontBufferViewport.width = frontBuffer.width;
    frontBufferViewport.height = frontBuffer.height;
    List<Renderable> visibleSet;
    visibleSet = _determineVisibleSet(renderables, camera);
    final int numLayers = layers.length;
    for (int layerIndex = 0; layerIndex < numLayers; layerIndex++) {
      _renderLayer(layers[layerIndex], visibleSet, camera);
    }
  }

  Renderer(this.frontBuffer, this.device, this.debugDrawManager,
           this.assetManager) {
    _renderTargetSampler = new SamplerState.linearClamp(
        'Renderer.renderTargetSampler',
        device);
    _rendererPack = assetManager.registerPack('renderer', '');
    _materialShaderPack = assetManager.registerPack('materialShaders','');
    _registerBuiltinMaterialShaders(this);
    _frontBufferViewport = new Viewport();
    _frontBufferViewport.width = frontBuffer.width;
    _frontBufferViewport.height = frontBuffer.height;
  }
}
