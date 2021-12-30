precision mediump float;

varying vec2 samplePoint;
uniform sampler2D source;

void main() {
  gl_FragColor = texture2D(source, samplePoint);
}
