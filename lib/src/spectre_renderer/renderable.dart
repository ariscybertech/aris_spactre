/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

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

part of spectre_renderer;

abstract class Renderable {
  final Renderer renderer;
  String name;
  Matrix4 transform = new Matrix4.identity();

  Renderable(this.name, this.renderer);

  Renderable.json(Map json, this.renderer) {
    fromJson(json);
  }

  void render(Layer layer, Camera camera);

  void fromJson(Map json) {
    name = json['name'];
    transform.copyFromArray(json['transform']);
  }

  dynamic toJson() {
    Map map = new Map();
    map['name'] = name;
    map['transform'] = new List<num>();
    transform.copyIntoArray(map['T']);
    return map;
  }
}
