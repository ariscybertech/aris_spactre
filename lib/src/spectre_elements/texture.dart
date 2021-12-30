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

library spectre_declarative_texture;

import 'dart:async';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:polymer/polymer.dart';
import 'package:spectre/spectre_declarative.dart';
import 'package:spectre/spectre.dart';
import 'spectre_element.dart';

/**
 * <s-texture id="textureId"></s-texture>
 *
 * Attributes:
 *
 * * src String
 * * type String ('auto', '2d', 'cube', 'color')
 * * format String (see pixel_format.dart)
 * * datatype String (see data_type.dart)
 * * color String (4 component hex string #rrggbbaa)
 * * width String (width of mip level 0)
 * * height String (height of mip level 0)
 */
@CustomTag('s-texture')
class SpectreTextureElement extends SpectreElement {
  @published String src = '';
  @published String srcCubeNegativeX = '';
  @published String srcCubeNegativeY = '';
  @published String srcCubeNegativeZ = '';
  @published String srcCubePositiveX = '';
  @published String srcCubePositiveY = '';
  @published String srcCubePositiveZ = '';
  @published String type = 'auto';
  @published String format = 'PixelFormat.Rgba';
  @published String dataType = 'DataType.Uint8';
  @published String color = '';
  @published String colorCubeNegativeX = '';
  @published String colorCubeNegativeY = '';
  @published String colorCubeNegativeZ = '';
  @published String colorCubePositiveX = '';
  @published String colorCubePositiveY = '';
  @published String colorCubePositiveZ = '';
  @published int width = 0;
  @published int height = 0;

  int _pixelFormat = PixelFormat.Rgba;
  int _dataType = DataType.Uint8;
  SpectreTexture _texture;
  SpectreTexture get texture => _texture;

  SpectreTextureElement.created() : super.created() {
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
    _update();
    _applyAttributes();
  }

  bool _hasCubeAttributes() {
    return (colorCubeNegativeX != '') ||
           (colorCubeNegativeY != '') ||
           (colorCubeNegativeZ != '') ||
           (colorCubePositiveX != '') ||
           (colorCubePositiveY != '') ||
           (colorCubePositiveZ != '') ||
           (srcCubeNegativeX != '') ||
           (srcCubeNegativeY != '') ||
           (srcCubeNegativeZ != '') ||
           (srcCubePositiveX != '') ||
           (srcCubePositiveY != '') ||
           (srcCubePositiveZ != '');
  }

  String _detectType() {
    String extension = path.extension(src);
    if (_hasCubeAttributes()) {
      return 'cube';
    }
    if ((extension == '.jpg') || (extension == '.png') ||
        (extension == '.gif')) {
      return '2d';
    }
    return 'color';
  }

  void _destroyOldTexture() {
    if (_texture != null) {
      _texture.dispose();
      _texture = null;
    }
  }

  void _parseColorIntoColorBuffer(String color, Uint8List colorBuffer) {
    colorBuffer[0] = 0x77;
    colorBuffer[1] = 0x77;
    colorBuffer[2] = 0x77;
    colorBuffer[3] = 0xFF;
    if (color.length != 9 || color[0] != '#') {
      return;
    }
    try {
      String r = color.substring(1, 3);
      String g = color.substring(3, 5);
      String b = color.substring(5, 7);
      String a = color.substring(7, 9);
      colorBuffer[0] = int.parse(r, radix:16) & 0xFF;
      colorBuffer[1] = int.parse(g, radix:16) & 0xFF;
      colorBuffer[2] = int.parse(b, radix:16) & 0xFF;
      colorBuffer[3] = int.parse(a, radix:16) & 0xFF;
    } catch (e) {
    }
  }

  static final Uint8List _patternColorBuffer = new Uint8List.fromList(
      [0x1e, 0x90, 0xff, 0xff, 0x1e, 0x90, 0xff, 0xff,
       0x70, 0x80, 0x90, 0xff, 0x70, 0x80, 0x90, 0xff,
       0x1e, 0x90, 0xff, 0xff, 0x1e, 0x90, 0xff, 0xff,
       0x70, 0x80, 0x90, 0xff, 0x70, 0x80, 0x90, 0xff,
       0x70, 0x80, 0x90, 0xff, 0x70, 0x80, 0x90, 0xff,
       0x1e, 0x90, 0xff, 0xff, 0x1e, 0x90, 0xff, 0xff,
       0x70, 0x80, 0x90, 0xff, 0x70, 0x80, 0x90, 0xff,
       0x1e, 0x90, 0xff, 0xff, 0x1e, 0x90, 0xff, 0xff]);

