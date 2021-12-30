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

/// Defines the winding used to determine whether a triangle is front or
/// back facing.
class FrontFace extends Enum {
  /// Triangles are considered front-facing if its vertices are clockwise.
  static const int Clockwise = WebGL.CW;
  /// Triangles are considered front-facing if its vertices are
  /// counter-clockwise.
  static const int CounterClockwise = WebGL.CCW;

  static const int Default = CounterClockwise;

  static Map<String, int> _values = {
    'FrontFace.Clockwise' : Clockwise,
    'FrontFace.CounterClockwise' : CounterClockwise
  };

  /// Convert a [String] to a [FrontFace].
  static int parse(String name, [int dflt = Default]) =>
      Enum._parse(_values, name, dflt);
  /// Convert a [FrontFace] to a [String].
  static String stringify(int value) => Enum._stringify(_values, value);
  /// Checks whether the value is a valid enumeration.
  static bool isValid(int value) => Enum._isValid(_values, value);
}
