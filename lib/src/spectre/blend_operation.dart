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

class BlendOperation extends Enum {
  /// The result is the destination added to the source.
  ///
  ///     Result = (Source Color * Source Blend) +
  ///              (Destination Color * Destination Blend)
  static const int Add = WebGL.FUNC_ADD;
  /// The result is the source subtracted from the destination.
  ///
  ///     Result = (Destination Color * Destination Blend) -
  ///              (Source Color * Source Blend)
  static const int ReverseSubtract = WebGL.FUNC_REVERSE_SUBTRACT;
  /// The result is the destination subtracted from the source.
  ///
  ///     Result = (Source Color * Source Blend) -
  ///              (Destination Color * Destination Blend)
  static const int Subtract = WebGL.FUNC_SUBTRACT;

  static const int Default = Add;

  static Map<String, int> _values = {
    'BlendOperation.Add' : Add,
    'BlendOperation.ReverseSubtract' : ReverseSubtract,
    'BlendOperation.Subtract' : Subtract
  };

  /// Convert a [String] to a [BlendOperation].
  static int parse(String name, [int dflt = Default]) =>
      Enum._parse(_values, name, dflt);
  /// Convert a [BlendOperation] to a [String].
  static String stringify(int value) => Enum._stringify(_values, value);
  /// Checks whether the value is a valid enumeration.
  static bool isValid(int value) => Enum._isValid(_values, value);
}
