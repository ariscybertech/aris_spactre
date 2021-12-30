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

/// Data Type.
class DataType extends Enum {
  static const int Int8 = WebGL.BYTE;
  static const int Uint8 = WebGL.UNSIGNED_BYTE;
  static const int Int16 = WebGL.SHORT;
  static const int Uint16 = WebGL.UNSIGNED_SHORT;
  static const int Int32 = WebGL.INT;
  static const int Uint32 = WebGL.UNSIGNED_INT;
  static const int Float32 = WebGL.FLOAT;

  static const int Default = Uint8;

  static Map<String, int> _values = {
    'DataType.Int8' : Int8,
    'DataType.Uint8' : Uint8,
    'DataType.Int16' : Int16,
    'DataType.Uint16' : Uint16,
    'DataType.Int32' : Int32,
    'DataType.Uint32' : Uint32,
    'DataType.Float32' : Float32
  };

  /// Convert a [String] to a [DataType].
  static int parse(String name, [int dflt = Default]) =>
      Enum._parse(_values, name, dflt);
  /// Convert a [DataType] to a [String].
  static String stringify(int value) => Enum._stringify(_values, value);
  /// Checks whether the value is a valid enumeration.
  static bool isValid(int value) => Enum._isValid(_values, value);
}