precision highp float;
attribute vec2 vPosition;
attribute vec2 vTexCoord;
varying vec2 samplePoint;

void main() {
  vec4 vPosition4 = vec4(vPosition.x, vPosition.y, 1.0, 1.0);
  gl_Position = vPosition4;
  samplePoint = vTexCoord;
}
