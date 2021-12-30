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

library spectre_layer_element;

import 'package:polymer/polymer.dart';
import 'package:spectre/spectre_elements.dart';
import 'package:spectre/spectre_declarative.dart';

@CustomTag('s-layer')
class SpectreLayerElement extends SpectreElement {
  @published String sceneId = '';
  @published String cameraId = '';
  @published String postEffectId = '';
  @published String sortOrder = 'none';
  @published String renderTargetId = 'system';

  SpectreSceneElement _scene;
  SpectreCameraElement _camera;
  SpectrePostEffectElement _postEffect;
  //SpectreRenderTargetElement _renderTarget;

  void sceneIdChanged(oldValue) {
    _scene = ownerDocument.querySelector(sceneId);
  }

  void cameraIdChanged(oldValue) {
    _camera = ownerDocument.querySelector(cameraId);
  }

  void postEffectIdChanged(oldValue) {
    _postEffect = ownerDocument.querySelector(postEffectId);
  }

  void sortOrderChanged(oldValue) {
  }

  void renderTargetIdChanged(oldValue) {
    // _renderTarget = query(renderTargetId).xtag;
  }

  SpectreLayerElement.created() : super.created() {
    init();
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
  }

  void render() {
    super.render();
    // apply render target.
  }
}