  void _uploadDefaultColorPattern(Texture2D texture) {
    texture.uploadPixelArray(4, 4, _patternColorBuffer);
  }

  void _createColorTexture() {
    _destroyOldTexture();
    Uint8List colorBuffer = new Uint8List(4);
    _parseColorIntoColorBuffer(color, colorBuffer);
    // Create new texture.
    var t = new Texture2D('SpectreTextureElement',
                          declarativeInstance.graphicsDevice);
    // Upload a 1x1 pixel texture.
    t.uploadPixelArray(1, 1, colorBuffer);
    // Generate mip maps.
    t.generateMipmap();
    _texture = t;
  }

  void _createTexture() {
    _destroyOldTexture();
    if (type == 'auto') {
      type = _detectType();
    }
    print('Creating $type texture $id');
    if (type == '2d') {
      var t = new Texture2D('SpectreTextureElement',
                            declarativeInstance.graphicsDevice);
      _uploadDefaultColorPattern(t);
      t.generateMipmap();
      _texture = t;
    } else if (type == 'cube') {
      var t = new TextureCube('SpectreTextureElement',
                              declarativeInstance.graphicsDevice);
      _uploadDefaultColorPattern(t.positiveX);
      _uploadDefaultColorPattern(t.positiveY);
      _uploadDefaultColorPattern(t.positiveZ);
      _uploadDefaultColorPattern(t.negativeX);
      _uploadDefaultColorPattern(t.negativeY);
      _uploadDefaultColorPattern(t.negativeZ);
      t.generateMipmap();
      _texture = t;
    } else if (type == 'color') {
      _createColorTexture();
    } else {
      throw new FallThroughError();
    }
  }

  void _applyAttributes() {
    _pixelFormat = PixelFormat.parse(format);
    _dataType = DataType.parse(dataType);
    _createTexture();
    _loadTexture();
  }

  void attributeChanged(String name, String oldValue, String newValue) {
    super.attributeChanged(name, oldValue, newValue);
    if (name == 'src' && (oldValue != newValue)) {
      _loadTexture();
    }
  }

  Future _loadCubeTexture(Texture2D texture2D, String faceSrc,
                          String faceColor) {
    if (faceSrc != '') {
      return texture2D.uploadFromURL(faceSrc);
    } else {
      // Parse color.
      Uint8List colorBuffer = new Uint8List(4);
      _parseColorIntoColorBuffer(color, colorBuffer);
      // Upload a 1x1 pixel texture.
      texture2D.uploadPixelArray(1, 1, colorBuffer);
    }
    return new Future.value(texture2D);
  }

  void _loadTexture() {
    if (_texture == null) {
      return;
    }
    print('Loading $type texture $id');
    if (_texture is Texture2D) {
      var t2d = _texture as Texture2D;
      if (src == '') {
        return;
      }
      t2d.uploadFromURL(src.toString()).then((t) {
        t.generateMipmap();
      });
    } else if (_texture is TextureCube) {
      var tCube = _texture as TextureCube;
      List l = [];
      l.add(_loadCubeTexture(tCube.positiveX, srcCubePositiveX,
                             colorCubePositiveX));
      l.add(_loadCubeTexture(tCube.positiveY, srcCubePositiveY,
                             colorCubePositiveY));
      l.add(_loadCubeTexture(tCube.positiveZ, srcCubePositiveZ,
                             colorCubePositiveY));
      l.add(_loadCubeTexture(tCube.negativeX, srcCubeNegativeX,
                             colorCubeNegativeX));
      l.add(_loadCubeTexture(tCube.negativeY, srcCubeNegativeY,
                             colorCubeNegativeY));
      l.add(_loadCubeTexture(tCube.negativeZ, srcCubeNegativeZ,
                             colorCubeNegativeZ));
      Future.wait(l).then((_) {
        print('Generating cube mipmap.');
        tCube.generateMipmap();
      });
    } else {
      throw new FallThroughError();
    }
  }

  render() {
    super.render();
  }

  void _update() {
  }
}
