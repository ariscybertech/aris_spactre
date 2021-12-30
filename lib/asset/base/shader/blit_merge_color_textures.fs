precision mediump float;

varying vec2 samplePoint;
uniform sampler2D sourceR;
uniform sampler2D sourceG;
uniform sampler2D sourceB;
uniform sampler2D sourceA;

void main() {
  float r = texture2D(sourceR, samplePoint).r;
  float g = texture2D(sourceG, samplePoint).g;
  float b = texture2D(sourceB, samplePoint).b;
  float a = texture2D(sourceA, samplePoint).a;
  gl_FragColor = vec4(r, g, b, a);
}
