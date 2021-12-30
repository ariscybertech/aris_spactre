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

part of spectre;

class SpectreTexture extends DeviceChild {
  final int _bindTarget;
  final int _bindingParam;
  final int _textureTarget;

  // Cached sampler state.
  int _textureWrapS;
  int _textureWrapT;
  int _textureMinFilter;
  int _textureMagFilter;

  int pixelFormat = PixelFormat.Rgba;
  int pixelDataType = DataType.Uint8;

  int _width = 0;
  int _height = 0;

  WebGL.Texture _deviceTexture;

  /// Width of texture.
  int get width => _width;
  /// Height of texture.
  int get height => _height;

  SpectreTexture(String name, GraphicsDevice device, this._bindTarget,
                 this._bindingParam, this._textureTarget)
      : super._internal(name, device) {
    _deviceTexture = device.gl.createTexture();
  }

  void finalize() {
    device.gl.deleteTexture(_deviceTexture);
    _deviceTexture = null;
    super.finalize();
  }

  bool canGenerateMipmap() {
    return _isPowerOfTwo(_width) && _isPowerOfTwo(_height);
  }

  /// Determines whether a [value] is a power of two.
  ///
  /// Assumes that the given value will always be positive.
  static bool _isPowerOfTwo(int value) {
    return (value & (value - 1)) == 0;
  }
}
