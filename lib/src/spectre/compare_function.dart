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

/// Defines comparison functions that can be chosen for stencil,
/// or depth-buffer tests.
class CompareFunction extends Enum {
  /// Always pass the test.
  static const int Always = WebGL.ALWAYS;
  /// Accept the new pixel if its value is equal to the value of the current
  /// pixel.
  static const int Equal = WebGL.EQUAL;
  /// Accept the new pixel if its value is greater than the value of the
  /// current pixel.
  static const int Greater = WebGL.GREATER;
  /// Accept the new pixel if its value is greater than or equal to the value
  /// of the current pixel.
  static const int GreaterEqual = WebGL.GEQUAL;
  /// Accept the new pixel if its value is less than the value of the current
  /// pixel.
  static const int Less = WebGL.LESS;
  /// Accept the new pixel if its value is less than or equal to the value of
  /// the current pixel.
  static const int LessEqual = WebGL.LEQUAL;
  /// Always fail the test.
  static const int Fail = WebGL.NEVER;
  ///  Accept the new pixel if its value does not equal the value of the
  /// current pixel.
  static const int NotEqual = WebGL.NOTEQUAL;

  static const int Default = LessEqual;

  static Map<String, int> _values = {
    'CompareFunction.Always' : Always,
    'CompareFunction.Equal' : Equal,
    'CompareFunction.Greater' : Greater,
    'CompareFunction.GreaterEqual' : GreaterEqual,
    'CompareFunction.Less' : Less,
    'CompareFunction.LessEqual' : LessEqual,
    'CompareFunction.Fail' : Fail,
    'CompareFunction.NotEqual' : NotEqual
  };

  /// Convert a [String] to a [CompareFunction].
  static int parse(String name, [int dflt = Default]) =>
      Enum._parse(_values, name, dflt);
  /// Convert a [CompareFunction] to a [String].
  static String stringify(int value) => Enum._stringify(_values, value);
  /// Checks whether the value is a valid enumeration.
  static bool isValid(int value) => Enum._isValid(_values, value);
}
