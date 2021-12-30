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

/// Defines various types of surface formats.
class SurfaceFormat extends Enum {
  /// 32-bit RGBA pixel format with alpha, using 8 bits per channel.
  ///
  /// Underlying format is an unsigned byte.
  static const int Rgba = WebGL.RGBA;
  /// 24-bit RGB pixel format, using 8 bits per channel.
  ///
  /// Underlying format is an unsigned byte.
  static const int Rgb = WebGL.RGB;
  /// DXT1 compression format.
  ///
  /// Only available if the compressed texture s3tc extension is supported.
  /// Assumes the texture has no alpha component. DXT1 can support
  /// alpha but only 1-bit.
  // Value is not in WebGLRenderingContext. Using value from spec.
  static const int Dxt1 = 0x83F0;
  /// DXT3 compression format.
  ///
  /// Only available if the compressed texture s3tc extension is supported.
// Value is not in WebGLRenderingContext. Using value from spec.
  static const int Dxt3 = 0x83F2;
  /// DXT5 compression format.
  ///
  /// Only available if the compressed texture s3tc extension is supported.
  // Value is not in WebGLRenderingContext. Using value from spec.
  static const int Dxt5 = 0x83F3;

  static const int Default = Rgba;

  static Map<String, int> _values = {
    'SurfaceFormat.Rgba' : Rgba,
    'SurfaceFormat.Rgb' : Rgb,
    'SurfaceFormat.Dxt1' : Dxt1,
    'SurfaceFormat.Dxt3' : Dxt3,
    'SurfaceFormat.Dxt5' : Dxt5
  };

  /// Convert a [String] to a [SurfaceFormat].
  static int parse(String name, [int dflt = Default]) =>
      Enum._parse(_values, name, dflt);
  /// Convert a [SurfaceFormat] to a [String].
  static String stringify(int value) => Enum._stringify(_values, value);
  /// Checks whether the value is a valid enumeration.
  static bool isValid(int value) => Enum._isValid(_values, value);

  /// Checks whether the value is a compressed format.
  static bool _isCompressedFormat(int value) {
    return ((value == Dxt1) || (value == Dxt3) || (value == Dxt5));
  }

  /// Retrieves the internal format used by the surface.
  ///
  /// WebGL does not determine the internal format based on the surface type
  /// so this must be queried directly.
  static int _getInternalFormat(int value) {
    // This method will not be called for compressed textures as there's
    // no internal format parameter within compressedTexImage) so just return
    // unsigned byte as the other formats are all unsigned byte
    return WebGL.UNSIGNED_BYTE;
  }
}
