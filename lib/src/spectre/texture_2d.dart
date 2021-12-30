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

/// Texture2D defines the storage for a 2D texture including Mipmaps
/// Set using [GraphicsContext.setTextures]
/// NOTE: Unlike OpenGL, Spectre textures do not describe how they are sampled
class Texture2D extends SpectreTexture {
  bool _loadError = false;

  /** Did an error occur when loading from a URL? */
  bool get loadError => _loadError;

  String toString() {
    return 'Texture2D name=$name width=$_width height=$_height '
           'pixelFormat=${PixelFormat.stringify(pixelFormat)} '
           'pixelDataType=${DataType.stringify(pixelDataType)}';
  }

  Texture2D(String name, GraphicsDevice device) :
      super(name, device, WebGL.TEXTURE_2D, WebGL.TEXTURE_BINDING_2D,
            WebGL.TEXTURE_2D);

  Texture2D._cube(String name, GraphicsDevice device, int bindTarget,
                  int bindParam, int textureTarget) :
      super(name, device, bindTarget, bindParam, textureTarget);

  void _uploadPixelArray(int width, int height, TypedData array) {
    device.gl.texImage2DTyped(_textureTarget, 0, pixelFormat, width, height,
                              0, pixelFormat, pixelDataType, array);
  }

  /** Replace texture contents with data stored in [array].
   * If [array] is null, space will be allocated on the GPU
   */
  void uploadPixelArray(int width, int height, TypedData array) {
    var old = device.context.setTexture(device.context._tempTextureUnit, this);
    _width = width;
    _height = height;
    _uploadPixelArray(width, height, array);
    device.context.setTexture(device.context._tempTextureUnit, old);
  }

  /** Replace texture contents with image data from [element].
   * Supported for [ImageElement], [VideoElement], and [CanvasElement].
   *
   * The image data will be converted to [pixelFormat] and [pixelType] before
   * being uploaded to the GPU.
   */
  void uploadElement(dynamic element) {
    if ((element is! ImageElement) &&
        (element is! CanvasElement) &&
        (element is! VideoElement)) {
      throw new ArgumentError('Element type is not supported.');
    }

    var old = device.context.setTexture(device.context._tempTextureUnit, this);
    if (element is ImageElement) {
      _width = element.naturalWidth;
      _height = element.naturalHeight;
      device.gl.texImage2DImage(_textureTarget, 0, pixelFormat, pixelFormat,
                                pixelDataType, element);
    } else if (element is CanvasElement) {
      _width = element.width;
      _height = element.height;
      device.gl.texImage2DCanvas(_textureTarget, 0, pixelFormat, pixelFormat,
                                 pixelDataType, element);
    } else if (element is VideoElement) {
      _width = element.width;
      _height = element.height;
      device.gl.texImage2DVideo(_textureTarget, 0, pixelFormat, pixelFormat,
                                pixelDataType, element);
    }
    device.context.setTexture(device.context._tempTextureUnit, old);
  }

  /** Replace texture contents with data fetched from [url].
   * If an error occurs while fetching the image, loadError will be true.
   */
  Future<Texture2D> uploadFromURL(String url) {
    ImageElement element = new ImageElement();
    Completer<Texture2D> completer = new Completer<Texture2D>();
    element.onError.listen((event) {
      _loadError = true;
      completer.complete(this);
    });
    element.onLoad.listen((event) {
      uploadElement(element);
      completer.complete(this);
    });
    // Initiate load.
    _loadError = false;
    element.src = url;
    return completer.future;
  }

  void _generateMipmap() {
    if (canGenerateMipmap()) {
      device.gl.generateMipmap(_textureTarget);
    }
  }


  /// Generate mipmaps for the [Texture2D].
  ///
  /// This must be done before the texture is used for rendering.
  ///
  /// A call to this method will only generate mipmap data if the
  /// texture is a power of two. If not then this call is ignored.
  void generateMipmap() {
    if (SpectreTexture._isPowerOfTwo(_width) &&
        SpectreTexture._isPowerOfTwo(_height)) {
      var old = device.context.setTexture(device.context._tempTextureUnit,
                                          this);
      _generateMipmap();
      device.context.setTexture(device.context._tempTextureUnit, old);
    }
  }
}
