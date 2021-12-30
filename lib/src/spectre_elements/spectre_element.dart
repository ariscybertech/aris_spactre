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

library spectre_element;

import 'dart:convert';
import 'dart:html';
import 'dart:mirrors';

import 'package:logging/logging.dart';

import 'package:polymer/polymer.dart';
import 'package:polymer_expressions/polymer_expressions.dart';
import 'package:vector_math/vector_math.dart';

@CustomTag('s-element')
class SpectreElement extends PolymerElement {
  SpectreElement.created() : super.created() {
  }

  static final Logger log = new Logger('Spectre.Element');

  static PolymerExpressions _spectreSyntax = new PolymerExpressions(globals: {
    'Vector2': (x, y) {
      return new Vector2(x, y);
    },
    'Vector3': (x, y, z) {
      print('Evaluating Vector3($x, $y, $z)');
      return new Vector3(x, y, z);
    },
    'Vector4': (x, y, z, w) {
      return new Vector4(x, y, z, w);
    },
    'ensureDouble': (x) {
      return x.toDouble();
    },
    'ensureInt': (x) {
      return x.toInt();
    }
  });

  static Vector4 _vector4Handler(String value, Object defaultValue) {
    try {
      List l = JSON.decode(value);
      assert(l.length == 4);
      return new Vector4(l[0], l[1], l[2], l[3]);
    } catch (_) {
      return defaultValue;
    }
  }

  static Vector3 _vector3Handler(String value, Object defaultValue) {
    try {
      List l = JSON.decode(value);
      assert(l.length == 3);
      return new Vector3(l[0], l[1], l[2]);
    } catch (_) {
      return defaultValue;
    }
  }

  static Vector2 _vector2Handler(String value, Object defaultValue) {
    try {
      List l = JSON.decode(value);
      assert(l.length == 2);
      return new Vector2(l[0], l[1]);
    } catch (_) {
      return defaultValue;
    }
  }

  static final _typeHandlers = () {
    var m = new Map();
    m[const Symbol('vector_math.Vector4')] = _vector4Handler;
    m[const Symbol('vector_math.Vector3')] = _vector3Handler;
    m[const Symbol('vector_math.Vector2')] = _vector2Handler;
    return m;
  }();

  Object deserializeValue(String value, Object defaultValue, TypeMirror type) {
    var handler = _typeHandlers[type.qualifiedName];
    if (handler != null) {
      return handler(value, defaultValue);
    }
    return super.deserializeValue(value, defaultValue, type);
  }

  bool get applyAuthorStyles => true;

  void enteredView() {
    super.enteredView();
  }

  void leftView() {
    super.leftView();
  }

  void attributeChanged(String name, String oldValue, String newValue) {
    super.attributeChanged(name, oldValue, newValue);
  }

  List findAllTagChildren(String tag) {
    List l = new List();
    children.forEach((e) {
      if (e.tagName == tag) {
        l.add(e);
      }
    });
    return l;
  }

  void renderChildren() {
    children.forEach((e) {
      e.render();
    });
  }

  void updateChildren() {
    children.forEach((e) {
      e.update();
    });
  }

  bool _inited = false;
  bool get inited => _inited;

  /// All elements *must* override the following methods:
  ///
  /// * [init]
  /// * [apply]
  /// * [render]
  ///

  /// If element is initialized, do nothing.
  /// If DeclarativeState.inited is false, do nothing.
  /// Initialize element.
  void init() {
    _inited = true;
  }

  void update() {
    assert(_inited);
  }

  void render() {
    assert(_inited);
  }
}
