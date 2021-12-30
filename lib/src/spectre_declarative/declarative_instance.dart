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

part of spectre_declarative;

class DeclarativeInstance {
  AssetManager assetManager;
  GraphicsDevice graphicsDevice;
  GraphicsContext graphicsContext;
  DebugDrawManager debugDrawManager;
  SpectreSpectreElement root;
  bool _inited = false;
  bool get inited => _inited;
  DeclarativeExample example;
  double time = 0.0;
  void _initElement(Element element) {
    if (element.xtag is SpectreElement) {
      SpectreElement se = element.xtag;
      SpectreElement.log.fine('Init $element ${element.id}');
      se.init();
    }
    element.children.forEach((e) {
      _initElement(e);
    });
  }

  void _init() {
    if (_inited) {
      return;
    }
    _inited = true;
    _initElement(document.body);
  }

  bool _isAssetPackUrl(String url) {
    return url.startsWith('assetpack://');
  }

  String _getAssetPackPath(String url) {
    return url.substring('assetpack://'.length);
  }

  dynamic getAsset(String url) {
    assert(_inited == true);
    if (url == null) return null;
    if (!_isAssetPackUrl(url)) return null;
    var p = _getAssetPackPath(url);
    var a = assetManager[p];
    return a;
  }

  SpectreElement getElement(String id) {
    if (id == null) {
      return null;
    }
    var q = document.querySelector(id);
    if (q != null) return q.xtag;
    return null;
  }
}

final DeclarativeInstance declarativeInstance = new DeclarativeInstance();
