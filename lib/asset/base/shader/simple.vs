/// The vertex position.
attribute vec3 POSITION;
/// The texture coordinate.
attribute vec2 TEXCOORD0;

uniform mat4 cameraProjectionView;
uniform mat4 objectTransform;

/// The texture coordinate of the vertex.
varying vec2 texCoord;

void main() {
  texCoord = TEXCOORD0; 
  gl_Position = cameraProjectionView * objectTransform * vec4(POSITION, 1.0);
}
