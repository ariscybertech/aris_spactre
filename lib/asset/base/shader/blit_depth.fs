precision mediump float;

varying vec2 samplePoint;
uniform sampler2D source;

void main() {
  float r = texture2D(source, samplePoint).r;
  gl_FragColor = vec4(r, r, r, 1.0);
}
