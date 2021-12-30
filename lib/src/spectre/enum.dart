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

class Enum {
  /// Convert from a [String] name to the corresponding enumeration value.
  static int _parse(Map<String, int> values, String name, int dflt) {
    int r = values[name];
    if (r == null) {
      return dflt;
    }
    return r;
  }

  /// Converts the enumeration value to a [String].
  static String _stringify(Map<String, int> values, int value) {
    String r = null;
    values.forEach((k, v) {
      if (v == value) {
        r = k;
      }
    });
    if (r == null) {
      throw new ArgumentError();
    }
    return r;
  }

  /// Checks whether the value is a valid enumeration.
  static bool _isValid(Map<String, int> values, int value) {
    bool valid = false;
    values.forEach((k, v) {
      if (v == value) {
        valid = true;
      }
    });
    return valid;
  }
}