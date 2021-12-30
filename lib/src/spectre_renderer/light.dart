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

class Light {
  /// Name of light. Used to prefix shader uniform variable names.
  final String lightName;

  /// Is the light active?
  bool active = true;

  MaterialConstant ambient;
  MaterialConstant diffuse;
  MaterialConstant specular;

  MaterialConstant position;
  MaterialConstant direction;

  MaterialConstant spotCutoffAngle;

  Light(this.lightName) {
    ambient = new MaterialConstant('${lightName}Ambient', 'vec4');
    diffuse = new MaterialConstant('${lightName}Diffuse', 'vec4');
    specular = new MaterialConstant('${lightName}Specular', 'vec4');

    position = new MaterialConstant('${lightName}Position', 'vec4');
    direction = new MaterialConstant('${lightName}Direction', 'vec4');

    spotCutoffAngle =
        new MaterialConstant('${lightName}SpotCutoffAngle', 'float');

    // fill in defaults.
  }

  factory Light.directional(String lightName, Vector4 direction) {
    Light l = new Light(lightName);
    l.direction.update(direction.storage);
    return l;
  }

  factory Light.Point(String lightName, Vector4 position) {

  }

  factory Light.Spot(String lightName, Vector4 position, Vector4 direction,
                     double spotCutoffAngle) {
    Light l = new Light(lightName);
    l.direction.update(direction.storage);
    l.position.update(position.storage);
    l.spotCutoffAngle._value[0] = spotCutoffAngle;
    return l;
  }
}

class LightMap {
  final Map<String, Light> lights = new Map<String, Light>();
}
