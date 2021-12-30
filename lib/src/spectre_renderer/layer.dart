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

/** A layer describes one rendering pass.
 *
 * A layer controls which render target is writes to.
 *
 * A layer controls whether or not the depth and color buffers are cleared
 * before drawing and what value they should be cleared to.
 *
 * A layer has a material. In the case of a fullscreen layer, the material
 * is the effect. In the case of a scene layer, the material is used as a
 * fallback material for renderables that do not have a material.
 */
abstract class Layer {
  final Renderer renderer;
  static const int SortModeNone = 0;
  static const int SortModeBackToFront = 1;
  static const int SortModeFrontToBack = 2;

  int _sortMode = SortModeNone;
  /// Current sort mode.
  int get sortMode => _sortMode;
  /// Set the sort mode to be None, BackToFront, or FrontToBack.
  set sortMode(int sm) {
    if (sm != SortModeNone && sm != SortModeBackToFront &&
        sm != SortModeFrontToBack) {
      throw new ArgumentError('sortMode invalid.');
    }
    _sortMode = sm;
  }

  /// Name of layer.
  String name;
  String get type;

  /// Material.
  Material _material;
  set material(Material m) {
    _material = m;
  }
  get material => _material;

  /// Force all renderables to rendered with the layer material?
  bool forceLayerMaterial = false;

  /// Render target.
  String renderTarget;

  /// Should the color target be cleared before rendering?
  bool clearColorTarget = false;
  /// Red color target clear value.
  num clearColorR = 0.0;
  /// Green color target clear value.
  num clearColorG = 0.0;
  /// Blue color target clear value.
  num clearColorB = 0.0;
  /// Alpha color target clear value.
  num clearColorA = 1.0;
  /// Should the depth target be cleared before rendering?
  bool clearDepthTarget = false;
  /// Depth target clear value.
  num clearDepthValue = 1.0;

  static BlendState _clearBlendState;
  static DepthState _clearDepthState;

  static _layerStaticInit(GraphicsDevice device) {
    if (_clearBlendState != null) {
      return;
    }
    _clearDepthState = new DepthState();
    _clearDepthState.depthBufferWriteEnabled = true;
    _clearBlendState = new BlendState();
    _clearBlendState.writeRenderTargetRed = true;
    _clearBlendState.writeRenderTargetGreen = true;
    _clearBlendState.writeRenderTargetBlue = true;
    _clearBlendState.writeRenderTargetAlpha = true;
  }

  /// Construct a new layer, specifying [name] and [type].
  Layer(this.name, this.renderer) {
    _layerStaticInit(renderer.device);
  }

  Layer.json(Map json, this.renderer) : name = json['name'] {
    _layerStaticInit(renderer.device);
    fromJson(json);
  }

  void clear() {
    GraphicsContext context = renderer.device.context;
    if (clearColorTarget) {
      context.setBlendState(Layer._clearBlendState);
      context.clearColorBuffer(clearColorR, clearColorG, clearColorB,
                               clearColorA);
    }
    if (clearDepthTarget) {
      context.setDepthState(Layer._clearDepthState);
      context.clearDepthBuffer(clearDepthValue);
    }
  }

  void render(Renderer renderer, List<Renderable> renderables, Camera camera);

  void fromJson(Map json) {
    name = json['name'];
    renderTarget = json['renderTarget'];
    clearColorTarget = json['clearColorTarget'];
    if (json['material'] != null) {
      material = new Material.json(json['material'], renderer);
    }
    clearColorR = json['clearColorR'];
    clearColorG = json['clearColorG'];
    clearColorB = json['clearColorB'];
    clearColorA = json['clearColorA'];
    clearDepthTarget = json['clearDepthTarget'];
    clearDepthValue = json['clearDepthValue'];
  }

  dynamic toJson() {
    Map json = new Map();
    json['name'] = name;
    json['type'] = type;
    json['renderTarget'] = renderTarget;
    json['material'] = material;
    json['clearColorTarget'] = clearColorTarget;
    json['clearColorR'] = clearColorR;
    json['clearColorG'] = clearColorG;
    json['clearColorB'] = clearColorB;
    json['clearColorA'] = clearColorA;
    json['clearDepthTarget'] = clearDepthTarget;
    json['clearDepthValue'] = clearDepthValue;
    return json;
  }
}