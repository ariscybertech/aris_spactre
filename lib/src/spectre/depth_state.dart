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

/// Contains depth state for the device.
/// Set using [GraphicsContext.setDepthState]
class DepthState {
  static const String _depthBufferEnabledName = 'depthBufferEnabled';
  static const String _depthBufferWriteEnabledName = 'depthBufferWriteEnabled';
  static const String _depthBufferFunctionName = 'depthBufferFunction';

  /// Whether depth buffering is enabled or disabled.
  /// The default is true.
  bool _depthBufferEnabled = true;
  /// Whether writing to the depth buffer is enabled or disabled.
  /// The default is true.
  bool _depthBufferWriteEnabled = true;
  /// The comparison function for the depth-buffer test.
  /// The default is CompareFunction.LessEqual
  int _depthBufferFunction = CompareFunction.LessEqual;

  /// Creates an instance of [DepthState] with default values.
  DepthState();

  /// Creates an instance of [DepthState] that writes to the depth buffer.
  DepthState.depthWrite()
    : _depthBufferEnabled = true,
      _depthBufferWriteEnabled = true;

  /// Creates an instance of [DepthState] that does depth checks.
  DepthState.depthRead()
      : _depthBufferEnabled = true,
        _depthBufferWriteEnabled = false;

  /// Creates an instance of [DepthState] which doesn't use a depth buffer.
  DepthState.none()
      : _depthBufferEnabled = false,
        _depthBufferWriteEnabled = false;

  /// Whether depth buffering is enabled or disabled.
  /// The default is true.
  bool get depthBufferEnabled => _depthBufferEnabled;
  set depthBufferEnabled(bool value) { _depthBufferEnabled = value; }

  /// Whether writing to the depth buffer is enabled or disabled.
  /// The default is true.
  bool get depthBufferWriteEnabled => _depthBufferWriteEnabled;
  set depthBufferWriteEnabled(bool value) { _depthBufferWriteEnabled = value; }

  /// The comparison function for the depth-buffer test.
  /// The default is CompareFunction.LessEqual
  int get depthBufferFunction => _depthBufferFunction;
  set depthBufferFunction(int value) {
    if (!CompareFunction.isValid(value)) {
      throw new ArgumentError('depthBufferFunction must be an enumeration within CompareFunction.');
    }

    _depthBufferFunction = value;
  }

  /// Serializes the [DepthState] to a JSON.
  dynamic toJson() {
    Map json = new Map();

    json[_depthBufferEnabledName]      = _depthBufferEnabled;
    json[_depthBufferWriteEnabledName] = _depthBufferWriteEnabled;
    json[_depthBufferFunctionName]     =
        CompareFunction.stringify(_depthBufferFunction);

    return json;
  }

  /// Deserializes the [DepthState] from a JSON.
  void fromJson(Map values) {
    assert(values != null);

    dynamic value;

    value = values[_depthBufferEnabledName];
    _depthBufferEnabled = (value != null) ? value : _depthBufferEnabled;

    value = values[_depthBufferWriteEnabledName];
    _depthBufferWriteEnabled = (value != null) ?
        value : _depthBufferWriteEnabled;

    value = values[_depthBufferFunctionName];
    _depthBufferFunction = (value != null) ?
        CompareFunction.parse(value) : _depthBufferFunction;
  }
}
